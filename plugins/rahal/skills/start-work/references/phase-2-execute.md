# start-work — phase two: execute

## 1. Step 0 and the commit gate

- Run checks 1–5, and re-check a stacked base (step 0 → The ticket folder, item 5).
- Read `choices.commit_when`. For `standing_yes_per_ticket`, ask once: "Commit as I go for ORB-<n>? (never a push)". For `ask_each`, ask before every commit. For `never`, leave changes uncommitted and say so at each task's end.

## 2. Pre-flight and the ledger

- Run the plan's Pre-flight block, adapted to the config:
  - `ORBIT_POSTGRES_PORT=<docker_ports.postgres> ORBIT_REDIS_PORT=<docker_ports.redis> docker compose up --wait` from the backend folder.
  - Prisma dev commands run with the dev database URL (step 0 → How to run commands).
  - `pnpm db:migrate`.
- Create `<work>/<slug>/ledger.md` from `${CLAUDE_PLUGIN_ROOT}/shared/templates/ledger.md`. Record every ruling, task completion, environmental problem, review finding and remote step there as it happens. It is what a later session resumes from.

## 3. Each task

1. Write the test. Run it: `NODE_OPTIONS='<e2e_node_options>' pnpm test:e2e <file>` or `pnpm test <file>`. Confirm it fails for the reason the plan states. A test that passes before the code exists is a finding about the test.
2. Write the code. Run the test again and confirm it passes. Then `pnpm typecheck` and `pnpm lint`.
3. Commit per `commit_size` and `attribution` with the profile's title format.
   - Every commit must pass typecheck and lint on its own.
   - To split one file's edits across two commits (interactive staging is not available): copy the full file to the scratchpad, `git checkout` it, re-apply the first part, commit, copy the full file back, commit.
   - To prove part of a change passes alone: stage it, `git stash push --keep-index --include-untracked`, typecheck and lint, commit, `git stash pop`.
4. Add the ledger line: `Task <n>: complete (commits <base7>..<head7>; tests: <command> → <result>)`.

When the plan is wrong (a name mismatch, a command that cannot work), rule on the smallest fix and ledger it as `Ruling: …`. When the ticket, `AGENTS.md` and the code disagree beyond the agreed decisions, stop and ask.

## 4. Docs

When `workspace_extras.docs_folder` is true, update `docs/<repo>/<feature>.md` and the nearest `index.md` (what was built: purpose, data flow, invariants, gotchas; no task status).

## 5. The gate

Run `NODE_OPTIONS='<e2e_node_options>' pnpm check` in the background, and watch it with a monitor if the session has one. Read the result. Label environmental failures as environmental, with no re-run loops. Record lint, format, typecheck, knip, unit, e2e and contract counts, and `openapi:check`.

## 6. Guard checks

For each key guard (a live-row filter, a unique-violation-to-409 mapping, a permission on a route, a size limit, a magic-number check, an object delete), break it once and record which case fails. Use a scratchpad runner:

```bash
#!/usr/bin/env bash
# Breaks one guard at a time, runs one e2e file, records the failing cases, and restores each
# file from its own copy, so uncommitted changes and new untracked files survive.
set -u
cd <repo>
SP="<scratchpad>"; OUT="$SP/mutations.md"; : > "$OUT"
BEFORE="$(git status --porcelain=v1)"
snap() { cp "$2" "$SP/orig-$1"; }
run() {
  name="$1"; file="$2"
  diff="$(diff -U0 "$SP/orig-$name" "$file" | grep -E '^[-+][^-+]')"
  { echo "## $name"; echo '```diff'; echo "$diff"; echo '```'; } >> "$OUT"
  if [ -z "$diff" ]; then echo "MUTATION NOT APPLIED" >> "$OUT"; else
    NODE_OPTIONS='<e2e_node_options>' pnpm test:e2e <e2e file> > "$SP/mut-$name.log" 2>&1
    echo "exit=$?" >> "$OUT"
    grep -E '^ *(×|FAIL )|^ +(Test Files|Tests|Errors) |[Uu]nhandled' "$SP/mut-$name.log" >> "$OUT"; echo "log: $SP/mut-$name.log" >> "$OUT"
  fi
  cp "$SP/orig-$name" "$file"; echo >> "$OUT"
}
# one block per guard: snap <name> <file>; an edit (perl -0pi, or sed into a temp file and cp back); run <name> <file>
if [ "$(git status --porcelain=v1)" = "$BEFORE" ]; then echo "tree: as before" >> "$OUT"; else
  { echo "TREE CHANGED"; git status --porcelain=v1; } >> "$OUT"; fi
```

- Write each mutation against the file as it is now, after prettier formatted it, never against the plan's code: once prettier wraps a line, a pattern copied from the plan no longer matches, and the record says `MUTATION NOT APPLIED`.
- Run it in the background and read `mutations.md`. It must end with `tree: as before`. Anything else: restore each file from its `orig-<name>` copy before going on.
- It never uses `git checkout` or `git stash`, so it is safe whatever the commit choice: uncommitted task changes and new files are restored exactly.
- Where the suite deliberately has no permanent case (a row lock the ticket proves "once in the pull request"), write a one-off proof script. Run it once as written and once with the mutation, and record both outputs.

## 7. Library measurements

Re-run the measurements from phase one against the final code, and record the commands and results for the PR body.

## 8. The PR body

Build `<work>/<slug>/pr-body.md` from `git show origin/main:.github/pull_request_template.md`, keeping its sections. Fill in:
- a stacked base (the plan's `**Base:**` line names a PR): the notice in `${CLAUDE_PLUGIN_ROOT}/shared/stack-notice.md` at the very top, with the blocker's PR number and branch filled in;
- the ticket id;
- **What:** the change; the existing definitions reused, by file and name; departures from the ticket with reasons; additions beyond the ticket's symbols; deployment notes (for example a storage bucket policy that must change);
- **Not in this pull request:** the ticket's Deferred list, then findings left unchanged;
- **How to verify:** the reviewed SHA; the gate counts; each test case with the decision it proves; the guard table (mutation → observed failure); the measurements (command → result); the one-off proof scripts in `<details>` blocks.

No attribution line unless `attribution: claude`.

## 9. The workspace's own steps

Follow anything the workspace's `CLAUDE.md` asks for at the end of a task (for example a reflector context file). The plugin adds nothing here.

## 10. Review

1. The review model, per `${CLAUDE_PLUGIN_ROOT}/shared/review-model.md`. `model=<name>` in the arguments answers it.
2. The reviewer agent, once, on the branch: base `$(git merge-base origin/<base> HEAD)`, head `HEAD`'s SHA, and the base branch `<base>` for its review clone. It runs `code-review` itself, as `${CLAUDE_PLUGIN_ROOT}/shared/review-model.md` says.
3. Verify every finding (`shared/evidence.md`).
4. Write `<work>/<slug>/review-<date>.md` from `${CLAUDE_PLUGIN_ROOT}/shared/templates/review-report.md`.
5. Show "Issues at a glance" and "Issues in detail", then stop. Ask which to fix.

## 11. The fix pass

For each accepted finding:
- write a test that reproduces it and watch it fail, then fix and watch it pass;
- when the code was already right and only the test was weak, prove the strengthened test by breaking the code once.

One commit per fix. Then re-run the gate, update the PR body (new SHA and counts) and the ledger (`Final: fixed <finding> — <test> red → green`). Unaccepted findings go to the ledger as `skipped per user`.
