# Decisions

Every decision behind the plugin, newest last. Ids are `PD-nn` ("plugin decision"), never the Orbit team's `D-0xx`. Each entry: Decision, Why, Cost if wrong, Where (repo paths), Date. A replaced decision stays, marked "Superseded by".

### PD-01 — Orbit only for the first release
- **Decision:** the plugin supports Orbit (`ORB-`) tickets and the three Orbit repos; another team comes later as a second profile.
- **Why:** one team's facts can be right; a second team is added the same way once the first works.
- **Cost if wrong:** a `GF-` ticket stops with a clear message until a profile is added.
- **Where:** `plugins/rahal/shared/profiles/orbit.md`
- **Date:** 2026-10-08

### PD-02 — A private repo, shared by invitation
- **Decision:** the plugin lives in a private GitHub repo; teammates are invited as collaborators.
- **Why:** it encodes the team's process and is not meant for the public.
- **Cost if wrong:** moving it to the org later is a transfer plus a new marketplace address.
- **Where:** `README.md`
- **Date:** 2026-10-08

### PD-03 — No personal paths or accounts in the plugin
- **Decision:** everything personal lives in each user's `<workspace>/.claude/rahal.local.md`, written by `/rahal:init`; `check.sh` refuses personal data in committed files.
- **Why:** the same plugin must work for every teammate's machine and accounts.
- **Cost if wrong:** none known; a missed value is asked by init.
- **Where:** `plugins/rahal/skills/init/SKILL.md`, `scripts/check.sh`
- **Date:** 2026-10-08

### PD-04 — A self-contained plugin
- **Decision:** skills, shared reference files and one reviewer agent; it works without the superpowers plugin and uses its skills when installed.
- **Why:** teammates get one install with no hidden dependency.
- **Cost if wrong:** some discipline from superpowers is restated in the plugin's own files.
- **Where:** `plugins/rahal/.claude-plugin/plugin.json`
- **Date:** 2026-10-08

### PD-05 — Four commands with short names
- **Decision:** `init`, `start-work`, `review-pr`, `pr-followup`, invoked as `/rahal:<name>`.
- **Why:** Claude Code prefixes plugin skills with the plugin name, so short names stay readable.
- **Cost if wrong:** a rename changes every user's muscle memory.
- **Where:** `plugins/rahal/skills`
- **Date:** 2026-10-08

### PD-06 — Step 0 before every command
- **Decision:** every command first checks config, GitHub, Linear, git and the toolchain as needed; a failure explains itself and asks.
- **Why:** later steps fail confusingly when access is wrong; checking first fails cheaply.
- **Cost if wrong:** a few seconds per command.
- **Where:** `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-08

### PD-07 — start-work runs in three phases with stops
- **Decision:** understand and plan, stop; execute ending in review, stop with findings; ship under the user's choices.
- **Why:** the user decides the plan and the fixes before anything irreversible.
- **Cost if wrong:** two extra prompts per ticket.
- **Where:** `plugins/rahal/skills/start-work/SKILL.md`
- **Date:** 2026-10-08

### PD-08 — Two review passes (superseded by PD-35)
- **Decision:** the ticket-aware reviewer agent first, then Claude Code's `code-review` at high in the main session.
- **Why:** the agent knows the ticket; `code-review` hunts bugs.
- **Cost if wrong:** two runs, and the `code-review` run ignored the chosen model. Superseded by PD-35.
- **Where:** `plugins/rahal/shared/review-model.md`
- **Date:** 2026-10-08

### PD-09 — The review model is suggested and asked per run
- **Decision:** each review suggests a model from the change's size and risk and asks; "always <model>" saves a standing choice; any model may be suggested.
- **Why:** cost and depth are the user's call, and the right model depends on the change.
- **Cost if wrong:** one question per review.
- **Where:** `plugins/rahal/shared/review-model.md`
- **Date:** 2026-10-08

### PD-10 — init asks only commit and GitHub-action choices
- **Decision:** when to commit, commit size, attribution, push, open PR (ready or draft), post comments, re-request review; everything else is fixed behaviour.
- **Why:** fewer knobs keep behaviour predictable across the team.
- **Cost if wrong:** a wanted preference needs a plugin change.
- **Where:** `plugins/rahal/skills/init/references/choices.md`
- **Date:** 2026-10-08

### PD-11 — Accurate commit types
- **Decision:** each commit uses the conventional type that fits it (`feat`, `test`, `fix`, `refactor`, `docs`, `chore`).
- **Why:** the repos' history does, and commitlint checks the shape.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/shared/profiles/orbit.md`
- **Date:** 2026-10-08

### PD-12 — A personal folder per ticket
- **Decision:** outputs go in `<workspace>/<work_folder>/<slug>/`; no command depends on another person's folder.
- **Why:** outputs are working notes, not shared state.
- **Cost if wrong:** a teammate cannot see your brief unless you share it.
- **Where:** `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-08

### PD-13 — pr-followup runs in two phases
- **Decision:** analyse comments into a fix plan, stop for acceptance; then fix, review, draft replies, with remote steps per choices.
- **Why:** the user picks which comments to act on before any change.
- **Cost if wrong:** one extra prompt per follow-up.
- **Where:** `plugins/rahal/skills/pr-followup/SKILL.md`
- **Date:** 2026-10-08

### PD-14 — The README shows each command's output
- **Decision:** the README explains install, init and the workspace layout, and each command with a short real example.
- **Why:** users should know what they get before running a command.
- **Cost if wrong:** none.
- **Where:** `README.md`
- **Date:** 2026-10-08

### PD-15 — "Tasks at a glance" uses 2–4 lines with an example
- **Decision:** briefs and plans summarise each task in 2–4 lines with a concrete example, linked to its detail.
- **Why:** a reader can stop at the overview or drill in.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/shared/templates/plan.md`
- **Date:** 2026-10-08

### PD-16 — A `model=<name>` argument
- **Decision:** review-running commands accept `model=<name>`, answering the model question for that run.
- **Why:** it makes headless runs and one-off choices possible.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/shared/review-model.md`
- **Date:** 2026-10-08

### PD-17 — The plugin does not write a reflector context file
- **Decision:** phase two's "workspace's own steps" defers to the workspace's `CLAUDE.md`.
- **Why:** a workspace with a reflector already asks for it; the plugin should not assume one.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/skills/start-work/references/phase-2-execute.md`
- **Date:** 2026-10-08

### PD-18 — Checks live outside the plugin folder
- **Decision:** `scripts/` and `tests/` sit at the repo root.
- **Why:** users install only `plugins/rahal/`.
- **Cost if wrong:** none.
- **Where:** `scripts/check.sh`
- **Date:** 2026-10-08

### PD-19 — The personal-data scan reads only files git would commit
- **Decision:** `check.sh` section 7 scans `git ls-files --cached --others --exclude-standard`, not the whole tree.
- **Why:** ignored scratch (plan workspaces) holds local paths and is never committed.
- **Cost if wrong:** an ignored file with personal data is not flagged, but it is never committed either.
- **Where:** `scripts/check.sh`
- **Date:** 2026-10-08

