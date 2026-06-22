# WORK IN PROGRESS - known limitations of this packaging approach:
#
# 1. Provider extras and the in-app `/install`, `/update`, and auto-update
#    commands do NOT work under Homebrew. They operate by re-running
#    `uv tool install` to mutate a uv-managed environment; a Homebrew keg is
#    immutable, so dcode's detect_install_method() returns "brew" and
#    refuses. Only the providers baked into this formula are usable (the base
#    set: OpenAI, Anthropic, Gemini). Users who need other providers must use
#    the upstream installer: `uv tool install 'deepagents-code[<extra>]'`. To
#    ship a different baked-in set, regenerate with the desired extras.
#
# 2. macOS is arm64-only: cryptography (a transitive dependency) ships no
#    x86_64 macOS wheel for this version, so Intel macOS would need a source
#    build. Linux x86_64/arm64 and macOS arm64 are covered.
#
# 3. Prebuilt wheels bypass Homebrew's source-build (--no-binary) policy, so
#    this is NOT acceptable into homebrew-core - it is valid only in this
#    personal tap. It relies on `preserve_rpath` so Homebrew does not rewrite
#    the wheels' .so dylib IDs (which overflow the Mach-O header).
#
# 4. Maintenance: every transitive wheel is pinned by URL + sha256 at one
#    resolved version. Version bumps must be regenerated with
#    scripts/regen_deepagents_code.py (transitive deps re-resolve each time).
#
# 5. No bottle yet: each install runs the offline uv step (~12s). Routing a
#    bump through a PR builds/pulls bottles via tests.yml + publish.yml.

