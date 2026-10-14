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

### PD-36 — code-review runs in a scratch clone
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