### PD-20 — Markdown changes are test-first
- **Decision:** pin new lines in `required-headings.txt`, removed wording in `forbidden-text.txt`, or add a fixture, and watch `check.sh` fail before editing.
- **Why:** the plugin is instructions; without a failing check, a fix can silently regress.
- **Cost if wrong:** a few lines of list maintenance per change.
- **Where:** `scripts/required-headings.txt`, `scripts/forbidden-text.txt`
- **Date:** 2026-10-08

### PD-21 — Guard mutations are restored from a copy
- **Decision:** the guard runner copies each file before mutating it and restores from the copy, never with `git checkout`.
- **Why:** `git checkout` destroyed uncommitted task work and left untracked files mutated.
- **Cost if wrong:** a copy per guard.
- **Where:** `plugins/rahal/skills/start-work/references/phase-2-execute.md`, `tests/probes/guard-runner.sh`
- **Date:** 2026-10-08

### PD-22 — The e2e shim path is quoted inside NODE_OPTIONS
- **Decision:** init records `--require "<path>"`, and commands use `NODE_OPTIONS='<e2e_node_options>'`.
- **Why:** Node splits `NODE_OPTIONS` at spaces; a user folder with a space broke every e2e run.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/skills/init/references/checks.md`
- **Date:** 2026-10-08

### PD-23 — The config check refuses unfilled values
- **Decision:** `check-output.sh config` rejects empty, `""`, `''`, comment-only and `<placeholder>` values.
- **Why:** an unfilled template passed, so the check proved nothing.
- **Cost if wrong:** a config without Linear tools fails the check until Linear is connected.
- **Where:** `scripts/check-output.sh`
- **Date:** 2026-10-08

### PD-24 — Find the ticket folder before making one; branch is feat/<slug>
- **Decision:** an existing `orb-<n>-*` folder is reused; the branch is read from `plan.md` and is `feat/<slug>`.
- **Why:** re-deriving the slug each run broke resume; `feat/orb-<n>-<slug>` doubled the ticket id.
- **Cost if wrong:** several matching folders make the command ask which.
- **Where:** `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-08

### PD-25 — pr-followup records handled comments and resumes
- **Decision:** each fix heading carries its comment id; `Handled:` is appended after replies; routing reads `Accepted:` and `Handled:`.
- **Why:** without ids, a re-run proposed the same fixes again.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/skills/pr-followup/SKILL.md`, `plugins/rahal/shared/templates/followup-plan.md`
- **Date:** 2026-10-08

### PD-26 — One reply file per review comment
- **Decision:** `reply-<date>-<reviewer>-<comment id>.md`, posted into that comment's thread. Departs from the plugin spec's "one file per reviewer".
- **Why:** replies are posted per thread; a per-reviewer file would post every reply into every thread.
- **Cost if wrong:** more small files in the ticket folder.
- **Where:** `plugins/rahal/shared/templates/reply.md`
- **Date:** 2026-10-08

### PD-27 — The main merge stays open until the checks pass
- **Decision:** `git merge --no-ff --no-commit origin/<base>`, then install, regenerate, typecheck and lint, then the titled commit.
- **Why:** without a terminal, `git merge` commits at once with Git's default message.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`, `tests/probes/merge-step.sh`
- **Date:** 2026-10-08

### PD-28 — The PR head is fetched with a force refspec and checked
- **Decision:** `"+pull/<n>/head:refs/remotes/origin/pr-<n>"`, then compare with `headRefOid`.
- **Why:** after a force push, the fetch failed silently and the review read stale code.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/skills/review-pr/references/review-steps.md`, `tests/probes/pr-fetch.sh`
- **Date:** 2026-10-08

### PD-29 — Shipping re-runs step 0 and gh is pinned to the repo
- **Decision:** phase three runs checks 1, 2, 4 and 5; every `gh pr`/`gh repo` command carries `GH_CONFIG_DIR` and `--repo`.
- **Why:** a resumed session could push or comment as the wrong account or on the wrong repo.
- **Cost if wrong:** a few seconds before shipping.
- **Where:** `plugins/rahal/skills/start-work/references/phase-3-ship.md`
- **Date:** 2026-10-08

### PD-30 — Replacing a PR description always asks
- **Decision:** any remote action without its own choice asks every time.
- **Why:** init's choices do not cover it, and overwriting a teammate's edits is not undoable from the plugin.
- **Cost if wrong:** one extra question per follow-up.
- **Where:** `plugins/rahal/shared/approval-gates.md`
- **Date:** 2026-10-08

### PD-31 — A reply waits for its commit to be pushed
- **Decision:** with `post_comments: auto`, a reply citing a commit is posted only after that commit is pushed.
- **Why:** otherwise a public "Fixed in <sha>" pointed at a commit nobody could see.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/shared/approval-gates.md`
- **Date:** 2026-10-08

### PD-32 — corepack enable needs a yes
- **Decision:** init checks `pnpm -v` and `corepack --version`; `corepack enable` is offered only when pnpm is missing.
- **Why:** it writes shims into the global Node install, a change outside the workspace.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/skills/init/references/checks.md`
- **Date:** 2026-10-08

### PD-33 — Step 0 finds renamed Linear tools
- **Decision:** when the recorded prefix fails, step 0 searches for `linear get_issue` and offers to record the new prefix.
- **Why:** connector ids differ per person and can change on reconnect.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-08

### PD-34 — Step 0 handles a clone without a local default branch
- **Decision:** the "behind" count runs only when the local default branch exists.
- **Why:** a docs clone with only feature branches made the command fail.
- **Cost if wrong:** none.
- **Where:** `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-08

### PD-35 — One review pass, on the chosen model
- **Decision:** in all three review steps (start-work phase two, review-pr, pr-followup phase two) the main session starts the reviewer agent once with the chosen model; the agent runs `code-review` itself through the Skill tool (`high review-target`, never `--fix` or `--comment`) and then the ticket checks, returning one list. Supersedes PD-08.
- **Why:** the user asked for one pass; a test showed `code-review` started from an agent runs its helper on that agent's model, so the choice holds.
- **Cost if wrong:** if a Claude Code update changes how skills run inside agents, `code-review` reports "not run" and the review covers ticket checks only.
- **Where:** `plugins/rahal/agents/rahal-reviewer.md`, `plugins/rahal/shared/review-model.md`
- **Date:** 2026-10-09

### PD-36 — code-review runs in a scratch clone (its base: superseded by PD-54)
- **Decision:** the reviewer builds a `git clone --shared` scratch clone with the head as `review-target`, `<base>` set to the fetched `origin/<base>`, and no remote, and runs `code-review` there.
- **Why:** `code-review` compares against the local default branch; with a stale local `main` it reported other people's merged files as the PR's. Without a remote it also needs no `gh`.
- **Cost if wrong:** a few seconds and a little disk per review; the clone is removed after.
- **Where:** `plugins/rahal/agents/rahal-reviewer.md`, `tests/probes/review-clone.sh`
- **Date:** 2026-10-09

