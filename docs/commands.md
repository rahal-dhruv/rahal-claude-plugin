# Commands

Five skills in `plugins/rahal/skills/`, invoked as `/rahal:<name>`. Each `SKILL.md` sets `disable-model-invocation: true`, so only a person can start one; Claude cannot, which is why every dry run needs someone typing. `start-work`, `review-pr` and `pr-followup` read `shared/step-0-checks.md` first and find the ticket folder through it; `init` runs the step 0 checks as its last step and has no ticket folder. `plan-tickets` runs checks 1–3 its own way (`## Step 0 for this command` in its `SKILL.md`) and has no ticket folder.

## /rahal:init `[workspace folder]`

- **Does:** finds the Orbit repos; checks `gh`, Linear, git and the toolchain; asks two groups of personal choices (commits; GitHub actions); writes `<workspace>/.claude/rahal.local.md` from `skills/init/references/config-template.md`; on Windows offers the e2e shim at `<workspace>/.claude/rahal/win-pnpm-shim.cjs`; ends by running step 0 checks 1–5.
- **Asks, never assumes:** every clone, install, shim, `work/` folder, `.gitignore` line and `corepack enable` needs a yes. The review model is never asked here.
- **Output check:** `scripts/check-output.sh config <file>`.
- **Known gaps:** re-running init writes `review_model: ask`, losing a saved standing model; started inside a repo it would write its settings into that repo (step 1 only confirms the folder); port clashes are looked for in Docker only.

## /rahal:start-work `<ORB link> [model=<name>]`

Three phases; the SKILL's "Which phase" section picks one from the ticket folder's files.

1. **Understand and plan** (`references/phase-1-understand.md`): reads the ticket, its relations and comments; checks every cited path on `origin/<default>`; measures library behaviour; turns each gap into a decision; writes `brief.md` and `plan.md`; shows the brief and asks decision 1 of N. **Stops.**
2. **Execute** (`references/phase-2-execute.md`): commit gate per `choices.commit_when`; pre-flight; `ledger.md`; each task test-first; docs; `pnpm check`; guard checks (the runner restores each file from its own copy); PR body from the live template; the single review pass; writes `review-<date>.md`. **Stops** with the findings; the fix pass runs only on accepted ones.
3. **Ship** (`references/phase-3-ship.md`): step 0 checks 1, 2, 4, 5 first; push (only fast-forward; never force); `gh pr create` with `--repo`; read CI once.

