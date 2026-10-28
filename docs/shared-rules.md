# Shared rules

Files in `plugins/rahal/shared/`, read by every command. Referenced as `${CLAUDE_PLUGIN_ROOT}/shared/…`; each `SKILL.md` also prints the plugin root, because files read with the Read tool never expand that variable.

## Step 0 (`step-0-checks.md`)

- **Header line:** `Step 0 — checks · rahal <version> from <plugin root>`, the version read from the loaded copy's `.claude-plugin/plugin.json`, so a run on a stale cached copy shows it.
- **How to run commands:** Git Bash commands that run `node`, `pnpm`, `claude` or a git hook start with `export PATH="<bash_node_path>:$PATH";`; every `gh` command starts with `GH_CONFIG_DIR="<gh_config_dir>"` when set, and every `gh pr`/`gh repo` command carries `--repo DigitalZoneApp/<repo name>`; `git show <rev>:<path>` and `gh api <path>` start with `MSYS_NO_PATHCONV=1`; every path is quoted; the repo's package manager (pnpm, or npm in the corporate backend) runs from inside the repo in a subshell, `(cd <repo> `pnpm` runs from inside the repo in a subshell, `(cd <repo> && pnpm …)`, because corepack reads pnpm's version from the repo's `package.json`;`pnpm` runs from inside the repo in a subshell, `(cd <repo> && pnpm …)`, because corepack reads pnpm's version from the repo's `package.json`; pnpm …)`, because corepack reads pnpm's version from the repo's `package.json`; a bare toolchain value (`<dev_database_url_port>`, `<e2e_node_options>`, `<docker_ports.postgres>`) is the routed family's own; a command named in bold (the **gate**, **regenerate**, **e2e file**) is that row of the family profile's Commands table; `ORB-<n>` anywhere stands for the ticket's id, whatever its team (`GF-935` too), written in a title in the case the profile's Branch practice gives; Prisma dev commands get `DATABASE_URL` rewritten to `<dev_database_url_port>` (the one copy of that line; start-work and pr-followup phase two point here).
- **The ticket folder:** outputs live in `<workspace_root>/<work_folder>/<slug>/`, slug `orb-<n>-<two to four words>`. An existing `orb-<n>-*` folder is reused before a new one is made; the branch comes from `plan.md`'s `**Branch:**` line, the PR's `headRefName`, or `feat/<slug>`; the base from the PR's `baseRefName` in a PR command (GitHub retargets a stacked PR once its blocker merges), from `plan.md`'s `**Base:**` line in start-work, or the repo's default branch `<default>` (`corporate` in the corporate backend, `main` elsewhere). A stacked base is re-checked with `gh pr view` when phase two or three starts: merged into `<default>` switches the Base line and the Pre-flight start to `<default>` (a ledger ruling; the stack notice leaves `pr-body.md`) and offers to merge `origin/<default>` into a branch that already exists, then regenerate and re-run the gate; merged into another branch, or closed without merging, stops and asks. The standard always comes from `origin/<default>`.
- **Check 1 Config:** `.claude/rahal.local.md` in the start folder or a parent; it must have `families:` (an old single-profile file stops with "run `/rahal:init` here"), and each family needs a profile (`orbit`, `corporate`).
- **Check 2 GitHub:** `gh` installed; the active account equals `github.account`; it can read the repo; a merged PR asks "continue anyway?".
- **Check 3 Linear:** loads `<linear.tools>get_issue` and friends; when they are missing or `tools` is empty, searches ToolSearch for `linear get_issue` and offers to record a new prefix; refuses a ticket whose team no configured family's profile lists (`ORB`; `GF` with corporate); then picks the repo (The ticket's repo) and prints a `Route` line.
- **The ticket's repo:** the first rule that answers wins: a PR command's link (a bare number asks the repo when more than one family is configured); a repo the ticket names in Context, Done When or Sources (folder, GitHub link, or a default branch only one repo has, such as `corporate`); with no repo named, the family from the team when only one family lists it (`GF-` → corporate), otherwise orbit (PD-93); the title tag within the family (`[Frontend]` uses the profile's Frontend rule); otherwise ask. A picked repo the config does not list stops with "run `/rahal:init` to add the <family> repos".
- **Check 4 Git:** remote prefix, commit email, fetch; the "behind" count only when a local default branch exists (a docs clone often has none); a clean tree for phases that commit.
- **Check 5 Toolchain:** Node against `.nvmrc` (or the Node the profile names, since the corporate repos have none), the repo's package manager, Docker, port clashes against the routed family's ports, on Windows the Node folder and, when the family sets one, `NODE_OPTIONS='<e2e_node_options>' node -e 1`; for review phases, the `code-review` skill.
- **plan-tickets:** runs checks 1–3 its own way, written in its `SKILL.md`: no `gh repo view` (its `gh pr list` shows the same failure), Linear proven by listing your tickets, and checks 4–5 printed as not needed.
- **A failed check:** say what is wrong, what it would break and the fixing command, then ask fix now / continue without that step / stop. (Open approval: whether a wrong account should stop outright.)
- **Known gaps:** check 2 does not fetch the PR title that check 3 needs; the `repo` scope test false-fails for fine-grained tokens; one `git show origin/main:…` line in `phase-2-execute.md` lacks `MSYS_NO_PATHCONV=1`.

## Approval gates (`approval-gates.md`)

- **Follows the user's choices:** commit (`commit_when`, `commit_size`, `attribution`), push, open PR (`open_pr`, `pr_state`), post comments (`post_comments`), re-request review (`re_request_review`). With `post_comments: auto`, a reply citing a commit is posted only once that commit is pushed.
- **Fixed for everyone:** stops between phases; no force push, `--no-verify`, `gh auth switch` or `git config`; never edit the ticket or `scope/`; comments written to the ticket folder before posting; CI read once; any remote action without its own choice (replacing a PR description) asks every time; a headless run prints its question and stops.

## Instructions (`instructions.md`)

- **Syntax:** `<link> [model=<name>] ["<instruction>"]` for start-work, review-pr and pr-followup; `["<instruction>"]` for plan-tickets. Unquoted text after the link is read as the instruction too, and the run says so.
- **Read as:** right after step 0, one line per action with its tier and the step it touches; each line is checked again when the run reaches that step.
- **Three tiers:** never overridden (the fixed rules and stops in `approval-gates.md`, `evidence.md`, step 0, each template's headings, lines and drafting rules, the repo's `AGENTS.md`, the account, ports and gh folder, plan-tickets' read-only rule); overridden for one run after a question (`choices.*`, the profile's practice, a decided plan decision, a departure from the ticket); applied without asking (wording, length, focus, extra checks, and an answer to a question the command would ask, whose facts are still printed before `Answered by your instruction: …`). What an instruction leaves out of an output is named there.
- **Conflicts:** asked one at a time as Now / You asked / It would / Options / Recommend. A never-overridden rule offers only "do the rest without it" or "stop"; a saved choice also offers "save as my choice", which writes `choices` in `.claude/rahal.local.md`.
- **Recorded:** on the `Instruction:` line (`none` when none) of `brief.md`, `plan.md`, `followup-<date>.md`, `review-<date>.md` and a saved queue, all checked by `check-output.sh`; `Model:` beside it in `plan.md` and `followup-<date>.md`; each conflict's answer under the plan's Decided (start-work phase one), in `ledger.md` (later, and pr-followup), or as `· ruled: …` on the line (review-pr, plan-tickets).
- **Re-runs:** no instruction keeps the recorded one; a different one asks add / replace / ignore; `"none"` clears it. start-work keeps it for the whole ticket, pr-followup carries it into the next round, and review-pr and plan-tickets start fresh.

## Evidence (`evidence.md`)

A check passes only when its output was seen passing; a test run's `Test Files` and `Errors` lines count, not only its `Tests` line; environmental failures are labelled and never looped; library behaviour is measured; every helper citation is re-opened; process claims are checked against repo history; the standard is read from `origin/<default>`; a test must be seen failing first.

## The review (`review-model.md`, `agents/rahal-reviewer.md`)

- **The model:** skipped when `model=<name>` was given now or is recorded as `Model:` in `plan.md` or the latest `followup-*.md`, or `choices.review_model` holds one; otherwise suggested from the change's size and risk and asked. "Always <model>" saves it.
- **One pass:** the main session starts `rahal:rahal-reviewer` once with the chosen `model`. The agent:
  1. builds a scratch clone of the repo with `git clone --shared --no-checkout`, checks out the head as `review-target`, sets the default branch to the fetched `origin/<base>` (the PR's `baseRefName` or the plan's `**Base:**` branch), and removes the remote, because `code-review` compares against the local default branch: a stale local `main` makes it report other people's merged files, and a stacked change's blocker commits would be reviewed too;
  2. runs `code-review` there through the Skill tool with exactly `high review-target` (never `--fix` or `--comment`); `code-review` starts its own helper agent, which runs on the same model;
  3. checks the ticket, `AGENTS.md`, correctness beyond `code-review`, test strength, Review Focus, the instruction's focus and extra checks, and the PR body;
  4. returns one merged list, first line `code-review: ran at high on <sha>` or `code-review: not run — <reason>`.
- **Not run** means the report covers ticket checks only, never "clean".

## Stack notice (`stack-notice.md`)

The paragraph that opens a stacked PR's body: merge the blocker alone, let GitHub move this PR to `main`, merge `origin/main` in, run `pnpm openapi`, never "merge stack" (it rebases and drops the merge commit with the regenerated API documents). start-work fills in the blocker's PR and branch, and drops it once the blocker merges. `pr-followup` phase two adds it to a stacked PR's body and removes it once the PR is retargeted.

## Profiles (`profiles/orbit.md`, `profiles/corporate.md`)

One profile per repo family; step 0 reads the routed family's, and its facts apply to that family's repos only. Both share the section order Linear (with a `Teams:` line step 0 reads), GitHub and repos, Commands, The standard, Branch practice, Rules that bind every ticket. The **Commands** table is the one place a command is spelled out: install, generate, services, migrate, new migration, unit file, e2e file, typecheck, lint, gate, gate counts, regenerate, generated files, hooks, one column per repo. The skills name a row in bold and never hard-code `pnpm` or `npm`.

Corporate (`corporate.md`): teams `ORB` and `GF` (a GF ticket is always corporate); `rahal-corporate-backend` on `corporate` with npm and Jest, its `npm run check` including the e2e suite and the Orbit client checks; `rahal-corporate-app` and `rahal-corporate-dashboard` on `main` with pnpm; the dashboard has no `check` script and no `AGENTS.md`; no repo has `CODEOWNERS` or `.nvmrc`; the backend's ports are fixed in its compose file. Branch practice is Orbit's (PD-94), except the commit scope: `ORB-<n>` in the backend, `orb-<n>` in the app and dashboard, whose commitlint refuses a capital scope.

Orbit (`orbit.md`) team facts: Linear workspace and team key, GitHub org, the three repos and their default branches (`rahal-orbit-docs` uses `docs-main`), pnpm only, the gates, the shared dev database warning for stacked branches (answer no to `db:migrate:dev`'s reset offer), building supertest requests when sent (never an array built up front), branch and commit practice (commitlint refuses any capital letter after the scope; a stacked PR is updated from its blocker's branch, titled `merge orb-<blocker n> into …`), the `AGENTS.md` rules that bind every ticket.

## Config keys (`.claude/rahal.local.md`, written by init)

| Key | Read by |
| --- | --- |
| `workspace_root`, `work_folder`, `families.<family>.repos.*` | step 0 check 1, The ticket's repo, the ticket folder |
| `github.account`, `gh_config_dir`, `remote_prefix`, `commit_email` | step 0 checks 2 and 4, every `gh` and push command |
| `linear.tools` | step 0 check 3 |
| `toolchain.bash_node_path` (shared); `families.<family>.e2e_node_options`, `docker_ports`, `dev_database_url_port` (per family) | step 0 check 5 and "How to run commands" (the dev database URL), `start-work` phase two, `pr-followup` phase two |
| `workspace_extras.*` | init's summary; `docs_folder` gates the docs step in phase two |
| `choices.*` | `approval-gates.md`, `review-model.md`, `instructions.md` ("save as my choice") |

Known gap: the front matter is not strict YAML (`remote_prefix: git@<alias>:` is unquoted); nothing parses it as YAML today.

## Templates (`templates/`)

| Template | Written by | Checked by |
| --- | --- | --- |
| `brief.md` | start-work phase one | `check-output.sh brief` (also its `Instruction:` line) |
| `plan.md` | start-work phase one | `check-output.sh plan` (also its Details anchors, the `**Base:**` line and the `Instruction:` line) |
| `ledger.md` | start-work phase two, pr-followup phase two | `check-output.sh ledger` |
| `review-report.md` | every review | `check-output.sh review` (also its `Instruction:` line) |
| `followup-plan.md` | pr-followup phase one | `check-output.sh followup` (also its `Instruction:` line) |
| `reply.md` | pr-followup phase two | `check-output.sh reply` |
| `ticket-queue.md` | plan-tickets, only when you choose to save | `check-output.sh queue` (also its `Instruction:` line) |
