# start-work — phase one: understand and plan

## 1. Step 0

Run checks 1–4 of `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md`. This phase changes nothing in any repo.

## 2. Read the ticket and its neighbours

- `get_issue` with `id: "ORB-<n>"` and `includeRelations: true`; `list_comments` with `issueId: "ORB-<n>"`. When the description has images (designs), `extract_images` on it.
- For each related ticket, `get_issue` with `fields: ["title","status","assignee","completedAt","description"]`, and note only what touches this ticket:
  - **blocked by:** merged? A blocker that is not merged may have an open PR to stack on (below);
  - **blocks:** which files and symbols that ticket reuses or will change from this one;
  - **related or siblings:** which files both change (`openapi/admin.json` is the usual one).
- The target repo is the one step 0's Route line picked (step 0 → The ticket's repo).

### Stacking on an unmerged blocker

For each blocker that is not merged, look for its open PR:

```bash
GH_CONFIG_DIR="<gh_config_dir>" gh pr list --repo DigitalZoneApp/<repo name> --state open --search "ORB-<blocker n>" \
  --json number,title,headRefName,headRefOid,baseRefName,reviewDecision,statusCheckRollup
```

Keep only a PR whose title holds `ORB-<blocker n>` (not a longer number) or whose branch holds `orb-<blocker n>-`. Then the base for this ticket (`<base>` below and in phase two and three) is:
- **No unmerged blocker:** `<default>`.
- **Unmerged blockers, none with an open PR:** `<default>`. Say so; there is nothing to stack on, and the work may need to wait.
- **Every unmerged blocker's PR in one chain** (usually a single PR; with several, each PR's `baseRefName` is the next one's `headRefName`): print the facts for the top PR of the chain and ask, with no default answer:

  ```
  Blocked by ORB-103: not merged. Its PR #146 is open:
    branch orb-103-car-rental-search-route · head 1a2b3c4
    review: changes requested · CI: green
    1. Wait:  stop here; re-run /rahal:start-work <link> after #146 merges. The branch then starts from <default>.
    2. Stack: start now from orb-103-car-rental-search-route. This PR targets that branch until #146 merges;
              GitHub then moves it to <default>, and you merge origin/<default> in once.
  Wait or stack?
  ```

  - **Wait:** stop. Nothing is written.
  - **Stack:** `<base>` is the top PR's `headRefName`. Step 6 records it in the plan's `**Base:**` line, with the PR number and the blocker's ticket id.
  - **Answered by the instruction** (`${CLAUDE_PLUGIN_ROOT}/shared/instructions.md`): print the facts above all the same, then `Answered by your instruction: <Wait | Stack>`, and go on as for that answer.
- **Otherwise** (two independent open PRs, or an open PR beside a blocker that has none): list each unmerged blocker with its PR and that PR's base, say "A branch can start from only one of them, so stacking is not offered. Re-run /rahal:start-work <link> once one of them merges.", and stop.

### Open PRs on the same files

List the open PRs that change a path the ticket names (quote each path):

```bash
printf '%s\n' <each path the ticket names> > "<scratchpad>/ticket-paths.txt"
GH_CONFIG_DIR="<gh_config_dir>" gh pr list --repo DigitalZoneApp/<repo name> --state open --limit 100 \
  --json number,headRefName,files --jq '.[] | .number as $n | .headRefName as $b | .files[] | "\($n)\t\($b)\t\(.path)"' \
  | awk -F '\t' 'NR == FNR { want[$0]; next } $3 in want { print "#" $1 " (" $2 "): " $3 }' "<scratchpad>/ticket-paths.txt" -
```

Report each in the brief's "Shares files with" line, beside the Linear siblings: whichever PR merges second must merge the other's change in. When stacked, the blocker's PR is expected there. gh lists at most 100 files per PR.

## 3. Check the ticket against the code

