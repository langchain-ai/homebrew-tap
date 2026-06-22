#!/usr/bin/env python3
"""Regenerate Formula/deepagents-code.rb from prebuilt PyPI wheels.

The formula installs deepagents-code and its whole dependency tree from prebuilt
wheels (no source compilation). This script re-pins every wheel (URL + sha256)
for a given release by cross-resolving the dependency tree per platform with
`uv pip compile`, then rendering the formula deterministically.

Requires: `uv` on PATH, and Python >= 3.11 (for tomllib). Run it through uv so a
matching interpreter is always available, both locally and in CI:

    uv run --no-project --python 3.13 scripts/regen_deepagents_code.py
    uv run --no-project --python 3.13 scripts/regen_deepagents_code.py --version 0.1.21
    uv run --no-project --python 3.13 scripts/regen_deepagents_code.py --check

Why wheels (not the Language::Python::Virtualenv source build): Homebrew's
std_pip_args forces `--no-binary=:all:`, and this tree's native deps either
build very slowly or fail outright (e.g. jsonschema-rs -> aws-lc-sys needs -O0
while Homebrew superenv forces -O3). See the wheel-based recipe for details.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
import tomllib
import urllib.request
from pathlib import Path

# --- Configuration (edit here if packaging a different/updated app) ----------

PACKAGE = "deepagents-code"
FORMULA_CLASS = "DeepagentsCode"
PYTHON_VERSION = "3.13"  # Homebrew python@ formula and uv resolution target
BINS = ["dcode", "deepagents-code"]  # console scripts to symlink into bin
# Build backends needed to build any sdist-only dep (e.g. forbiddenfruit) fully
# offline. setuptools already appears in the tree; wheel does not, so pin it in.
EXTRA_REQUIREMENTS = ["wheel"]

# Supported platforms: label -> uv --python-platform target triple.
# macOS is arm64-only because cryptography publishes no x86_64 macOS wheel; the
# rendered formula enforces this with `depends_on arch: :arm64` under on_macos.
PLATFORMS = {
    "macos_arm": "aarch64-apple-darwin",
    "linux_arm": "aarch64-unknown-linux-gnu",
    "linux_intel": "x86_64-unknown-linux-gnu",
}
# Which label maps to which on_os/on_arch block in the formula.
MACOS_LABELS = {"arm": "macos_arm"}
LINUX_LABELS = {"arm": "linux_arm", "intel": "linux_intel"}

DESC = "Terminal coding agent (dcode) for Deep Agents"
HOMEPAGE = "https://github.com/langchain-ai/deepagents"
LICENSE = "MIT"

# Leading comment emitted at the top of the formula: known limitations of this
# packaging approach. Kept here so `regen` reproduces it on every version bump.
LIMITATIONS_NOTE = [
    "# WORK IN PROGRESS - known limitations of this packaging approach:",
    "#",
    "# 1. Provider extras and the in-app `/install`, `/update`, and auto-update",
    "#    commands do NOT work under Homebrew. They operate by re-running",
    "#    `uv tool install` to mutate a uv-managed environment; a Homebrew keg is",
    "#    immutable, so dcode's detect_install_method() returns \"brew\" and",
    "#    refuses. Only the providers baked into this formula are usable (the base",
    "#    set: OpenAI, Anthropic, Gemini). Users who need other providers must use",
    "#    the upstream installer: `uv tool install 'deepagents-code[<extra>]'`. To",
    "#    ship a different baked-in set, regenerate with the desired extras.",
    "#",
    "# 2. macOS is arm64-only: cryptography (a transitive dependency) ships no",
    "#    x86_64 macOS wheel for this version, so Intel macOS would need a source",
    "#    build. Linux x86_64/arm64 and macOS arm64 are covered.",
    "#",
    "# 3. Prebuilt wheels bypass Homebrew's source-build (--no-binary) policy, so",
    "#    this is NOT acceptable into homebrew-core - it is valid only in this",
    "#    personal tap. It relies on `preserve_rpath` so Homebrew does not rewrite",
    "#    the wheels' .so dylib IDs (which overflow the Mach-O header).",
    "#",
    "# 4. Maintenance: every transitive wheel is pinned by URL + sha256 at one",
    "#    resolved version. Version bumps must be regenerated with",
    "#    scripts/regen_deepagents_code.py (transitive deps re-resolve each time).",
    "#",
    "# 5. No bottle yet: each install runs the offline uv step (~12s). Routing a",
    "#    bump through a PR builds/pulls bottles via tests.yml + publish.yml.",
]

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_OUTPUT = REPO_ROOT / "Formula" / "deepagents-code.rb"

VERSION_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._!+-]*$")
IND = "  "


# --- Helpers -----------------------------------------------------------------

def die(msg: str) -> "None":
    sys.stderr.write(f"error: {msg}\n")
    raise SystemExit(1)


def latest_version(package: str) -> str:
    url = f"https://pypi.org/pypi/{package}/json"
    req = urllib.request.Request(url, headers={"User-Agent": "regen-deepagents-code"})
    with urllib.request.urlopen(req, timeout=30) as resp:  # noqa: S310 (https only)
        return json.load(resp)["info"]["version"]


def run_compile(reqfile: Path, triple: str, outfile: Path) -> None:
    outfile.parent.mkdir(parents=True, exist_ok=True)
    # No --only-binary=:all: on purpose: a few pure-Python deps are sdist-only
    # (e.g. forbiddenfruit) and that flag would make resolution fail. We still
    # prefer wheels and select them below.
    cmd = [
        "uv", "pip", "compile", str(reqfile),
        "--python-platform", triple,
        "--python-version", PYTHON_VERSION,
        "--format", "pylock.toml",
        "-o", str(outfile),
        "--quiet",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        die(f"`uv pip compile` failed for {triple}:\n{proc.stderr.strip()}")


def wheel_score(filename: str) -> tuple[int, int]:
    """Rank wheels so we pick what pip/uv would install: prefer an exact cp313
    wheel, then the highest cpXX-abi3 (stable ABI), then py3-none."""
    parts = filename[:-4].split("-")  # strip .whl
    pytag, abitag = parts[-3], parts[-2]
    cp = lambda t: int(t[2:]) if t.startswith("cp") and t[2:].isdigit() else 0
    if abitag == f"cp{PYTHON_VERSION.replace('.', '')}":
        return (3, int(PYTHON_VERSION.split(".")[1]))
    if abitag == "abi3":
        return (2, cp(pytag))
    if abitag == "none":
        return (1, 0)
    return (2, cp(pytag))


def pick_wheel(pkg: dict) -> dict | None:
    wheels = pkg.get("wheels") or []
    if not wheels:
        return None
    return max(wheels, key=lambda w: wheel_score(w["url"].rsplit("/", 1)[-1]))


def load_pylock(path: Path) -> dict[str, dict]:
    data = tomllib.loads(path.read_text())
    return {p["name"]: p for p in data["packages"]}


# --- Resolution + classification --------------------------------------------

class Resolution:
    def __init__(self) -> None:
        self.main: tuple[str, str] | None = None       # (url, sha) universal wheel
        self.shared: dict[str, tuple[str, str]] = {}   # name -> (url, sha)
        self.sdist: dict[str, tuple[str, str]] = {}    # name -> (url, sha)
        self.native: dict[str, dict[str, tuple[str, str]]] = {
            label: {} for label in PLATFORMS
        }


def resolve(version: str, tmp: Path) -> Resolution:
    reqfile = tmp / "requirements.in"
    reqfile.write_text("\n".join([f"{PACKAGE}=={version}", *EXTRA_REQUIREMENTS]) + "\n")

    locks: dict[str, dict[str, dict]] = {}
    for label, triple in PLATFORMS.items():
        out = tmp / label / "pylock.toml"
        run_compile(reqfile, triple, out)
        locks[label] = load_pylock(out)

    names: set[str] = set()
    for pkgs in locks.values():
        names |= set(pkgs)

    res = Resolution()
    for name in sorted(names):
        per: dict[str, tuple[str, str, str]] = {}  # label -> (url, sha, filename)
        wheelless: list[str] = []
        for label, pkgs in locks.items():
            pkg = pkgs.get(name)
            if pkg is None:
                continue
            w = pick_wheel(pkg)
            if w is None:
                wheelless.append(label)
            else:
                fn = w["url"].rsplit("/", 1)[-1]
                per[label] = (w["url"], w["hashes"]["sha256"], fn)

        if not per:
            # No wheel on any platform -> build from sdist everywhere.
            pkg = next(locks[l][name] for l in PLATFORMS if name in locks[l])
            sd = pkg.get("sdist")
            if not sd:
                die(f"{name} has neither wheels nor an sdist; cannot package it")
            res.sdist[name] = (sd["url"], sd["hashes"]["sha256"])
            continue

        if wheelless:
            die(
                f"{name} has wheels on {sorted(per)} but not on {sorted(wheelless)}. "
                "A supported platform would have to build it from source. Either drop "
                "that platform or pin a version with full wheel coverage."
            )

        filenames = {v[2] for v in per.values()}
        universal = len(filenames) == 1 and all(
            v[2].endswith("-none-any.whl") for v in per.values()
        )
        first = next(iter(per.values()))

        if name == PACKAGE:
            if not universal:
                die(f"{PACKAGE} main wheel is not universal (py3-none-any); "
                    "the formula template assumes a single cross-platform main wheel")
            res.main = (first[0], first[1])
        elif universal:
            res.shared[name] = (first[0], first[1])
        else:
            for label in PLATFORMS:
                if label in per:
                    res.native[label][name] = (per[label][0], per[label][1])

    if res.main is None:
        die(f"{PACKAGE} was not found in the resolved dependency set")
    # Parity check: every native package must exist on every supported platform.
    all_native = set().union(*(set(res.native[l]) for l in PLATFORMS))
    for label in PLATFORMS:
        missing = all_native - set(res.native[label])
        if missing:
            die(f"native packages missing on {label}: {sorted(missing)}")
    return res


# --- Rendering ---------------------------------------------------------------

def res_block(name: str, url: str, sha: str, indent: int) -> str:
    p = IND * indent
    return (f'{p}resource "{name}" do\n'
            f'{p}{IND}url "{url}"\n'
            f'{p}{IND}sha256 "{sha}"\n'
            f'{p}end')


def native_block(res: Resolution, label: str, indent: int) -> str:
    out = []
    for name in sorted(res.native[label]):
        url, sha = res.native[label][name]
        out.append(res_block(name, url, sha, indent))
        out.append("")
    return "\n".join(out).rstrip("\n")


def render(version: str, res: Resolution) -> str:
    main_url, main_sha = res.main
    L: list[str] = []
    a = L.append
    for line in LIMITATIONS_NOTE:
        a(line)
    a("")
    a(f"class {FORMULA_CLASS} < Formula")
    a("  include Language::Python::Virtualenv")
    a("")
    a(f'  desc "{DESC}"')
    a(f'  homepage "{HOMEPAGE}"')
    a(f'  url "{main_url}", using: :nounzip')
    a(f'  sha256 "{main_sha}"')
    a(f'  license "{LICENSE}"')
    a("")
    a("  # Installs from prebuilt PyPI wheels via uv - no source compilation.")
    a('  depends_on "uv" => :build')
    a('  depends_on "libyaml"')
    a(f'  depends_on "python@{PYTHON_VERSION}"')
    a("")
    a("  # Native (compiled) wheels - one per OS/CPU architecture.")
    a("  on_macos do")
    a("    # macOS is arm64-only: cryptography (a transitive dependency) publishes no")
    a("    # x86_64 macOS wheel, so x86_64 macOS would have to build it from source.")
    a("    depends_on arch: :arm64")
    a("")
    a("    on_arm do")
    a(native_block(res, MACOS_LABELS["arm"], 3))
    a("    end")
    a("  end")
    a("")
    a("  on_linux do")
    a("    on_arm do")
    a(native_block(res, LINUX_LABELS["arm"], 3))
    a("    end")
    a("")
    a("    on_intel do")
    a(native_block(res, LINUX_LABELS["intel"], 3))
    a("    end")
    a("  end")
    a("")
    a("  # Prebuilt wheels ship extension modules (.so) and bundled dylibs with @rpath")
    a("  # install names and no header padding. Keep those IDs as-is so Homebrew does")
    a("  # not try to rewrite them to absolute keg paths that overflow the Mach-O header.")
    a("  preserve_rpath")
    a("")
    a("  # Pure-Python (py3-none-any) wheels - identical across all platforms.")
    for name in sorted(res.shared):
        url, sha = res.shared[name]
        a(res_block(name, url, sha, 1))
        a("")
    if res.sdist:
        a("  # No wheel on PyPI; the pure-Python sdist is built offline at install time")
        a("  # (the bundled setuptools/wheel build backend make this work without network).")
        for name in sorted(res.sdist):
            url, sha = res.sdist[name]
            a(res_block(name, url, sha, 1))
            a("")
    a("  def install")
    a("    # Create the virtualenv via the mixin (its Cellar->opt symlink-hardening lets")
    a(f"    # the venv survive python@{PYTHON_VERSION} patch upgrades), then install prebuilt")
    a("    # wheels with uv - fully offline, no network, no compilation.")
    a(f'    virtualenv_create(libexec, "python{PYTHON_VERSION}")')
    a("")
    a("    # Assemble an offline wheelhouse from the downloaded artifacts. Copy each")
    a("    # cached download under its real filename (wheels stay wheels, sdists stay")
    a("    # tarballs) so uv can resolve everything locally with no network.")
    a('    wheelhouse = buildpath/"wheelhouse"')
    a("    wheelhouse.mkpath")
    a('    cp Dir[buildpath/"*.whl"], wheelhouse # main package wheel (downloaded :nounzip)')
    a('    resources.each { |r| cp r.cached_download, wheelhouse/File.basename(r.url) }')
    a("")
    a('    system "uv", "pip", "install", "--python", libexec/"bin/python",')
    a('           "--offline", "--no-index", "--find-links=#{wheelhouse}",')
    a(f'           "{PACKAGE}==#{{version}}"')
    a("")
    bins = ", ".join(f'libexec/"bin/{b}"' for b in BINS)
    a(f"    bin.install_symlink {bins}")
    a("  end")
    a("")
    a("  test do")
    for b in BINS:
        a(f'    assert_match version.to_s, shell_output("#{{bin}}/{b} --version")')
    a("  end")
    a("end")
    return "\n".join(L) + "\n"


# --- CLI ---------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description=f"Regenerate the {PACKAGE} Homebrew formula.")
    ap.add_argument("--version", help="release to pin (default: latest on PyPI)")
    ap.add_argument("--output", type=Path, default=DEFAULT_OUTPUT,
                    help=f"formula path (default: {DEFAULT_OUTPUT})")
    ap.add_argument("--check", action="store_true",
                    help="do not write; exit 1 if the on-disk formula is out of date")
    args = ap.parse_args()

    version = args.version or latest_version(PACKAGE)
    if not VERSION_RE.match(version):
        die(f"invalid version string: {version!r}")

    print(f"Resolving {PACKAGE}=={version} for {', '.join(PLATFORMS)} ...", file=sys.stderr)
    with tempfile.TemporaryDirectory(prefix="regen-dcode-") as td:
        res = resolve(version, Path(td))
    formula = render(version, res)

    n_native = len(res.native[next(iter(PLATFORMS))])
    print(f"  main + {len(res.shared)} universal + {n_native}x{len(PLATFORMS)} native "
          f"+ {len(res.sdist)} sdist", file=sys.stderr)

    if args.check:
        current = args.output.read_text() if args.output.exists() else ""
        if current != formula:
            print(f"{args.output} is OUT OF DATE for {PACKAGE}=={version}", file=sys.stderr)
            return 1
        print(f"{args.output} is up to date for {PACKAGE}=={version}", file=sys.stderr)
        return 0

    args.output.write_text(formula)
    print(f"wrote {args.output} ({PACKAGE}=={version})", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