class DeepagentsCode < Formula
  include Language::Python::Virtualenv

  desc "Terminal coding agent (dcode) for Deep Agents"
  homepage "https://github.com/langchain-ai/deepagents"
  url "https://files.pythonhosted.org/packages/68/f1/e1d427ed9486a5e99a092a21f9d69821828ba4727bb8a6f1b6bc826216f0/deepagents_code-0.1.20-py3-none-any.whl", using: :nounzip
  sha256 "96474c3c90ef29ff73b990bdb6f8878f9a0a8381ca3fae7df096296ec78f9766"
  license "MIT"

  # Installs from prebuilt PyPI wheels via uv - no source compilation.
  depends_on "uv" => :build
  depends_on "libyaml"
  depends_on "python@3.13"

  # Native (compiled) wheels - one per OS/CPU architecture.
  on_macos do
    # macOS is arm64-only: cryptography (a transitive dependency) publishes no
    # x86_64 macOS wheel, so x86_64 macOS would have to build it from source.
    depends_on arch: :arm64

    on_arm do
      resource "cffi" do
        url "https://files.pythonhosted.org/packages/4a/d2/a6c0296814556c68ee32009d9c2ad4f85f2707cdecfd7727951ec228005d/cffi-2.0.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "45d5e886156860dc35862657e1494b9bae8dfa63bf56796f2fb56e1679fc0bca"
      end

      resource "charset-normalizer" do
        url "https://files.pythonhosted.org/packages/c1/3b/66777e39d3ae1ddc77ee606be4ec6d8cbd4c801f65e5a1b6f2b11b8346dd/charset_normalizer-3.4.7-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "f496c9c3cc02230093d8330875c4c3cdfc3b73612a5fd921c65d39cbcef08063"
      end

      resource "cryptography" do
        url "https://files.pythonhosted.org/packages/9b/22/adf66990e63584a68dfb50c24f48a125c07b1699899381c8151e63ed458c/cryptography-49.0.0-cp311-abi3-macosx_11_0_arm64.whl"
        sha256 "966fe0e9c67490071f14c0d2b1cb2dfb3023c5ce39457343931415f08382f2db"
      end

      resource "grpcio" do
        url "https://files.pythonhosted.org/packages/04/19/21a9806eb8240e174fd1ab0cd5b9aa948bb0e05c2f2f55f9d5d7405e6d08/grpcio-1.80.0-cp313-cp313-macosx_11_0_universal2.whl"
        sha256 "92d787312e613754d4d8b9ca6d3297e69994a7912a32fa38c4c4e01c272974b0"
      end

      resource "grpcio-tools" do
        url "https://files.pythonhosted.org/packages/57/5a/c8a05b32bd7203f1b9f4c0151090a2d6179d6c97692d32f2066dc29c67a6/grpcio_tools-1.80.0-cp313-cp313-macosx_11_0_universal2.whl"
        sha256 "a447f28958a8fe84ff0d9d3d9473868feb27ee4a9c9c805e66f5b670121cec59"
      end

      resource "httptools" do
        url "https://files.pythonhosted.org/packages/5e/e5/8cfcabc5546e8022f168be28bcdaa128a240a0befdd03b59d558b4f18bd6/httptools-0.8.0-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "614ceea8ea606848bece2338ac03b3ce5324bcb4be8dc7d377ed708012fa4db8"
      end

      resource "jiter" do
        url "https://files.pythonhosted.org/packages/86/59/db537c0949e83668c38481d426b9f2fd5ab758c4ee53a811dd0a510626a0/jiter-0.15.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "d1e7b1776f0797956c509e123d0952d10d293a9492dea9f288ab9570ec01d1a5"
      end

      resource "jsonschema-rs" do
        url "https://files.pythonhosted.org/packages/47/59/57efa11b8a7069687c7d741849a75092cbb4a6bdce30d52a2832a168c3c5/jsonschema_rs-0.44.1-cp310-abi3-macosx_10_12_x86_64.macosx_11_0_arm64.macosx_10_12_universal2.whl"
        sha256 "6f8be6467ee403e126e4e0abb68f13cfbf7199db54d5a4c0f2a1b00e1304f2e3"
      end

      resource "orjson" do
        url "https://files.pythonhosted.org/packages/32/33/93fcc25907235c344ae73122f8a4e01d2d393ef062b4af7d2e2487a32c37/orjson-3.11.9-cp313-cp313-macosx_10_15_x86_64.macosx_11_0_arm64.macosx_10_15_universal2.whl"
        sha256 "4bab1b2d6141fe7b32ae71dac905666ece4f94936efbfb13d55bb7739a3a6021"
      end

      resource "ormsgpack" do
        url "https://files.pythonhosted.org/packages/eb/29/bb0eba3288c0449efbb013e9c6f58aea79cf5cb9ee1921f8865f04c1a9d7/ormsgpack-1.12.2-cp313-cp313-macosx_10_12_x86_64.macosx_11_0_arm64.macosx_10_12_universal2.whl"
        sha256 "5ea60cb5f210b1cfbad8c002948d73447508e629ec375acb82910e3efa8ff355"
      end

      resource "pillow" do
        url "https://files.pythonhosted.org/packages/71/43/905a14a8b17fdb1ccb58d282454490662d2cb89a6bfec26af6d3520da5ec/pillow-12.2.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "56b25336f502b6ed02e889f4ece894a72612fe885889a6e8c4c80239ff6e5f5f"
      end

      resource "protobuf" do
        url "https://files.pythonhosted.org/packages/5c/01/a3c3ed5cd186f39e7880f8303cc51385a198a81469d53d0fdecf1f64d929/protobuf-6.33.6-cp39-abi3-macosx_10_9_universal2.whl"
        sha256 "9720e6961b251bde64edfdab7d500725a2af5280f3f4c87e57c0208376aa8c3a"
      end

      resource "pydantic-core" do
        url "https://files.pythonhosted.org/packages/c1/81/4fa520eaffa8bd7d1525e644cd6d39e7d60b1592bc5b516693c7340b50f1/pydantic_core-2.46.4-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "c94f0688e7b8d0a67abf40e57a7eaaecd17cc9586706a31b76c031f63df052b4"
      end

      resource "pyyaml" do
        url "https://files.pythonhosted.org/packages/b1/16/95309993f1d3748cd644e02e38b75d50cbc0d9561d21f390a76242ce073f/pyyaml-6.0.3-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "2283a07e2c21a2aa78d9c4442724ec1eb15f5e42a723b99cb3d822d48f5f7ad1"
      end

      resource "regex" do
        url "https://files.pythonhosted.org/packages/aa/da/797e91ecec6f84135da778ddce78c20e0af5d2a15c26f87a81bc3eadb6db/regex-2026.5.9-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "d626b84406444b165fc0ba981604edea39f0588ff1f92baa23fe50799ea9afdb"
      end

      resource "rpds-py" do
        url "https://files.pythonhosted.org/packages/ca/bb/d1b85117967c11191441a7274ae616c65d93901d082c588f89a50a8da5ae/rpds_py-2026.5.1-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "c39f5b67a8a2e67179ada2a954227d670fe65fa9098457f698f56ddf248709b3"
      end

      resource "sqlite-vec" do
        url "https://files.pythonhosted.org/packages/a4/3d/3677e0cd2f92e5ebc43cd29fbf565b75582bff1ccfa0b8327c7508e1084f/sqlite_vec-0.1.9-py3-none-macosx_11_0_arm64.whl"
        sha256 "1d52e30513bae4cc9778ddbf6145610434081be4c3afe57cd877893bad9f6b6c"
      end

      resource "textual-speedups" do
        url "https://files.pythonhosted.org/packages/fd/ab/af8eb2c53b65bd1f868109602ae11daac34d0889c80380b556f644793af5/textual_speedups-0.2.1-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "c762c60275dce06b9c9bde4173cefef950798877da0aac46538ccd0d2ffb2f43"
      end

      resource "tiktoken" do
        url "https://files.pythonhosted.org/packages/53/61/c68e123b6d753e3fc2751e9b18e732c9d8bf1e1926762e736eee935d931c/tiktoken-0.13.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "8fe806a50664e83a6ffd56cbd1e4f5dcc6cd32a3e7538f70dc38b1a271384545"
      end

      resource "uuid-utils" do
        url "https://files.pythonhosted.org/packages/ed/a1/3b48859953ee74fc26628ca5d9e5f848209655a0a8c934032fc596035976/uuid_utils-0.16.2-cp313-cp313-macosx_10_12_x86_64.macosx_11_0_arm64.macosx_10_12_universal2.whl"
        sha256 "c19b7d595d12923da682ed13d313c2333b9ebf214e65a47a24927a8a3a81b191"
      end

      resource "uvloop" do
        url "https://files.pythonhosted.org/packages/89/8c/182a2a593195bfd39842ea68ebc084e20c850806117213f5a299dfc513d9/uvloop-0.22.1-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "561577354eb94200d75aca23fbde86ee11be36b00e52a4eaf8f50fb0c86b7705"
      end

      resource "watchfiles" do
        url "https://files.pythonhosted.org/packages/31/3a/0da302f2307aee316922806ebd5726c542cbd787c938271cf14a074c7daf/watchfiles-1.2.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "7ba0480b9a74af058f43b337e937a451e109295c420916d68ad24e3dc02f5e44"
      end

      resource "websockets" do
        url "https://files.pythonhosted.org/packages/cb/9f/51f0cf64471a9d2b4d0fc6c534f323b664e7095640c34562f5182e5a7195/websockets-15.0.1-cp313-cp313-macosx_10_13_universal2.whl"
        sha256 "ee443ef070bb3b6ed74514f5efaa37a252af57c90eb33b956d35c8e9c10a1931"
      end

      resource "xxhash" do
        url "https://files.pythonhosted.org/packages/2a/6e/46b84017b1301d54091430353d4ad5901654a3e0871649877a416f7f1644/xxhash-3.7.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "91c3b07cf3362086d8f126c6aecd8e5e9396ad8b2f2219ea7e49a8250c318acd"
      end

      resource "zstandard" do
        url "https://files.pythonhosted.org/packages/3f/06/9ae96a3e5dcfd119377ba33d4c42a7d89da1efabd5cb3e366b156c45ff4d/zstandard-0.25.0-cp313-cp313-macosx_11_0_arm64.whl"
        sha256 "a1a4ae2dec3993a32247995bdfe367fc3266da832d82f8438c8570f989753de1"
      end
    end
  end

  on_linux do
    on_arm do
      resource "cffi" do
        url "https://files.pythonhosted.org/packages/a9/f5/a2c23eb03b61a0b8747f211eb716446c826ad66818ddc7810cc2cc19b3f2/cffi-2.0.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "d48a880098c96020b02d5a1f7d9251308510ce8858940e6fa99ece33f610838b"
      end

      resource "charset-normalizer" do
        url "https://files.pythonhosted.org/packages/2e/4e/b7f84e617b4854ade48a1b7915c8ccfadeba444d2a18c291f696e37f0d3b/charset_normalizer-3.4.7-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "0ea948db76d31190bf08bd371623927ee1339d5f2a0b4b1b4a4439a65298703c"
      end

      resource "cryptography" do
        url "https://files.pythonhosted.org/packages/09/41/3797cfaf69cae04a13ee78ebd83f0678d9c02b4779d21ce24445326f1a69/cryptography-49.0.0-cp311-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "36d1709f992593689b45bda411498d62c6e365f2ca00b84657d4dadd24de16db"
      end

      resource "grpcio" do
        url "https://files.pythonhosted.org/packages/18/3a/23347d35f76f639e807fb7a36fad3068aed100996849a33809591f26eca6/grpcio-1.80.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "8ac393b58aa16991a2f1144ec578084d544038c12242da3a215966b512904d0f"
      end

      resource "grpcio-tools" do
        url "https://files.pythonhosted.org/packages/82/6b/794350ed645c12c310008f97068f6a6fd927150b0d0d08aad1d909e880b1/grpcio_tools-1.80.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "75f00450e08fe648ad8a1eeb25bc52219679d54cdd02f04dfdddc747309d83f6"
      end

      resource "httptools" do
        url "https://files.pythonhosted.org/packages/77/00/258bfc0837221f81d9725c45f9b948a6a6b2994a147a4fb66e85100c668f/httptools-0.8.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "88bdd940f2b5d487b4d032c6afa5489a7dc4694410d43de3c38c4fb3af0dc45d"
      end

      resource "jiter" do
        url "https://files.pythonhosted.org/packages/37/38/ea0e13b18c30ef951da0d47d39e7fa9edb82a93a62990ffbd7cea9b622d4/jiter-0.15.0-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "351a341c2105aa430b7047e30f1bf7975f6313b00165d3fc07be2edaf741f279"
      end

      resource "jsonschema-rs" do
        url "https://files.pythonhosted.org/packages/a8/19/6475da01b4e81c0445698290a7b8f237e678a0dc9fbf55df663243597b70/jsonschema_rs-0.44.1-cp310-abi3-manylinux_2_28_aarch64.whl"
        sha256 "502af60c802cf149185ea01edbd31a143b09aaf06b27b6422f8b8893984b1998"
      end

      resource "orjson" do
        url "https://files.pythonhosted.org/packages/21/0f/c9ede0bf052f6b4051e64a7d4fa91b725cccf8321a6a786e86eb03519f00/orjson-3.11.9-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "ffe02797b5e9f3a9d8292ddcd289b474ad13e81ad83cd1891a240811f1d2cb81"
      end

      resource "ormsgpack" do
        url "https://files.pythonhosted.org/packages/6e/31/5efa31346affdac489acade2926989e019e8ca98129658a183e3add7af5e/ormsgpack-1.12.2-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "f3601f19afdbea273ed70b06495e5794606a8b690a568d6c996a90d7255e51c1"
      end

      resource "pillow" do
        url "https://files.pythonhosted.org/packages/73/dd/42107efcb777b16fa0393317eac58f5b5cf30e8392e266e76e51cff28c3d/pillow-12.2.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "f1c943e96e85df3d3478f7b691f229887e143f81fedab9b20205349ab04d73ed"
      end

      resource "protobuf" do
        url "https://files.pythonhosted.org/packages/ee/90/b3c01fdec7d2f627b3a6884243ba328c1217ed2d978def5c12dc50d328a3/protobuf-6.33.6-cp39-abi3-manylinux2014_aarch64.whl"
        sha256 "e2afbae9b8e1825e3529f88d514754e094278bb95eadc0e199751cdd9a2e82a2"
      end

      resource "pydantic-core" do
        url "https://files.pythonhosted.org/packages/03/d5/fd02da45b659668b05923b17ba3a0100a0a3d5541e3bd8fcc4ecb711309e/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "f027324c56cd5406ca49c124b0db10e56c69064fec039acc571c29020cc87c76"
      end

      resource "pyyaml" do
        url "https://files.pythonhosted.org/packages/50/31/b20f376d3f810b9b2371e72ef5adb33879b25edb7a6d072cb7ca0c486398/pyyaml-6.0.3-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "ee2922902c45ae8ccada2c5b501ab86c36525b883eff4255313a253a3160861c"
      end

      resource "regex" do
        url "https://files.pythonhosted.org/packages/d3/9b/b3fdd62b003baa1a9b593cd8c8699c9651c2e80cc21a5c715707983c42d7/regex-2026.5.9-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "aa0fbdbac82cb3e4450d0ccde7d7a35607f4cb2dd9fba4b8b69bfaf8c9fa6aed"
      end

      resource "rpds-py" do
        url "https://files.pythonhosted.org/packages/7c/46/d84105f062e626a1b233f863907288a4708c2d833b8b4c6fb2764bc080c0/rpds_py-2026.5.1-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "b5c30f3f04eef4fbd362226a6f31d7c8895ca4fbb6e0b790f6890a98d8da8559"
      end

      resource "sqlite-vec" do
        url "https://files.pythonhosted.org/packages/00/d4/f2b936d3bdc38eadcbd2a87875815db36430fab0363182ba5d12cd8e0b51/sqlite_vec-0.1.9-py3-none-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "4e921e592f24a5f9a18f590b6ddd530eb637e2d474e3b1972f9bbeb773aa3cb9"
      end

      resource "textual-speedups" do
        url "https://files.pythonhosted.org/packages/9a/d8/aab66c0401118633ac3121d4f79695e86d37aae3b2ebd49a626d034ba64e/textual_speedups-0.2.1-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "42172f4b7742988d9ff28098600b8a4a86a7e86ba39fcc3c779a93b98ef31abc"
      end

      resource "tiktoken" do
        url "https://files.pythonhosted.org/packages/ef/8b/96cc178cc584e65d363134500f297790b06cd48cdeb1e8fcf7bbe60f4715/tiktoken-0.13.0-cp313-cp313-manylinux_2_28_aarch64.whl"
        sha256 "125bc05005e747f993a83dc67934249932d6e4209854452cd4c0b1d53fba3ba2"
      end

      resource "uuid-utils" do
        url "https://files.pythonhosted.org/packages/ad/0e/8e799537ea458abaefb0f5c3b3b05304d3faf413feb0997605a3f8ae2484/uuid_utils-0.16.2-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "27271b37fbc6812bb1542c4b8e22ee00223a6bf7f62b1f38d3bcf8e92f6d9acd"
      end

      resource "uvloop" do
        url "https://files.pythonhosted.org/packages/b7/02/654426ce265ac19e2980bfd9ea6590ca96a56f10c76e63801a2df01c0486/uvloop-0.22.1-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "6e2ea3d6190a2968f4a14a23019d3b16870dd2190cd69c8180f7c632d21de68d"
      end

      resource "watchfiles" do
        url "https://files.pythonhosted.org/packages/db/ef/d5bdb705c224dbc256aa0c1ec47bf4e61ec52558f2afb44a71a1fe4d7015/watchfiles-1.2.0-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "4f34e26a19f91f710c08e0183429f0d1d15df734e6bc78c31e77b9ea9c433658"
      end

      resource "websockets" do
        url "https://files.pythonhosted.org/packages/31/1d/063b25dcc01faa8fada1469bdf769de3768b7044eac9d41f734fd7b6ad6d/websockets-15.0.1-cp313-cp313-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
        sha256 "595b6c3969023ecf9041b2936ac3827e4623bfa3ccf007575f04c5a6aa318c22"
      end

      resource "xxhash" do
        url "https://files.pythonhosted.org/packages/f3/29/a804ded9f5d3d3758292678d23e7528b08fda7b7e750688d08b052322475/xxhash-3.7.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "921c14e93817842dd0dd9f372890a0f0c72e534650b6ab13c5be5cd0db11d47e"
      end

      resource "zstandard" do
        url "https://files.pythonhosted.org/packages/6d/db/ddb11011826ed7db9d0e485d13df79b58586bfdec56e5c84a928a9a78c1c/zstandard-0.25.0-cp313-cp313-manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
        sha256 "bfc4e20784722098822e3eee42b8e576b379ed72cca4a7cb856ae733e62192ea"
      end
    end

    on_intel do
      resource "cffi" do
        url "https://files.pythonhosted.org/packages/98/df/0a1755e750013a2081e863e7cd37e0cdd02664372c754e5560099eb7aa44/cffi-2.0.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "c8d3b5532fc71b7a77c09192b4a5a200ea992702734a2e9279a37f2478236f26"
      end

      resource "charset-normalizer" do
        url "https://files.pythonhosted.org/packages/fa/07/330e3a0dda4c404d6da83b327270906e9654a24f6c546dc886a0eb0ffb23/charset_normalizer-3.4.7-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "e044c39e41b92c845bc815e5ae4230804e8e7bc29e399b0437d64222d92809dd"
      end

      resource "cryptography" do
        url "https://files.pythonhosted.org/packages/e6/8b/43011f7ebe515a8aa20d61f290a326cd890c2e738e16e59eaff8d9c3a412/cryptography-49.0.0-cp311-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "0e959b578856a3924bc0cbb710fc12c387b9412a951389f3ca61704a9e25f325"
      end

      resource "grpcio" do
        url "https://files.pythonhosted.org/packages/9b/e2/da1506ecea1f34a5e365964644b35edef53803052b763ca214ba3870c856/grpcio-1.80.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "873ff5d17d68992ef6605330127425d2fc4e77e612fa3c3e0ed4e668685e3140"
      end

      resource "grpcio-tools" do
        url "https://files.pythonhosted.org/packages/10/f3/abe089b058f87f9910c9a458409505cbeb0b3e1c2d993a79721d02ee6a32/grpcio_tools-1.80.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "7982b5fe42f012686b667dda12916884de95c4b1c65ff64371fb7232a1474b23"
      end

      resource "httptools" do
        url "https://files.pythonhosted.org/packages/2e/1b/46f1cecf06b9bbde8e4b8c88034ac7908989e5ff7a3a388ef38392949c1f/httptools-0.8.0-cp313-cp313-manylinux1_x86_64.manylinux_2_28_x86_64.manylinux_2_5_x86_64.whl"
        sha256 "eb3028cca2fc0a6d720e52ef61d8ebb62fcbfeb1de56874546d858d3f25a26b7"
      end

      resource "jiter" do
        url "https://files.pythonhosted.org/packages/8f/7c/89fbcabb2739b7a5b8dc959a1b6c5761f6484f5fed3486854b3c789bb1de/jiter-0.15.0-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "d1aa62e277fc1cbd80e6deacae6f4d983b41b3d7728e0645c5d741a6149bba45"
      end

      resource "jsonschema-rs" do
        url "https://files.pythonhosted.org/packages/35/a9/6d750088795947a5366cdfa6b9064680a3b0a86f61806521beb35d88c8fb/jsonschema_rs-0.44.1-cp310-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "8078c834c3cea6303796fc4925bb8646d1f68313bd54f6d3dde08c8b8eb74bc1"
      end

      resource "orjson" do
        url "https://files.pythonhosted.org/packages/a1/08/dca0082dd2a194acb93e5457e73455388e2e2ca464a2672449a9ddbb679d/orjson-3.11.9-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "4e39364e726a8fff737309aff059ff67d8a8c8d5b677be7bb49a8b3e84b7e218"
      end

      resource "ormsgpack" do
        url "https://files.pythonhosted.org/packages/1c/a2/072343e1413d9443e5a252a8eb591c2d5b1bffbe5e7bfc78c069361b92eb/ormsgpack-1.12.2-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "39c1bd2092880e413902910388be8715f70b9f15f20779d44e673033a6146f2d"
      end

      resource "pillow" do
        url "https://files.pythonhosted.org/packages/a8/68/b93e09e5e8549019e61acf49f65b1a8530765a7f812c77a7461bca7e4494/pillow-12.2.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "03f6fab9219220f041c74aeaa2939ff0062bd5c364ba9ce037197f4c6d498cd9"
      end

      resource "protobuf" do
        url "https://files.pythonhosted.org/packages/16/92/d1e32e3e0d894fe00b15ce28ad4944ab692713f2e7f0a99787405e43533a/protobuf-6.33.6-cp39-abi3-manylinux2014_x86_64.whl"
        sha256 "e9db7e292e0ab79dd108d7f1a94fe31601ce1ee3f7b79e0692043423020b0593"
      end

      resource "pydantic-core" do
        url "https://files.pythonhosted.org/packages/07/f8/41db9de19d7987d6b04715a02b3b40aea467000275d9d758ffaa31af7d50/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "9551187363ffc0de2a00b2e47c25aeaeb1020b69b668762966df15fc5659dd5a"
      end

      resource "pyyaml" do
        url "https://files.pythonhosted.org/packages/74/27/e5b8f34d02d9995b80abcef563ea1f8b56d20134d8f4e5e81733b1feceb2/pyyaml-6.0.3-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "0f29edc409a6392443abf94b9cf89ce99889a1dd5376d94316ae5145dfedd5d6"
      end

      resource "regex" do
        url "https://files.pythonhosted.org/packages/30/e1/c93444052cf41581f3c884ab3fb5823daf0992f11cd4388d4275ca610558/regex-2026.5.9-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "b6d189041f15691cfa2b6c4290448ec221244d225b3f5fe9e7771b34ffcdf6e2"
      end

      resource "rpds-py" do
        url "https://files.pythonhosted.org/packages/4b/25/05678d97fc25e2622df14dc530fb82023174ecfff6733991ed0d78f167bd/rpds_py-2026.5.1-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "b1b964e3ab599e718dc46c018d104b1ebc007cbc6567d827c94a687fca56d77e"
      end

      resource "sqlite-vec" do
        url "https://files.pythonhosted.org/packages/6f/ad/6afd073b0f817b3e03f9e37ad626ae341805891f23c74b5292818f49ac63/sqlite_vec-0.1.9-py3-none-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux1_x86_64.whl"
        sha256 "1515727990b49e79bcaf75fdee2ffc7d461f8b66905013231251f1c8938e7786"
      end

      resource "textual-speedups" do
        url "https://files.pythonhosted.org/packages/65/45/38a83d71467dab3e4dff6423ce2daa57da67032cfd918a6f697e31e6807c/textual_speedups-0.2.1-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "1389c87c4e1a071ba7ef0a2189d6989b753893ade56fea2e46bda5579f9e1844"
      end

      resource "tiktoken" do
        url "https://files.pythonhosted.org/packages/86/f5/bab735d2c72ea55404b295d02d092644eb5f7cc6205e34d35eb9abfb9ab2/tiktoken-0.13.0-cp313-cp313-manylinux_2_28_x86_64.whl"
        sha256 "5e6358911cab4adee6712da27d65573496a4f68cf8a2b5fca6a4ad10fc5748cf"
      end

      resource "uuid-utils" do
        url "https://files.pythonhosted.org/packages/37/0d/c3918356932ce467b11e954d0c93697fb4652cf664957e3d9521f7ece22f/uuid_utils-0.16.2-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "fcc329be41bb6534ecb03e50596179ab76c7643ced33d13c66967d5ae1869663"
      end

      resource "uvloop" do
        url "https://files.pythonhosted.org/packages/15/c0/0be24758891ef825f2065cd5db8741aaddabe3e248ee6acc5e8a80f04005/uvloop-0.22.1-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "0530a5fbad9c9e4ee3f2b33b148c6a64d47bbad8000ea63704fa8260f4cf728e"
      end

      resource "watchfiles" do
        url "https://files.pythonhosted.org/packages/a7/6c/89b1a230a78f57c52dd8893adb1f92f94411721b6ec12596c56d98c74356/watchfiles-1.2.0-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "ca148d73dea36c9763aaa351e4d7a51780ec1584217c45276f4fe8239c768b71"
      end

      resource "websockets" do
        url "https://files.pythonhosted.org/packages/ff/b2/83a6ddf56cdcbad4e3d841fcc55d6ba7d19aeb89c50f24dd7e859ec0805f/websockets-15.0.1-cp313-cp313-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "0f3c1e2ab208db911594ae5b4f79addeb3501604a165019dd221c0bdcabe4db8"
      end

      resource "xxhash" do
        url "https://files.pythonhosted.org/packages/65/59/172424b79f8cfd4b6d8a122b2193e6b8ad4b11f7159bb3b6f9b3191329bb/xxhash-3.7.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "496736f86a9bedaf64b0dc70e3539d0766df01c71ea22032698e88f3f04a1ce9"
      end

      resource "zstandard" do
        url "https://files.pythonhosted.org/packages/63/4b/e3678b4e776db00f9f7b2fe58e547e8928ef32727d7a1ff01dea010f3f13/zstandard-0.25.0-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "8e735494da3db08694d26480f1493ad2cf86e99bdd53e8e9771b2752a5c0246a"
      end
    end
  end

  # Prebuilt wheels ship extension modules (.so) and bundled dylibs with @rpath
  # install names and no header padding. Keep those IDs as-is so Homebrew does
  # not try to rewrite them to absolute keg paths that overflow the Mach-O header.
  preserve_rpath

  # Pure-Python (py3-none-any) wheels - identical across all platforms.
  resource "agent-client-protocol" do
    url "https://files.pythonhosted.org/packages/7b/18/d8c7ff337cf621ea79a84006a7252ff057bfb5767549bb102cc6649f4ec2/agent_client_protocol-0.10.1-py3-none-any.whl"
    sha256 "a03d3198f4d772f2e0ec012c00ac1cce131b4710220a3dc9fae3c991d047c750"
  end

  resource "aiosqlite" do
    url "https://files.pythonhosted.org/packages/00/b7/e3bf5133d697a08128598c8d0abc5e16377b51465a33756de24fa7dee953/aiosqlite-0.22.1-py3-none-any.whl"
    sha256 "21c002eb13823fad740196c5a2e9d8e62f6243bd9e7e4a1f87fb5e44ecb4fceb"
  end

  resource "annotated-types" do
    url "https://files.pythonhosted.org/packages/78/b6/6307fbef88d9b5ee7421e68d78a9f162e0da4900bc5f5793f6d3d0e34fb8/annotated_types-0.7.0-py3-none-any.whl"
    sha256 "1f02e8b43a8fbbc3f3e0d4f0f4bfc8131bcb4eebe8849b8e5c773f3a1c582a53"
  end

  resource "anthropic" do
    url "https://files.pythonhosted.org/packages/f1/bb/09e82a81885d787f350fb55ca9df865b63140dd28b3b5b3104c4ae261657/anthropic-0.111.0-py3-none-any.whl"
    sha256 "c14edb36ed80da9099acbd26b5cec810d76606c31f32a0d56a4cf9d4fa9e25ae"
  end

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/ba/16/9826f089383c593cdfc4a6e5aca94d9e91ae1692c57af82c3b2aa5e810f7/anyio-4.14.0-py3-none-any.whl"
    sha256 "dd9b7a2a9799ed6552fde617b2c5df02b7fdd7d88392fc48101e51bae46164d9"
  end

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/64/b4/17d4b0b2a2dc85a6df63d1157e028ed19f90d4cd97c36717afef2bc2f395/attrs-26.1.0-py3-none-any.whl"
    sha256 "c647aa4a12dfbad9333ca4e71fe62ddc36f4e63b2d260a37a8b83d2f043ac309"
  end

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/88/c6/92fcd42f1ba33e1184263f25bfabf3d27c383410470f169e4b8163bf9c17/beautifulsoup4-4.15.0-py3-none-any.whl"
    sha256 "d6f88de62e1d4e38ecb1077eb9724cd0eff29d2a08ca16a401e9b9e93f117cf9"
  end

  resource "blockbuster" do
    url "https://files.pythonhosted.org/packages/95/c1/84fc6811122f54b20de2e5afb312ee07a3a47a328755587d1e505475239b/blockbuster-1.5.26-py3-none-any.whl"
    sha256 "f8e53fb2dd4b6c6ec2f04907ddbd063ca7cd1ef587d24448ef4e50e81e3a79bb"
  end

  resource "bracex" do
    url "https://files.pythonhosted.org/packages/9d/2a/9186535ce58db529927f6cf5990a849aa9e052eea3e2cfefe20b9e1802da/bracex-2.6-py3-none-any.whl"
    sha256 "0b0049264e7340b3ec782b5cb99beb325f36c3782a32e36e876452fd49a09952"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/ef/2f/c5464532e965badff2f4c4c1a3a83f5697f0d7c407ed0cda44aaa99bb451/certifi-2026.6.17-py3-none-any.whl"
    sha256 "2227dcbaafe0d2f59279d1762ddddc37783ed4354594f194ffc31d20f41fc3db"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/c7/0d/67e5b4109ea4a837e80daa87c2c696711955e40449a97e8926672534def2/click-8.4.1-py3-none-any.whl"
    sha256 "482be17c6991b8c19c5429a1e995d9b0efdbb63172824c41f99965dc0ade8ec2"
  end

  resource "cloudpickle" do
    url "https://files.pythonhosted.org/packages/88/39/799be3f2f0f38cc727ee3b4f1445fe6d5e4133064ec2e4115069418a5bb6/cloudpickle-3.1.2-py3-none-any.whl"
    sha256 "9acb47f6afd73f60dc1df93bb801b472f05ff42fa6c84167d25cb206be1fbf4a"
  end

  resource "croniter" do
    url "https://files.pythonhosted.org/packages/d0/39/783980e78cb92c2d7bdb1fc7dbc86e94ccc6d58224d76a7f1f51b6c51e30/croniter-6.2.2-py3-none-any.whl"
    sha256 "a5d17b1060974d36251ea4faf388233eca8acf0d09cbd92d35f4c4ac8f279960"
  end

  resource "deepagents" do
    url "https://files.pythonhosted.org/packages/1f/81/49f1a98434b462aa60a07ef5a98437bd6a4445219b91c459e1e7e5d5564e/deepagents-0.6.10-py3-none-any.whl"
    sha256 "21486ba213f027f7f2d5b4822bf6099f806a1d325dd33e93d3f5b9e857b2ea89"
  end

  resource "deepagents-acp" do
    url "https://files.pythonhosted.org/packages/c9/05/5cc23022dcf59543d5d26c5564754cdc8158866feba403d7527ddc788486/deepagents_acp-0.0.8-py3-none-any.whl"
    sha256 "0380c8e804a5d5c0fa245a5b1d7dfde8a867f7a9a17ef54749a69da31ed341cf"
  end

  resource "distro" do
    url "https://files.pythonhosted.org/packages/12/b3/231ffd4ab1fc9d679809f356cebee130ac7daa00d6d6f3206dd4fd137e9e/distro-1.9.0-py3-none-any.whl"
    sha256 "7bffd925d65168f85027d8da9af6bddab658135b840670a223589bc0c8ef02b2"
  end

  resource "docstring-parser" do
    url "https://files.pythonhosted.org/packages/a7/5f/ed01f9a3cdffbd5a008556fc7b2a08ddb1cc6ace7effa7340604b1d16699/docstring_parser-0.18.0-py3-none-any.whl"
    sha256 "b3fcbed555c47d8479be0796ef7e19c2670d428d72e96da63f3a40122860374b"
  end

  resource "filetype" do
    url "https://files.pythonhosted.org/packages/18/79/1b8fa1bb3568781e84c9200f951c735f3f157429f44be0495da55894d620/filetype-1.2.0-py2.py3-none-any.whl"
    sha256 "7ce71b6880181241cf7ac8697a2f1eb6a8bd9b429f7ad6d27b8db9ba5f1c2d25"
  end

  resource "google-auth" do
    url "https://files.pythonhosted.org/packages/44/71/c0321dc6d63d99946da45f7c06299b934e4f7f7da5c4f14d101bcb39adf1/google_auth-2.55.0-py3-none-any.whl"
    sha256 "a17cef9dedf98c4ebae2fb0c48c8f75952c877cbc2efe09f329ef16c2783d88a"
  end

  resource "google-genai" do
    url "https://files.pythonhosted.org/packages/a3/17/bb2cdd0a6c6fec32f14e85735917d1052f82430b1de58c2b606740740419/google_genai-2.9.0-py3-none-any.whl"
    sha256 "2a79e2b08e8439f5f25c2b42f98e3f3e8ea4be9c9265f5d7321580dbaf2764f4"
  end

  resource "googleapis-common-protos" do
    url "https://files.pythonhosted.org/packages/e7/c8/e2645aa8ed02fd4c7a2f59d68783b65b1f3cbdfe39a6308e156509d1fee8/googleapis_common_protos-1.75.0-py3-none-any.whl"
    sha256 "961ed60399c457ceb0ee8f285a84c870aabc9c6a832b9d37bb281b5bebde43ed"
  end

  resource "grpcio-health-checking" do
    url "https://files.pythonhosted.org/packages/5e/d1/d97eb30386feff6ac2a662620e2ed68be352e9a182d62e06213db694906a/grpcio_health_checking-1.80.0-py3-none-any.whl"
    sha256 "d804d4549cbb71e90ca2c7bf0c501060135dfd220aca8e2c54f96d3e79e210e5"
  end

  resource "h11" do
    url "https://files.pythonhosted.org/packages/04/4b/29cac41a4d98d144bf5f6d33995617b185d14b22401f75ca86f384e87ff1/h11-0.16.0-py3-none-any.whl"
    sha256 "63cf8bbe7522de3bf65932fda1d9c2772064ffb3dae62d55932da54b31cb6c86"
  end

  resource "httpcore" do
    url "https://files.pythonhosted.org/packages/7e/f5/f66802a942d491edb555dd61e3a9961140fd64c90bce1eafd741609d334d/httpcore-1.0.9-py3-none-any.whl"
    sha256 "2d400746a40668fc9dec9810239072b40b4484b640a8c38fd654a024c7a1bf55"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/2a/39/e50c7c3a983047577ee07d2a9e53faf5a69493943ec3f6a384bdc792deb2/httpx-0.28.1-py3-none-any.whl"
    sha256 "d909fcccc110f8c7faf814ca82a9a4d816bc5a6dbfea25d6591d6985b8ba59ad"
  end

  resource "httpx-sse" do
    url "https://files.pythonhosted.org/packages/d2/fd/6668e5aec43ab844de6fc74927e155a3b37bf40d7c3790e49fc0406b6578/httpx_sse-0.4.3-py3-none-any.whl"
    sha256 "0ac1c9fe3c0afad2e0ebb25a934a59f4c7823b60792691f779fad2c5568830fc"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/1e/5e/d4e9f1a599fb8e573b7b87160658329fbf28d19eac2718f51fc3def3aa5a/idna-3.18-py3-none-any.whl"
    sha256 "7f952cbe720b688055e3f87de14f5c3e5fdaa8bc3928985c4077ca689de849a2"
  end

  resource "jsonpatch" do
    url "https://files.pythonhosted.org/packages/73/07/02e16ed01e04a374e644b575638ec7987ae846d25ad97bcc9945a3ee4b0e/jsonpatch-1.33-py2.py3-none-any.whl"
    sha256 "0ae28c0cd062bbd8b8ecc26d7d164fbbea9652a1a3693f3b956c1eae5145dade"
  end

  resource "jsonpointer" do
    url "https://files.pythonhosted.org/packages/9e/6a/a83720e953b1682d2d109d3c2dbb0bc9bf28cc1cbc205be4ef4be5da709d/jsonpointer-3.1.1-py3-none-any.whl"
    sha256 "8ff8b95779d071ba472cf5bc913028df06031797532f08a7d5b602d8b2a488ca"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/69/90/f63fb5873511e014207a475e2bb4e8b2e570d655b00ac19a9a0ca0a385ee/jsonschema-4.26.0-py3-none-any.whl"
    sha256 "d489f15263b8d200f8387e64b4c3a75f06629559fb73deb8fdfb525f2dab50ce"
  end

  resource "jsonschema-specifications" do
    url "https://files.pythonhosted.org/packages/41/45/1a4ed80516f02155c51f51e8cedb3c1902296743db0bbc66608a0db2814f/jsonschema_specifications-2025.9.1-py3-none-any.whl"
    sha256 "98802fee3a11ee76ecaca44429fda8a41bff98b00a0f2838151b113f210cc6fe"
  end

  resource "langchain" do
    url "https://files.pythonhosted.org/packages/59/f6/a682e68d004a2e23cae6c5c42e3c0d071bc0e7768167bd12277992f096f9/langchain-1.3.10-py3-none-any.whl"
    sha256 "5da67f21aa56119744ad51b3e46ffac570c88f4fae0876e3b1c6a1c4bc0e344e"
  end

  resource "langchain-anthropic" do
    url "https://files.pythonhosted.org/packages/26/af/927dbbc5a1f5fea1a69adc2883f034cbd1430004e36f4eacd302d500393a/langchain_anthropic-1.4.6-py3-none-any.whl"
    sha256 "dbd412a956b6b8b0716d9d8460ef71f834a6731cdbfc59e6160482a4a9fb5200"
  end

  resource "langchain-core" do
    url "https://files.pythonhosted.org/packages/13/d6/bdf6f0481cc57ef300d6b1eb48cf1400c0409be715d6eb3cabadd1142a09/langchain_core-1.4.8-py3-none-any.whl"
    sha256 "d84c28b05e3ba8d4271d0827aad5b592ccdaaf986e76768c23503f0a2045e8aa"
  end

  resource "langchain-google-genai" do
    url "https://files.pythonhosted.org/packages/6a/82/3d4d3dc181ea1756f323dad4d5936239c2f404ea0acb5102316224280634/langchain_google_genai-4.2.5-py3-none-any.whl"
    sha256 "289699ddb8e1076a76144f83e25e0086e4ce629b196fc103251f2a629e0756e5"
  end

  resource "langchain-mcp-adapters" do
    url "https://files.pythonhosted.org/packages/66/89/b4869db84ce529de6c7548319197df50c24d0f8a7412f74f889e22324036/langchain_mcp_adapters-0.3.0-py3-none-any.whl"
    sha256 "1af511a95e028d9546502e360f95698ae8b691dbc07981fc48170c2cb1ebd7a9"
  end

  resource "langchain-openai" do
    url "https://files.pythonhosted.org/packages/03/21/cbf6c3786de881b214c8c6c9f61fe44c9c47608428676a5cd5c5b2b0cda5/langchain_openai-1.3.2-py3-none-any.whl"
    sha256 "3d247f43bba9f85d32a374b1bdf3932a0d1e3c60913ebeadf68630de52add67e"
  end

  resource "langchain-protocol" do
    url "https://files.pythonhosted.org/packages/99/2e/d82db9eec13ad0f72e7aaad5c4bc730ab111934fdc83c85523206eb9b0a0/langchain_protocol-0.0.18-py3-none-any.whl"
    sha256 "70b53a86fbf9cedc863555effe44da192ab02d556ddbf2cf95b8873adcf41b5a"
  end

  resource "langgraph" do
    url "https://files.pythonhosted.org/packages/89/32/772db1b00a9fe42f50320d1aa20caefb76e621eff1f7218b9918093d631d/langgraph-1.2.6-py3-none-any.whl"
    sha256 "1cf94d3ca124f84f77ce408fa1b06c3dee680a8aafffe364a8fd5d7d03eb8695"
  end

  resource "langgraph-api" do
    url "https://files.pythonhosted.org/packages/0e/38/6b0cdcaaed9b3105102b452a5a70fb08894a9511458cf00c061c4725347c/langgraph_api-0.10.0-py3-none-any.whl"
    sha256 "f4b545bf1936c4e90bed1cc07a6852b1be37e1667007ab4736d800cc18e9f9b3"
  end

  resource "langgraph-checkpoint" do
    url "https://files.pythonhosted.org/packages/bd/b4/71425e3e38be92611300b9cc5e46a5bf98ab23f5ea8a75b73d02a2f1413c/langgraph_checkpoint-4.1.1-py3-none-any.whl"
    sha256 "25d29144b082827218e7bc3f1e9b0566a4bb007895cd6cc26f66a8428739f56e"
  end

  resource "langgraph-checkpoint-sqlite" do
    url "https://files.pythonhosted.org/packages/97/07/b342811a16327900af2747c752ea19676172fcddf9b592cc384031076623/langgraph_checkpoint_sqlite-3.1.0-py3-none-any.whl"
    sha256 "cc9b40df0076feae8a9ad42ae713621b148b00ac23adc09dc1dc66090a46e5ad"
  end

  resource "langgraph-cli" do
    url "https://files.pythonhosted.org/packages/3e/b6/94cbd2ba0820caae203a915272394c576a21ab4a56dfbc93724dc8cd8e2b/langgraph_cli-0.4.30-py3-none-any.whl"
    sha256 "9c577750c57da1a0e3407e8b83e5a0d7eaa80685fe99d95aa7f9bf0e1e73ca92"
  end

  resource "langgraph-prebuilt" do
    url "https://files.pythonhosted.org/packages/e9/43/3fe1a700b8490ed02679cdbbc8c915eb23a092faf496c9c1118abcd10be3/langgraph_prebuilt-1.1.0-py3-none-any.whl"
    sha256 "51e311747d755b751d5c6b39b0c1446124d3a7643d2515017e6714b323508fc9"
  end

  resource "langgraph-runtime-inmem" do
    url "https://files.pythonhosted.org/packages/fe/df/cfb15c70fa4dcab9ea48f8fda9f4ed87d1767eea6e4d2901dc704da297ba/langgraph_runtime_inmem-0.30.0-py3-none-any.whl"
    sha256 "08a36b83b5e32fe6e30cb25062a1e671a42e2a0206e4043cc95f41198dcbbb12"
  end

  resource "langgraph-sdk" do
    url "https://files.pythonhosted.org/packages/a0/05/aac507337cceae773c2cc9ab91eb6301963af7aeeb55b4217a00e15aff17/langgraph_sdk-0.4.2-py3-none-any.whl"
    sha256 "75fa5096c1177ce39c847096a8fe3745ffd480ddb412995f836e9f5f884c43dd"
  end

  resource "langsmith" do
    url "https://files.pythonhosted.org/packages/c6/64/d411be633d1c976955a09f6b3c58fbe70592d1370d262d171f7daf7e3793/langsmith-0.9.0-py3-none-any.whl"
    sha256 "5eeccc36ff956946df8510a2b3b5a87d36c44f11bfb2e5205e9cf03d7b65ec9c"
  end

  resource "linkify-it-py" do
    url "https://files.pythonhosted.org/packages/b4/de/88b3be5c31b22333b3ca2f6ff1de4e863d8fe45aaea7485f591970ec1d3e/linkify_it_py-2.1.0-py3-none-any.whl"
    sha256 "0d252c1594ecba2ecedc444053db5d3a9b7ec1b0dd929c8f1d74dce89f86c05e"
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/b3/81/4da04ced5a082363ecfa159c010d200ecbd959ae410c10c0264a38cac0f5/markdown_it_py-4.2.0-py3-none-any.whl"
    sha256 "9f7ebbcd14fe59494226453aed97c1070d83f8d24b6fc3a3bcf9a38092641c4a"
  end

  resource "markdownify" do
    url "https://files.pythonhosted.org/packages/43/ce/f1e3e9d959db134cedf06825fae8d5b294bd368aacdd0831a3975b7c4d55/markdownify-1.2.2-py3-none-any.whl"
    sha256 "3f02d3cc52714084d6e589f70397b6fc9f2f3a8531481bf35e8cc39f975e186a"
  end

  resource "mcp" do
    url "https://files.pythonhosted.org/packages/2e/e1/4c1dc1fbb688641a712d34650c3d58bbbdcb314ddb75bc5817bbf33515a4/mcp-1.28.0-py3-none-any.whl"
    sha256 "9c1e7cf3a9125557e418ecd4fed8e9adddce81b0dfdae4d6601d700f5beb71a4"
  end

  resource "mdit-py-plugins" do
    url "https://files.pythonhosted.org/packages/a5/69/6da5581c6a7fede7dc261bf4e67d6adca4196f176b43288b55b3db395b6e/mdit_py_plugins-0.6.1-py3-none-any.whl"
    sha256 "214c82fb2ac524472ab6a5bcab1de80f73b50443e187f401bfd77efbc7c6481d"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/b3/38/89ba8ad64ae25be8de66a6d463314cf1eb366222074cfda9ee839c56a4b4/mdurl-0.1.2-py3-none-any.whl"
    sha256 "84008a41e51615a49fc9966191ff91509e3c40b939176e643fd50a5c2196b8f8"
  end

  resource "openai" do
    url "https://files.pythonhosted.org/packages/a3/d2/ba767f4bbb30776c03d40906a2d3afad716a165ffa1771fc23b8992f7920/openai-2.43.0-py3-none-any.whl"
    sha256 "65a670b54fadf2268c9e1330133373c963eb779ee969e5cbad419ec2c21dce97"
  end

  resource "opentelemetry-api" do
    url "https://files.pythonhosted.org/packages/a3/ca/9520cc1f3dfbbd03ac5903bbf55833e257bc64b1cf30fa8b0d6df374d821/opentelemetry_api-1.42.1-py3-none-any.whl"
    sha256 "51a69edacadbc03a8950ace1c4c21099cacc538820ac2c9e36277e78cebba714"
  end

  resource "opentelemetry-exporter-otlp-proto-common" do
    url "https://files.pythonhosted.org/packages/d6/43/2375e7612e1121a4518c17603b6e0b03ad94f565aafad53f464dc5be2bf6/opentelemetry_exporter_otlp_proto_common-1.42.1-py3-none-any.whl"
    sha256 "f48d395ab815b444da118868977e9798ea354c25737d5cf39578ae894011c140"
  end

  resource "opentelemetry-exporter-otlp-proto-http" do
    url "https://files.pythonhosted.org/packages/d3/96/82cb223a1502f0787d4bbff12907f5f8d870a50731febcd5818d93ef9555/opentelemetry_exporter_otlp_proto_http-1.42.1-py3-none-any.whl"
    sha256 "00a16da1b312a1d6c7233d600d557c91df71125af73020f3b9a7765bd699d59d"
  end

  resource "opentelemetry-proto" do
    url "https://files.pythonhosted.org/packages/41/9d/171c02c84a76940b7e601805b3bb536985aded9168fbcc9ba52f0a730fa2/opentelemetry_proto-1.42.1-py3-none-any.whl"
    sha256 "dedb74cba2886c59c7789b227a7a670613025a07489040050aedff6e5c0fb43c"
  end

  resource "opentelemetry-sdk" do
    url "https://files.pythonhosted.org/packages/8f/6b/4287766cfbde577ae2272e8884abac325aeaac0d64f41c61d5b8cc595105/opentelemetry_sdk-1.42.1-py3-none-any.whl"
    sha256 "083cd4bbfaa5aa7b5a9e552430d9951219967cfb27aa61feb13a77aba1fc839d"
  end

  resource "opentelemetry-semantic-conventions" do
    url "https://files.pythonhosted.org/packages/cb/7a/7fe66f5f3682b1dd47d88cc4e11f1c6c0966b737de2d16671146e23c39a5/opentelemetry_semantic_conventions-0.63b1-py3-none-any.whl"
    sha256 "dfe5ef4dee82586b746f522b818ceb298d00b3d59f660042bd79404bff8d0682"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/df/b2/87e62e8c3e2f4b32e5fe99e0b86d576da1312593b39f47d8ceef365e95ed/packaging-26.2-py3-none-any.whl"
    sha256 "5fc45236b9446107ff2415ce77c807cee2862cb6fac22b8a73826d0693b0980e"
  end

  resource "pathspec" do
    url "https://files.pythonhosted.org/packages/f1/d9/7fb5aa316bc299258e68c73ba3bddbc499654a07f151cba08f6153988714/pathspec-1.1.1-py3-none-any.whl"
    sha256 "a00ce642f577bf7f473932318056212bc4f8bfdf53128c78bbd5af0b9b20b189"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/81/e6/cd9575ac904136b3cbf7aa7ee819ef86eedb7274e46f230e94ea4342e729/platformdirs-4.10.0-py3-none-any.whl"
    sha256 "fb516cdb12eb0d857d0cd85a7c57cea4d060bee4578d6cf5a14dfdf8cbf8784a"
  end

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/84/03/0d3ce49e2505ae70cf43bc5bb3033955d2fc9f932163e84dc0779cc47f48/prompt_toolkit-3.0.52-py3-none-any.whl"
    sha256 "9aac639a3bbd33284347de5ad8d68ecc044b91a762dc39b7c21095fcd6a19955"
  end

  resource "pyasn1" do
    url "https://files.pythonhosted.org/packages/5d/a0/7d793dce3fa811fe047d6ae2431c672364b462850c6235ae306c0efd025f/pyasn1-0.6.3-py3-none-any.whl"
    sha256 "a80184d120f0864a52a073acc6fc642847d0be408e7c7252f31390c0f4eadcde"
  end

  resource "pyasn1-modules" do
    url "https://files.pythonhosted.org/packages/47/8d/d529b5d697919ba8c11ad626e835d4039be708a35b0d22de83a269a6682c/pyasn1_modules-0.4.2-py3-none-any.whl"
    sha256 "29253a9207ce32b64c3ac6600edc75368f98473906e8fd1043bd6b5b1de2c14a"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/0c/c3/44f3fbbfa403ea2a7c779186dc20772604442dde72947e7d01069cbe98e3/pycparser-3.0-py3-none-any.whl"
    sha256 "b727414169a36b7d524c1c3e31839a521725078d7b2ff038656844266160a992"
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/fd/7b/122376b1fd3c62c1ed9dc80c931ace4844b3c55407b6fb2d199377c9736f/pydantic-2.13.4-py3-none-any.whl"
    sha256 "45a282cde31d808236fd7ea9d919b128653c8b38b393d1c4ab335c62924d9aba"
  end

  resource "pydantic-settings" do
    url "https://files.pythonhosted.org/packages/77/c1/6e422f34e569cf8e18df68d1939c81c099d2b61e4f7d9621c8a77560799c/pydantic_settings-2.14.2-py3-none-any.whl"
    sha256 "a20c97b37910b6550d5ea50fbcc2d4187defe58cd57070b73863d069419c9440"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/f4/7e/a72dd26f3b0f4f2bf1dd8923c85f7ceb43172af56d63c7383eb62b332364/pygments-2.20.0-py3-none-any.whl"
    sha256 "81a9e26dd42fd28a23a2d169d86d7ac03b46e2f8b59ed4698fb4785f946d0176"
  end

  resource "pyjwt" do
    url "https://files.pythonhosted.org/packages/a3/5e/ecf12fdb62546d64385c158514e9b2b671f7832108ef2ecd2020ce0af2d1/pyjwt-2.13.0-py3-none-any.whl"
    sha256 "66adcc2aff09b3f1bbd95fc1e1577df8ac8723c978552fd43304c8a290ac5728"
  end

  resource "pyperclip" do
    url "https://files.pythonhosted.org/packages/df/80/fc9d01d5ed37ba4c42ca2b55b4339ae6e200b456be3a1aaddf4a9fa99b8c/pyperclip-1.11.0-py3-none-any.whl"
    sha256 "299403e9ff44581cb9ba2ffeed69c7aa96a008622ad0c46cb575ca75b5b84273"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/ec/57/56b9bcc3c9c6a792fcbaf139543cee77261f3651ca9da0c93f5c1221264b/python_dateutil-2.9.0.post0-py2.py3-none-any.whl"
    sha256 "a8b2bc7bffae282281c8140a97d3aa9c14da0b136dfe83f850eea9a5f7470427"
  end

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/0b/d7/1959b9648791274998a9c3526f6d0ec8fd2233e4d4acce81bbae76b44b2a/python_dotenv-1.2.2-py3-none-any.whl"
    sha256 "1d8214789a24de455a8b8bd8ae6fe3c6b69a5e3d64aa8a8e5d68e694bbcb285a"
  end

  resource "python-multipart" do
    url "https://files.pythonhosted.org/packages/e1/04/e8135ebd1ad02c56ec633277529b2602ff99ff634be76cdba5744cf554fd/python_multipart-0.0.32-py3-none-any.whl"
    sha256 "ff6d3f776f16878c894e52e107296ffc890e913c611b1a4ec6c44e2821fe2e23"
  end

  resource "referencing" do
    url "https://files.pythonhosted.org/packages/2c/58/ca301544e1fa93ed4f80d724bf5b194f6e4b945841c5bfd555878eea9fcb/referencing-0.37.0-py3-none-any.whl"
    sha256 "381329a9f99628c9069361716891d34ad94af76e461dcb0335825aecc7692231"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl"
    sha256 "2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0"
  end

  resource "requests-toolbelt" do
    url "https://files.pythonhosted.org/packages/3f/51/d4db610ef29373b879047326cbf6fa98b6c1969d6f6dc423279de2b1be2c/requests_toolbelt-1.0.0-py2.py3-none-any.whl"
    sha256 "cccfdd665f0a24fcf4726e690f65639d272bb0637b9b92dfd91a5568ccf6bd06"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/82/3b/64d4899d73f91ba49a8c18a8ff3f0ea8f1c1d75481760df8c68ef5235bf5/rich-15.0.0-py3-none-any.whl"
    sha256 "33bd4ef74232fb73fe9279a257718407f169c09b78a87ad3d296f548e27de0bb"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/9d/76/f789f7a86709c6b087c5a2f52f911838cad707cc613162401badc665acfe/setuptools-82.0.1-py3-none-any.whl"
    sha256 "a59e362652f08dcd477c78bb6e7bd9d80a7995bc73ce773050228a348ce2e5bb"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/six-1.17.0-py2.py3-none-any.whl"
    sha256 "4721f391ed90541fddacab5acf947aa0d3dc7d27b2e1e8eda2be8970586c3274"
  end

  resource "sniffio" do
    url "https://files.pythonhosted.org/packages/e9/44/75a9c9421471a6c4805dbf2356f7c181a29c1879239abab1ea2cc8f38b40/sniffio-1.3.1-py3-none-any.whl"
    sha256 "2f6da418d1f1e0fddd844478f41680e794e6051915791a034ff65e5f100525a2"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/5e/f5/0c41cb68dcae6b7de4fac4188a3a9589e21fb31df21ea3a2e888db95e6c9/soupsieve-2.8.4-py3-none-any.whl"
    sha256 "e7e6b0769c8f51ed59acab6e994b00621096cfb1c640a7509295987388fbaf65"
  end

  resource "sse-starlette" do
    url "https://files.pythonhosted.org/packages/f8/7f/3de5402f39890ac5660b86bcf5c03f9d855dad5c4ed764866d7b592b46fd/sse_starlette-3.3.4-py3-none-any.whl"
    sha256 "84bb06e58939a8b38d8341f1bc9792f06c2b53f48c608dd207582b664fc8f3c1"
  end

  resource "starlette" do
    url "https://files.pythonhosted.org/packages/ec/bb/2799cc2ede3ed41131f8975621e7213dfc7ef4acbbaadfa440f32500c370/starlette-1.3.1-py3-none-any.whl"
    sha256 "c7372aae11c3c3f26a42df7bd626cec2f47d03483d261d369516a615a53714c6"
  end

  resource "structlog" do
    url "https://files.pythonhosted.org/packages/a8/45/a132b9074aa18e799b891b91ad72133c98d8042c70f6240e4c5f9dabee2f/structlog-25.5.0-py3-none-any.whl"
    sha256 "a8453e9b9e636ec59bd9e79bbd4a72f025981b3ba0f5837aebf48f02f37a7f9f"
  end

  resource "tavily-python" do
    url "https://files.pythonhosted.org/packages/1b/c2/616ebcd49561d74c93099efa45fd5a4af2e528415f01351575980be0ba9e/tavily_python-0.7.26-py3-none-any.whl"
    sha256 "9b9e7f2d10b3572444e13e9a3bf4f5341975d591cbc1306be04ef89a363e42a7"
  end

  resource "tenacity" do
    url "https://files.pythonhosted.org/packages/d7/c1/eb8f9debc45d3b7918a32ab756658a0904732f75e555402972246b0b8e71/tenacity-9.1.4-py3-none-any.whl"
    sha256 "6095a360c919085f28c6527de529e76a06ad89b23659fa881ae0649b867a9d55"
  end

  resource "textual" do
    url "https://files.pythonhosted.org/packages/a8/f5/c1e18bc0707300a0e90204343abbf7d7acd6fb7ebe03a6d4893b99a234b8/textual-8.2.7-py3-none-any.whl"
    sha256 "4caaa13a90bc4cf9c6c862c067ccd34fe84e9c161710a2a907a8026313b6bd73"
  end

  resource "textual-autocomplete" do
    url "https://files.pythonhosted.org/packages/9f/66/ebe744d79c87f25a42d2654dddbd09462edd595f2ded715245a51a546461/textual_autocomplete-4.0.6-py3-none-any.whl"
    sha256 "bff69c19386e2cbb4a007503b058dc37671d480a4fa2ddb3959c15ceb4aff9b5"
  end

  resource "tomli-w" do
    url "https://files.pythonhosted.org/packages/c7/18/c86eb8e0202e32dd3df50d43d7ff9854f8e0603945ff398974c1d91ac1ef/tomli_w-1.2.0-py3-none-any.whl"
    sha256 "188306098d013b691fcadc011abd66727d3c414c571bb01b1a174ba8c983cf90"
  end

  resource "tqdm" do
    url "https://files.pythonhosted.org/packages/d8/8e/bb97bb0c71802080bfc8952937d174e49cfc50de5c951dd47b2496f0dcdb/tqdm-4.68.3-py3-none-any.whl"
    sha256 "39832cc2def2789a6f29df83f172db7416cea70052c0907a57801c5f2fdccb03"
  end

  resource "truststore" do
    url "https://files.pythonhosted.org/packages/19/97/56608b2249fe206a67cd573bc93cd9896e1efb9e98bce9c163bcdc704b88/truststore-0.10.4-py3-none-any.whl"
    sha256 "adaeaecf1cbb5f4de3b1959b42d41f6fab57b2b1666adb59e89cb0b53361d981"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/18/67/36e9267722cc04a6b9f15c7f3441c2363321a3ea07da7ae0c0707beb2a9c/typing_extensions-4.15.0-py3-none-any.whl"
    sha256 "f0fa19c6845758ab08074a0cfa8b7aecb71c999ca73d62883bc25cc018c4e548"
  end

  resource "typing-inspection" do
    url "https://files.pythonhosted.org/packages/dc/9b/47798a6c91d8bdb567fe2698fe81e0c6b7cb7ef4d13da4114b41d239f65d/typing_inspection-0.4.2-py3-none-any.whl"
    sha256 "4ed1cacbdc298c220f1bd249ed5287caa16f34d44ef4e9c3d0cbad5b521545e7"
  end

  resource "uc-micro-py" do
    url "https://files.pythonhosted.org/packages/61/73/d21edf5b204d1467e06500080a50f79d49ef2b997c79123a536d4a17d97c/uc_micro_py-2.0.0-py3-none-any.whl"
    sha256 "3603a3859af53e5a39bc7677713c78ea6589ff188d70f4fee165db88e22b242c"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/7f/3e/5db95bcf282c52709639744ca2a8b149baccf648e39c8cc87553df9eae0c/urllib3-2.7.0-py3-none-any.whl"
    sha256 "9fb4c81ebbb1ce9531cce37674bbc6f1360472bc18ca9a553ede278ef7276897"
  end

  resource "uvicorn" do
    url "https://files.pythonhosted.org/packages/88/fa/e1388bbcf24ef3274f45c0c1c7b501fd14971037c1b6ee23610553307497/uvicorn-0.49.0-py3-none-any.whl"
    sha256 "ba3d14c3ee7e41c6c654c46c9eb489d33213cdd30aa1696eab1374337c13f68f"
  end

  resource "wcmatch" do
    url "https://files.pythonhosted.org/packages/eb/d8/0d1d2e9d3fabcf5d6840362adcf05f8cf3cd06a73358140c3a97189238ae/wcmatch-10.1-py3-none-any.whl"
    sha256 "5848ace7dbb0476e5e55ab63c6bbd529745089343427caa5537f230cc01beb8a"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/bd/6e/95b0e537de1f4d4301f76f944642c6da50d1511cc7b3d64dc418a66c7509/wcwidth-0.8.1-py3-none-any.whl"
    sha256 "f453740b1e4a4f3291faa37944c555d71056c4da08d59809b307ef4feba695c8"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/87/1b/9e33c09813d65e248f7f773119148a612516a4bea93e9c6f545f78455b7c/wheel-0.47.0-py3-none-any.whl"
    sha256 "212281cab4dff978f6cedd499cd893e1f620791ca6ff7107cf270781e587eced"
  end

  # No wheel on PyPI; the pure-Python sdist is built offline at install time
  # (the bundled setuptools/wheel build backend make this work without network).
  resource "forbiddenfruit" do
    url "https://files.pythonhosted.org/packages/e6/79/d4f20e91327c98096d605646bdc6a5ffedae820f38d378d3515c42ec5e60/forbiddenfruit-0.1.4.tar.gz"
    sha256 "e3f7e66561a29ae129aac139a85d610dbf3dd896128187ed5454b6421f624253"
  end

  def install
    # Create the virtualenv via the mixin (its Cellar->opt symlink-hardening lets
    # the venv survive python@3.13 patch upgrades), then install prebuilt
    # wheels with uv - fully offline, no network, no compilation.
    virtualenv_create(libexec, "python3.13")

    # Assemble an offline wheelhouse from the downloaded artifacts. Copy each
    # cached download under its real filename (wheels stay wheels, sdists stay
    # tarballs) so uv can resolve everything locally with no network.
    wheelhouse = buildpath/"wheelhouse"
    wheelhouse.mkpath
    cp Dir[buildpath/"*.whl"], wheelhouse # main package wheel (downloaded :nounzip)
    resources.each { |r| cp r.cached_download, wheelhouse/File.basename(r.url) }

    system "uv", "pip", "install", "--python", libexec/"bin/python",
           "--offline", "--no-index", "--find-links=#{wheelhouse}",
           "deepagents-code==#{version}"

    bin.install_symlink libexec/"bin/dcode", libexec/"bin/deepagents-code"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dcode --version")
    assert_match version.to_s, shell_output("#{bin}/deepagents-code --version")
  end
end