### PD-37 — Contributions go through pull requests
- **Decision:** contributors branch and open a pull request into `main`; the maintainer merges, bumps the version and tags.
- **Why:** one person controls what teammates install.
- **Cost if wrong:** the maintainer is a bottleneck for merges.
- **Where:** `AGENTS.md`
- **Date:** 2026-10-09

### PD-38 — AGENTS.md is the contract; CLAUDE.md imports it
- **Decision:** the rules live in `AGENTS.md`; `CLAUDE.md` is the single line `@AGENTS.md`.
- **Why:** the Orbit repos do the same, and teammates using Codex read `AGENTS.md`.
- **Cost if wrong:** none.
- **Where:** `AGENTS.md`, `CLAUDE.md`
- **Date:** 2026-10-09

### PD-39 — The reflector is opt-in per person (curated files: superseded by PD-49)
- **Decision:** the hook is registered in each contributor's own `.claude/settings.local.json`; curated files are committed and raw logs ignored.
- **Why:** nobody pays for a background run each turn unless they choose to, and raw logs never conflict in git.
- **Cost if wrong:** lessons are only captured for contributors who opt in. Committing the curated files is superseded by PD-49; the opt-in hook stands.
- **Where:** `reflector/README.md`, `.gitignore`, `scripts/check.sh`
- **Date:** 2026-10-09

### PD-40 — The reflector never edits the plugin
- **Decision:** it edits notes, docs and 1–3 line `AGENTS.md` promotions; everything else is escalated to the maintainer.
- **Why:** the plugin changes test-first through reviewed pull requests, not from a background agent.
- **Cost if wrong:** small fixes wait for a person.
- **Where:** `.claude/agents/reflector.md`
- **Date:** 2026-10-09

### PD-41 — Docs are distilled; the original spec and plan stay with the maintainer
- **Decision:** `docs/` describes what was built per area, plus this log; the design spec and plans are not copied in.
- **Why:** a long plan the code has moved past would mislead a reader.
- **Cost if wrong:** some original reasoning is summarised, not quoted.
- **Where:** `docs/index.md`
- **Date:** 2026-10-09

### PD-42 — Decision ids are PD-nn
- **Decision:** this log numbers entries `PD-01` upward.
- **Why:** they must never be confused with the Orbit team's `D-0xx` decision log.
- **Cost if wrong:** none.
- **Where:** `docs/decisions.md`
- **Date:** 2026-10-09

### PD-43 — No audit command; check.sh covers alignment
- **Decision:** `check.sh` sections 9–11 check the docs map, the decision log and the opt-in hook; there is no `/audit`.
- **Why:** deterministic checks in the gate run on every change; an audit command runs only when remembered.
- **Cost if wrong:** content drift in docs is caught by review, not by a tool.
- **Where:** `scripts/check.sh`, `tests/probes/check-sections.sh`
- **Date:** 2026-10-09

### PD-44 — The maintainer's account name only in the README
- **Decision:** docs refer to "the repo named in the README" instead of spelling out the account.
- **Why:** `check.sh` keeps account names out of every other file, so personal data cannot spread.
- **Cost if wrong:** one extra click to find the address.
- **Where:** `README.md`, `scripts/check.sh`
- **Date:** 2026-10-09

### PD-45 — Shipped bash blocks get probes
- **Decision:** every bash block Claude runs on a user's machine has a probe in `tests/probes/`, proven once on a broken copy.
- **Why:** three real bugs (guard restore, merge commit, stale fetch) and the stale-base review were found only by running the blocks.
- **Cost if wrong:** a probe to maintain per block.
- **Where:** `tests/probes`, `scripts/test-probes.sh`
- **Date:** 2026-10-09

### PD-46 — Every checkout uses LF line endings
- **Decision:** `.gitattributes` sets `* text=auto eol=lf`.
- **Why:** Git for Windows defaults to `core.autocrlf=true`; Windows line endings made `check.sh` report about 150 false failures in a fresh clone.
- **Cost if wrong:** none; editors on Windows read LF files.
- **Where:** `.gitattributes`, `tests/probes/fresh-clone.sh`
- **Date:** 2026-10-09

### PD-47 — Scripts are recorded executable, and check.sh checks it
- **Decision:** every tracked `*.sh` is stored as mode `100755`; `check.sh` section 12 fails otherwise.
- **Why:** a Windows checkout with `core.filemode=false` committed the scripts non-executable, which breaks the gate on macOS and Linux.
- **Cost if wrong:** none.
- **Where:** `scripts/check.sh`
- **Date:** 2026-10-09

