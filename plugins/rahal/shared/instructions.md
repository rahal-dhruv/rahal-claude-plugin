# Instructions

An optional instruction in double quotes adapts one run of `start-work`, `review-pr` or `pr-followup`, after the link, and of `plan-tickets`, which takes no link:

```
/rahal:pr-followup <PR link> model=opus "merge the blocker branch first; keep replies under 3 lines"
/rahal:plan-tickets "only the Visas project; skip On Hold"
```

The command applies what fits, records the instruction so a later run still follows it, and asks only when a part of it conflicts with a rule.

## Reading it

1. In `$ARGUMENTS` the link comes first, `model=<name>` may follow, and the instruction is the text between double quotes. Text after the link that is neither `model=` nor quoted is read as the instruction too; say `Read the unquoted text as your instruction: "<text>"`.
2. With no instruction given, use the recorded one (Where it is recorded). When a new one differs from the recorded one, show both and ask `add (both apply) · replace (only the new one) · ignore (keep the recorded one)`. The instruction `"none"` clears the recorded one without asking.
3. Right after step 0's lines, split the instruction into actions and print one line per action: the action, its tier (What it can change), and the step it touches.

```
Instruction — read as:
  1. keep replies under 3 lines — wording, applied · phase two, step 7
  2. merge the blocker branch first — team practice (orbit.md → Branch practice), asked below · phase two, step 2
```

   With no instruction, print `Instruction — none`. A recorded one names its file: `Instruction — read as (recorded in plan.md):`.
4. Check every line against the tiers now, and again when the run reaches the step it touches: a conflict that shows only then (the branch turns out to be behind) is asked then.
5. A line that no step of the command does: say `<line>: <command> has no step that does this; ignored`. Never invent a step to carry it out.

## What it can change

Three tiers. When unsure which tier a line belongs to, use the stricter one.

**Never overridden.** No instruction changes:
- the rules in `approval-gates.md` → Fixed for everyone, among them the stops after planning, after the follow-up's fix plan and before fixing review findings;
- `evidence.md`;
- step 0 and its checks;
- the headings and lines of each template in `templates/`, and the drafting rules written there (no `suggestion` block in a drafted comment, no other PR named in a reply);
- the repo's `AGENTS.md`, which wins on code;
- the GitHub account, the ports and the gh config folder, which change only through `/rahal:init`;
- `plan-tickets`' read-only rule: it never changes, comments on or reassigns a ticket or PR.

**Overridden for this run, after a question:**
- a saved choice, `choices.*` in `.claude/rahal.local.md`, such as `push: ask`;
- the profile's practice (`profiles/orbit.md`), such as "a branch behind `main` merges `origin/main`";
- a decision already under the plan's Decided;
- what the ticket says: a departure from it, listed in the PR body as every departure is.

**Applied without asking:**
- wording, length and tone;
- focus: which files, risks, comments or tickets come first, or are left out;
- extra checks, tests or measurements;
- an answer to a question the command would ask, such as the project, "Wait or stack?", the review model or an open plan decision. Print the facts the question would show all the same, then `Answered by your instruction: <answer>`, and carry on. The stops above are not questions an instruction can answer.

What an instruction leaves out of an output is named there ("left out by your instruction: ORB-206 (On Hold)"), never dropped silently.

## When it conflicts

Ask one conflict at a time, in this shape, and wait for the answer:

```
Instruction conflict 1 of 1 — team practice (orbit.md → Branch practice: a branch behind main merges origin/main)
  Now:       item 0 merges origin/main; the PR diff shows only ORB-185's commits.
  You asked: "merge the blocker branch first"
  It would:  merge feat/orb-184-… in; the diff shows ORB-184's commits until it lands; the PR body must say so.
  Options:   1. apply it this run only · 2. keep the practice, do the rest · 3. wait for ORB-184 to merge, then merge main
  Recommend: 3 — reviewers see only this ticket's change.
```

- **Now** is what the run does without the instruction, and **It would** what changes, step by step, including what a reviewer or teammate sees.
- **A never-overridden rule** offers only `1. do the rest without it · 2. stop`, and names the rule. For the account, a port or the gh folder, add that `/rahal:init` changes it.
- **A saved choice** also offers `save as my choice`, which writes the new value under `choices` in `.claude/rahal.local.md` after a yes, so it stops conflicting.
- Recommend one option and say why in one line.
- A headless run (`claude -p`) prints the question and stops (`approval-gates.md`).

## Where it is recorded

So a resumed run, a new session or the next round follows the same instruction:
- **The instruction as typed,** or `none`, on the `Instruction:` line of each file the run writes from a template: `brief.md` and `plan.md` (start-work), `followup-<date>.md` (pr-followup), `review-<date>.md` (every review), and a saved ticket queue (plan-tickets).
- **The model** from `model=<name>`, as `Model:` beside it in `plan.md` and `followup-<date>.md`, or `ask` when none was given. A later run for the ticket uses it without asking again (`review-model.md`); a new `model=` replaces it.
- **Each conflict's answer:** in start-work phase one, under the plan's Decisions → Decided; after that, and in pr-followup, as an `Instruction: Ruling: …` line in `ledger.md`, created from its template if absent; in review-pr and plan-tickets, which keep no ledger, as `· ruled: <line> — <answer>` after the `Instruction:` line.
- **Which record a later run reads:** start-work reads the plan's line in every phase. pr-followup reads the latest `followup-*.md`'s line, in a new round too, and says `Instruction carried over from followup-<date>.md: "<text>"`. review-pr and plan-tickets start fresh on every run.
