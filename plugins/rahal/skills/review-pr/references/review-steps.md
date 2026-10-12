# review-pr — steps

## 1. Step 0 and the PR's state

Run checks 1–4. Then:

```bash
GH_CONFIG_DIR="<gh_config_dir>" gh pr view <n> --repo DigitalZoneApp/<repo name> \
  --json number,title,author,state,mergedAt,baseRefName,headRefName,headRefOid,reviewDecision,statusCheckRollup,body
```

A merged PR: ask whether to continue (step 0 check 2).

## 2. The ticket

Take `ORB-<n>` from the PR title or branch. `get_issue` with relations, and `list_comments`. Note whether the ticket was updated after the PR opened (`updatedAt`): a reviewer may have amended it. The output folder is the ticket folder (step 0 → The ticket folder).

## 3. Read the code at the PR head

Never switch the user's checkout.

```bash
git -C <repo> fetch origin --quiet
git -C <repo> fetch origin "+pull/<n>/head:refs/remotes/origin/pr-<n>" --quiet
[ "$(git -C <repo> rev-parse origin/pr-<n>)" = "<headRefOid>" ] || echo "STALE: origin/pr-<n> is not the PR head <headRefOid>"   # stop and say so
BASE="$(git -C <repo> merge-base origin/<base> origin/pr-<n>)"
git -C <repo> log --oneline "$BASE"..origin/pr-<n>
git -C <repo> diff --stat "$BASE"..origin/pr-<n>
MSYS_NO_PATHCONV=1 git -C <repo> show origin/pr-<n>:<path>
```

- To run something at the head, use `git -C <repo> worktree add --detach "<scratchpad>/pr-<n>" origin/pr-<n>` and remove it afterwards with `git -C <repo> worktree remove --force "<scratchpad>/pr-<n>"`.
- Read the standard on `origin/<base>`: `AGENTS.md`, `CODEOWNERS`, `.github/pull_request_template.md`.
- List CODEOWNERS files the PR touches.

## 4. Existing comments

```bash
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/pulls/<n>/reviews \
  --jq '.[] | "\(.user.login) \(.state): \(.body)"'
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/pulls/<n>/comments \
  --jq '.[] | "\(.id) \(.user.login) \(.path):\(.line // .original_line): \(.body)"'
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/issues/<n>/comments \
  --jq '.[] | select(.user.type != "Bot") | "\(.user.login): \(.body)"'
```

These go in section 5 of the report and are not repeated as new issues.

## 5. Review

Follow `${CLAUDE_PLUGIN_ROOT}/shared/review-model.md`:
1. Ask the model (unless `model=<name>` or a standing choice).
2. Run the reviewer agent once, with the ticket, base `$BASE`, head `origin/pr-<n>`'s SHA, the repo folder and its default branch name, the scratchpad folder, `AGENTS.md`, and the existing comments. It runs `code-review` itself; there is no separate `code-review` run.

## 6. Verify and write the report

- Re-open every citation at the head SHA. Probe, mutate in the scratchpad worktree, or dry-run where needed. Drop what does not hold.
- Write `<workspace_root>/<work_folder>/<slug>/review-<date>.md` from `${CLAUDE_PLUGIN_ROOT}/shared/templates/review-report.md`:
  - **Section 2:** walk the PR step by step (by area or commit), each with an example. End with the line checking it against the ticket.
  - **Section 3:** plain, non-technical lines, each with an everyday example, and the verdict line.
  - **Section 4:** the full detail of each issue, including a dry run with real values.
- Show sections 1–4 in chat; sections 5–6 can stay in the file.

## 7. Draft and post comments

- Draft one comment per issue the user may post, inside its `<details>` block. Each stands on its own and states the issue plus one concrete example; the author chooses the fix. Never a `suggestion` block or a proposed fix, an @-mention, should or must, or another PR or commit.
- An inline comment's line must be inside the diff. Get the hunk ranges with:

```bash
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api repos/DigitalZoneApp/<repo name>/pulls/<n>/files --paginate \
  --jq '.[] | "\(.filename) \(.patch | [scan("@@ -[0-9,]+ \\+([0-9]+),?([0-9]*)")] )"'
```

  An anchor outside every `+start,count` range becomes a conversation comment that names the file and line.
- Posting follows `choices.post_comments`: with `ask`, show the drafts and post only those the user names. Post an inline comment with:

```bash
MSYS_NO_PATHCONV=1 GH_CONFIG_DIR="<gh_config_dir>" gh api -X POST repos/DigitalZoneApp/<repo name>/pulls/<n>/comments \
  -f commit_id=<head sha> -f path=<file> -F line=<line> -f side=RIGHT -F body=@"<file holding the comment>"
```

- Record each posted comment's id and URL in the report file.
