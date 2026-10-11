# start-work — phase three: ship

Each step follows `choices` in `.claude/rahal.local.md`. With `ask`, ask before the step; with `auto`, do it and say so.

`<branch>` below is the `**Branch:**` line of the ticket folder's `plan.md` (step 0 → The ticket folder), e.g. `feat/orb-183-visa-destinations`.

## 0. Step 0

Run checks 1, 2, 4 and 5 of `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md` first, and re-check a stacked base (The ticket folder, item 5): this phase may start in a new session, where the gh account, the remote, the tree or the blocker's PR may have changed. Any ✗ stops before the push.

## 1. Push

```bash
git -C <repo> fetch origin --quiet
git -C <repo> ls-remote --exit-code --heads origin <branch> >/dev/null && \
  git -C <repo> merge-base --is-ancestor origin/<branch> HEAD && echo fast-forward
export PATH="<bash_node_path>:$PATH"; git -C <repo> push -u origin <branch>
```

- If the remote branch exists and is not an ancestor of HEAD, stop: someone else pushed. Never force.
- The pre-push hook runs typecheck, format, knip, `openapi:check` and the unit tests. Report each result.

## 2. Open the PR

```bash
GH_CONFIG_DIR="<gh_config_dir>" gh pr create --repo DigitalZoneApp/<repo name> --base main \
  --head <branch> --title "feat(ORB-<n>): <ticket title as a lowercase imperative>" \
  --body-file "<workspace_root>/<work_folder>/<slug>/pr-body.md" [--draft]
```

Use `--draft` when `pr_state: draft`. Record the URL in the ledger.

## 3. Read CI once

```bash
GH_CONFIG_DIR="<gh_config_dir>" gh pr view <n> --repo DigitalZoneApp/<repo name> \
  --json headRefOid,mergeable,mergeStateStatus,statusCheckRollup \
  --jq '"head=\(.headRefOid[0:7]) mergeable=\(.mergeable)", (.statusCheckRollup[]? | "  \(.name // .context): \(.status // .state) \(.conclusion // "")")'
```

Report what it shows, once. Never poll.