### PD-48 — The personal-data scan covers Git Bash paths and email addresses
- **Decision:** section 7 also matches `/c/…`-style paths and any email address except `example.com` and `git@` remotes; ports other than the maintainer's two remapped ones are left to contributors.
- **Why:** the reflector runs in Git Bash, so a leaked path most likely has that form, and the docs promised email coverage.
- **Cost if wrong:** a legitimate path in prose that starts with a one-letter folder is flagged and must be reworded (this entry's own first draft was).
- **Where:** `scripts/check.sh`, `tests/probes/check-sections.sh`
- **Date:** 2026-10-09

### PD-49 — The reflector's notes and approvals stay on each machine
- **Decision:** `reflector/notes.md` and `reflector/pending-approvals.md` are git-ignored, and the reflector creates them from skeletons on its first run. The hook, the agent and `reflector/README.md` stay committed, so anyone can still opt in. Partly supersedes PD-39.
- **Why:** the maintainer chose to keep the reflector's output out of the repo while keeping the loop available to anyone who opts in; per-person files also never conflict in git.
- **Cost if wrong:** one contributor's lessons and escalations no longer reach others; an escalation that needs the maintainer travels in a pull request instead.
- **Where:** `.gitignore`, `.claude/agents/reflector.md`, `reflector/README.md`, `tests/probes/check-sections.sh`
- **Date:** 2026-10-09

### PD-50 — The ground-truth check also reads the turn's commits
- **Decision:** the context file may list `commits`, the SHAs the turn created. A claimed file counts as present when it is in `git_status_diff`, in one of those commits, or git-ignored; a listed SHA that does not exist is a signal.
- **Why:** a turn that commits its work leaves `git status` empty, so every committed file looked like a false claim (commit 3f091a7: 10 files); ignored files never appear in either place.
- **Cost if wrong:** a session that leaves out `commits` gets the old false signals; a claimed change to an ignored file is never checked; a clean merge commit lists no files in `git show`, so files brought in by a merge are still flagged.
- **Where:** `.claude/agents/reflector.md`, `reflector/README.md`, `scripts/required-headings.txt`
- **Date:** 2026-10-11

### PD-51 — Every change to the plugin bumps its version
- **Decision:** a branch that changes anything under `plugins/rahal/` bumps `version` in `plugin.json`; `check.sh` section 13 fails otherwise, comparing with where the branch left `main`. Of two branches that chose the same number, the later merge takes the next.
- **Why:** sessions load a copy cached per version at install, so the one-pass review (PD-35) never reached real runs while the version stayed 0.1.0; every run on 2026-10-09 to 10-11 still reviewed twice.
- **Cost if wrong:** a version-number conflict when two branches merge, settled by hand at merge.
- **Where:** `scripts/check.sh`, `tests/probes/version-bump.sh`, `AGENTS.md`
- **Date:** 2026-10-11

### PD-52 — Step 0 names the plugin copy and version
- **Decision:** the step 0 header reads `Step 0 — checks · rahal <version> from <plugin root>`, with the version read from the loaded copy's `plugin.json`.
- **Why:** desktop sessions ran a copy cached at install for three days after newer commits landed, and nothing on screen showed it.
- **Cost if wrong:** one longer line at the top of every run.
- **Where:** `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-11

### PD-53 — start-work can stack a ticket on an unmerged blocker's PR
- **Decision:** when a blocker is not merged, phase one looks up its open PR. If the unmerged blockers form one chain of open PRs, it prints the facts and asks "Wait or stack?" with no default answer. Wait stops with nothing written; stack records `**Base:** `<blocker branch>` · stacked on #<PR> (ORB-<n>)` in `plan.md`. Every plan writes its Base line, and `check-output.sh plan` requires it. Two independent open PRs, or an open PR beside a blocker with none, stop with stacking not offered. Phases two and three re-read a stacked PR first: merged into `main` switches the Base line and the Pre-flight start to `main`, says so, and offers to merge `origin/main` into a branch that already exists; merged into another branch, or closed without merging, stops and asks.
- **Why:** ORB-196 needed eight hand-written overrides to stack on an unmerged blocker. The maintainer chose to keep the choice with the user, because only 3 of about 240 team PRs were ever stacked. A branch can start from only one base, so two independent blockers cannot both be stacked on.
- **Cost if wrong:** a ticket whose blockers merge out of order may wait longer than it needs to.
- **Where:** `plugins/rahal/skills/start-work/references/phase-1-understand.md`, `plugins/rahal/shared/step-0-checks.md`, `plugins/rahal/shared/templates/plan.md`, `scripts/check-output.sh`
- **Date:** 2026-10-11

### PD-54 — The review clone diffs against the change's own base
- **Decision:** the reviewer receives the default branch (`<default>`) and the base branch (`<base>`: the PR's `baseRefName`, or the plan's `**Base:**` branch), and its scratch clone sets `<default>` to the fetched `origin/<base>`. Supersedes the part of PD-36 that set the clone's base to the default branch. `AGENTS.md` still comes from `origin/<default>`.
- **Why:** `code-review` compares against the local default branch. With that branch at `origin/main`, every stacked PR, in start-work and in review-pr alike, was also reviewed for its blocker's commits.
- **Cost if wrong:** none for an ordinary PR, where `<base>` and `<default>` are the same branch.
- **Where:** `plugins/rahal/agents/rahal-reviewer.md`, `plugins/rahal/shared/review-model.md`, `plugins/rahal/skills/review-pr/references/review-steps.md`, `tests/probes/review-clone.sh`
- **Date:** 2026-10-11

### PD-55 — One stack notice, warning against "merge stack"
- **Decision:** a stacked PR's body opens with the notice in `shared/stack-notice.md`: merge the blocker alone, let GitHub move this PR to `main`, merge `origin/main` in, run `pnpm openapi`, and never use GitHub's "merge stack" button. start-work adds it, and removes it once the blocker has merged. The text lives once, so pr-followup can use the same file.
- **Why:** "merge stack" rebased a stacked PR and dropped the merge commit holding the regenerated `openapi/admin.json`.
- **Cost if wrong:** one paragraph at the top of a rare kind of PR.
- **Where:** `plugins/rahal/shared/stack-notice.md`, `plugins/rahal/skills/start-work/references/phase-2-execute.md`
- **Date:** 2026-10-11

### PD-56 — The ticket is saved word for word; changes are judged by its text
- **Decision:** start-work phase one saves `ticket-<date>.md` (id, title, status, `updatedAt`, the full description and every comment, never summarised) in the ticket folder. review-pr compares the current description with the latest saved copy, never with `updatedAt` alone.
- **Why:** any comment, including our own, moves `updatedAt`, so "updated after the PR opened" was true on every PR we had commented on. A summary cannot show what a reviewer reworded.
- **Cost if wrong:** one more file per ticket; a PR whose ticket was never saved can only report that the change cannot be checked.
- **Where:** `plugins/rahal/skills/start-work/references/phase-1-understand.md`, `plugins/rahal/skills/review-pr/references/review-steps.md`
- **Date:** 2026-10-11

### PD-57 — gh-only commands are pinned; git and shell logic gets probes (refined by PD-80)
- **Decision:** a new or changed bash block with git or shell logic gets a probe, proven once on a broken copy. A gh-only command (a lookup, `gh pr create`, a `--jq` read) is pinned word for word in `scripts/required-headings.txt`. Shell logic around gh output, such as the open-PR overlap filter, is probed with a stand-in `gh`. Refines PD-45.
- **Why:** a probe cannot reach GitHub, and jq is not installed on every contributor's machine, so a stand-in `gh` would only re-check the same text a pin checks. The maintainer chose pins for gh lines on 2026-10-11.
- **Cost if wrong:** a wrong `--jq` filter or gh field shows up only in a dry run against a real PR.
- **Where:** `AGENTS.md`, `scripts/required-headings.txt`, `tests/probes/overlap-prs.sh`
- **Date:** 2026-10-11

### PD-60 — The follow-up checkout fast-forwards from the PR's branch by name
- **Decision:** phase two fetches, switches to `<headRefName>`, fast-forwards only from `origin/<headRefName>` and only while that branch is checked out, then stops unless `HEAD` equals `headRefOid`, naming both branches. `pull --ff-only` is forbidden text.
- **Why:** `git pull` follows the checkout's upstream. On 2026-10-10 a follow-up on a stacked PR moved the blocker's branch onto the stacked PR's commit; a branch made from a blocker's branch can also track it and never reach its own head.
- **Cost if wrong:** a local branch holding unpushed commits stops the run instead of continuing; the user pushes or resets it first.
- **Where:** `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`, `tests/probes/pr-checkout.sh`, `scripts/forbidden-text.txt`
- **Date:** 2026-10-11

### PD-61 — A stacked PR's follow-up reads main's rules and names its blocker
- **Decision:** when a PR's base is not the default branch, phase one finds the blocker's PR by its head branch, states "stacked on #<n> (<state>, head <sha7>)", and diffs `AGENTS.md` and the PR template from the stack's merge-base with `origin/<default>` as well as with `origin/<base>`. The merge commit, PR body and reply name the real base; its title is `chore(ORB-<n>): merge orb-<blocker n> into the <branch words> branch`.
- **Why:** the standard lives on the default branch, which the blocker's branch may not have merged; the full base branch name made the title 98 characters for ORB-196, over the 72-character limit (the maintainer's choice, decision 4 of the feature batch).
- **Cost if wrong:** a rule added to `main` after the stack branched off is missed until the blocker merges; a title with the blocker's id hides which branch was merged until the PR body is read.
- **Where:** `plugins/rahal/skills/pr-followup/references/phase-1-analyse.md`, `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`, `plugins/rahal/shared/templates/followup-plan.md`, `plugins/rahal/shared/profiles/orbit.md`, `tests/probes/stacked-rules.sh`
- **Date:** 2026-10-11

