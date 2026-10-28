# Commands

Five skills in `plugins/rahal/skills/`, invoked as `/rahal:<name>`. Each `SKILL.md` sets `disable-model-invocation: true`, so only a person can start one; Claude cannot, which is why every dry run needs someone typing. `start-work`, `review-pr` and `pr-followup` read `shared/step-0-checks.md` first and find the ticket folder through it; `init` runs the step 0 checks as its last step and has no ticket folder. `plan-tickets` runs checks 1–3 its own way (`## Step 0 for this command` in its `SKILL.md`) and has no ticket folder. The commands work in a workspace holding the orbit repos, the corporate repos or both: step 0 routes each ticket or PR to its repo and loads that family's profile (`shared-rules.md` → The ticket's repo, Profiles), and `GF-` tickets are accepted wherever the corporate family is configured. Every command but `init` takes an optional instruction in double quotes (`shared/instructions.md`, described in `shared-rules.md` → Instructions): it prints `Instruction — read as:` after step 0, applies what fits, records it, and asks only on a conflict.

A side session that another Claude Code session started cannot start a `/rahal:` command either, so a brief that needs one tells the person to type it there. Letting Claude start phase one would break `AGENTS.md` §3 and `check.sh` section 4.

## /rahal:init `[workspace folder]`

- **Does:** finds the repos of each family (orbit: `rahal-orbit-*`; corporate: `rahal-corporate-*`; a linked worktree counts), asks which families the workspace works on, and writes one `families.<family>` block for each; records `workspace_root` in the Windows drive form with forward slashes (never `/c/…`, which breaks commands run with `MSYS_NO_PATHCONV=1`); checks `gh`, Linear, git and the toolchain; asks two groups of personal choices (commits; GitHub actions); writes `<workspace>/.claude/rahal.local.md` from `skills/init/references/config-template.md`; on Windows offers the e2e shim at `<workspace>/.claude/rahal/win-pnpm-shim.cjs` for the orbit family; records each family's ports (Orbit's can move, the corporate backend's are fixed); ends by running step 0 checks 1–5.
- **Asks, never assumes:** every clone, install, shim, `work/` folder, `.gitignore` line and `corepack enable` needs a yes. The review model is never asked here.
- **Output check:** `scripts/check-output.sh config <file>`.
- **Known gaps:** re-running init writes `review_model: ask`, losing a saved standing model; started inside a repo it would write its settings into that repo (step 1 only confirms the folder); port clashes are looked for in Docker only.

## /rahal:start-work `<ticket link> [model=<name>] ["<instruction>"]`

Three phases; the SKILL's "Which phase" section picks one from the ticket folder's files.

1. **Understand and plan** (`references/phase-1-understand.md`): reads the ticket, its relations and comments; for each unmerged blocker looks up its open PR and, when the unmerged blockers form one chain of open PRs, prints the facts and asks "Wait or stack?" with no default (wait stops with nothing written; two independent open PRs, or an open PR beside a blocker with none, stop with stacking not offered); checks every cited path on `origin/<base>` (the standard stays on `origin/main`); when stacked, checks each "From ORB-x" and Dependencies item against what the blocker built, reading the blocker's own ticket folder only if it exists (PD-12); lists open PRs that change a path the ticket names (whole-path match) in the brief's "Shares files with" line; measures library behaviour (SQL on real rows inside a transaction rolled back at the end); turns each gap into a decision; writes `brief.md` and `plan.md`; shows the brief and asks decision 1 of N. **Stops.**
2. **Execute** (`references/phase-2-execute.md`): commit gate per `choices.commit_when`; pre-flight; `ledger.md`; each task test-first; docs; the profile's **gate**; guard checks (an `ORDER BY` is deleted once, and a suite that stays green is reported as uncovered; mutations written against the prettier-formatted file; the runner restores each file from its own copy, and keeps vitest's and jest's failed-case and summary lines plus the full log's path; the e2e command is the profile's **e2e file** row); PR body from the live template; the single review pass; writes `review-<date>.md`. **Stops** with the findings; the fix pass runs only on accepted ones.
3. **Ship** (`references/phase-3-ship.md`): step 0 checks 1, 2, 4, 5 and the stacked-base re-check first; push (only fast-forward; never force); `gh pr create` with `--repo` and `--base <base>`; read CI and the requested reviewers once (none requested is reported; the plugin never requests reviewers itself).

