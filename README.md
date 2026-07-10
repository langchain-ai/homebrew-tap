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

## Maintaining

Formula bottles (prebuilt binaries) are built in CI and served from GitHub
Packages (ghcr.io). To publish bottles for a formula, add the **`pr-pull`**
label to its PR once `test-bot` is green; `langchain-actions-pr-bot` then
commits the bottle block to `main` and uploads the bottles.

**Label the bump PR — do not click Merge.** The `pr-pull` label *is* the
publish trigger. `test-bot` going green only builds the bottles as PR
artifacts; it does not publish them. Merging the PR manually lands the version
bump (`url` + `sha256`) on `main` but skips `brew pr-pull` entirely, so no
bottles are built and the formula keeps whatever stale bottle block it had.
If you already merged, recover with a **rebottle PR**: bump `revision` by 1
(audit requires exactly +1 from `main`), remove the stale `bottle do` block,
open a PR, and add `pr-pull` once `test-bot` is green.

**First bottle for a new formula requires a one-time manual step.** The ghcr
package is created **private**, and this org disables public packages by
default, so `brew install` can't fetch the bottles until an **org owner** makes
the package public — once, per new package (not per release):

> `github.com/orgs/langchain-ai/packages/container/tap%2F<formula>/settings`
> → *Danger Zone* → **Change visibility → Public**

Casks don't use ghcr and need no such step.

## Documentation

`brew help`, `man brew`, or [Homebrew's documentation](https://docs.brew.sh).
