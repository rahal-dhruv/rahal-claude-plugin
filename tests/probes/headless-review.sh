#!/usr/bin/env bash
# Runs the headless code-review block (review-model.md step 2) with a stand-in `claude` that records the
# folder it was started in and its arguments, then runs step 4's ReportFindings count on two streams.
# Passes when the run starts in the review clone, asks for `high review-target` without --fix or --comment, turns hooks off,
# and the count is 1 for a stream with a ReportFindings call and 0 for one without.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/shared/review-model.md}"
T="$(mktemp -d)/headless review"; mkdir -p "$T/scratch/review-abc123" "$T/bin"
W="$T/scratch/review-abc123"
block() { # <start pattern> → the first bash block after it, placeholders filled
  awk -v pat="$1" '$0 ~ pat {s=1} s&&/^   ```bash$/{p=1;next} p&&/^   ```$/{exit} p' "$MD" \
    | sed -e 's/^   //' -e "s#<scratchpad folder>#$T/scratch#g" -e 's#<head SHA>#abc123#g' -e 's#<model>#opus#g'
}
{ printf 'W="%s"\n' "$W"; block '^2\\. \\*\\*Start `code-review` headless'; } > "$T/run.sh"
block '^4\\. \\*\\*When both have finished' > "$T/count.sh"
grep -q 'claude -p' "$T/run.sh" || { echo "FAIL no headless block found in ${MD##*/}"; exit 1; }
grep -q 'ReportFindings' "$T/count.sh" || { echo "FAIL no ReportFindings count found in ${MD##*/}"; exit 1; }
cat > "$T/bin/claude" <<'STUB'
#!/usr/bin/env bash
pwd -P > "$STUB_DIR/cwd"
printf '%s\n' "$@" > "$STUB_DIR/args"
cat "$STUB_DIR/stream"
STUB
chmod +x "$T/bin/claude"
export STUB_DIR="$T"
FAILS=0
printf '%s\n' '{"type":"system","subtype":"init"}' \
  '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t1","name":"ReportFindings","input":{"findings":[]}}]}}' > "$T/stream"
PATH="$T/bin:$PATH" bash "$T/run.sh" > /dev/null 2>&1
[ "$(cat "$T/cwd" 2>/dev/null)" = "$(cd "$W" && pwd -P)" ] \
  || { echo "FAIL the headless run started in [$(cat "$T/cwd" 2>/dev/null)], not the review clone"; FAILS=$((FAILS + 1)); }
grep -qx '/code-review high review-target' "$T/args" 2>/dev/null \
  || { echo "FAIL the headless run does not ask for exactly /code-review high review-target"; FAILS=$((FAILS + 1)); }
grep -qE -- '--fix|--comment' "$T/args" 2>/dev/null && { echo "FAIL the headless run passes --fix or --comment"; FAILS=$((FAILS + 1)); }
grep -A1 -x -- '--settings' "$T/args" 2>/dev/null | grep -qx '{"disableAllHooks":true}' \
  || { echo "FAIL the headless run does not turn hooks off with --settings"; FAILS=$((FAILS + 1)); }
[ "$(bash "$T/count.sh" 2>/dev/null)" = 1 ] || { echo "FAIL the count is not 1 for a stream with ReportFindings"; FAILS=$((FAILS + 1)); }
printf '%s\n' '{"type":"system","subtype":"init"}' '{"type":"result","result":"the skill returned no output"}' > "$T/scratch/code-review-abc123.jsonl"
[ "$(bash "$T/count.sh" 2>/dev/null)" = 0 ] || { echo "FAIL the count is not 0 for a stream without ReportFindings"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "headless-review: all clear"; else echo "headless-review: $FAILS problem(s)"; exit 1; fi
