---
name: review-pr
description: "Review any Orbit pull request against its Linear ticket, the repo's AGENTS.md and the code, without touching your checkout. Writes a report: what the ticket solves, what the PR does step by step with examples, issues at a glance in plain words, then each issue in detail with impact, example and dry run, plus drafted GitHub comments. Usage: /rahal:review-pr <PR link or number> [model=<name>]"
argument-hint: "<PR link or number> [model=<name>]"
disable-model-invocation: true
---

# /rahal:review-pr

Arguments: `$ARGUMENTS`. The first is the PR link (`https://github.com/DigitalZoneApp/<repo>/pull/<n>`), or a number for `rahal-orbit-backend`. An optional `model=<name>` answers the review-model question for this run. If no PR was given, ask for it and stop.

Plugin root: `${CLAUDE_PLUGIN_ROOT}`. If that appears unexpanded, the plugin root is two folders above this skill's base directory.

Read:
- `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/explanation-style.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/approval-gates.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/evidence.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/review-model.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/profiles/orbit.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/review-pr/references/review-steps.md`, and follow it step by step.

This command changes nothing in any repo. Posting comments follows `choices.post_comments`.
