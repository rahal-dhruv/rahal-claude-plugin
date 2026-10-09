# Checks

The gate is `scripts/check.sh`, `scripts/test-check-output.sh` and `scripts/test-probes.sh`, each printing "all clear".

## `scripts/check.sh`

1. **Validator:** `claude plugin validate --strict` on the marketplace and on `plugins/rahal`.
2. **Required files:** every path in `scripts/required-files.txt`.
3. **Required lines:** every `path|exact line` in `scripts/required-headings.txt` (whole-line, fixed-string match; indentation counts).
4. **Skill front matter:** `name`, `description`, `argument-hint`, `disable-model-invocation: true`.
5. **Reviewer agent:** named `rahal-reviewer`; no `Edit`, `Write` or `NotebookEdit`; no pinned model; `--fix` or `--comment` only on the line that forbids them.
6. **References:** every `${CLAUDE_PLUGIN_ROOT}/<path>` resolves.
7. **Personal data:** scans every file git would commit (`git ls-files --cached --others --exclude-standard`, so ignored files are skipped) for absolute local paths, a personal email domain, the maintainer's local ports and a filled-in gh config folder setting; the maintainer's account name only in `README.md`.
8. **Forbidden text:** no line of `scripts/forbidden-text.txt` (`text|why`) appears in the plugin.
9. **Docs map:** every link in `docs/index.md` resolves; every `docs/*.md` is listed there.
10. **Decision log:** each `### PD-nn` in `docs/decisions.md` has Decision, Why, Cost if wrong and Where; no id repeats; every backticked Where path exists.
11. **Opt-in reflector:** a `.claude/settings.json` that names `post-task.sh` fails.

Known gaps: section 5 misses a list-form `tools:` and `MultiEdit`; section 4 accepts a blank first line; section 7 scans nothing outside a git checkout and has no pattern for the maintainer's first name.

## `scripts/check-output.sh <kind> <file>`

| Kind | Demands |
| --- | --- |
| `brief` | `## What it asks for`, `## Where it sits`, `## What I checked`, `## The plan at a glance`, `## Decision 1 of` |
| `plan` | `## Tasks at a glance`, `## Global Constraints`, `## Decisions`, `## Review Focus`, `## Pre-flight`, `### Task 1:`, `## Self-check`; every `[Details →](#…)` anchor matches a heading |
| `ledger` | first line `# Ledger — plan: `, then `## Rulings`, `## Tasks`, `## Environment`, `## Review`, `## Remote steps` |
| `review` | sections `## 1.`–`## 6.` and a `Verdict:` line |
| `followup` | `## Comments at a glance`, `## Detailed fixes`, `Which do you accept?`, and ` · comment ` in fix headings |
| `reply` | no `#<n>` or `/pull/<n>`; a commit SHA or the word `Evidence` |
| `config` | every key present; required values real (not empty, `""`, `''`, a comment, or an unfilled `<placeholder>`) |

`scripts/test-check-output.sh` proves it: each `tests/fixtures/good-<kind>.md` passes and each `bad-<kind>.md` and `bad-<kind>-<reason>.md` fails. Known gaps: a plan with no Details links passes; a heading with trailing spaces fails; the reply check misses "PR 145".

## Probes (`tests/probes/`, run by `scripts/test-probes.sh`)

A probe extracts a bash block from the shipped Markdown, runs it in a throwaway git repo under a folder whose name has a space, and prints `<name>: all clear` or `FAIL …`. Each takes an optional file path, so it can be run once against a deliberately broken copy to prove it bites.

| Probe | Proves |
| --- | --- |
| `check-sections` | `check.sh` sections 7 and 9–11 fail on planted problems and stop failing once fixed |
| `guard-runner` | the guard runner restores uncommitted and untracked files exactly |
| `merge-step` | the main merge stays open (`--no-commit`) instead of committing with Git's message |
| `pr-fetch` | the PR fetch follows a force-pushed head (`+` refspec), in both files that carry it |
| `review-clone` | the reviewer's scratch clone reviews only the PR's files when the local `main` is stale, and leaves the user's repo untouched |
| `reflector-hook` | the hook spawns once per new context file, never for a reflector run, with hooks off |

## The test-first practice for Markdown

A change to plugin Markdown starts in `scripts/`: pin the new exact line in `required-headings.txt`, or the removed wording in `forbidden-text.txt`, or add a fixture; run `check.sh` and watch it fail; then edit. A pinned line inside a list or code block keeps its indentation. A new bash block gets a probe. Example: the one-pass review began as five pins and five forbidden strings that failed until the reviewer agent, `review-model.md`, the template header and step 0 said the same thing.
