# Review — PR #<n> · <PR title>

At <head SHA> · <open | merged> · CI <green | red | running> · by <author> · reviewed with <model>: code-review (high) plus ticket checks

## 1. What the ticket is trying to solve

<One plain paragraph and an example of what changes for its users.>

## 2. What the PR does

1. <Area or commit — 2–4 lines with an example, e.g. "POST { countryCode: 'AE' } → 201; a second one → 409".>
2. <…>

Against the ticket: Must Haves present <n/n> · Must Not Change <untouched | which changed> · acceptance criteria with a test <n/n> · CODEOWNERS files touched <none | which>.

## 3. Issues at a glance

Verdict: <ready to merge | ready with fixes | not ready> — <n> blocking, <n> should fix, <n> minor, <n> follow-up.

1. <Severity> — <2–3 plain, non-technical lines>. Example: <everyday example>.
2. <…>

## 4. Issues in detail

### 1. <title> — <Blocking | Should fix | Minor | Follow-up> · <live | latent>

- **Where:** <file:line> (<caller; test that exercises it>)
- **What's going on:** <mechanism>
- **Impact:** <who sees what>
- **Example:** <input → wrong output>
- **Dry run:** <step by step with real values>
- **How checked:** <command → result>
- **Fix:** <change, and the test that would prove it>

<details><summary>Draft GitHub comment</summary>

<Standalone text. A `suggestion` block only when the line is inside the diff's hunks. No mention of other PRs.>

</details>

## 5. Already raised by other reviewers

- <reviewer — point — where; not repeated above>

## 6. Considered and set aside

- <behaviour — why it was set aside>
