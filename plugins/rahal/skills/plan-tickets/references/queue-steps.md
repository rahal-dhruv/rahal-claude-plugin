# plan-tickets — steps

Run these after step 0. Write in the style of `explanation-style.md`.

Every Linear call passes `fields`: a `get_issue` without them returned about 69,000 characters. Never ask for `description`: one ticket's is about 66,000 characters and overflows the call, losing its links with it.

## Statuses

ORB's statuses and how this command reads them. A status not listed here is read by its kind (`statusType`) and named in Data gaps.

| Status | Kind | Read as |
| --- | --- | --- |
| Triage, Backlog | `triage`, `backlog` | open; ordered like Todo; marked `(Triage)` or `(Backlog)` |
| Todo | `unstarted` | open |
| On Hold | `unstarted` | open and parked: marked `(On Hold)`; placed after the other tickets ready at the same time (step 7, key 1) |
| In Progress | `started` | open, blocking; "in progress" |
| Code Review | `started` | open, blocking; "in review" |
| Rework | `started` | open, blocking; "in rework" (changes requested) |
| QA Staging, QA UAT | `started` | merged, in QA: does not block; "merged, in QA: verify on main" |
| Ready for Release, Done | `completed` | closed |
| Canceled | `canceled` | closed |
| Duplicate | `duplicate` | closed |

- **Open:** kind `triage`, `backlog`, `unstarted` or `started`.
- **Blocking:** open, and not QA Staging or QA UAT.
- **Closed:** anything else. An `ORB-<n>` missing from step 3's table is closed.

## 1. Your tickets

`list_issues(team: "ORB", assignee: "me", limit: 250, fields: [id, title, status, statusType, priority, project, assignee, assigneeId])`, following `cursor` while `hasNextPage` is true. This is step 0's Linear proof.
- Your `assigneeId` decides every "yours" and "same owner" below. Never match people by name: `assignee` is a name for some people and an email for others.
- Your open tickets are the rows whose kind is open. None at all: say "You have no open ORB tickets." and stop.

## 2. Ask which project

List the projects that hold your open tickets, most open first, each with its count, and ask:

```
Which project? You have open tickets in 2:
  1. Visas (you: 5 open)
  2. Foundation (you: 1 open)
```

Add `(no project)` as an entry when some of your open tickets have no project. Take a number or a name, ignoring case. An answer that matches no entry, or several, gets the list again. Wait for the answer; never pick for the user.

An instruction that names a project answers this question (`${CLAUDE_PLUGIN_ROOT}/shared/instructions.md`): print the list all the same, then `Answered by your instruction: <project>`.

## 3. The open-ticket table

Four calls, one per open kind: `list_issues(team: "ORB", state: "<kind>", limit: 250, fields: [id, status, statusType, assignee, assigneeId, project])` for `triage`, `backlog`, `unstarted` and `started`, each following `cursor`. Together they hold every open ORB ticket's status, owner and project. Titles come from step 1 and from relation entries.

If any of the four calls fails or stops before its last page, stop and say which kind could not be read: without the full table, a missing ticket can't be told apart from a closed one.

## 4. Your tickets' links

For each of your open tickets in the chosen project: `get_issue(id: "ORB-<n>", fields: [id, relations])`. `relations` holds `blockedBy`, `blocks` and `relatedTo`, each entry `{id, title}`. `relatedTo` serves only the related-ticket caveat in step 8.

A failed read: mark the ticket "links unknown", order it by its other keys, and name it in Data gaps.

## 5. One step out

For each blocking ticket in step 4's `blockedBy` lists that is not yours (someone else's, unassigned, or in another team), in ticket-number order, at most 25: `get_issue(id, fields: [id, relations])`. A non-ORB id is not in the table, so ask for `fields: [id, title, status, statusType, assignee, assigneeId, relations]`. Name in Data gaps every blocker past the 25th ("ORB-x: links not read") and every failed read.

A non-ORB blocker that was not read (past the 25th, or a failed read) has an unknown status: count it as blocking, so the tickets it blocks never earn `can start now`.

## 6. Open PRs

Once per code repo, `rahal-orbit-backend` and `rahal-orbit-dashboard`:

```bash
GH_CONFIG_DIR="<github.gh_config_dir>" gh pr list --repo DigitalZoneApp/<repo name> --state open --limit 100 --json number,title,headRefName,baseRefName,isDraft,reviewDecision,mergeStateStatus,url
```

