---
name: start-work
description: "Work an Orbit Linear ticket end to end in three phases with stops: (1) understand the ticket against the code and write a brief and a test-first plan, then stop for decisions; (2) execute the plan with a ledger, the gate, guard checks and one review pass (the rahal reviewer, on the model you choose, runs code-review and checks the ticket), then stop with the findings; (3) ship under your commit and GitHub choices. Re-run it with the same link to resume; an instruction in double quotes after the link adapts the run and is kept for the ticket. Usage: /rahal:start-work <ORB ticket link> [model=<name>] [\"<instruction>\"]"
argument-hint: '<ORB ticket link> [model=<name>] ["<instruction>"]'
disable-model-invocation: true
---

# /rahal:start-work

Arguments: `$ARGUMENTS`. The first is the Linear ticket link (or an id like `ORB-185`). An optional `model=<name>` answers the review-model question for this ticket, and an optional instruction in double quotes adapts the run (`${CLAUDE_PLUGIN_ROOT}/shared/instructions.md`). If no link was given, ask for it and stop.

Plugin root: `${CLAUDE_PLUGIN_ROOT}`. If that appears unexpanded, the plugin root is two folders above this skill's base directory.

Always read:
- `${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/explanation-style.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/approval-gates.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/instructions.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/evidence.md`
- `${CLAUDE_PLUGIN_ROOT}/shared/profiles/orbit.md`

Then follow the workspace's own `CLAUDE.md` task-start steps if it has any.

## Which phase

Run step 0 check 1, read the ticket id, and find the ticket folder (`${CLAUDE_PLUGIN_ROOT}/shared/step-0-checks.md` → The ticket folder). Then:
- **No `plan.md`:** phase one. Read `${CLAUDE_PLUGIN_ROOT}/skills/start-work/references/phase-1-understand.md`.
- **`plan.md` with open decisions:** continue phase one from step 7 (ask the next decision).
- **Decisions done, `ledger.md` absent or without completed tasks:** ask "Ready to execute?". On yes, read `${CLAUDE_PLUGIN_ROOT}/skills/start-work/references/phase-2-execute.md`.
- **`ledger.md` with completed tasks:** resume phase two at the first task without a `complete` line. Trust the ledger and `git log` over memory.
- **Review findings recorded and not yet ruled on:** show them again and ask which to fix.
- **Gate green and findings settled:** phase three. Read `${CLAUDE_PLUGIN_ROOT}/skills/start-work/references/phase-3-ship.md`.

Every phase prints `Instruction — read as:` right after its step 0 (`${CLAUDE_PLUGIN_ROOT}/shared/instructions.md` → Reading it), from the instruction given now or, without one, the plan's `**Instruction:**` line.

Never move from one phase to the next without the stop that phase ends with.
