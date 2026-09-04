# LangChain Homebrew Tap

Homebrew formulae and casks maintained by [LangChain](https://github.com/langchain-ai).

## Install

```sh
brew install langchain-ai/tap/<package>
```

Or tap first, then install:

```sh
brew tap langchain-ai/tap
brew install <package>
```

Or in a `brew bundle` `Brewfile`:

```ruby
tap "langchain-ai/tap"
brew "<package>"
```

## Packages

| Package | Type | Description |
| ------- | ---- | ----------- |
| `langsmith-cli` | formula | Agent-first CLI (`langsmith`) for [LangSmith](https://smith.langchain.com) resources. |
| `open-swe-desktop` | cask | Desktop client for [Open SWE](https://github.com/langchain-ai/open-swe). |

## Maintaining

Formula bottles (prebuilt binaries) are built in CI and served from GitHub
Packages (ghcr.io). To publish bottles for a formula, add the **`pr-pull`**
label to its PR once `test-bot` is green; `langchain-actions-pr-bot` then
commits the bottle block to `main` and uploads the bottles.

**Releases of `open-swe-desktop` need no manual step.** Publishing a stable desktop
release dispatches the `update Open SWE cask` workflow, which verifies the
release and asset, updates the version and checksum, audits the cask, and pushes
the update directly with the ruleset-bypass App. Nightly releases are ignored.

**Releases of `langsmith-cli` need no manual step.** Tagging a release there
opens a bump PR here (its `bump-tap` job), and `auto pr-pull` applies the
`pr-pull` label as soon as `test-bot` is green — tag to published bottles with
no human in the loop. `auto pr-pull` only labels PRs that are authored by
`langtions-bot`, on a branch in this repo, and touch nothing but `Formula/*.rb`;
anything failing those checks waits for a human label as below.

**For everything else: label the bump PR — do not click Merge.** The `pr-pull`
label *is* the publish trigger. `test-bot` going green only builds the bottles
as PR artifacts; it does not publish them. Merging the PR manually lands the
version bump (`url` + `sha256`) on `main` but skips `brew pr-pull` entirely, so
no bottles are built and the formula keeps whatever stale bottle block it had.
If you already merged, recover with a **rebottle PR**: bump `revision` by 1
(audit requires exactly +1 from `main`), remove the stale `bottle do` block,
open a PR, and add `pr-pull` once `test-bot` is green.

**If a release never opened a bump PR here**, run the **bump formulae** workflow
(Actions → *bump formulae* → *Run workflow*). It uses `brew livecheck` to find
any formula behind its upstream and opens the PR the release should have; a
formula already at the latest version is skipped, so it is safe to run anytime.
It is manual-only on purpose — the upstream push is the normal path, and a cron
would just race it.

**First bottle for a new formula requires a one-time manual step.** The ghcr
package is created **private**, and this org disables public packages by
default, so `brew install` can't fetch the bottles until an **org owner** makes
the package public — once, per new package (not per release):

> `github.com/orgs/langchain-ai/packages/container/tap%2F<formula>/settings`
> → *Danger Zone* → **Change visibility → Public**

Casks don't use ghcr and need no such step.

## Documentation

`brew help`, `man brew`, or [Homebrew's documentation](https://docs.brew.sh).
