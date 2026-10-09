# Review model

Used before every review run: the end of `start-work` execution, `review-pr`, and `pr-followup` phase two.

## How to ask

Skip the question when:
- the command was started with `model=<name>` (that run only); or
- `choices.review_model` holds a model (a standing choice).

Otherwise suggest one model from what the change contains, and ask:

```
Review model — recommended: Opus
  Why: 36 files, a migration, row locks and a public upload; these need the most careful pass.
  Sonnet would be cheaper but is likelier to miss the transaction and lock issues.
Use Opus? (or name another; say "always <model>" to stop being asked)
```

Rule of thumb:
- **Haiku or Sonnet:** small, low-risk changes, such as docs, config, a few files, no database, permissions, money or storage.
- **Opus:** normal features, and anything with migrations, locks or transactions, auth or permissions, money, public storage, concurrency, or a large diff.
- **Fable:** may be suggested for an unusually large or subtle change. Name the extra cost.

The user decides. "Always <model>" writes `choices.review_model: <model>` into `.claude/rahal.local.md` and stops the question.

## How to run the review

1. Run the reviewer agent, once: the Agent tool with `subagent_type: "rahal:rahal-reviewer"` and `model: <chosen model>`. In that one pass it runs `code-review` at effort `high` on the chosen model, then checks the change against the ticket. There is no second review run in this session. Its prompt holds:
   - the ticket text;
   - the plan path, if any;
   - the repo folder and its default branch name;
   - the base and head SHAs (fetch first, so `origin/<default>` and the head are current);
   - this session's scratchpad folder (the agent builds its review clone there);
   - `AGENTS.md` read from `origin/<default>`;
   - the plan's Review Focus, if any;
   - the ledger's rulings, if any;
   - existing PR comments, if any.
2. Read its first line. `code-review: not run — <reason>` means the review covers the ticket checks only: say so in the report header and never call the result clean.
3. Re-open every citation it returns (`shared/evidence.md`), and probe, mutate or dry-run where a claim needs it.
4. Write the result with `${CLAUDE_PLUGIN_ROOT}/shared/templates/review-report.md`.
