# ORB-<n> <Feature Name> Implementation Plan

**Goal:** <one sentence>
**Approach:** <2–3 sentences>
**Tech stack:** <from the profile and the ticket>
**Ticket:** <link> · **Brief:** `work/<slug>/brief.md` · **Branch:** `feat/<slug>`
**Base:** `<main, or the blocker's branch>` · <stacked only: stacked on #<blocker PR> (ORB-<blocker n>)>

## Tasks at a glance

**Task 1 — <name>.** <2–4 lines: what it does, what is true afterwards, an example.> [Details →](#task-1-name)

<One entry like this per task. Its link is the task heading turned into an anchor: lower case, drop everything except letters, digits, spaces, `_` and `-`, spaces become `-`. For example "### Task 3: List, read and create" gives `#task-3-list-read-and-create`.>

## Global Constraints

- <Each exact value copied verbatim from the ticket: limits, sentences, key formats.>
- Must Not Change: <the ticket's list>

## Decisions

- **Open:** <none, or each with its options>
- **Decided:** <decision — what was chosen — by whom — date>
- **Made without asking:** <each, listed again in the PR body>

## Review Focus

1. <Input or condition no test covers, and the behaviour a reasonable person expects. Most likely first; five at most.>
- Extra test cases beyond the ticket's list: <each, marked keep or drop>

## Pre-flight

```bash
git -C <repo> fetch origin && git -C <repo> switch main && git -C <repo> merge --ff-only origin/main
git -C <repo> switch -c feat/<slug>
pnpm install --frozen-lockfile && pnpm db:generate
<docker compose up --wait with the configured ports; pnpm db:migrate with the dev database port>
```

### Task 1: <name>

**Files:** <create / modify / test, exact paths>
**Interfaces:** Consumes <…> · Produces <exact names and types later tasks use>

- [ ] **Step 1: Write the failing test** <code>
- [ ] **Step 2: Run it and watch it fail.** Run: `<command>` · Expected: <the failure and why>
- [ ] **Step 3: Write the code** <code>
- [ ] **Step 4: Run it and watch it pass.** Run: `<command>` · Expected: <pass>, then typecheck and lint
- [ ] **Step 5: Commit** `<type>(ORB-<n>): <title>` (when the commit choice allows)

## Self-check

- Every Must Have → <task>
- Every acceptance criterion → <test case>
- Must Not Change → <confirmed untouched>