### PD-62 — A PR whose blocker merged is retargeted before its branch update
- **Decision:** when the blocker's PR is merged but this PR's base is still the blocker's branch, item 0 becomes "retarget to the default branch, then merge it". The local merge uses `origin/<default>`; `gh pr edit --base <default>` runs in the remote steps before the push and always asks. Every branch update then checks that `git diff origin/<base> -- openapi/` shows only this ticket's own changes.
- **Why:** GitHub retargets a stacked PR only when the merged branch is deleted, and merging the old base then brings nothing; a regenerated document that lost or gained another ticket's paths is the symptom of the "merge stack" loss.
- **Cost if wrong:** one extra question per retarget; a ticket that legitimately removes a path explains it at the stop.
- **Where:** `plugins/rahal/skills/pr-followup/references/phase-1-analyse.md`, `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`, `plugins/rahal/shared/templates/followup-plan.md`
- **Date:** 2026-10-11

### PD-63 — Regenerated API documents stay in the merge commit
- **Decision:** PD-27 stands: the branch update regenerates `openapi/*.json` and commits it inside the titled merge commit, not in a commit of its own. Protection against a rebase dropping them comes from the stack notice and the `openapi/` diff check (PD-62).
- **Why:** measured on 2026-10-11 with the backend's lefthook 2.1.14 and its exact `openapi` job (a stand-in generator in place of `pnpm openapi`): a merge that brings in a controller stages it, the job runs during the merge commit, and `git add openapi/` folds the regenerated file in even when the old version was staged. A separate commit would need `--no-verify` (the maintainer's choice, decision 3 of the feature batch).
- **Cost if wrong:** a rebase of the stacked PR, such as GitHub's "merge stack", drops the regenerated lines with the merge commit; the stack notice forbids that button.
- **Where:** `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`, `tests/probes/merge-step.sh`
- **Date:** 2026-10-11

### PD-64 — A stacked PR's body warns against "merge stack"
- **Decision:** one shared text, `shared/stack-notice.md`, goes at the top of a stacked PR's body: merge the blocker alone, let GitHub retarget, merge `origin/main` in and run `pnpm openapi`, never use "merge stack". `pr-followup` phase two adds it to the PR body and removes it once the PR is retargeted.
- **Why:** GitHub's "merge stack" rebased a stacked PR and dropped the merge commit holding its regenerated `openapi/admin.json`; that commit cannot be split off (PD-63), so the warning has to reach whoever presses the button.
- **Cost if wrong:** one paragraph of PR body to read and delete; a reviewer who ignores it still loses the regenerated lines.
- **Where:** `plugins/rahal/shared/stack-notice.md`, `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`
- **Date:** 2026-10-11

