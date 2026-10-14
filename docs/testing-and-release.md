# Testing and release

## Loading the plugin

- **One terminal session:** `claude --plugin-dir "<repo>/plugins/rahal"`. Only that session sees `/rahal:` commands; desktop sessions do not.
- **Every new session in one workspace:** a local-scope install from the repo folder:
  ```bash
  claude plugin marketplace add "<repo>" --scope local
  claude plugin install rahal@rahal-claude-plugin --scope local
  ```
  Run these from the workspace folder. `claude plugin list` then shows "Read from: <repo>/plugins/rahal", but sessions load a copy cached at install time, not the folder. An edit reaches a session only after `version` in `plugins/rahal/.claude-plugin/plugin.json` is bumped, `claude plugin update rahal@rahal-claude-plugin --scope local` is run from the workspace folder, and a new session is opened. It is enabled in that workspace only. To try unreleased edits, use `--plugin-dir`.
- **Undo:** `claude plugin uninstall rahal@rahal-claude-plugin --scope local`, then `claude plugin marketplace remove rahal-claude-plugin`.
- **Size:** `claude --plugin-dir plugins/rahal plugin details rahal` prints the components and the token cost (`claude plugin details` alone takes an installed name, not a path).
- **Never** use `claude plugin init` to explore: it writes into the user's own skills folder and loads there.

## Proving a run used the plugin

A plugin command opens with the "Step 0 — checks" block, whose header line names the version and the plugin root the run loaded; a root inside `plugins/cache/` is the copy cached at install. Its session transcript (`~/.claude/projects/<encoded workspace>/<session>.jsonl`) contains `<command-name>/rahal:<command></command-name>`. A slash command typed into a session without the plugin is just text, and a "result" from it is not a plugin result.

## Headless runs

`claude -p --plugin-dir <dir> --permission-mode auto --max-budget-usd <n> --settings '{"disableAllHooks":true}' "/rahal:review-pr <link>"` runs read-only checks with a spending cap and without the workspace's hooks. A plugin command in a headless run prints its first question and stops.

## Dry runs

| Scenario | Proves |
| --- | --- |
| `/rahal:init` in the real workspace | the config is complete: `scripts/check-output.sh config <workspace>/.claude/rahal.local.md` |
| `/rahal:init` in an empty folder with a space in its name | missing repos are offered, not fatal; paths are quoted |
| `/rahal:review-pr` with no argument | it asks for the link and stops |
| wrong `gh_config_dir` | step 0 names the account conflict and asks fix now / continue without that step / stop, before any review (whether it should stop outright is an open approval) |
| `/rahal:start-work <ticket>` | `brief.md` and `plan.md` pass `check-output.sh`; it stops at decision 1 |
| `/rahal:review-pr <open PR>` | the reviewer's first line says `code-review: ran at high on <sha>`; findings cite only the PR's files; the checkout is unchanged |
| `/rahal:pr-followup <PR>` | `followup-<date>.md` passes `check-output.sh followup`; answered threads are skipped |
| `/rahal:plan-tickets` | it lists only the projects holding your open tickets and waits; the queue shows in chat; nothing is written until you answer the save question; a saved file passes `check-output.sh queue` |
| one live `gh pr list --repo DigitalZoneApp/rahal-orbit-backend --state open --limit 1 --json number,title,headRefName,baseRefName,isDraft,reviewDecision,mergeStateStatus,url` | every JSON field plan-tickets asks for exists; the `pr-list` probe's stand-in `gh` accepts any field name |
| `/rahal:review-pr <open PR> "focus on <a file in the PR>; keep each drafted comment to two lines"` | no conflict: `Instruction — read as:` lists both lines as applied and asks nothing; the reviewer's prompt carries the focus; the report's `**Instruction:**` line holds the text and passes `check-output.sh review` |
| `/rahal:pr-followup <PR> "push as soon as the gate is green"` with `choices.push: ask` | a saved-choice conflict: one question with Now, You asked, It would, Options (one of them "save as my choice") and Recommend; the answer lands as an `Instruction: Ruling:` line in `ledger.md` |
| `/rahal:review-pr <open PR> "add a suggestion block with the fix to each drafted comment"` | a never-overridden rule: the question names the drafting rule and offers only "do the rest without it" or "stop" |
| `/rahal:start-work <ticket> model=sonnet`, then the same link without `model=` in a new session at phase two | `plan.md` records `**Model:** sonnet`, and the review uses it without asking |

## Windows traps

- Git Bash does not read PowerShell Node managers (fnm, nvm-windows): put the Node folder first on PATH per shell (`toolchain.bash_node_path`).
- The backend's e2e setup spawns `pnpm` without a shell; init's shim fixes it, loaded through `NODE_OPTIONS='--require "<path>"'` (the inner double quotes keep a path with spaces whole).
- Git Bash rewrites `rev:path` and `/api/...` arguments; prefix `git show` and `gh api` with `MSYS_NO_PATHCONV=1`.
- The Claude desktop app's terminal integration can be missing, so Claude cannot type into a terminal tab; open the tab and type the command yourself.

## Release

1. The maintainer merges the pull request into `main`.
2. The branch already bumped `version` in `plugins/rahal/.claude-plugin/plugin.json` (`check.sh` section 13); if two merged branches chose the same number, give the later one the next.
3. `claude plugin tag plugins/rahal` creates the `rahal--v<version>` tag; push `main` and the tag.
4. Teammates install from the marketplace address in `README.md`'s Install section (with an SSH alias if they use several GitHub accounts), then `/plugin install rahal@rahal-claude-plugin`.
