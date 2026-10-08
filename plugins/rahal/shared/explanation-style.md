# Explanation style

How every command explains things to the user.

## Every finding, decision or step

Write each one in this order:
1. **Verdict first:** blocking or not, live (happens today) or latent (needs a future change to bite).
2. **What's going on:** the mechanism, in plain words.
3. **Where:** `file:line`, plus the caller or test that exercises it.
4. **Example:** a concrete input and the wrong output it gives.
5. **Dry run** for data, byte or SQL issues: each step with real values (request → query → rows → answer).
6. **Fix:** the change, and the test that would prove it.

## Writing rules

- Plain prose. A table is only a closing summary, never the main answer.
- Explain every Claude Code or tooling term in plain words the first time it appears ("a marketplace is a small catalog file that tells `/plugin install` where a plugin lives").
- "At a glance" lines are for a non-technical reader: two or three short lines, each with an everyday example ("the list shows 'Dubai', but typing 'dub' finds nothing").
- Ask decisions one at a time, each with a recommendation and why. Never send a question with an unfilled `<pick one>` slot.
- In "Tasks at a glance", give each task 2–4 lines: what it does, what is true afterwards, an example.
- Say what was checked and how (command and result), not just the conclusion.
