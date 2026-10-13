# rahal — Claude Code plugin for the Orbit team

`rahal` turns a Linear ticket or a GitHub pull request link into the Orbit team's way of working:
- understand the ticket against the real code, and plan it test-first;
- execute it with evidence;
- review it against the ticket and `AGENTS.md`;
- ship it;
- handle reviewers' comments.
- plan which of your tickets to pick next, what can run in parallel, and what could start early on a stacked PR.

Every command stops at the points where you decide, and nothing reaches GitHub unless your choices allow it.

Commands: `/rahal:init` · `/rahal:start-work <ticket>` · `/rahal:review-pr <PR>` · `/rahal:pr-followup <PR>` · `/rahal:plan-tickets`. Orbit (`ORB-`) tickets only for now.

## Install

A **marketplace** is a small catalog file that tells Claude Code's `/plugin install` where a plugin lives. This repo is both the catalog and the plugin. It is private, so ask the owner for collaborator access first.

In Claude Code:

```
/plugin marketplace add rahal-dhruv/rahal-claude-plugin
/plugin install rahal@rahal-claude-plugin
```

If you use several GitHub accounts through SSH aliases, add it by your alias address instead, for example `/plugin marketplace add git@<alias>:rahal-dhruv/rahal-claude-plugin.git`. A plain `github.com` address may sign in as your other account.

To try a local copy without installing: `claude --plugin-dir <path to this repo>/plugins/rahal`.

## How /rahal:init works

Run it once in your workspace folder (the folder holding the Orbit repos), and again whenever you want to change an answer.
1. **Workspace:** finds `rahal-orbit-backend`, `rahal-orbit-dashboard` and `rahal-orbit-docs`, and offers to clone any that are missing.
2. **GitHub:** checks `gh` is installed and signed in, which account, and that it can read the repos. If you keep a separate gh config folder for this account, tell it where.
3. **Linear:** finds the Linear tools your Claude has and reads one ticket to prove they work. If none, it tells you how to connect Linear; Claude cannot sign in for you.
4. **Toolchain:**
   - checks Node against the repo's `.nvmrc`, pnpm and Docker;
   - moves Orbit's Postgres and Redis ports if another project holds them;
   - on Windows, finds the Node folder Git Bash needs and writes the small e2e test shim.
5. **Extras:** offers to install the superpowers plugin (recommended, not required).
6. **Your choices.** Two questions, with defaults you can keep:
   - **commits:** when to commit (ask each time / once per ticket / never), commit size, attribution;
   - **GitHub actions:** push, open the PR (ready or draft), post comments and replies, re-request review. Each is "ask me" or "do it automatically".
7. **Writes** `<workspace>/.claude/rahal.local.md`, your personal settings. It never goes into any repo. Edit it or re-run `init` to change it.

The review model is not asked here. Each review suggests one with a reason, and you choose. Say "always <model>" to stop being asked.

## Suggested workspace layout

```
<workspace>/                        not a git repo
  .claude/rahal.local.md            written by /rahal:init
  rahal-orbit-backend/  rahal-orbit-dashboard/  rahal-orbit-docs/
  work/
    orb-183-visa-destinations/      one folder per ticket, yours only
      brief.md  plan.md  ledger.md  pr-body.md
      review-2026-10-07.md  followup-2026-10-08.md  reply-2026-10-08-amr-2417.md
    ticket-queue/                   saved ticket queues, only when you ask
  docs/                             optional notes on what was built
```

## /rahal:start-work

`/rahal:start-work https://linear.app/digitalzone/issue/ORB-183/...` runs in three phases, each ending in a stop.

**Phase one — understand and plan.** It reads the ticket, its related tickets and comments, checks every file the ticket names against GitHub's `main`, measures library behaviour the ticket relies on, and writes `brief.md` and `plan.md`. In chat you get:

```
ORB-183 — Add visa destinations with their admin routes   (Todo · Visas › Visa catalog setup)

What it asks for
  BD and ops need a list of countries Orbit sells visas to … e.g. POST { countryCode: 'AE' } answers 201,
  a second one answers 409 "already exists".
Where it sits     Blocked by ORB-176 (merged). Unblocks ORB-184 and ORB-185.
What I checked    main moved 2 commits, none touching the ticket's files. Drift: a fourth suite deletes every country.
The plan at a glance
  Task 3 — list, read, create, update, delete. A second POST for AE answers 409; ZZ answers 400
  "No live country holds this code."
Decision 1 of 2 — the storage comment's "that prefix" goes stale. Recommend: "those prefixes".
```

You answer each decision. It updates the plan, then asks "Ready to execute?".

**Phase two — execute.**
- **Each task:** branch, test first (it watches each test fail, then pass), commits per your choices, and the ledger records every step.
- **After the last task:**
  - the full `pnpm check`;
  - breaking each key guard once to prove a test catches it;
  - the PR body from the repo's template;
  - one review pass: the `rahal-reviewer` agent, on the model you pick, runs Claude Code's `code-review` and checks the change against the ticket.
