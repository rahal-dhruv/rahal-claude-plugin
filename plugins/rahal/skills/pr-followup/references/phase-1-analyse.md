# pr-followup — phase one: analyse and plan

## 1. Step 0

Checks 1–4. This phase changes nothing in any repo.

## 2. Rebuild the context

```bash
GH_CONFIG_DIR="<gh_config_dir>" gh pr view <n> --repo DigitalZoneApp/<repo name> \
  --json number,title,author,state,baseRefName,headRefName,headRefOid,reviewDecision,statusCheckRollup,body,commits
git -C <repo> fetch origin --quiet
git -C <repo> fetch origin "+pull/<n>/head:refs/remotes/origin/pr-<n>" --quiet
[ "$(git -C <repo> rev-parse origin/pr-<n>)" = "<headRefOid>" ] || echo "STALE: origin/pr-<n> is not the PR head <headRefOid>"   # stop and say so
BASE="$(git -C <repo> merge-base origin/<base> origin/pr-<n>)"
MSYS_NO_PATHCONV=1 git -C <repo> diff "$BASE" origin/<base> -- AGENTS.md .github/pull_request_template.md
```

- The ticket from the PR title: `get_issue` and `list_comments`. Say whether it changed after the PR opened, and what changed.
- A rule added to `AGENTS.md` or the template since `$BASE` binds this PR. For example, a rule to measure a dependency's behaviour means the PR body needs that measurement.

## 3. Collect the comments

```bash
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/pulls/<n>/reviews \
  --jq '.[] | "\(.id) \(.user.login) \(.state) \(.submitted_at): \(.body)"'
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/pulls/<n>/comments --paginate \
  --jq '.[] | "\(.id) in_reply_to=\(.in_reply_to_id) \(.user.login) \(.path):\(.line // .original_line): \(.body)"'
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/issues/<n>/comments \
  --jq '.[] | select(.user.type != "Bot") | "\(.id) \(.user.login): \(.body)"'
```

- Skip bots.
- Skip a thread whose latest comment is by the PR author (already answered).
- Skip comment ids listed on a `Handled:` line of an earlier `followup-*.md` in the ticket folder.

## 4. Check the branch

```bash
git -C <repo> rev-list --left-right --count origin/<base>...origin/pr-<n>          # behind / ahead
T="<scratchpad>/merge-trial-<n>"
git -C <repo> worktree add -q --detach "$T" origin/pr-<n>
git -C "$T" merge --no-commit --no-ff origin/<base> >/dev/null 2>&1
git -C "$T" diff --name-only --diff-filter=U                                        # conflicting files
git -C <repo> worktree remove --force "$T"; git -C <repo> worktree prune
```

Name which conflicts are generated files (`openapi/*.json`), which are regenerated, never hand-merged.

## 5. Verify each comment

- Read the cited code at the PR head (`git show origin/pr-<n>:<path>`).
- When the comment is about behaviour, measure it: a scratchpad script against the installed package or the dev database, with the command and result recorded.
- Say whether the fix departs from the ticket text. If it does, the fix plan says how to handle it: ask the ticket owner to amend the ticket, or list it as a departure in the PR body.

## 6. Write the fix plan and stop

- Write `<workspace_root>/<work_folder>/<slug>/followup-<date>.md` from `${CLAUDE_PLUGIN_ROOT}/shared/templates/followup-plan.md`:
  - "Comments at a glance" in plain words, each with an everyday example and a recommendation;
  - item 0, the branch update, when the branch is behind;
  - "Detailed fixes": each with how it was verified, the ticket alignment, a test-first fix plan with its commit title, an alternative push-back where reasonable, and a reply draft.
- Show it in chat and end with "Which do you accept?". Stop.
