# Review model

Used before every review run: the end of `start-work` execution, `review-pr`, and `pr-followup` phase two.

## How to ask

Skip the question when:
- `model=<name>` was given now, or is recorded for this ticket as `Model:` in `plan.md` or the latest `followup-*.md` (`shared/instructions.md` → Where it is recorded); or
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

1. **Build the review clone.** `code-review` compares a branch against the local `<default>` branch. The user's local `<default>` may be behind, and a stacked change's real base is another branch, so in their repo it would report other people's merged changes, or the blocker's commits, as part of this one. Never run it in the user's repo. Fetch first, so `origin/<base>` and the head are current, then build a clone in this session's scratchpad folder that borrows the repo's objects, with `<default>` set to the fetched `origin/<base>` and no remote:

   ```bash
   W="<scratchpad folder>/review-<head SHA>"
   git clone --quiet --shared --no-checkout "<repo folder>" "$W"
   git -C "$W" checkout --quiet -b review-target <head SHA>
   git -C "$W" branch --force <default> "$(git -C "<repo folder>" rev-parse origin/<base>)"
   git -C "$W" remote remove origin
   ```

2. **Start `code-review` headless in the clone,** in the background (the Bash tool's `run_in_background`), on the chosen model (`<model>` is its short name, such as `opus` or `sonnet`). It runs as its own `claude` process started in the clone, because a `cd` made inside a helper agent does not carry into its next tool call:

   ```bash
   bash -c 'cd "$1" && claude -p "/code-review high review-target" --model "$2" \
     --allowedTools "Bash(git:*)" Read Grep Glob Agent --disallowedTools Edit Write \
     --settings "$3" --no-session-persistence --output-format stream-json --verbose' \
     _ "$W" "<model>" '{"disableAllHooks":true}' > "<scratchpad folder>/code-review-<head SHA>.jsonl"
   ```

   Hooks are off (`disableAllHooks`) because the findings come from the stream, not from any hook, and a user's hook could otherwise hand a refused tool's permission request to another app that holds it.

   Never add `--fix` or `--comment`: `--fix` edits files and `--comment` posts to GitHub. With `Edit`, `Write` and `gh` outside the allowed tools, a stray flag still cannot change files or post.
   - It takes about 3 minutes (160 s on Opus for an 11-file change). The status line says so and gives the expected finish time.
3. At once, so both run in parallel, start the reviewer agent: the Agent tool with `subagent_type: "rahal:rahal-reviewer"` and `model: <chosen model>`. It checks the change against the ticket, `AGENTS.md`, the plan and correctness; it does not run `code-review`. Its prompt holds:
   - the ticket text;
   - the plan path, if any;
   - the repo folder, its default branch name and the base branch (the PR's `baseRefName`, or the plan's `**Base:**` branch);
   - the base and head SHAs;
   - this session's scratchpad folder;
   - `AGENTS.md` read from `origin/<default>`;
   - the plan's Review Focus, if any;
   - the instruction's focus and extra checks, if any (`shared/instructions.md`);
   - the ledger's rulings, if any;
   - existing PR comments, if any.
4. **When both have finished,** count the `ReportFindings` calls in the stream:

   ```bash
   grep -c '"name":"ReportFindings"' "<scratchpad folder>/code-review-<head SHA>.jsonl"
   ```

   - It prints 0, or the process exited non-zero: write `code-review: not run — <reason, from the stream's last result event>` in the report header. The review then covers the ticket checks only: never call the result clean. Never read the run's final text instead: a plain-text run once said it returned no output.
   - Otherwise take `code-review`'s findings from that call's `input.findings` (each has `file`, `line`, `summary` and `failure_scenario`). Merge them into the agent's list, dropping duplicates, and write `code-review: ran at high on <head SHA>` in the report header.
5. Re-open every citation in the merged list (`shared/evidence.md`), and probe, mutate or dry-run where a claim needs it.
6. Remove the clone (`rm -rf "$W"`) and the stream file.
7. Write the result with `${CLAUDE_PLUGIN_ROOT}/shared/templates/review-report.md`.
