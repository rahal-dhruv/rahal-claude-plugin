# ORB-<n> — <ticket title>

<status> · <assignee> · <project> › <milestone> · <ticket link>

## What it asks for

<One plain paragraph: the problem, and what changes for whoever uses it.>

- <Deliverable> — example: <request → response, or before → after>
- <Deliverable> — example: …

## Where it sits

- Blocked by: <ticket — status; merged? its open PR, if any>
- Base: <`main`, or stacked on #<blocker PR> (`<blocker branch>`)>
- Unblocks: <tickets — what each reuses from this one>
- Shares files with: <tickets — which files, e.g. `openapi/admin.json`>
- Size: <as the ticket states>

## What I checked

- main: <how far local main is behind>; <commits since the ticket's base commit that touch its files, or "none">
- Files and symbols the ticket names: <all exist on origin/<base>, or which are missing>
- Library behaviour measured: <command → result>, or "nothing the ticket relies on needed measuring"
- Drift: <each place the ticket and the code disagree>, or "none"

## The plan at a glance

**Task 1 — <name>.** <2–4 lines: what it does, what is true afterwards, an example.>

**Task 2 — <name>.** <2–4 lines with an example.>

## Decision 1 of <N> — <title>

**Verdict:** <blocking or not · live or latent>
**What's going on:** <mechanism>
**Where:** <file:line> (<caller or test>)
**Example:** <input → wrong output>
**Options:** <A — … · B — …>
**Recommendation:** <A or B, and why in one sentence>

<One line per remaining decision; each is asked after this one.>
