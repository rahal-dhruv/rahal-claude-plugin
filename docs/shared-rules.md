# Shared rules

Files in `plugins/rahal/shared/`, read by every command. Referenced as `${CLAUDE_PLUGIN_ROOT}/shared/…`; each `SKILL.md` also prints the plugin root, because files read with the Read tool never expand that variable.

## Step 0 (`step-0-checks.md`)

- **Header line:** `Step 0 — checks · rahal <version> from <plugin root>`, the version read from the loaded copy's `.claude-plugin/plugin.json`, so a run on a stale cached copy shows it.
- **How to run commands:** Git Bash commands that run `node`, `pnpm`, `claude` or a git hook start with `export PATH="<bash_node_path>:$PATH";`; every `gh` command starts with `GH_CONFIG_DIR="<gh_config_dir>"` when set, and every `gh pr`/`gh repo` command carries `--repo DigitalZoneApp/<repo name>`; `git show <rev>:<path>` and `gh api <path>` start with `MSYS_NO_PATHCONV=1`; every path is quoted; `pnpm` runs from inside the repo in a subshell, `(cd <repo> && pnpm …)`, because corepack reads pnpm's version from the repo's `package.json`; Prisma dev commands get `DATABASE_URL` rewritten to `<dev_database_url_port>` (the one copy of that line; start-work and pr-followup phase two point here).
- **The ticket folder:** outputs live in `<workspace_root>/<work_folder>/<slug>/`, slug `orb-<n>-<two to four words>`. An existing `orb-<n>-*` folder is reused before a new one is made; the branch comes from `plan.md`'s `**Branch:**` line, the PR's `headRefName`, or `feat/<slug>`; the base from `plan.md`'s `**Base:**` line, the PR's `baseRefName`, or `main`. A stacked base is re-checked with `gh pr view` when phase two or three starts: merged switches it to `main` (a ledger ruling, and the stack notice leaves `pr-body.md`), closed without merging stops. The standard always comes from `origin/main`.
- **Check 1 Config:** `.claude/rahal.local.md` in the start folder or a parent; `profile: orbit`.
- **Check 2 GitHub:** `gh` installed; the active account equals `github.account`; it can read the repo; a merged PR asks "continue anyway?".
- **Check 3 Linear:** loads `<linear.tools>get_issue` and friends; when they are missing or `tools` is empty, searches ToolSearch for `linear get_issue` and offers to record a new prefix; refuses non-`ORB-` tickets.
- **Check 4 Git:** remote prefix, commit email, fetch; the "behind" count only when a local default branch exists (a docs clone often has none); a clean tree for phases that commit.
- **Check 5 Toolchain:** Node against `.nvmrc`, pnpm, Docker, port clashes, on Windows the Node folder and `NODE_OPTIONS='<e2e_node_options>' node -e 1`; for review phases, the `code-review` skill.
- **A failed check:** say what is wrong, what it would break and the fixing command, then ask fix now / continue without that step / stop. (Open approval: whether a wrong account should stop outright.)
- **Known gaps:** check 2 does not fetch the PR title that check 3 needs; the `repo` scope test false-fails for fine-grained tokens; one `git show origin/main:…` line in `phase-2-execute.md` lacks `MSYS_NO_PATHCONV=1`.

## Approval gates (`approval-gates.md`)

- **Follows the user's choices:** commit (`commit_when`, `commit_size`, `attribution`), push, open PR (`open_pr`, `pr_state`), post comments (`post_comments`), re-request review (`re_request_review`). With `post_comments: auto`, a reply citing a commit is posted only once that commit is pushed.
- **Fixed for everyone:** stops between phases; no force push, `--no-verify`, `gh auth switch` or `git config`; never edit the ticket or `scope/`; comments written to the ticket folder before posting; CI read once; any remote action without its own choice (replacing a PR description) asks every time; a headless run prints its question and stops.

## Evidence (`evidence.md`)

A check passes only when its output was seen passing; a test run's `Test Files` and `Errors` lines count, not only its `Tests` line; environmental failures are labelled and never looped; library behaviour is measured; every helper citation is re-opened; process claims are checked against repo history; the standard is read from `origin/<default>`; a test must be seen failing first.

## The review (`review-model.md`, `agents/rahal-reviewer.md`)

- **The model:** skipped when the run has `model=<name>` or `choices.review_model` holds one; otherwise suggested from the change's size and risk and asked. "Always <model>" saves it.
- **One pass:** the main session starts `rahal:rahal-reviewer` once with the chosen `model`. The agent:
  1. builds a scratch clone of the repo with `git clone --shared --no-checkout`, checks out the head as `review-target`, sets the default branch to the fetched `origin/<base>` (the PR's `baseRefName` or the plan's `**Base:**` branch), and removes the remote, because `code-review` compares against the local default branch: a stale local `main` makes it report other people's merged files, and a stacked change's blocker commits would be reviewed too;
  2. runs `code-review` there through the Skill tool with exactly `high review-target` (never `--fix` or `--comment`); `code-review` starts its own helper agent, which runs on the same model;
  3. checks the ticket, `AGENTS.md`, correctness beyond `code-review`, test strength, Review Focus and the PR body;
  4. returns one merged list, first line `code-review: ran at high on <sha>` or `code-review: not run — <reason>`.
- **Not run** means the report covers ticket checks only, never "clean".

## Stack notice (`stack-notice.md`)

The paragraph that opens a stacked PR's body: merge the blocker alone, let GitHub move this PR to `main`, merge `origin/main` in, run `pnpm openapi`, never "merge stack" (it rebases and drops the merge commit with the regenerated API documents). start-work fills in the blocker's PR and branch, and drops it once the blocker merges.

## Profile (`profiles/orbit.md`)

Team facts: Linear workspace and team key, GitHub org, the three repos and their default branches (`rahal-orbit-docs` uses `docs-main`), pnpm only, the gates, the shared dev database warning for stacked branches (answer no to `db:migrate:dev`'s reset offer), building supertest requests when sent (never an array built up front), branch and commit practice, the `AGENTS.md` rules that bind every ticket.

## Config keys (`.claude/rahal.local.md`, written by init)

| Key | Read by |
| --- | --- |
| `profile`, `workspace_root`, `repos.*`, `work_folder` | step 0 check 1, the ticket folder |
| `github.account`, `gh_config_dir`, `remote_prefix`, `commit_email` | step 0 checks 2 and 4, every `gh` and push command |
| `linear.tools` | step 0 check 3 |
| `toolchain.bash_node_path`, `e2e_node_options`, `docker_ports`, `dev_database_url_port` | step 0 check 5 and "How to run commands" (the dev database URL), `start-work` phase two, `pr-followup` phase two |
| `workspace_extras.*` | init's summary; `docs_folder` gates the docs step in phase two |
| `choices.*` | `approval-gates.md`, `review-model.md` |

Known gap: the front matter is not strict YAML (`remote_prefix: git@<alias>:` is unquoted); nothing parses it as YAML today.

## Templates (`templates/`)

| Template | Written by | Checked by |
| --- | --- | --- |
| `brief.md` | start-work phase one | `check-output.sh brief` |
| `plan.md` | start-work phase one | `check-output.sh plan` (also its Details anchors and the `**Base:**` line) |
| `ledger.md` | start-work phase two, pr-followup phase two | `check-output.sh ledger` |
| `review-report.md` | every review | `check-output.sh review` |
| `followup-plan.md` | pr-followup phase one | `check-output.sh followup` |
| `reply.md` | pr-followup phase two | `check-output.sh reply` |