- **Outputs (ticket folder):** `brief.md` (`check-output.sh brief`), `plan.md` (`plan`), `ledger.md` (`ledger`), `pr-body.md`, `review-<date>.md` (`review`).
- **Resume:** re-run with the same link; the ticket folder is found by its `orb-<n>-*` name, the branch read from `plan.md`'s `**Branch:**` line, and phase two resumes at the first task without a `complete` line in `ledger.md`.
- **Gotchas:** the branch is `feat/<slug>`, and the slug already starts with `orb-<n>-` (`feat/orb-183-visa-destinations`).
- **Known gaps:** the review reads commits only (the reviewer's clone checks out the head commit), so with `commit_when: never` it sees none of the work; the end of phase two and its "gate green" resume marker are not written to the ledger; a ticket with no open decisions cannot pass the brief check (it requires `## Decision 1 of`); the stash recipe for splitting one file across commits can conflict on adjacent hunks (the stash is kept).

## /rahal:review-pr `<PR link or number> [model=<name>]`

`references/review-steps.md`: step 0 and the PR's state; the ticket; the PR head fetched with `"+pull/<n>/head:refs/remotes/origin/pr-<n>"` and checked against `headRefOid`; existing comments; the single review pass; verification; the report; drafted comments.

- **Never touches the user's checkout.** The reviewer's `code-review` runs in a scratch clone (`shared-rules.md`, "The review").
- **Output:** `review-<date>.md` in the ticket folder (`check-output.sh review`); comments are drafted inside it and posted only per `choices.post_comments`.
- **Known gaps:** a PR whose title has no `ORB-<n>` is matched through its branch name only; step 0's Linear check names only the title. Comment reads lack `--paginate` (busy PRs lose comments past 30). The hunk listing errors on files with no patch, and an anchor outside every hunk needs a conversation comment.

## /rahal:pr-followup `<PR link or number> [model=<name>]`

Two phases; "Which phase" reads the latest `followup-*.md` in the ticket folder.

1. **Analyse** (`references/phase-1-analyse.md`): rebuilds context from GitHub, Linear and the repo (no shared files needed); collects comments, skipping bots, answered threads and ids on an earlier `Handled:` line; trial-merges `origin/<base>` in a scratch worktree; verifies each comment; writes `followup-<date>.md` with "Which do you accept?". **Stops.**
2. **Fix** (`references/phase-2-fix.md`): records `Accepted: …`; merges `origin/<base>` with `--no-ff --no-commit` so install, regenerate, typecheck and lint run before the titled commit; fixes test-first, one commit each; gate; the single review pass (**stops** with its findings); PR body; one reply file per comment; remote steps per choices; appends `Handled: <ids>`.

- **Outputs:** `followup-<date>.md` (`check-output.sh followup`, which needs ` · comment <id>` in each fix heading), `reply-<date>-<reviewer>-<comment id>.md` (`reply`), `pr-body.md`, `ledger.md`, `review-<date>.md`.
- **Resume:** no `Accepted:` → the question is open; `Accepted:` without `Handled:` → phase two resumes at the first step the ledger does not record.
- **Gotchas:** replies are posted only after the push that contains their commit; replacing the PR description always asks.
- **Known gaps:** reviews and conversation comments are read without `--paginate` (only inline comments use it), so past 30 of either the rest are silently skipped.

## /rahal:plan-tickets (no arguments)

`references/queue-steps.md`:
1. your tickets (the Linear proof);
2. which project, listing only those holding your open tickets;
3. the open-ticket table (four `list_issues` calls, one per open status kind);
4. each of your tickets' links (`get_issue` with `fields: [id, relations]`);
5. up to 25 blockers owned by others, one step out;
6. open PRs in backend and dashboard;
7. the order, lanes, stack candidates and other people's tickets.

- **Read-only:** Linear `list_issues` and `get_issue`; `gh --version`, `gh auth status`, `gh pr list`. Descriptions are never read: one is about 66,000 characters and overflows the call.
- **Statuses:** QA Staging and QA UAT count as merged (they don't block). On Hold is parked and ordered last. Duplicate is closed.
- **Unread data:** a ticket whose links could not be read is marked "links unknown" and is never called startable; a repo whose PRs could not be read shows "PRs not read", never "no open PR".
- **Order:** predecessors come first, through any chain of blocking links. Then On Hold last, waits on someone else, unblocks the most, priority, ticket number. Tickets that can't be placed (loops) go under "Can't order".
- **Stacking:** start-work's own rule (each blocker's single open PR in the ticket's repo, all in one chain); each candidate says to run start-work and answer **Stack** at its "Wait or stack?" question. Never the default.
- **Output:** shown in chat. It is saved only on request, whole or by lanes, to `<work_folder>/ticket-queue/<project>-<date>.md` (`check-output.sh queue`). An existing file asks replace or keep both.
- **Known limits:**
  - which files a ticket touches is unknown until start-work;
  - the order is only as good as Linear's links;
  - a PR without `orb-<n>` in its title or branch isn't found;
  - the docs repo's PRs aren't read;
  - it plans only your own queue, in ORB only;
  - a ticket's repo comes from its title tag;
  - chains through three or more other people's tickets aren't seen;
  - the status meanings are ORB's, written in `queue-steps.md`.

## Never on their own

No command force-pushes, skips hooks, runs `gh auth switch` or `git config`, edits a Linear ticket or a `scope/` folder, polls CI, or posts anything without the user's choice allowing it. A headless run (`claude -p`) prints its question and stops.
