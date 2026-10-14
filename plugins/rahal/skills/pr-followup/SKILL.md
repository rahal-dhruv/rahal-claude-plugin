---
name: pr-followup
description: "Handle reviewers' comments on an Orbit pull request in two phases: (1) rebuild the context from GitHub, Linear and the repo, verify each comment, and write a fix plan with the comments at a glance and a detailed fix for each, then stop for you to accept items; (2) update the branch from its base (main, or the blocker's branch for a stacked PR) if accepted, fix test-first, run the gate and an internal review, and draft the replies. Usage: /rahal:pr-followup <PR link or number> [model=<name>]"
argument-hint: "<PR link or number> [model=<name>]"
disable-model-invocation: true
---

# /rahal:pr-followup

Arguments: `$ARGUMENTS`. The PR link or number, and an optional `model=<name>` for the internal review in phase two. If no PR was given, ask for it and stop.

Plugin root: `${CLAUDE_PLUGIN_ROOT}`. If that appears unexpanded, the plugin root is two folders above this skill's base directory.

Always read:
- `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/explanation-style.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/approval-gates.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/evidence.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/profiles/orbit.md`

No local file is assumed. The ticket folder (`${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md` → The ticket folder) receives the outputs; read it for extra context if it already exists.

## Which phase

Look at the latest `followup-*.md` in the ticket folder:
- **None, or it ends with a `Handled:` line:** phase one. Read `${CLAUDE_PLUGIN_ROOT}/skills/pr-followup/references/phase-1-analyse.md`.
- **It has no `Accepted:` line:** its question is still open. When the user has just answered it (for example "0, 1, 2", or "1 only, push back on 2"), go to phase two: read `${CLAUDE_PLUGIN_ROOT}/skills/pr-followup/references/phase-2-fix.md`. Otherwise show it again and stop.
- **It has `Accepted:` but no `Handled:` line:** phase two is unfinished. Read `${CLAUDE_PLUGIN_ROOT}/skills/pr-followup/references/phase-2-fix.md` and resume at the first step the ledger does not record as done.
