---
name: review-pr
description: "Review any Orbit or corporate pull request against its Linear ticket, the repo's AGENTS.md and the code, without touching your checkout. Writes a report: what the ticket solves, what the PR does step by step with examples, issues at a glance in plain words, then each issue in detail with impact, example and dry run, plus drafted GitHub comments. An instruction in double quotes after the link adapts the run. Usage: /rahal:review-pr <PR link or number> [model=<name>] [\"<instruction>\"]"
argument-hint: '<PR link or number> [model=<name>] ["<instruction>"]'
disable-model-invocation: true
---

# /rahal:review-pr

Arguments: `$ARGUMENTS`. The first is the PR link (`https://github.com/DigitalZoneApp/<repo>/pull/<n>`), or a number, for which step 0 asks the repo when more than one family is configured. An optional `model=<name>` answers the review-model question for this run, and an optional instruction in double quotes adapts the run (`${CLAUDE_PLUGIN_ROOT}/shared/instructions.md`). If no PR was given, ask for it and stop.

Plugin root: `${CLAUDE_PLUGIN_ROOT}`. If that appears unexpanded, the plugin root is two folders above this skill's base directory.

Read:
- `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/explanation-style.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/approval-gates.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/instructions.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/evidence.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/review-model.md`
- the profile of the family step 0 routed to: `${CLAUDE_PLUGIN_ROOT}/shared/profiles/orbit.md` or `${CLAUDE_PLUGIN_ROOT}/shared/profiles/corporate.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/review-pr/references/review-steps.md`, and follow it step by step.

After step 0 (`review-steps.md` step 1), print `Instruction — read as:` (`${CLAUDE_PLUGIN_ROOT}/shared/instructions.md` → Reading it).

This command changes nothing in any repo. Posting comments follows `choices.post_comments`.
