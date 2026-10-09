# Reflector — pending approvals

Changes waiting for the maintainer's decision. Agents surface these at session start and never act on them. Format: `## YYYY-MM-DD — <title>` with **What / Why / Suggested action**.

---

## 2026-10-09 — Wrong GitHub account: stop outright, or offer a choice?

**What**: When step 0 finds `gh` signed in as an account other than the one in `.claude/rahal.local.md`, the plugin spec says the command must stop. The plugin plan's dry run expects three options instead: fix now, continue without that step, or stop. `plugins/rahal/shared/step-0-checks.md` currently ends every failed check with those three options.

**Why**: A command that runs on with the wrong account can read the wrong repos or post as the wrong person, so "continue" may be unsafe here even though it suits other checks.

**Suggested action**: Decide one behaviour for the account conflict. If it is "stop", add one line under check 2 in `shared/step-0-checks.md`, pinned in `scripts/required-headings.txt`.

---

## 2026-10-09 — Drafted review comments: adopt the issue-plus-example style for everyone?

**What**: The maintainer's own workspace rule for comments drafted on teammates' PRs is: state only the issue plus a concrete example; no @-mentions, review summary, fixes or suggestion blocks, should/must wording, or citations of other PRs or commits. The plugin's review template (`plugins/rahal/shared/templates/review-report.md`) still allows a `suggestion` block on a line inside the diff.

**Why**: Comment style is a team convention, not a personal one, once the plugin is shared.

**Suggested action**: Decide whether the plugin adopts the style for everyone. If yes, change the template's draft-comment guidance and `review-steps.md` step 7, pinning the new wording and forbidding "suggestion block".

---