- **Then it stops** with the findings at a glance and in detail, and you choose which to fix.

**Phase three — ship.** Push, open the PR and read CI once, each per your choices.

Re-run the command with the same link to resume; it continues from the ledger.

## /rahal:review-pr

`/rahal:review-pr https://github.com/DigitalZoneApp/rahal-orbit-backend/pull/147` reviews the PR at its head commit without touching your checkout, and writes `review-<date>.md`:
1. what the ticket is trying to solve;
2. what the PR does, step by step, each with an example;
3. **issues at a glance**, in plain words:
   ```
   Verdict: ready with fixes — 1 blocking, 2 should fix.
   1. Blocking — the search can't find a destination by the name shown on screen.
      Example: the list shows "Dubai", but typing "dub" finds nothing.
   ```
4. **issues in detail:** where, what's going on, impact, example, a dry run with real values, how it was checked, the fix, and a drafted GitHub comment;
5. points other reviewers already raised;
6. what was considered and set aside.

It asks which model to review with, suggesting one from the PR's size and risk. Pass `model=<name>` to skip the question. Comments are posted only per your choice.

## /rahal:pr-followup

`/rahal:pr-followup <PR link>` handles reviewers' comments in two phases.

**Phase one** rebuilds the context from GitHub, Linear and the repo (no shared files needed), verifies each comment, and writes a fix plan:

```
Comments at a glance
  1. Amr — search can't find a destination by its label. Recommend: fix (blocking).
  2. Muntadher — % and _ act as wildcards. Recommend: fix (not blocking); departs from the ticket.
  0. Branch update — merge main first; only openapi/admin.json conflicts (generated).
Detailed fixes   … one block per comment: how it was verified, the test-first fix, a reply draft …
Which do you accept? e.g. "0, 1, 2"
```

**Phase two** does only what you accepted:
1. merges `main` into the branch;
2. fixes each comment test-first in its own commit;
3. runs the gate and an internal review;
4. updates the PR body and drafts one reply per comment.

Pushing, posting and re-requesting review follow your choices.

## /rahal:plan-tickets

`/rahal:plan-tickets` asks which project to look at (it lists only those holding your open tickets), then reads your tickets' blocking links in Linear and the open PRs on GitHub. It changes nothing in either. In chat you get:

```
Pick order
  1. ORB-901 Add the visa product list — can start now · unblocks 2 (your ORB-902, Lee's ORB-910) · High
  2. ORB-904 Add the nationality filter — can start now · Medium
  3. ORB-902 Add visa product activation — after your ORB-901 (step 1)
  4. ORB-903 Serve the visa product page — waits on Sam's ORB-905 (Code Review, #12)
Lanes             A: ORB-901 (start now) → ORB-902 · B: ORB-904 (start now) · C: ORB-903
Stack candidates  ORB-903 can stack on #12 (feat/orb-905-visa-product-reads). Stack if you can't wait:
                  run /rahal:start-work ORB-903 and answer Stack when it asks "Wait or stack?".
Blocking you      ORB-905 — Sam · Code Review · PR #12 · holds up your ORB-903: offer to help review it, or stack on it (see Stack candidates).
Save this ticket queue? all lanes · lane A only (recommended) · lanes … · don't save
```

The order rests on blocking links, then how many tickets each one unblocks, then priority and ticket number. The queue says so, because tickets carry no estimates or due dates. QA Staging and QA UAT count as merged. Nothing is saved unless you choose; a save goes to `work/ticket-queue/<project>-<date>.md`.

## Troubleshooting

- **"Linear tools not available"**: connect Linear in claude.ai → Settings → Connectors, or authorise it with `/mcp`, then re-run `/rahal:init`.
- **"gh signs in as another account"**: point `gh_config_dir` in `.claude/rahal.local.md` at the right gh folder, or run `gh auth login` there. Never `gh auth switch`; it changes every workspace.
- **Windows: `spawnSync pnpm ENOENT` in e2e**: re-run `/rahal:init` to write the shim; e2e runs then use `NODE_OPTIONS` from your settings.
- **Windows: `node` not found in Git Bash**: `/rahal:init` records the Node folder; check `bash_node_path`.
- **Port already allocated**: another project's container holds 5432 or 6379. `/rahal:init` moves Orbit's ports.
- **Docker not running**: start Docker Desktop; execution needs it for the gate.

## Adding a profile

Team facts live in `plugins/rahal/shared/profiles/<name>.md`: repos, branches, gates, practices. A second team (for example Rahal corporate, `GF-` tickets) means:
- a new profile file;
- a profile choice in `init`;
- step 0 accepting that team's ticket prefix.

Nothing personal goes in a profile.
