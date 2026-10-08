# pr-followup — phase two: fix, review, reply

Record the user's answer at the end of the follow-up file (`Accepted: …`). Track progress in `<work>/<slug>/ledger.md` (create it from the template if absent).

## 1. Step 0

Checks 1–5, and check out the PR branch:

```bash
git -C <repo> status --porcelain=v1          # must be empty
git -C <repo> switch <headRefName> 2>/dev/null || git -C <repo> switch -c <headRefName> --track origin/<headRefName>
git -C <repo> pull --ff-only
```

Commits follow `choices.commit_when` (for `standing_yes_per_ticket`, ask once for this follow-up).

## 2. Branch update

Only if item 0 was accepted:

```bash
git -C <repo> merge origin/<base>
git -C <repo> diff --name-only --diff-filter=U
```

- For a generated file only: `git -C <repo> checkout --ours <file>`, then `pnpm db:generate && pnpm openapi`, and `git -C <repo> add openapi/`.
- Any other conflicting file: stop and ask.
- Then `pnpm typecheck && pnpm lint`, and commit `chore(ORB-<n>): merge main into the <slug> branch`.
- Then `pnpm db:migrate` with the dev database URL.
- Never rebase, never force push, and never rename the PR's migration folders.

## 3. Each accepted fix

- Test first: add the assertion from the fix plan, run the suite file, and confirm it fails with the stated result.
- Then change the code and confirm it passes; typecheck and lint.
- One commit per fix, with the planned title.
- When the code was already right and the comment asked for a stronger test, prove the test by breaking the code once.

## 4. Gate

`NODE_OPTIONS='<e2e_node_options>' pnpm check` in the background. Record the counts, and label environmental failures as such.

## 5. Internal review

- Follow `${CLAUDE_PLUGIN_ROOT}/shared/review-model.md` over the whole branch (`git merge-base origin/<base> HEAD`..HEAD), flagging the commits added in this follow-up.
- Write `review-<date>.md`, show the findings at a glance and in detail, and stop. Fix the accepted ones test-first, then re-run the gate.

## 6. PR body

Update `<work>/<slug>/pr-body.md`; if absent, start from `gh pr view <n> --json body --jq .body`:
- the reviewed SHA and the gate counts;
- the changed test-case lines;
- new measurements;
- a line saying `main` was merged in (with the merge SHA);
- anything the fixes made untrue.

## 7. Replies

One file per reviewer, `<work>/<slug>/reply-<date>-<reviewer>.md`, from `${CLAUDE_PLUGIN_ROOT}/shared/templates/reply.md`:
- **fix:** the fix SHA, what changed, the test line, the gate result;
- **push-back:** "Evidence:" with the command and result.

Standalone, never mentioning other PRs.

## 8. Remote steps

Each step follows `choices`; with `ask`, ask per step.

```bash
git -C <repo> merge-base --is-ancestor origin/<headRefName> HEAD && export PATH="<bash_node_path>:$PATH" && git -C <repo> push origin <headRefName>
GH_CONFIG_DIR="<gh_config_dir>" gh pr edit <n> --repo DigitalZoneApp/<repo name> --body-file "<work>/<slug>/pr-body.md"
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api -X POST repos/DigitalZoneApp/<repo name>/pulls/<n>/comments/<comment id>/replies -F body=@"<reply file>"
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api -X POST repos/DigitalZoneApp/<repo name>/pulls/<n>/requested_reviewers -f "reviewers[]=<login>"
GH_CONFIG_DIR="<gh_config_dir>" gh pr view <n> --repo DigitalZoneApp/<repo name> --json mergeable,mergeStateStatus,reviewDecision,statusCheckRollup
```

- A conversation comment (not inline) is answered with `gh pr comment <n> --body-file <reply file>`.
- Push: never with `--force`.
- PR description: replace it with the updated `pr-body.md`.
- Reply: post in the reviewer's thread.
- Re-request review from the reviewer whose comments were handled.
- CI: read it once and report it.

Record each step in the ledger.