- **Outputs (ticket folder):** `ticket-<date>.md` (the ticket word for word), `brief.md` (`check-output.sh brief`), `plan.md` (`plan`), `ledger.md` (`ledger`), `pr-body.md` (a stacked one opens with the stack notice), `review-<date>.md` (`review`).
- **Resume:** re-run with the same link; the ticket folder is found by its `orb-<n>-*` name, the branch read from `plan.md`'s `**Branch:**` line and the base from its `**Base:**` line, the instruction and model from its `**Instruction:**` and `**Model:**` line (so a resumed phase two no longer asks for the model again) (re-checked when phase two or three starts: a blocker merged into the default branch switches the base and the Pre-flight start to it, says so, and offers to merge `origin/<default>` into an existing branch; one merged elsewhere or closed stops), and phase two resumes at the first task without a `complete` line in `ledger.md`.
- **Gotchas:** the branch is `feat/<slug>`, and the slug already starts with `orb-<n>-` (`feat/orb-183-visa-destinations`). It is cut from `origin/<base>` with `--no-track`, so a later pull never follows the blocker's branch; the review range starts at `git merge-base origin/<base> HEAD`.
- **Known gaps:** the review reads commits only (the reviewer's clone checks out the head commit), so with `commit_when: never` it sees none of the work; the end of phase two and its "gate green" resume marker are not written to the ledger; a ticket with no open decisions cannot pass the brief check (it requires `## Decision 1 of`); the stash recipe for splitting one file across commits can conflict on adjacent hunks (the stash is kept).

## /rahal:review-pr `<PR link or number> [model=<name>] ["<instruction>"]`

`references/review-steps.md`: step 0 and the PR's state; the ticket (its description compared with the latest saved `ticket-<date>.md`, never judged by `updatedAt`); the PR head fetched with `"+pull/<n>/head:refs/remotes/origin/pr-<n>"` and checked against `headRefOid`; existing comments; the single review pass; verification; the report; drafted comments.

- **Instruction:** its focus and extra checks reach the reviewer agent; it is recorded on the report's `**Instruction:**` line, with each conflict's answer as `· ruled: …`. Every run starts fresh.
- **Never touches the user's checkout.** The reviewer's `code-review` runs in a scratch clone (`shared-rules.md`, "The review"), diffed against the PR's own base, so a PR stacked on another branch is reviewed without that branch's commits. The standard is read from `origin/main`.
- **Output:** `review-<date>.md` in the ticket folder (`check-output.sh review`); comments are drafted inside it and posted only per `choices.post_comments`. Each draft states the issue plus one concrete example and leaves the fix to the author: no `suggestion` block, proposed fix, @-mention, should or must, or other PR or commit.
- **Known gaps:** a PR whose title has no `ORB-<n>` is matched through its branch name only; step 0's Linear check names only the title. Comment reads lack `--paginate` (busy PRs lose comments past 30). The hunk listing errors on files with no patch, and an anchor outside every hunk needs a conversation comment.

## /rahal:pr-followup `<PR link or number> [model=<name>] ["<instruction>"]`

Two phases; "Which phase" reads the latest `followup-*.md` in the ticket folder.

1. **Analyse** (`references/phase-1-analyse.md`): rebuilds context from GitHub, Linear and the repo (no shared files needed); compares the ticket's description word for word with the latest `ticket-<date>.md` in the ticket folder, never `updatedAt`, which every comment moves; for a stacked PR (base not the default branch) finds the blocker's PR (`gh pr list --head <base>`), states "stacked on #<n> (<state>, head <sha7>)", and also diffs `AGENTS.md` and the PR template from the stack's merge-base with `origin/<default>`, because the standard lives there; when the blocker's PR is merged but this PR was not retargeted, item 0 becomes "retarget to the default branch, then merge it"; collects comments, skipping bots, answered threads and ids on an earlier `Handled:` line; trial-merges `origin/<base>` in a scratch worktree; verifies each comment; writes `followup-<date>.md` with "Which do you accept?". **Stops.**
2. **Fix** (`references/phase-2-fix.md`): records `Accepted: …`; switches to the PR branch and fast-forwards it from `origin/<headRefName>` by name, never its upstream, stopping unless the checkout is that branch at `headRefOid`; merges `origin/<base>` with `--no-ff --no-commit` so install, regenerate, typecheck and lint run before the titled commit (`merge main into …`, or `merge orb-<blocker n> into …` for a stacked PR), stopping when `git diff origin/<base> -- openapi/` shows anything but this ticket's own changes; fixes test-first, one commit each; gate; the single review pass (**stops** with its findings); PR body (a stacked PR's starts with `shared/stack-notice.md`, removed once retargeted); one reply file per comment; remote steps per choices; after the push, lists the open PRs stacked on this one (`gh pr list --base <headRefName>`), each needing `git merge origin/<headRefName>`; appends `Handled: <ids>`.

