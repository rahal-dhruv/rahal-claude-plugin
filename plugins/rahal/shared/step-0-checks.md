# Step 0 — access checks

Run these first in every command and print one line per check:

```
Step 0 — checks
✓ Config      workspace <root>, profile orbit
✓ GitHub      gh signed in as <account>, can read DigitalZoneApp/<repo>
✓ Linear      read ORB-<n> ("<title>", <status>)
✗ Git         <repo> has uncommitted changes (<n> files)
– Toolchain   not needed for this phase
```

`✓` passed · `✗` failed · `–` not run. The calling command names the checks it needs.

## How to run commands

- Check 1 reads `.claude/rahal.local.md`; use its values in every command below.
- In Git Bash, start every command that runs `node`, `pnpm`, `claude` or a git hook (commit, push) with
  `export PATH="<toolchain.bash_node_path>:$PATH";` when that value is set.
- Start every `gh` command with `GH_CONFIG_DIR="<github.gh_config_dir>"` when that value is set.
- In Git Bash, start `git show <rev>:<path>` and `gh api <path>` with `MSYS_NO_PATHCONV=1`, or the path is rewritten.
- Quote every path: a workspace path may contain spaces.
- `<repo>` below means `"<workspace_root>/<repos.backend>"` (or the dashboard or docs folder the command targets).

## Check 1 — Config

1. Find `.claude/rahal.local.md` in the folder Claude Code started in, or its nearest parent folder that has one.
2. Missing: `✗ Config  no rahal setup here`. Say: "Run `/rahal:init` in your workspace folder first." Stop (unless the command is `init`).
3. `profile` must be `orbit`. Anything else: `✗ Config  profile <value> is not supported`. Stop.

## Check 2 — GitHub

1. `gh --version`. Missing: "Install the GitHub CLI from https://cli.github.com, then run `/rahal:init` again."
2. `gh auth status`. The active account must equal `github.account`, and "Token scopes" must include `repo`.
   A different account is a conflict: "gh here signs in as `<other>`, your config says `<account>`. Point `github.gh_config_dir` at the gh folder that signs in as `<account>`, or run `gh auth login` there. Never use `gh auth switch`: it changes the account for every workspace on this machine."
3. `gh repo view DigitalZoneApp/<repo name> --json name`. A failure means the account cannot read the repo.
4. PR commands only: `gh pr view <n> --repo DigitalZoneApp/<repo name> --json state,mergedAt,headRefOid`. A merged PR: ask "PR #<n> is already merged. Continue anyway?"

## Check 3 — Linear

1. Load the Linear tools with ToolSearch: `select:<linear.tools>get_issue,<linear.tools>list_comments` (and `<linear.tools>extract_images`, `<linear.tools>list_issues` for `start-work`).
2. Not available: `✗ Linear  tools not available`. Say: "Connect Linear in claude.ai → Settings → Connectors, or authorise the Linear plugin with `/mcp`. Claude can't sign in for you." If tools with a different prefix but the same names are available, offer to record that prefix in `.claude/rahal.local.md`.
3. Call `get_issue` on the ticket: from the link (`start-work`), or the `ORB-<n>` in the PR title (`review-pr`, `pr-followup`).
4. A ticket whose identifier does not start with `ORB-`: "This plugin supports Orbit (ORB-) tickets only for now." Stop.

## Check 4 — Git

For each repo the command touches:
1. `git -C <repo> remote get-url origin` must start with `github.remote_prefix`. Otherwise: "The remote does not use your configured address, so pushes may sign in as another account." Show the fix: `git -C <repo> remote set-url origin <remote_prefix>DigitalZoneApp/<repo name>.git`.
2. `git -C <repo> config user.email` must equal `github.commit_email`. Otherwise report it. The fix is the user's own git identity setup; never run `git config`.
3. `git -C <repo> fetch origin --quiet`, then `git -C <repo> rev-list --left-right --count <default>...origin/<default>`. Report "local <default> is N behind" (information, not a failure).
4. Phases that commit: `git -C <repo> status --porcelain=v1` must print nothing. Otherwise list the files.

## Check 5 — Toolchain

Only for phases that run code.
1. `node -v` must match `<repo>/.nvmrc` (major and minor); `pnpm -v` must work.
2. `docker info --format '{{.ServerVersion}}'` must work.
3. `docker ps --format '{{.Names}} {{.Ports}}'`: a container outside Orbit's compose project holding `toolchain.docker_ports.postgres` or `.redis` is a clash. Name the container. Suggest `/rahal:init` to move Orbit's ports, or stopping the other container, which is the user's call.
4. Windows: the folder in `toolchain.bash_node_path` must contain `node`, and the shim file named in `toolchain.e2e_node_options` must exist.
5. Review phases: the `code-review` skill must be in this session's skill list. Missing: say so; the review then runs the reviewer agent only.

## When a check fails

Stop and say, in plain words:
- what is wrong;
- which later step it would break;
- the exact command that fixes it.

Then ask: **fix now**, **continue without that step**, or **stop**. Never run `gh auth switch`, `git config`, or anything that changes the user's other workspaces.
