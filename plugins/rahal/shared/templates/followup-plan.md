# PR #<n> follow-up — <k> comments to handle

<Base: main | stacked on #<n> (<open | merged | closed>, head <sha7>)> · <Branch: N behind <base>; trial merge conflicts: <files | none>> · <Ticket: unchanged | amended <time>: <what changed>> · <New rules since the branch on <base>: <commit — rule> | none; when stacked, also on main: <commit — rule> | none>

## Comments at a glance

1. <Reviewer> — <2 plain lines: what they ask>. Recommend: <fix (blocking | not blocking) | push back | follow-up ticket>. <Departs from the ticket? say so.>
   Example: <everyday example>.
0. Branch update — <merge <base> first, or, once the blocker has merged, retarget to main and merge main; which files conflict (generated?)> (only when the branch is behind or its blocker has merged)

## Detailed fixes

### 1. <Reviewer> · <file:line> · comment <id>

- **What they ask:** <plain words>
- **How I verified it:** <command → result>
- **Ticket:** <matches | departs from the ticket text — how to handle it>
- **Fix plan:** test first — <test change; the red result expected>; then <code change>. Commit: `<type>(ORB-<n>): <title>`
- **Alternative:** <push back, with the evidence> (when it is worth considering)
- **Reply draft:** <posted after the fix>

### 0. Branch update

- Merge `origin/<base>`, titled `chore(ORB-<n>): merge <main | orb-<blocker n>> into the <branch words> branch`; regenerate generated files (`pnpm db:generate`, `pnpm openapi`); check that `git diff origin/<base> -- openapi/` shows only this ticket's changes; `pnpm db:migrate` locally; typecheck and lint. A conflict outside generated files stops and asks.
- <Once the blocker has merged: retarget the PR to `main` before the push (asks every time), and merge `origin/main` instead.>

Which do you accept? e.g. "0, 1, 2" · "1 only, push back on 2"