- **Outputs:** `followup-<date>.md` (`check-output.sh followup`): each glance entry adds `In plain words:` and `Example:`; each fix block, headed ` · comment <id>`, gives Before this PR (the code on `origin/<base>`), Now (the code at the PR head), What they raised, How checked, Ticket, Fix we should apply (a step that breaks code on purpose to prove a test is labelled temporary and never stands in for the fix), a Dry run with real values, an Alternative and a Reply draft naming no other PR; `reply-<date>-<reviewer>-<comment id>.md` (`reply`), `pr-body.md`, `ledger.md`, `review-<date>.md`.
- **Resume:** no `Accepted:` → the question is open; `Accepted:` without `Handled:` → phase two resumes at the first step the ledger does not record. The instruction and model come from the latest `followup-*.md`'s `Instruction:` line, in a new round too (carried over, and said so).
- **Gotchas:** replies are posted only after the push that contains their commit; replacing the PR description and retargeting the PR always ask.
- **Known gaps:** reviews and conversation comments are read without `--paginate` (only inline comments use it), so past 30 of either the rest are silently skipped. A ticket folder without a `ticket-<date>.md` gets "no saved copy to compare" instead of a ticket check.

## /rahal:plan-tickets `["<instruction>"]`

`references/queue-steps.md`:
1. your tickets (the Linear proof);
2. which project, listing only those holding your open tickets (an instruction naming one answers it, the list still shown);
3. the open-ticket table (four `list_issues` calls, one per open status kind);
4. each of your tickets' links (`get_issue` with `fields: [id, relations]`);
5. up to 25 blockers owned by others, one step out;
6. open PRs in backend and dashboard;
7. the order, lanes, stack candidates and other people's tickets (steps 7–10);
8. the queue in chat, then the save question (step 11).

- **Read-only:** Linear `list_issues` and `get_issue` (a result Linear saves to a file is read back, after checking its `id`); `gh --version`, `gh auth status`, `gh pr list`. Each of your tickets in the project is read once with `fields: [id, description]` alone, one per call and never in parallel, and routed to its repo by step 0's rule (The ticket's repo, items 2 to 4), so plan-tickets and start-work put a ticket in the same repo; a description asked for with other fields (about 66,000 characters) overflows the call.
- **Instruction:** it can name the project and narrow or focus the queue; tickets it leaves out are named in Data gaps. One asking to change, comment on or reassign a ticket or PR gets only "do the rest without it" or "stop". Every run starts fresh; a saved queue records it on its `**Instruction:**` line.
- **Statuses:** QA Staging and QA UAT count as merged (they don't block). On Hold is parked: placed after the other tickets ready at the same time, and never marked start now. Duplicate is closed.
- **Unread data:** a ticket whose links could not be read is marked "links unknown" and is never called startable; a repo whose PRs could not be read shows "PRs not read", never "no open PR".
- **Order:** predecessors come first, through any chain of blocking links. Then, among tickets ready at the same time: On Hold after the rest, tickets that don't wait on someone else before those that do, then unblocks the most, priority, ticket number. Tickets that can't be placed (loops) go under "Can't order".
- **Stacking:** start-work's own rule (each blocker's single open PR in the ticket's repo, all in one chain); each candidate says to run start-work and answer **Stack** at its "Wait or stack?" question. Never the default.
- **Output:** shown in chat. It is saved only on request, whole or by lanes, to `<work_folder>/ticket-queue/<project>-<date>.md` (`check-output.sh queue`). An existing file asks replace or keep both.
- **Known limits:**
  - which files a ticket touches is unknown until start-work;
  - the order is only as good as Linear's links;
  - a PR without `orb-<n>` in its title or branch isn't found;
  - the docs repo's PRs aren't read;
  - it plans only your own queue, in the teams the configured families list (ORB; GF with corporate);
  - a ticket whose description names no repo falls back to its team and title tag (step 0's rule), and a `[Cross]` or untagged one counts in every code repo of its family; the description reads cost one Linear call per ticket;
  - chains through three or more other people's tickets aren't seen;
  - the status meanings are ORB's, written in `queue-steps.md`; a GF status not listed is read by its kind.

## Never on their own

No command force-pushes, skips hooks, runs `gh auth switch` or `git config`, edits a Linear ticket or a `scope/` folder, polls CI, or posts anything without the user's choice allowing it. A headless run (`claude -p`) prints its question and stops.
