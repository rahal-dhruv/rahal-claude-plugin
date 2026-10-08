# Approval gates

What needs the user's yes. Read `choices` from `.claude/rahal.local.md`.

## Follows your choices

| Action | `ask` / `ask_each` | Other values |
| --- | --- | --- |
| Commit (`commit_when`) | ask before every commit | `standing_yes_per_ticket`: ask once after the plan is approved, then commit freely for that ticket · `never`: leave changes uncommitted and say so |
| Commit size (`commit_size`) | — | `natural_seams` (default): small commits at seams, grouping what must land together · `per_task` · `single` |
| Attribution (`attribution`) | — | `none`: no co-author line, no "Generated with" line · `claude`: add both |
| Push (`push`) | ask | `auto`: push once the gate has passed |
| Open the PR (`open_pr`, `pr_state`) | ask | `auto`: open right after the push · `pr_state`: `ready` or `draft` |
| Post a comment or reply (`post_comments`) | show the draft, post on yes | `auto`: post right after writing the draft. A reply that cites a commit is posted only once that commit is pushed |
| Re-request review (`re_request_review`) | ask | `auto`: re-request after the replies are posted |

## Fixed for everyone

- Planning stops before execution; `pr-followup` stops after its fix plan; review findings are shown before any fix.
- No force push. No `--no-verify`. Never `gh auth switch`. Never `git config`.
- Never edit the Linear ticket or a `scope/` folder.
- Every comment or reply is written to `work/<slug>/` before it is posted.
- After a push, read CI once and report it. Never poll.
- Any remote action without its own choice above, such as replacing a PR's description, asks every time.
- A session that cannot ask questions (a headless `claude -p` run): print the question and stop. Never assume an answer.
