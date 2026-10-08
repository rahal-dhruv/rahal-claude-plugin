# init — the personal choices

Ask one group per question. Show the defaults; accept "keep" or a change per item.

## Group 1 — Commits

- **When to commit** (`commit_when`): `ask_each` — ask before each commit · `standing_yes_per_ticket` *(default)* — ask once after the plan is approved, then commit freely for that ticket · `never` — leave the changes for me.
- **Commit size** (`commit_size`): `natural_seams` *(default)* — small commits at natural seams, grouping what must land together · `per_task` — one per plan task · `single` — one at the end.
- **Attribution** (`attribution`): `none` *(default)* · `claude` — add a Claude co-author line and a "Generated with Claude Code" line.

## Group 2 — GitHub actions

For each: `ask` *(default)* — ask every time · `auto` — do it automatically.
- **Push** (`push`); `auto` pushes once the gate has passed.
- **Open the PR** (`open_pr`), and whether it opens **ready** *(default)* or as a **draft** (`pr_state`).
- **Post a review comment or reply** (`post_comments`). The draft is always written to `work/` first; `auto` posts it straight after.
- **Re-request review after a follow-up** (`re_request_review`).

Not asked here: the review model. It is suggested and asked at each review; saying "always <model>" then saves it.