- Drop the `GH_CONFIG_DIR="…"` prefix when `github.gh_config_dir` is empty.
- A PR belongs to every `ORB-<n>` whose `orb-<n>` appears in its title or `headRefName`, ignoring case, matched as a whole number: `orb-10` does not match `orb-103`. Never use Linear's `gitBranchName` or attachments for this.
- Exactly 100 PRs back: "PR list may be cut off at 100" in Data gaps.
- A failed call, or GitHub skipped at step 0: that repo's PRs are unknown, not absent. For its tickets, write "PRs not read" wherever "no open PR" would go (Finish first, Blocking you); Stack candidates says "None: PRs not read (<reason>)."; Blocking-you rule 3 becomes "PRs not read: ask <owner> where it stands."; skip the Code Review and QA checks in the next bullet for that repo; and Data gaps names the repo.
- A Code Review ticket with no open PR: "ORB-x is in Code Review but has no open PR (merged or closed? its status may be stale)" in Data gaps. A QA ticket whose PR is still open: "ORB-x is in QA but PR #<k> is still open: check it merged" in Data gaps; it still counts as merged.

## 7. Order the tickets

**The set** is your open tickets in the chosen project.
- **Finish first:** the started ones. Show each with its status in plain words and its open PR (`#<k>`, review state), or "no open PR". A QA ticket shows "merged, in QA: verify on main". Don't reorder them.
- **Pick order:** the rest, numbered from 1.

**The link graph** holds every `blockedBy` and `blocks` link from steps 4 and 5 whose two tickets are both blocking. Count each link once, though both of its tickets report it.

**Predecessor:** P is a predecessor of T when a chain of links in the graph leads from P to T, with P and T both in the set. The chain may pass through tickets outside the set: someone else's, unassigned, or yours in another project. Example: your ORB-206 blocks Sam's ORB-210, which blocks your ORB-208, so ORB-206 precedes ORB-208. A predecessor in Finish first counts as already placed.

**Waits on someone else:** T has a direct blocking `blockedBy` ticket outside the set.

**Can start now:** every direct `blockedBy` ticket of T is closed or in QA. Only this earns the reason `can start now` and a lane's `(start now)`. Example: ORB-207, blocked by your in-progress ORB-206, waits on nobody else but can't start now.

A ticket marked "links unknown" never earns `can start now` or `(start now)`: its blockers were not read.

An On Hold ticket never earns `can start now` or `(start now)` either: it is parked.

**Place the tickets one at a time:**
1. The candidates are the Pick order tickets whose predecessors are all placed.
2. Place the candidate that comes first by these keys, in order:
   1. not On Hold, before On Hold;
   2. doesn't wait on someone else, before does;
   3. unblocks more: the number of distinct blocking tickets, anyone's, that name it in `blockedBy`;
   4. priority: Urgent, High, Medium, Low, then No priority;
   5. the lower ticket number.
3. Repeat. When tickets remain but none is a candidate, put every remaining one under Can't order with its reason: the loop written out (`ORB-208 → ORB-209 → ORB-208`), or "behind ORB-208, which is in a loop".

**Each entry** is `<n>. ORB-<id> <title> — <reasons joined by " · ">`. Drop the title's leading emoji and keep its `[Backend]`-style tag. The reasons, in this order, each only when true:
- `(On Hold)`, `(Backlog)` or `(Triage)`;
- `links unknown`, when step 4 could not read its links;
- `can start now`;
- `after your ORB-x (step k)`, or `after your ORB-x (in progress)`, `(in review)`, `(in rework)`;
- `waits on <owner>'s ORB-x (<status>[, #<k>])`, `waits on your ORB-x in <project> (<status>)`, or `waits on unassigned ORB-x (<status>)`;
- `ORB-x is merged, in QA: verify on main`;
- `unblocks <k> (<ids, with the owner when not yours>)`;
- the priority name, when set.

Every entry gets at least one reason; a ticket with none of the above gets `no links or priority`.

Show an owner as the `assignee` value, or the part of an email before `@`.

**What the order rests on** is one line: `<a> blocking links · priority set on <b> of <c> tickets · ticket number breaks the remaining ties · estimates, due dates and descriptions are not used`.

## 8. Lanes

- Two tickets of the set share a lane when a predecessor chain joins them, either way round. Name lanes A, B, C in the order of their first Pick order ticket; a lane of Finish first tickets only comes last.
- Write each lane in pick order, Finish first tickets at its head, marked `(in progress)`, `(in review)`, `(in rework)` or `(in QA)`. Show forks: `ORB-206 → ORB-207, then ORB-208 and ORB-209 (both after 207)`.
- Mark `(start now)` on each ticket that can start now and isn't started.
- Under the lanes, always: "Which files each ticket touches is unknown until `/rahal:start-work` reads the code."
- When two or more lanes hold `[Backend]` tickets, add: "Backend lanes that add or change routes all regenerate `openapi/admin.json`: expect a conflict there at merge, fixed by regenerating."
- For each `relatedTo` link between tickets in different lanes, add: "ORB-203 (lane B) is related to ORB-206 (lane A): check they don't change the same code."

## 9. Stack candidates

