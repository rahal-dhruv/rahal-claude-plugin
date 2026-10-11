# pr-followup — phase two: fix, review, reply

Record the user's answer at the end of the follow-up file (`Accepted: …`). Track progress in the ticket folder's `ledger.md` (create it from the template if absent): one line per finished step below (`Follow-up <date> step <n>: done …`), so a later run resumes at the first unfinished step.

## 1. Step 0

Checks 1–5, and check out the PR branch:

```bash
git -C <repo> status --porcelain=v1          # must be empty
git -C <repo> fetch origin --quiet
git -C <repo> switch <headRefName> || git -C <repo> switch -c <headRefName> --track origin/<headRefName>
[ "$(git -C <repo> branch --show-current)" = "<headRefName>" ] && git -C <repo> merge --ff-only "origin/<headRefName>"
[ "$(git -C <repo> branch --show-current)" = "<headRefName>" ] && [ "$(git -C <repo> rev-parse HEAD)" = "<headRefOid>" ] || echo "STOP: the checkout is $(git -C <repo> branch --show-current) at $(git -C <repo> rev-parse --short HEAD), not <headRefName> at <headRefOid>"   # stop and say so
```

The fast-forward names `origin/<headRefName>`, never the branch's upstream: a branch made from a blocker's branch can track it, and following the upstream once moved another ticket's branch onto this PR's commit. A `STOP` line means stop and name both branches; never commit or merge on another branch.

Commits follow `choices.commit_when` (for `standing_yes_per_ticket`, ask once for this follow-up).

## 2. Branch update

Only if item 0 was accepted.

When item 0 is a retarget (the blocker has merged), `<base>` in this step is `<default>`; the PR itself is retargeted in step 8, before the push.

```bash
git -C <repo> merge --no-ff --no-commit origin/<base>
git -C <repo> diff --name-only --diff-filter=U
```

`--no-commit` leaves the merge open even when nothing conflicts, so the checks below run before the commit, and the commit gets the team's title instead of Git's default message.
- A conflict in a generated file only (`openapi/*.json`, `src/generated/`): take either side with `git -C <repo> checkout --ours <file>`; it is regenerated below, never hand-merged.
- Any other conflicting file: stop and ask. `git -C <repo> merge --abort` undoes the merge.
- Then, in the repo: `pnpm install --frozen-lockfile`, `pnpm db:generate && pnpm openapi`, `git add` what they regenerated, then `pnpm typecheck && pnpm lint`.
- Then `git -C <repo> diff origin/<base> -- openapi/` must show only this ticket's own changes. A path or schema removed, or one that another ticket adds, means a stale document: stop and say so.
- Commit: `git -C <repo> commit -m "chore(ORB-<n>): merge <main | orb-<blocker n>> into the <branch words> branch"`: `main`, or for a stacked PR the blocker's ticket id, e.g. `chore(ORB-196): merge orb-194 into the visa provider admin routes branch`.
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

Update the ticket folder's `pr-body.md`; if absent, start from `GH_CONFIG_DIR="<gh_config_dir>" gh pr view <n> --repo DigitalZoneApp/<repo name> --json body --jq .body`:
- the reviewed SHA and the gate counts;
- the changed test-case lines;
- new measurements;
- a line naming the base branch that was merged in (with the merge SHA);
- anything the fixes made untrue.

## 7. Replies

One file per comment, `<ticket folder>/reply-<date>-<reviewer>-<comment id>.md`, from `${CLAUDE_PLUGIN_ROOT}/shared/templates/reply.md`:
- **fix:** the fix SHA, what changed, the test line, the gate result;
- **push-back:** "Evidence:" with the command and result.

Standalone, never mentioning other PRs.

## 8. Remote steps

Each step follows `choices`; with `ask`, ask per step.

```bash
GH_CONFIG_DIR="<gh_config_dir>" gh pr edit <n> --repo DigitalZoneApp/<repo name> --base <default>
git -C <repo> merge-base --is-ancestor origin/<headRefName> HEAD && export PATH="<bash_node_path>:$PATH" && git -C <repo> push origin <headRefName>
GH_CONFIG_DIR="<gh_config_dir>" gh pr edit <n> --repo DigitalZoneApp/<repo name> --body-file "<work>/<slug>/pr-body.md"
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api -X POST repos/DigitalZoneApp/<repo name>/pulls/<n>/comments/<comment id>/replies -F body=@"<reply file>"
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api -X POST repos/DigitalZoneApp/<repo name>/pulls/<n>/requested_reviewers -f "reviewers[]=<login>"
GH_CONFIG_DIR="<gh_config_dir>" gh pr view <n> --repo DigitalZoneApp/<repo name> --json mergeable,mergeStateStatus,reviewDecision,statusCheckRollup
```

- A conversation comment (not inline) is answered with `GH_CONFIG_DIR="<gh_config_dir>" gh pr comment <n> --repo DigitalZoneApp/<repo name> --body-file "<reply file>"`.
- Retarget: only when item 0 was a retarget, before the push. It always asks first (`approval-gates.md` → Fixed for everyone).
- Push: never with `--force`.
- PR description: replace it with the updated `pr-body.md`. This always asks first, whatever the other choices (`approval-gates.md` → Fixed for everyone).
- Reply: post in the comment's thread, only after the push that contains the commit it cites. If the push was declined, keep the replies as drafts and say so.
- Re-request review from the reviewer whose comments were handled.
- CI: read it once and report it.

After the replies are posted, append `Handled: <comment ids>` to the follow-up file (`Handled: none` when nothing was accepted). Record each step in the ledger.