Everything on `origin/<base>` (step 2: `<default>`, or the blocker's branch when stacked), never the local checkout:

```bash
git -C <repo> fetch origin --quiet
git -C <repo> rev-list --left-right --count <default>...origin/<default>   # local lag, for the brief
git -C <repo> log --oneline <ticket base sha>..origin/<base> -- <files the ticket names>   # drift since the ticket was written
MSYS_NO_PATHCONV=1 git -C <repo> cat-file -e origin/<base>:<path> && echo ok || echo missing   # every cited path
MSYS_NO_PATHCONV=1 git -C <repo> show origin/<base>:<path>             # each file the ticket says to copy
```

- The ticket's base commit is usually written as "On `<default>` (`<sha>`)", e.g. "On `corporate` (`4d1c2ba5`)". Paths are the backticked `src/…`, `test/…`, `prisma/…` names.
- Read the standard on `origin/<default>`, even when stacked: `AGENTS.md`, `CODEOWNERS` (`.github/CODEOWNERS` or `CODEOWNERS`) and `.github/pull_request_template.md`. Read the tooling on `origin/<base>`, which is what the branch will run: `lefthook.yml` or `.husky/` (whichever the repo has), `eslint.config.js` (`moduleMap`) and the `package.json` scripts.
- When the build needs the design notes the ticket cites, read them from `rahal-orbit-docs` on `origin/docs-main`, when the orbit family is configured: the channel contract a corporate ticket cites lives there too.
- Flag every drift: a file that moved or vanished, a symbol renamed, a new suite or rule the ticket does not know about.
- **Stacked:** check what the ticket takes from the blocker against what the blocker built, on `origin/<base>`. Each "From ORB-<blocker n>" item and each Dependencies entry (a symbol, route, table or file) must exist there with the name and shape the ticket expects; a difference is a decision (step 5). When a ticket folder for the blocker exists (`<workspace_root>/<work_folder>/orb-<blocker n>-*/`), also read its `plan.md` Decisions and `ledger.md` Rulings for departures from the blocker's ticket. That folder is optional: the blocker is often someone else's work, and no command depends on another person's folder.

## 4. Measure library behaviour

For each thing the ticket relies on a package doing (a validator, a parser, a driver, an SQL operator), run the real value through the installed package once in the scratchpad:
- Load CommonJS through `createRequire('<repo>/package.json')`.
- Load ESM-only packages by `file:///` URL to their `exports` entry.
- Measure SQL through `pg` against the dev database (port `<dev_database_url_port>`), with bound parameters, on real rows, inside a transaction that ends in `ROLLBACK`, so nothing the measurement writes stays.

Record the command and the result: they go in the brief and later in the PR body.

## 5. Decisions

Every gap between the ticket, `AGENTS.md` and the code becomes a decision, in the `shared/explanation-style.md` order:
- verdict;
- what's going on;
- `file:line`;
- an example;
- the options;
- a recommendation and why.

Typical sources:
- the ticket prescribes a second copy of something that already exists;
- wording that goes stale once the change lands;
- a value the ticket doesn't give;
- a change to a `CODEOWNERS` file.

## 6. Write the brief and the plan

- `<workspace_root>/<work_folder>/<slug>/ticket-<date>.md`: the ticket as read in step 2, word for word, never summarised: its id, title, status and `updatedAt`, the full description, and every comment with its author and date. A later review compares the description against it.
- `<workspace_root>/<work_folder>/<slug>/brief.md` from `${CLAUDE_PLUGIN_ROOT}/shared/templates/brief.md`.
- `<workspace_root>/<work_folder>/<slug>/plan.md` from `${CLAUDE_PLUGIN_ROOT}/shared/templates/plan.md`:
  - The `**Base:**` line holds the base from step 2: `<default>`, or the blocker's branch with its PR number and ticket id.
  - The `**Instruction:**` line holds the instruction as typed, or `none`, and `**Model:**` the `model=` name, or `ask`; `brief.md` carries the same Instruction line. A conflict's answer goes under Decisions → Decided.
  - Every task carries real code, exact paths, an `Expected:` line for every command, and test-first steps.
  - Commit points follow `choices.commit_size`.
  - The Review Focus lists the five likeliest untested failures. Extra test cases beyond the ticket's list are marked keep-or-drop.
  - The Self-check maps every Must Have to a task and every acceptance criterion to a test case.
  - Check each `[Details →](#…)` link: lower-case the heading text, drop characters other than letters, digits, spaces, `_` and `-`, and replace spaces with `-`. The anchor must equal that.
- If superpowers is installed, its `writing-plans` discipline applies. These templates and paths still win: never save under `docs/superpowers/` and never create `.superpowers/` inside a repo.

## 7. Show the brief and stop

- Print the brief in chat (the same text as `brief.md`).
- Then ask decision 1 of N in full; list the rest in one line each.
- A decision the instruction answers is shown in full all the same and moved to Decided as `— by your instruction —`.
- Stop.
- Each answer updates `plan.md`: move the decision to "Decided" with the date, delete the rejected alternatives from the steps, and update the Tasks at a glance lines.
- Then ask the next decision.

When all are decided, ask any execution choice still open, such as keep or drop of each extra test case, then "Ready to execute?". Stop.
