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

1. The reviewer agent first. Use the Agent tool with `subagent_type: "rahal:rahal-reviewer"` and `model: <chosen model>`. Its prompt holds:
   - the ticket text;
   - the plan path, if any;
   - the base and head SHAs;
   - the repo folder;
   - `AGENTS.md` read from `origin/<default>`;
   - the plan's Review Focus, if any;
   - the ledger's rulings, if any;
   - existing PR comments, if any.
2. Then Claude Code's `code-review` skill at effort `high`, on the same change:
   - First `cd <repo>`, so its git commands see the repo; the workspace root is not one.
   - Give it the full PR URL (`https://github.com/DigitalZoneApp/<repo name>/pull/<n>`) when there is a PR; otherwise the range `<base SHA>..<head SHA>`.
   - Run every `gh` command it needs with step 0's `GH_CONFIG_DIR` prefix and `--repo`.
   - If it is not available (step 0 check 5), fails, or reports that it reviewed nothing, record it as **not run**, never as clean, and continue with the reviewer's findings only.
3. Merge the two lists and remove duplicates. Re-open every citation (`shared/evidence.md`), and probe, mutate or dry-run where a claim needs it.
4. Write the result with `${CLAUDE_PLUGIN_ROOT}/shared/templates/review-report.md`.
