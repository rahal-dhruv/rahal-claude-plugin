# Ticket queue — <project> — <YYYY-MM-DD>

**For:** <your name> · **Lanes saved:** <all | A | A, C | not saved> · **Read:** <n> of your open tickets, <m> linked tickets, open PRs in backend and dashboard at <HH:MM>
**Instruction:** <"the instruction as typed" | none> <· ruled: <line> — <answer>, for each conflict answered>

A suggestion only: nothing in Linear or GitHub was changed.

## At a glance

<Two or three short lines for a non-technical reader, each with an example: what to start now, what can run beside it, what could start early on a stacked PR.>

## What the order rests on

<a> blocking links · priority set on <b> of <c> tickets · ticket number breaks the remaining ties · estimates, due dates and descriptions are not used

## Finish first

- ORB-<n> <title> — <in progress | in review | in rework | merged, in QA: verify on main> · <PR #<k> (<review state>) | no open PR | PRs not read>

## Pick order

1. ORB-<n> <title> — <reasons joined by " · ">

## Lanes

- **Lane A:** ORB-<n> (start now) → ORB-<n> → ORB-<n>

Which files each ticket touches is unknown until `/rahal:start-work` reads the code.
<When two or more lanes hold [Backend] tickets: Backend lanes that add or change routes all regenerate `openapi/admin.json`: expect a conflict there at merge, fixed by regenerating.>
<For each relatedTo link between lanes: ORB-<n> (lane B) is related to ORB-<n> (lane A): check they don't change the same code.>

## Stack candidates

- **ORB-<n>** can stack on #<k> (`<branch>`, ORB-<n>, <owner's | yours>) · <draft | not a draft> · <review state> · <merge state>. <Recommendation.>
  Run `/rahal:start-work ORB-<n>` and answer **Stack** when it asks *Wait or stack?*.
  When #<k> changes, merge its branch into yours (never rebase). When #<k> merges, GitHub moves your PR to the default branch; merge `origin/<default>` in once.
- ORB-<n> can't stack: <reason>.

## Blocking you

- **ORB-<n>** <title> — <owner | unassigned> · <status> · <project, when not this one> · <PR #<k> | no open PR | PRs not read> · holds up your ORB-<n>. <Suggestion.>

## Waiting on you

- <owner>'s **ORB-<n>** waits on your ORB-<n>.

## Can't order

- <ORB-<n> → ORB-<n> → ORB-<n> (a loop) | ORB-<n>: behind ORB-<n>, which is in a loop>

## Data gaps

- <unknown status, missing repo tag, failed read, unread blocker, PR list cut off at 100, Code Review with no open PR, QA with an open PR, PRs not read, left out by your instruction: ORB-<n> (<why>)>

<A section with nothing to list says "None.">
