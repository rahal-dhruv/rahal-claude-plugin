---
name: init
description: "Set up the rahal plugin for this workspace on this machine: finds the Orbit and corporate repos, checks GitHub, Linear, git and the toolchain, asks your commit and GitHub-action choices, and writes .claude/rahal.local.md. Run it once per workspace, and again to change your answers. Usage: /rahal:init [workspace folder]"
argument-hint: "[workspace folder]"
disable-model-invocation: true
---

# /rahal:init

Set up the plugin for one workspace. Arguments: `$ARGUMENTS` (an optional workspace folder; default is the folder Claude Code started in).

Plugin root: `${CLAUDE_PLUGIN_ROOT}`. If that appears unexpanded, the plugin root is two folders above this skill's base directory.

Read first:
- `${CLAUDE_PLUGIN_ROOT}/shared/explanation-style.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/approval-gates.md`
- both profiles: `${CLAUDE_PLUGIN_ROOT}/shared/profiles/orbit.md`, `${CLAUDE_PLUGIN_ROOT}/shared/profiles/corporate.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/init/references/checks.md` (the commands for every step below)

Every change below needs the user's yes. Never write inside a repo. Never run `gh auth switch` or `git config`. If `.claude/rahal.local.md` already exists, read it first and offer its values as the defaults ("keep" or "change").

## Steps

1. **Workspace.** Confirm the folder. List which repos of each family are present (`checks.md` → Workspace): orbit (`rahal-orbit-backend`, `rahal-orbit-dashboard`, `rahal-orbit-docs`) and corporate (`rahal-corporate-backend`, `rahal-corporate-app`, `rahal-corporate-dashboard`). A family with at least one repo present is configured; ask which families this workspace works on, and offer to clone a missing repo of a chosen family, with the remote prefix chosen in step 2.
2. **GitHub.** Check `gh` (installed, signed in, which account, `repo` scope). Ask whether this workspace uses a separate gh config folder (common with a second GitHub account). Check the account can read each configured repo. Record `account`, `gh_config_dir`, `remote_prefix` (read from an existing repo's `origin`, e.g. `git@github.com:` or an SSH alias like `git@<alias>:`), and `commit_email` (read from `git config user.email` inside a repo; report it, never change it).
3. **Linear.** Find the Linear tools this session has (`checks.md` → Linear). Ask for one ticket id (ORB, or GF for corporate) and read it with `get_issue` to prove they work. Record the tool name prefix. If none: explain how to connect Linear (claude.ai → Settings → Connectors, or `/mcp`), and record `tools:` empty, which step 0 will report.
4. **Toolchain.** For each configured family, check Node against its backend's `.nvmrc` (or the Node its profile names), its package managers (pnpm, and npm for the corporate backend), and Docker.
   - Record each family's Postgres and Redis ports under `families.<family>`. Find clashes on them; Orbit's ports can move (`ORBIT_POSTGRES_PORT`, `ORBIT_REDIS_PORT`), the corporate backend's are fixed in its compose file, so when both families are configured, Orbit's move off the corporate ones.
   - On Windows, find the Node folder Git Bash needs, and offer to write the e2e shim for the orbit family (`checks.md` → Windows e2e shim); the corporate e2e suites need none.
5. **Extras.** Detect `docs/` at the workspace root, a `reflector/` folder, and the superpowers plugin. Offer to install superpowers (`claude plugin install superpowers@claude-plugins-official`); it is recommended, not required.
6. **Folders.** Offer to create `<work_folder>/` (default `work`). Show `${CLAUDE_PLUGIN_ROOT}/skills/init/references/workspace-layout.md`.
7. **Choices.** Ask the two groups in `${CLAUDE_PLUGIN_ROOT}/skills/init/references/choices.md`, one group per question. Show the defaults; the user keeps them or changes some. Do not ask about the review model: it is asked at each review.
8. **Write** `.claude/rahal.local.md` from `${CLAUDE_PLUGIN_ROOT}/skills/init/references/config-template.md`, filling every value; leave a value empty only where the template allows it. If the workspace root is a git repo, add `.claude/rahal.local.md` to its `.gitignore` (with a yes).
9. **Verify:** run `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md` checks 1–5. Report anything still failing, with its fix.

## Summary to print

```
Rahal plugin — set up for <workspace> (<families>)
GitHub     <account> via <gh config: default | folder>, remotes <remote_prefix>…      ✓/✗
Linear     <tools found | not connected>, read <ticket id>                             ✓/✗
Toolchain  Node <v>, pnpm <v>, npm <v>, Docker <up/down>; per family: Postgres <port>, Redis <port>   ✓/✗
Choices    commit: <commit_when>, <commit_size>, attribution <attribution>;
           push <push> · PR <open_pr> (<pr_state>) · comments <post_comments> · re-request <re_request_review>
Written    .claude/rahal.local.md
Next       /rahal:start-work <ticket link>
```
