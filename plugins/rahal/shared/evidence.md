# Evidence

## Rules

- Report a check as passed only when its output was seen passing. Name the command, the result, and every step not run and why.
- An environmental failure (Docker, symlink permissions, process spawn, ports, a missing PATH entry) is labelled environmental. Prove the logic another way where possible. Never loop re-runs hoping for green.
- Library behaviour the change relies on is measured, never assumed: run the value through the installed package once in the scratchpad and record the command and result for the PR body (`AGENTS.md` requires it).
- Re-open every `file:line` a helper agent cites (`git show <rev>:<path>`) before the user sees it. Drop claims that don't hold.
- Before calling a git or process step "how we do it", check the repo's history (`git log origin/<default> --merges`, the order migrations landed in), not only `AGENTS.md`.
- Read the default branch, `AGENTS.md`, `CODEOWNERS` and the PR template from `origin/<default>` after a fresh `git fetch`, never from a stale local checkout.
- A test that passed before the code existed proves nothing: watch it fail first. When the code was already right, prove the test by breaking the code once (a mutation) and watching it fail.
- A test run's summary is not the whole result: a test file can fail in a hook, or vitest can report Errors, while every test passes. Read the `Test Files` and `Errors` lines, and the full log whenever either shows a failure.
