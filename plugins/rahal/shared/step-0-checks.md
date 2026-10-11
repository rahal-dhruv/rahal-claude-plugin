# Step 0 — access checks

Run these first in every command and print the header line, then one line per check:

```
Step 0 — checks · rahal <version> from <plugin root>
✓ Config      workspace <root>, profile orbit
✓ GitHub      gh signed in as <account>, can read DigitalZoneApp/<repo>
✓ Linear      read ORB-<n> ("<title>", <status>)
✗ Git         <repo> has uncommitted changes (<n> files)
– Toolchain   not needed for this phase
```

`✓` passed · `✗` failed · `–` not run. The calling command names the checks it needs.

The header line names the plugin copy this run loaded: `<plugin root>` is the root the command's `SKILL.md` gave, and `<version>` is the `version` in `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. A root inside Claude Code's `plugins/cache/` folder is the copy cached at install: it changes only after a version bump and `claude plugin update`, so an older version there means this run uses an older plugin.

## How to run commands

- Check 1 reads `.claude/rahal.local.md`; use its values in every command below.
- In Git Bash, start every command that runs `node`, `pnpm`, `claude` or a git hook (commit, push) with
  `export PATH="<toolchain.bash_node_path>:$PATH";` when that value is set.
- Start every `gh` command with `GH_CONFIG_DIR="<github.gh_config_dir>"` when that value is set, and give every `gh pr` and `gh repo` command `--repo DigitalZoneApp/<repo name>`: the workspace root is not a repo, and inside another repo `gh` would act on that repo's PR.
- In Git Bash, start `git show <rev>:<path>` and `gh api <path>` with `MSYS_NO_PATHCONV=1`, or the path is rewritten.
- Run `pnpm` from inside the repo, in the same command: `(cd <repo> && pnpm …)`. Corepack takes pnpm's version from the repo's `package.json`, so from the workspace folder another version runs; the parentheses keep the session's own folder unchanged.
- Prisma commands on the dev database (`pnpm db:migrate`, `pnpm db:migrate:dev`) run with `DATABASE_URL` on port `<dev_database_url_port>` when `.env` names another: `export DATABASE_URL="$(grep '^DATABASE_URL=' .env | cut -d= -f2- | sed 's#:5432/#:<dev_database_url_port>/#')"` in the same command, inside the backend. Never edit `.env`.
- Quote every path: a workspace path may contain spaces.
- `<repo>` below means `"<workspace_root>/<repos.backend>"` (or the dashboard or docs folder the command targets).

## The ticket folder

A ticket's outputs live in `<workspace_root>/<work_folder>/<slug>/`. The slug is `orb-<n>-<two to four words from the ticket title>`, lower case, joined by `-` (e.g. `orb-183-visa-destinations`). Find the folder before making one, so a later run lands in the same place:
1. List `"<workspace_root>/<work_folder>"/orb-<n>-*/`. One folder: use it; its name is the slug. Several: ask which.
2. None: make the slug from the ticket title. Create the folder when the first file is written.
3. The branch is the `**Branch:**` line of that folder's `plan.md` when it has one; for a PR, the PR's `headRefName`; otherwise `feat/<slug>`.
4. The base is the branch in the first backticks of `plan.md`'s `**Base:**` line (`orb-103-car-rental-search-route` in ``**Base:** `orb-103-car-rental-search-route` · stacked on #146 (ORB-103)``); for a PR, the PR's `baseRefName`; otherwise `main`. The standard (`AGENTS.md`, `CODEOWNERS`, the PR template) always comes from `origin/main`, whatever the base.
5. A stacked base is re-checked when phase two or phase three starts: `GH_CONFIG_DIR="<gh_config_dir>" gh pr view <blocker PR> --repo DigitalZoneApp/<repo name> --json state,mergedAt`.
   - Merged: say so ("#146 (ORB-103) merged on <date>; ORB-<n> now starts from main"), set the Base line to `` `main` ``, record the change as a `Ruling:` in `ledger.md`, and remove the stack notice from `pr-body.md` if it has one.
   - Closed without merging: stop and ask.
   - Open: keep the base.

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
2. Not loaded, or `linear.tools` is empty: search with ToolSearch, query `linear get_issue`, max 10 results. A tool set whose names end in `get_issue`, `list_comments`, `list_issues` and `extract_images` is Linear; its prefix is everything before `get_issue`. Found under another prefix: say so, offer to record the new prefix in `.claude/rahal.local.md`, and continue with it.
3. None found: `✗ Linear  tools not available`. Say: "Connect Linear in claude.ai → Settings → Connectors, or authorise the Linear plugin with `/mcp`. Claude can't sign in for you."
4. Call `get_issue` on the ticket: from the link (`start-work`), or the `ORB-<n>` in the PR title (`review-pr`, `pr-followup`).
5. A ticket whose identifier does not start with `ORB-`: "This plugin supports Orbit (ORB-) tickets only for now." Stop.

## Check 4 — Git

For each repo the command touches:
1. `git -C <repo> remote get-url origin` must start with `github.remote_prefix`. Otherwise: "The remote does not use your configured address, so pushes may sign in as another account." Show the fix: `git -C <repo> remote set-url origin <remote_prefix>DigitalZoneApp/<repo name>.git`.
2. `git -C <repo> config user.email` must equal `github.commit_email`. Otherwise report it. The fix is the user's own git identity setup; never run `git config`.
3. `git -C <repo> fetch origin --quiet`. When a local `<default>` branch exists (`git -C <repo> rev-parse -q --verify refs/heads/<default>`), report how far it is behind with `git -C <repo> rev-list --left-right --count <default>...origin/<default>`. When it does not (a docs clone often has only feature branches), say "no local <default> branch; commands read origin/<default>". Either way this is information, not a failure: every command reads code from `origin/<default>`, or from `origin/<base>` for a stacked ticket.
4. Phases that commit: `git -C <repo> status --porcelain=v1` must print nothing. Otherwise list the files.

## Check 5 — Toolchain

Only for phases that run code.
1. `node -v` must match `<repo>/.nvmrc` (major and minor); `pnpm -v` must work.
2. `docker info --format '{{.ServerVersion}}'` must work.
3. `docker ps --format '{{.Names}} {{.Ports}}'`: a container outside Orbit's compose project holding `toolchain.docker_ports.postgres` or `.redis` is a clash. Name the container. Suggest `/rahal:init` to move Orbit's ports, or stopping the other container, which is the user's call.
4. Windows: the folder in `toolchain.bash_node_path` must contain `node`; the shim file named in `toolchain.e2e_node_options` (the path between its double quotes) must exist; and `NODE_OPTIONS='<e2e_node_options>' node -e 1` must exit 0.
5. Review phases: the `code-review` skill must be in this session's skill list, because the reviewer agent runs it. Missing: say so; the review then counts as ticket checks only, never as clean.

## When a check fails

Stop and say, in plain words:
- what is wrong;
- which later step it would break;
- the exact command that fixes it.

Then ask: **fix now**, **continue without that step**, or **stop**. Never run `gh auth switch`, `git config`, or anything that changes the user's other workspaces.