### PD-65 — The follow-up explains each comment with before, now and a dry run
- **Decision:** each glance entry adds `In plain words:` and `Example:` (someone does X → sees Y today → would see Z after). Each fix block gives Before this PR (the code on `origin/<base>`), Now (the code at the PR head), What they raised, How checked, Ticket, Fix we should apply, Dry run, Alternative and Reply draft, sharing labels with the review report. `check-output.sh followup` checks every entry and block from 1 up, and that no reply draft names another PR.
- **Why:** the old four-string check passed a report whose second comment had no explanation, and a reader could not tell what the reviewer reacted to without opening the diff. Before means the base and the fix has its own field (the maintainer's choice, decision 5 of the feature batch).
- **Cost if wrong:** a longer report per comment; a one-line nit still needs a dry run to pass the check.
- **Where:** `plugins/rahal/shared/templates/followup-plan.md`, `plugins/rahal/skills/pr-followup/references/phase-1-analyse.md`, `scripts/check-output.sh`, `tests/fixtures/good-followup.md`
- **Date:** 2026-10-12

### PD-66 — The follow-up compares the ticket's text, not its update time
- **Decision:** phase one compares the ticket's description word for word with the latest `ticket-<date>.md` in the ticket folder and reports what changed; without that file it says the text could not be compared. It never judges by `updatedAt`.
- **Why:** `updatedAt` moves whenever anyone comments on the ticket, our own runs included, so "changed after the PR opened" was true for every ticket.
- **Cost if wrong:** a ticket folder made before start-work saved the ticket gets no ticket check until a copy exists.
- **Where:** `plugins/rahal/skills/pr-followup/references/phase-1-analyse.md`, `plugins/rahal/shared/templates/followup-plan.md`
- **Date:** 2026-10-12

### PD-67 — Drafted comments state the issue plus an example only
- **Decision:** every comment the plugin drafts on a teammate's PR states the issue plus one concrete example, and the author chooses the fix: no `suggestion` block, no proposed fix, no @-mention, no should or must, no other PR or commit. An anchor outside the diff becomes a conversation comment naming the file and line. Follow-up replies never carry a `suggestion` block or proposed code either. `check-output.sh` refuses a `suggestion` block in a review's drafted comments, in a reply, and in a follow-up's reply drafts; a reviewer's own suggestion quoted under What they raised is allowed.
- **Why:** comment style is a team convention once the plugin is shared, and the maintainer chose this style for everyone (decision 8 of the feature batch), closing the reflector approval of 2026-10-09.
- **Cost if wrong:** a one-line fix the author could have applied with a click now needs typing; reviewers who want to propose code write it by hand.
- **Where:** `plugins/rahal/shared/templates/review-report.md`, `plugins/rahal/skills/review-pr/references/review-steps.md`, `plugins/rahal/shared/templates/reply.md`, `plugins/rahal/shared/templates/followup-plan.md`, `scripts/check-output.sh`

### PD-70 — A fifth command, /rahal:plan-tickets, that only reads
- **Decision:** `/rahal:plan-tickets` suggests a pick order, lanes, stack candidates and cross-owner blockers for your open tickets in one project. Its only tools are Linear `list_issues` and `get_issue` and `gh --version`, `gh auth status` and `gh pr list`, pinned as one line in its `SKILL.md`. Extends PD-05's command list.
- **Why:** the maintainer asked for a way to plan what to pick, what can run in parallel and who to work with, without anything changing in Linear or GitHub.
- **Cost if wrong:** a fifth name to learn; the name was chosen over `/rahal:queue` and `/rahal:next`.
- **Where:** `plugins/rahal/skills/plan-tickets/SKILL.md`, `scripts/required-headings.txt`
- **Date:** 2026-10-12

### PD-71 — No argument; it asks from the projects that hold your open tickets
- **Decision:** the command takes no argument. Every run lists only the projects holding your open tickets, each with its count, and waits for a pick.
- **Why:** the maintainer chose to be asked every time; projects with none of your tickets would give an empty queue.
- **Cost if wrong:** one round trip per run.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-12

### PD-72 — Its step 0 variations live in its own SKILL.md
- **Decision:** plan-tickets runs checks 1–3 with differences written in its own `SKILL.md`: no `gh repo view`, Linear proven by listing your tickets, checks 4–5 printed as not needed. `shared/step-0-checks.md` is unchanged.
- **Why:** step 0 is written around one ticket and one repo; editing it for a command with neither would complicate it for the other four, and another branch was editing it at the same time.
- **Cost if wrong:** a later change to step 0 must be checked against this variant by hand.
- **Where:** `plugins/rahal/skills/plan-tickets/SKILL.md`
- **Date:** 2026-10-12

### PD-73 — Open tickets only, links only, never descriptions
- **Decision:** the status-and-owner table comes from four `list_issues` calls, one per open status kind. Links come from `get_issue` with `fields: [id, relations]` for your open tickets and up to 25 of their blockers owned by others. No call reads a description.
- **Why:** all 238 ORB tickets came to about 51 KB, too large to read inline, against about 5 KB for the 45 open ones. One description was about 66,000 characters, and asking for it overflowed the call and lost the ticket's links.
- **Cost if wrong:** the "Pick order N of M" lines in descriptions are not used; in the tickets checked they repeated existing links.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-12

### PD-74 — How the pick order is built
- **Decision:** predecessors come first, through any chain of blocking links, including through other people's tickets. Among tickets ready at the same time, ties go by: On Hold after the rest, then tickets that don't wait on someone else before those that do, unblocks the most, priority, ticket number. Tickets that can't be placed go under "Can't order" with the reason.
- **Why:** tickets carry no estimates or due dates, and many have no priority, so links and how much each ticket unblocks are the only real signals. The maintainer chose "unblocks" ahead of priority.
- **Cost if wrong:** a high-priority ticket nobody waits on can sit below one that unblocks others.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-12

### PD-75 — ORB's status meanings
- **Decision:** QA Staging and QA UAT count as merged and do not block; Code Review and Rework block; On Hold is parked: placed after the other tickets ready at the same time, and never marked start now; Duplicate is closed. A status not in the table is read by its kind and named in Data gaps.
- **Why:** Linear's status kinds put QA, Rework and Code Review all under "started" and On Hold under "unstarted", which would sink tickets behind merged work and rank parked tickets first.
- **Cost if wrong:** a ticket that fails QA and goes back is treated as unblocking its dependents until its status changes.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-12

### PD-76 — Stacking uses start-work's rule and hands off to it
- **Decision:** a ticket can stack when each blocker has exactly one open PR in the ticket's repo and those PRs form one chain; the candidate tells you to run `/rahal:start-work` and answer **Stack** at its "Wait or stack?" question. It is never the default, and every entry gives the waiting recommendation first. plan-tickets merges after start-work's stack support.
- **Why:** only 3 of about 240 code PRs ever had a non-`main` base, so stacking is an option, not a habit; using start-work's rule keeps the two commands from disagreeing.
- **Cost if wrong:** if start-work's question is reworded, the hand-off line goes stale; it is pinned so the gate shows where to change it.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`, `scripts/required-headings.txt`
- **Date:** 2026-10-12

### PD-77 — Parallel work is shown as lanes
- **Decision:** your tickets are grouped into lanes joined by predecessor chains, with each startable ticket marked. Every queue says which files a ticket touches is unknown until start-work. Backend lanes get the `openapi/admin.json` conflict caveat. Tickets related across lanes are named.
- **Why:** lanes show what can run side by side beyond today; the caveats cover what Linear links can't.
- **Cost if wrong:** two lanes may still touch the same files.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-12

### PD-78 — Other people's tickets: matched by id, suggestions in text
- **Decision:** owners are matched by `assigneeId`. Each blocker owned by someone else gets one suggestion, most specific first: can't help yet, help review its PR, ask about timing and pair, pick it up if unowned, or take it on together. Nothing is reassigned, commented or messaged.
- **Why:** `assignee` is a name for some people and an email for others; the maintainer asked that a teammate's blocker suggest working on it together.
- **Cost if wrong:** a suggestion may not fit the team's situation; it is text only.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-12

### PD-79 — Nothing is saved unless you choose; the output and the gh line are tested
- **Decision:** the queue is shown in chat and saved only on request, whole or by lanes, with an existing file asking replace or keep both. A saved file is checked by `check-output.sh queue`. The shipped `gh pr list` line is run by a probe against a stand-in `gh`.
- **Why:** a queue is a suggestion; the probe follows PD-45 without needing GitHub.
- **Cost if wrong:** the probe can't catch a misspelled JSON field; a manual live check in the testing doc covers that.
- **Where:** `plugins/rahal/shared/templates/ticket-queue.md`, `scripts/check-output.sh`, `tests/probes/pr-list.sh`
- **Date:** 2026-10-12

### PD-80 — A gh line with arguments that could break in the shell also gets a probe
- **Decision:** a gh-only line stays pinned word for word (PD-57); when its arguments could break in the shell, such as a config folder path with spaces or a quoted search, it also gets a probe with a stand-in `gh` that checks every argument arrives whole. plan-tickets' `pr-list` probe is the first.
- **Why:** a pinned line proves only that the text did not change, not that the shell hands `gh` the path in one piece; the maintainer kept the `pr-list` probe on that ground.
- **Cost if wrong:** one more small probe per such line to maintain.
- **Where:** `AGENTS.md`, `docs/checks.md`, `tests/probes/pr-list.sh`
- **Date:** 2026-10-14

### PD-81 — The instruction is a quoted string after the link
- **Decision:** start-work, review-pr and pr-followup take `<link> [model=<name>] ["<instruction>"]`, and plan-tickets takes `["<instruction>"]`. Text after the link that is neither `model=` nor quoted is read as the instruction too, and the run says so. Each `argument-hint` is a YAML single-quoted string.
- **Why:** the quotes mark where the instruction starts and ends, so a `model=` or a `#169` inside it is not taken for an argument, and reading unquoted text anyway keeps a forgotten quote from costing a re-run. The maintainer chose this over "everything after the link" and `note="…"`. `claude plugin validate --strict` fails the hint written in double quotes ("YAML frontmatter failed to parse") and passes it in single quotes.
- **Cost if wrong:** an instruction that itself holds a double quote is cut short; the read-as list shows where.
- **Where:** `plugins/rahal/shared/instructions.md`, `plugins/rahal/skills/start-work/SKILL.md`, `plugins/rahal/skills/review-pr/SKILL.md`, `plugins/rahal/skills/pr-followup/SKILL.md`, `plugins/rahal/skills/plan-tickets/SKILL.md`
- **Date:** 2026-10-14

### PD-82 — Three tiers decide what an instruction can change
- **Decision:** one shared file, `shared/instructions.md`. Never overridden: the fixed rules and stops in `approval-gates.md`, `evidence.md`, step 0, each template's headings, lines and drafting rules, the repo's `AGENTS.md`, the account, ports and gh folder, and plan-tickets' read-only rule. Overridden for one run after a question: `choices.*`, the profile's practice, a decided plan decision, a departure from the ticket. Applied without asking: wording, length, focus and extra checks. When unsure, the stricter tier wins. A line that no step does is reported as ignored, never turned into a new step. The reviewer agent receives the focus and extra checks, which add to its checks and never loosen one.
- **Why:** the maintainer asked that each round adapt to its own requirements and that the run ask only when a conflict arises; the tiers keep the safety rules and the checked outputs out of an instruction's reach.
- **Cost if wrong:** a line put in too loose a tier is applied without a question; the read-as list shows each line's tier before anything runs.
- **Where:** `plugins/rahal/shared/instructions.md`, `plugins/rahal/shared/review-model.md`, `plugins/rahal/agents/rahal-reviewer.md`
- **Date:** 2026-10-14

### PD-83 — A conflict is one question: Now, You asked, It would, Options, Recommend
- **Decision:** conflicts are asked one at a time in that shape: at the start when they can be known then, otherwise at the step they touch. A never-overridden rule offers only "do the rest without it" or "stop" and names the rule. A saved choice also offers "save as my choice", which writes `choices` in `.claude/rahal.local.md` after a yes.
- **Why:** the maintainer asked to be shown the current situation, what the request would do, and options, and only when a conflict arises.
- **Cost if wrong:** a conflict that shows only at its step interrupts a long phase; a headless run prints it and stops.
- **Where:** `plugins/rahal/shared/instructions.md`
- **Date:** 2026-10-14

### PD-84 — An instruction can answer a command's question; the facts are still shown
- **Decision:** an instruction may answer a question the command would ask, such as the project, "Wait or stack?", the review model or an open plan decision. The run prints the facts the question would show, then `Answered by your instruction: <answer>`, and carries on. The fixed stops (after planning, after the fix plan, before fixing review findings) are not such questions.
- **Why:** the maintainer's choice; `model=` already answered the review-model question this way, and the stop after planning still lets the person change the answer before any code runs.
- **Cost if wrong:** a stack answered in advance writes the plan on the blocker's branch; the brief stop shows it before execution.
- **Where:** `plugins/rahal/shared/instructions.md`, `plugins/rahal/skills/start-work/references/phase-1-understand.md`, `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-14

### PD-85 — Every output records the instruction on a checked `Instruction:` line
- **Decision:** `brief.md`, `plan.md`, `followup-<date>.md`, `review-<date>.md` and a saved ticket queue carry an `Instruction:` line holding the instruction as typed or `none`. `check-output.sh` kinds `brief`, `plan`, `review`, `followup` and `queue` fail without it or with an unfilled placeholder. A conflict's answer goes under the plan's Decided in start-work phase one, then into `ledger.md` as `Instruction: Ruling: …`, or as `· ruled: …` on the line in review-pr and plan-tickets, which keep no ledger.
- **Why:** an instruction followed once is lost when the run resumes. The plan named the plan and follow-up files; `AGENTS.md` §3 ties every template change to its check, so the brief, review and queue lines are checked too.
- **Cost if wrong:** one more header line in every output.
- **Where:** `plugins/rahal/shared/templates/brief.md`, `plugins/rahal/shared/templates/plan.md`, `plugins/rahal/shared/templates/followup-plan.md`, `plugins/rahal/shared/templates/review-report.md`, `plugins/rahal/shared/templates/ticket-queue.md`, `plugins/rahal/shared/templates/ledger.md`, `scripts/check-output.sh`
- **Date:** 2026-10-14

### PD-86 — Re-runs keep the recorded instruction; a new follow-up round carries it over
- **Decision:** a run with no instruction keeps the recorded one; a different one shows both and asks add, replace or ignore; `"none"` clears it without asking. start-work reads the plan's line in every phase. pr-followup reads the latest `followup-*.md`'s line, in a new round too, and says it was carried over. review-pr and plan-tickets start fresh on every run.
- **Why:** the maintainer chose carrying over into the next round over starting fresh or asking each time. review-pr and plan-tickets have no resume or rounds, and the ticket folder's `review-*.md` files also come from start-work's and pr-followup's internal reviews, so reading one back would mix commands. `"none"` is the one way to drop a carried instruction without a question.
- **Cost if wrong:** a stale carried instruction ("merge the blocker branch first" after the blocker merged) reaches the next round; its read-as line names it, and the re-check at its step asks.
- **Where:** `plugins/rahal/shared/instructions.md`, `plugins/rahal/skills/start-work/SKILL.md`, `plugins/rahal/skills/pr-followup/SKILL.md`
- **Date:** 2026-10-14

### PD-87 — `model=` is recorded as `Model:`, so a resumed run stops asking
- **Decision:** `model=<name>` is recorded as `Model:` beside the Instruction line in `plan.md` and `followup-<date>.md` (`ask` when none was given). `review-model.md` skips the question when a model is given now or recorded for the ticket; a new `model=` replaces the recorded one. The old wording "(that run only)" is forbidden.
- **Why:** start-work asked for the model again when phase two resumed in a new session.
- **Cost if wrong:** a model chosen in phase one is reused much later; a new `model=` changes it.
- **Where:** `plugins/rahal/shared/review-model.md`, `plugins/rahal/shared/templates/plan.md`, `plugins/rahal/shared/templates/followup-plan.md`, `scripts/forbidden-text.txt`
- **Date:** 2026-10-14

### PD-88 — plan-tickets takes an instruction too
- **Decision:** `/rahal:plan-tickets ["<instruction>"]`. An instruction can name the project, which answers step 2's question with the list still shown, and narrow or focus the queue; the tickets it leaves out are named in Data gaps. The command's read-only rule is never overridden. The old sentence "plan-tickets takes no arguments" is forbidden.
- **Why:** the maintainer's choice: planning a queue has per-run needs too, such as "only the Visas project; skip On Hold".
- **Cost if wrong:** a filter hides a ticket the person needed; Data gaps names every ticket left out.
- **Where:** `plugins/rahal/skills/plan-tickets/SKILL.md`, `plugins/rahal/skills/plan-tickets/references/queue-steps.md`, `plugins/rahal/shared/templates/ticket-queue.md`
- **Date:** 2026-10-14

### PD-89 — Releases ship from the private GitHub repo
- **Decision:** `main` and each `rahal--v<version>` tag are pushed to the private repo named in `README.md`'s Install section, and every install, the maintainer's included, comes from that marketplace; local working branches are not pushed. Contributors open pull requests into `main`; the maintainer merges, tags and pushes the tag. Unreleased edits are tried with `--plugin-dir`. Builds on PD-02 and PD-37.
- **Why:** a local-folder install reaches only the maintainer and loads a copy cached at install time, so teammates could not get a release at all, and the maintainer's own sessions lagged without anyone seeing it.
- **Cost if wrong:** each teammate needs an invite and a git login with access; the maintainer's install now depends on a push before a change reaches their sessions.
- **Where:** `README.md`, `docs/testing-and-release.md`
- **Date:** 2026-10-15

### PD-90 — One config, repos grouped by family
- **Decision:** `.claude/rahal.local.md` has no `profile:` key. It lists one block per repo family under `families:` (`orbit`, `corporate`), each with its `repos`, `docker_ports`, `dev_database_url_port` and `e2e_node_options`; `toolchain.bash_node_path`, `github`, `linear` and `choices` stay shared. Step 0 reads the routed family's values; a bare `<dev_database_url_port>` means that family's. An old single-profile file stops at step 0 with "run `/rahal:init` here", rather than being read as Orbit.
- **Why:** the maintainer combined the Orbit and corporate workspaces into one, worked by one Claude, so one config must hold six repos and two sets of ports (Orbit's move off the corporate ones, which are fixed). Grouping by family keeps each port and shim beside the repos it belongs to; reading the old shape as well would leave step 0 carrying two shapes indefinitely.
- **Cost if wrong:** every placeholder carries one more level; an Orbit-only workspace must re-run init once after updating the plugin.
- **Where:** `plugins/rahal/skills/init/references/config-template.md`, `plugins/rahal/shared/step-0-checks.md`, `scripts/check-output.sh`
- **Date:** 2026-10-28

### PD-91 — GF tickets go through the plugin, always corporate
- **Decision:** each profile lists its Linear teams (`orbit.md`: ORB; `corporate.md`: ORB and GF). Step 0 accepts a ticket whose team a configured family lists; a `GF-` ticket always routes to a corporate repo. `ORB-<n>` throughout the plugin stands for the ticket's id, whatever its team, and `orb-<n>` for its lower-case form, so a GF ticket's folder is `gf-<n>-…`.
- **Why:** the maintainer chose to run the old corporate work (open GF pull requests, new GF bugs) through the same commands; no GF ticket targets an Orbit repo, so its family is fixed.
- **Cost if wrong:** plan-tickets reads GF statuses by their kind only (the status table is ORB's).
- **Where:** `plugins/rahal/shared/profiles/corporate.md`, `plugins/rahal/shared/step-0-checks.md`, `plugins/rahal/skills/plan-tickets/references/queue-steps.md`
- **Date:** 2026-10-28

### PD-92 — Each command reads the routed family's profile and its Commands table
- **Decision:** both profiles carry the same Commands table (install, generate, services, migrate, new migration, unit file, e2e file, typecheck, lint, gate, gate counts, regenerate, generated files, hooks), one column per repo. The skills name a row in bold (the **gate**) instead of a hard-coded `pnpm` command, and every `SKILL.md` loads the profile of the family step 0 routed to.
- **Why:** the corporate backend runs npm and Jest, its gate includes the e2e suite, the app regenerates a different file, and the corporate dashboard has no gate at all; a shared table keeps each command in one place per family instead of branching in every step.
- **Cost if wrong:** a step that names a row the profile leaves as `—` must say so; the guard runner's record now keeps jest's lines beside vitest's.
- **Where:** `plugins/rahal/shared/profiles/orbit.md`, `plugins/rahal/shared/profiles/corporate.md`, `plugins/rahal/skills/start-work/references/phase-2-execute.md`, `plugins/rahal/skills/pr-followup/references/phase-2-fix.md`
- **Date:** 2026-10-28

### PD-93 — Step 0 picks the repo from the ticket; with none named, an ORB ticket is Orbit's
- **Decision:** step 0's "The ticket's repo" takes the first rule that answers: the PR link; a repo the ticket names in Context, Done When or Sources (folder, link, or a default branch only one repo has, such as `corporate`); the team when only one family lists it (`GF-` → corporate), else orbit; the title tag within the family; ask. It prints a `Route` line saying why, and the brief repeats it. A bare PR number asks the repo when two families are configured.
- **Why:** ORB tickets serve both families (the Corporate Airport Services project is in team ORB), so the prefix cannot decide; the integration tickets name their repo. The maintainer chose the Orbit default for an ORB ticket naming none, so Orbit's own tickets gain no question; phase one's stop at the brief catches a wrong route before any code runs.
- **Cost if wrong:** a corporate ORB ticket that names no repo plans against an Orbit repo until the brief's Repo line is read.
- **Where:** `plugins/rahal/shared/step-0-checks.md`, `plugins/rahal/shared/templates/brief.md`
- **Date:** 2026-10-28

### PD-94 — Orbit's process wins in corporate repos, except a check the repo runs
- **Decision:** the corporate profile's branch practice is Orbit's (`feat/<slug>` branches, a titled merge commit to update a branch, never rebase or force push). The commit scope follows each repo's own check: `ORB-<n>` in the backend, which has no commitlint, and `orb-<n>` in the app and the dashboard, whose commitlint has `scope-case: lower-case`.
- **Why:** the maintainer set Orbit's rules as the base of the combined workspace; a repo's own check binds, and weakening a check is forbidden.
- **Cost if wrong:** corporate history mixes `ORB-` and `orb-` scopes; the backend `AGENTS.md`'s allowance for a force push with the owner's word is not used.
- **Where:** `plugins/rahal/shared/profiles/corporate.md`
- **Date:** 2026-10-28

### PD-95 — plan-tickets reads each description and routes with step 0's rule
- **Decision:** plan-tickets reads each of your tickets in the chosen project with `get_issue(fields: [id, description])`, one ticket per call and never in parallel, checks the `id` of a result Linear saved to a file, and picks the repo with step 0's "The ticket's repo" items 2 to 4; item 5 (ask) becomes "repo unknown". A failed read falls back to the team and the title tag. The earlier guess from open PRs is gone, and the rule is referenced, never copied.
- **Why:** the maintainer asked for it before release: without the description, every corporate ORB ticket with no PR yet (ORB-781 to ORB-791 in Corporate Airport Services) was planned under the Orbit repos. A description asked for alone fits the call or is saved to a file; asked for with other fields it overflowed and lost them, which is why the old rule said never to ask for it.
- **Cost if wrong:** one Linear call per ticket, made in sequence, so a large project takes longer to plan.
- **Where:** `plugins/rahal/skills/plan-tickets/references/queue-steps.md`, `plugins/rahal/shared/step-0-checks.md`
- **Date:** 2026-10-28
