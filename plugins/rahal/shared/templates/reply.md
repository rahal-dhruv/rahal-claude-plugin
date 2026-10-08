# Reply shapes

Write one file per comment: `work/<slug>/reply-<date>-<reviewer>-<comment id>.md`. Each is posted into that comment's thread. Never mention other PRs or issues by number.

## When the comment was fixed

Fixed in `<fix commit SHA>`. <What changed, in one or two sentences.>

Proved by <the test case name>: <the assertion line that proves it, in a code block>. Before the fix it answered <the red result>.

<If the branch was updated: "The branch also merges `main` in `<merge SHA>`.">

`pnpm check` on `<head SHA>`: <lint, prettier, typecheck, knip; unit <files/tests>; e2e <files/tests>; contract <files/tests>; openapi:check clean>.

## When pushing back

Evidence: <command → result that shows the code already behaves correctly, or why the change would break something>.

<One or two sentences on what we keep and why, and what would change our mind.>