A ticket's repo comes from the tag after the title's emoji: `[Backend]` → `rahal-orbit-backend`; `[Frontend]` or `[Dashboard]` → `rahal-orbit-dashboard`; `[Cross]` → both. No tag: both, each entry saying "if this ticket is <repo> work", and Data gaps names the ticket.

Check each Pick order ticket that has a blocking `blockedBy` ticket, in each repo its tag names. It **can stack** in a repo when both hold:
- every one of its blocking `blockedBy` tickets has exactly one open PR in that repo;
- those PRs form one chain: each PR except the bottom one is based on another's `headRefName`.

The top PR, the one no other PR builds on, is the base. This is start-work's own rule, so both commands agree.

Write each candidate like this:

```
- **ORB-217** can stack on #183 (`feat/orb-214-shared-booking-transactions`, ORB-214, Sam's) · not a draft · review required · clean. Stack if you can't wait.
  Run `/rahal:start-work ORB-217` and answer **Stack** when it asks *Wait or stack?*.
  When #183 changes, merge its branch into yours (never rebase). When #183 merges, GitHub moves your PR to `main`; merge `origin/main` in once.
```

Write "yours" in place of "Sam's" when the blocker is your own ticket. The recommendation comes from the top PR:
- **`reviewDecision` `APPROVED` and `mergeStateStatus` `CLEAN`:** "Likely merges soon; waiting is cheaper."
- **`APPROVED`, but `DIRTY` or `BEHIND`:** "Approved, but it conflicts with main or is behind it, so it will change before it merges."
- **`CHANGES_REQUESTED`:** "Its code will still change; you'd merge its branch into yours after each change."
- **Anything else, or a draft:** "Stack if you can't wait."

Stacking is never the default: the recommendation comes before the how-to.

For a blocked ticket where at least one blocker has an open PR but the ticket can't stack, write one line, `ORB-<n> can't stack: <reason>`. The reason is one of:
- two PRs that don't form one chain: "a branch can start from only one of them; wait for one to merge";
- a blocker with no open PR: "ORB-x has no open PR yet";
- the PR is in another repo: "ORB-103's PR is in the backend; a dashboard branch can't start from it";
- a blocker with two open PRs in the repo: "two open PRs; pick one".

## 10. Other people's tickets

**Blocking you:** each blocking ticket outside your own, someone else's or unassigned, that is a direct `blockedBy` of a ticket in the set. Give its owner, status, project when not the chosen one, open PR if any, and which of your tickets it holds up. Then one suggestion; the first rule that fits wins:
1. It has a blocking `blockedBy` ticket of its own (from step 5): "Taking it over won't help yet: it waits on ORB-101 (Lee, Todo)."
2. It has an open PR: "It has PR #146 (<review state>): offer to help review it." Add "or stack on it: see Stack candidates" only when a candidate there uses that PR.
3. Started, with no open PR. In Progress: "Ask Sam about timing, and offer to pair on it." Rework: "Sam is reworking it after review: ask about timing, and offer to pair."
4. Unassigned: "Nobody owns it: you could pick it up."
5. Not started: "ORB-103 is Sam's and holds up 2 of yours: ask Sam to take it on together, or to hand it over." If it's On Hold: "It's On Hold: ask Sam why, since it holds up 2 of yours."

A blocker whose step 5 read failed or was cut off can't use rule 1; Data gaps already names it.

**Waiting on you:** each blocking ticket outside your own that names a ticket of the set in `blockedBy`, written like "Sam's ORB-210 waits on your ORB-206."

These are suggestions in text only. Never reassign, comment on or change any ticket or PR, and never message anyone.

## 11. Show the queue and ask to save

Show the whole queue in chat, laid out as `${CLAUDE_PLUGIN_ROOT}/shared/templates/ticket-queue.md`, with `**Lanes saved:** not saved`. Then ask, recommending the lane that holds Pick order step 1:

```
Save this ticket queue? all lanes · lane A only (recommended: it holds your first pick) · lanes … (name them) · don't save
```

- **Don't save:** write nothing, and end.
- **A headless run** (`claude -p`): print the queue and the question, then stop.
- **On a save:**
  - **All lanes:** set `**Lanes saved:** all`.
  - **Path:** write `<workspace_root>/<work_folder>/ticket-queue/<project slug>-<YYYY-MM-DD>.md`, creating the folder if needed. The slug is the project name in lower case, with each run of other characters turned into one `-` and none at either end: `Car Rentals` → `car-rentals`, and `(no project)` → `no-project`.
  - **If the file exists:** ask "replace it, or keep both?". Keeping both writes `-2.md`, `-3.md` and so on, the first free name.
  - **Chosen lanes:** each section lists only those lanes' tickets, and `**Lanes saved:**` names them. Pick order keeps the numbers shown in chat. A section left with nothing says "None.".
  - **Headings:** every heading of the template stays.
  - **Afterwards:** print the path written.
