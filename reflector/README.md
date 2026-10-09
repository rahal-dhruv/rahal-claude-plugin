# Reflector — operating manual

The reflector is an optional self-improvement loop for people working on this repo. After each Claude Code turn it reads a short context file the session wrote, curates shared lessons, keeps `docs/` honest, and asks the maintainer before anything bigger. It never changes the plugin.

## Turn it on

It is off unless you turn it on for yourself. Add this to `.claude/settings.local.json` in this repo (the file is git-ignored; merge it with anything already there):

```json
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command",
  "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/post-task.sh\"",
  "async": true, "timeout": 300 } ] } ] } }
```

The hook runs with bash: on Windows that is Git Bash, which must be on PATH for the shell Claude Code starts. Without it the hook fails to start and Claude Code shows a hook error; the session itself is unaffected.

Open your Claude Code session in this repo's folder: hooks and `AGENTS.md` apply to sessions started here, not to a session opened in a parent folder.

To turn it off, remove the `Stop` entry from your `.claude/settings.local.json`. Never add it to `.claude/settings.json`: `scripts/check.sh` refuses that, so nobody is opted in by accident.

## What happens each turn

1. `AGENTS.md` asks your session to write `.claude/reflector-context.json` before its final message, but only while your hook is registered.
2. The `Stop` hook runs `.claude/hooks/post-task.sh` in the background. It skips the run when:
   - the session is itself a reflector run (`CLAUDE_REFLECTOR_RUN=1`);
   - there is no context file;
   - the context file is unchanged since the last run (its `git hash-object` hash is kept in `reflector/.last-context.hash`);
   - `git` or `claude` is not on PATH.
3. Otherwise it starts `claude --print --agent reflector --permission-mode acceptEdits` with every hook off, and logs each decision to `reflector/reflector-runs.log`.

## Two tiers

| Tier | File | Nature |
| --- | --- | --- |
| Working memory | `reflector/notes.md` | Cheap to add, curated, pruned after 30 days untouched |
| Contract | `AGENTS.md` | Read by every contributor's agent in every session |

A lesson moves from notes into `AGENTS.md` only after the same friction appears in at least 3 entries of your `reflector/improvement-log.md`, and only as a 1–3 line edit. Anything bigger is escalated.

## Shared and local files

| File | In git? | Why |
| --- | --- | --- |
| `reflector/README.md`, `notes.md`, `pending-approvals.md` | committed | curated knowledge everyone benefits from |
| `reflector/improvement-log.md`, `reflector-runs.log`, `.last-context.hash` | ignored | one person's raw history; never causes merge conflicts |
| `.claude/reflector-context.json`, `.claude/settings.local.json` | ignored | per session, per person |

The reflector's edits to `notes.md` and `docs/` appear as ordinary uncommitted changes in your branch. Review them and commit them with your work, or on their own as `docs(reflector): …`.

## What it may change

- **On its own:** `reflector/notes.md` (between its markers), `docs/`, and 1–3 line `AGENTS.md` promotions.
- **Never; it escalates to `pending-approvals.md`:** `plugins/rahal/`, `scripts/`, `tests/`, the manifests, `README.md`, `.claude/agents/`, `.claude/hooks/`, structural `AGENTS.md` changes, and new skills or agents.
- **Never writes personal data** (paths, accounts, emails, ports); `scripts/check.sh` catches a local path, an email address or an account name before the commit, but not every port.

The maintainer closes pending approvals.

## Context schema

Written by the session to `.claude/reflector-context.json` before its final message, overwriting the last one:

```json
{
  "timestamp": "2026-10-09T10:00:00Z",
  "task": "Add a review-pr probe for the scratch clone",
  "response_summary": "Two or three sentences on what was done.",
  "files_accessed": { "code": ["plugins/rahal/agents/rahal-reviewer.md"], "docs": ["docs/checks.md"] },
  "files_modified": ["tests/probes/review-clone.sh", "scripts/required-files.txt"],
  "git_status_diff": "M  scripts/required-files.txt\n?? tests/probes/review-clone.sh",
  "friction_signals": [ { "type": "re_prompt", "detail": "Had to ask twice for the gate commands." } ],
  "outcome": "success",
  "notes": "Anything a future session should know."
}
```

`git_status_diff` is the verbatim `git status --porcelain=v1` of this repo, or `""` when clean. `friction_signals[].type` is one of `re_prompt`, `context_injection`, `wrong_file_accessed`, `partial_completion`, `explicit_correction`. `outcome` is `success`, `partial` or `failed`.

## Why outputs land in `reflector/` and `docs/`

The reflector runs with `acceptEdits`, so it can write without prompting. Its inputs live in `.claude/`, and it is forbidden to edit them; its outputs land only where §"What it may change" allows.
