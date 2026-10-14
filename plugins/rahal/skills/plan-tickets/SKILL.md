---
name: plan-tickets
description: "Suggest how to work through your open Orbit Linear tickets in one project, read-only: the order to pick them in with a reason for each, lanes you can work on in parallel, blocked tickets that could start now as a stacked PR on an open blocker's branch, and tickets owned by others that block or wait on yours, with a suggestion to work on them together. Shown in chat; saved only if you choose. Usage: /rahal:plan-tickets"
argument-hint: "(none; it asks which project)"
disable-model-invocation: true
---

# /rahal:plan-tickets

Arguments: `$ARGUMENTS`. This command takes none. If any were given, say "plan-tickets takes no arguments; it asks which project." and carry on.

Plugin root: `${CLAUDE_PLUGIN_ROOT}`. If that appears unexpanded, the plugin root is two folders above this skill's base directory.

This command only reads. Its only tools are Linear's `list_issues` and `get_issue`, and `gh --version`, `gh auth status` and `gh pr list`; its only write is the file you choose to save.

Read:
- `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/explanation-style.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/approval-gates.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/profiles/orbit.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/templates/ticket-queue.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/plan-tickets/references/queue-steps.md`, and follow it step by step after step 0.

## Step 0 for this command

Run step 0 checks 1–3 from `step-0-checks.md` with these differences, then print checks 4 and 5 as not needed:
- **Check 1, Config:** as written.
- **Check 2, GitHub:** items 1 and 2 only. Skip item 3 (`gh repo view`): a failing `gh pr list` in step 6 shows the same problem. Item 4 is for PR commands. Print it as `✓ GitHub      gh signed in as <account>`.
- **Check 3, Linear:** load `<linear.tools>list_issues` and `<linear.tools>get_issue`; item 2 still finds renamed tools, but don't offer to record a new prefix: say that `/rahal:init` records it. In place of items 4 and 5, step 1 of `queue-steps.md` is the proof, and its line reads `✓ Linear      read your <n> ORB tickets`. The team is ORB, from the profile.
- **Checks 4 and 5:** print `– Git         not needed: this command reads no repo` and `– Toolchain   not needed: this command runs no code`.

When a check fails, follow step 0's "When a check fails". Linear failing stops the run. If GitHub fails and the user chooses "continue", no PRs are read; `queue-steps.md` step 6 says what the queue shows then.
