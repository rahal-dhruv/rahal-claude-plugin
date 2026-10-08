# PR #<n> follow-up — <k> comments to handle

<Branch: N behind main; trial merge conflicts: <files | none>> · <Ticket: unchanged | amended <time>: <what changed>> · <New rules on main since the branch: <commit — rule> | none>

## Comments at a glance

1. <Reviewer> — <2 plain lines: what they ask>. Recommend: <fix (blocking | not blocking) | push back | follow-up ticket>. <Departs from the ticket? say so.>
   Example: <everyday example>.
0. Branch update — <merge main first; which files conflict (generated?)> (only when the branch is behind)

## Detailed fixes

### 1. <Reviewer> · <file:line>

- **What they ask:** <plain words>
- **How I verified it:** <command → result>
- **Ticket:** <matches | departs from the ticket text — how to handle it>
- **Fix plan:** test first — <test change; the red result expected>; then <code change>. Commit: `<type>(ORB-<n>): <title>`
- **Alternative:** <push back, with the evidence> (when it is worth considering)
- **Reply draft:** <posted after the fix>

### 0. Branch update

- `git merge origin/main`; regenerate generated files (`pnpm db:generate`, `pnpm openapi`); `pnpm db:migrate` locally; typecheck and lint. A conflict outside generated files stops and asks.

Which do you accept? e.g. "0, 1, 2" · "1 only, push back on 2"
