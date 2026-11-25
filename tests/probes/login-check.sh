#!/usr/bin/env bash
# Runs step 0 check 5's `claude -p "Reply ok"` block (step-0-checks.md) with a stand-in `claude` that records
# the folder it was started in and its arguments. Passes when the call starts in the scratchpad folder (so no
# project CLAUDE.md loads), turns every tool off (`--tools ""`, `--strict-mcp-config`) and every hook off
# (`--settings '{"disableAllHooks":true}'`), and the block prints the stand-in's reply.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/shared/step-0-checks.md}"
T="$(mktemp -d)/login check"; mkdir -p "$T/scratch" "$T/bin" "$T/workspace"
awk '/^5\. Review phases/ {s=1} s&&/^   ```bash$/{p=1;next} p&&/^   ```$/{exit} p' "$MD" \
  | sed -e 's/^   //' -e "s#<scratchpad folder>#$T/scratch#g" > "$T/run.sh"
grep -q 'claude -p' "$T/run.sh" || { echo "FAIL no login-check block found under check 5 in ${MD##*/}"; exit 1; }
cat > "$T/bin/claude" <<'STUB'
#!/usr/bin/env bash
pwd -P > "$STUB_DIR/cwd"
printf '[%s]\n' "$@" > "$STUB_DIR/args"
echo ok
STUB
chmod +x "$T/bin/claude"
export STUB_DIR="$T"
FAILS=0
out="$(cd "$T/workspace" && PATH="$T/bin:$PATH" bash "$T/run.sh" 2>&1)"
[ "$out" = ok ] || { echo "FAIL the block did not print the reply (got [$out])"; FAILS=$((FAILS + 1)); }
[ "$(cat "$T/cwd" 2>/dev/null)" = "$(cd "$T/scratch" && pwd -P)" ] \
  || { echo "FAIL the call started in [$(cat "$T/cwd" 2>/dev/null)], not the scratchpad folder"; FAILS=$((FAILS + 1)); }
grep -qx '\[Reply ok\]' "$T/args" 2>/dev/null || { echo "FAIL the call does not send the prompt Reply ok"; FAILS=$((FAILS + 1)); }
grep -A1 -x '\[--tools\]' "$T/args" 2>/dev/null | grep -qx '\[\]' \
  || { echo "FAIL the call does not turn every tool off with --tools \"\""; FAILS=$((FAILS + 1)); }
grep -qx '\[--strict-mcp-config\]' "$T/args" 2>/dev/null || { echo "FAIL the call does not skip MCP servers"; FAILS=$((FAILS + 1)); }
grep -A1 -x '\[--settings\]' "$T/args" 2>/dev/null | grep -qx '\[{"disableAllHooks":true}\]' \
  || { echo "FAIL the call does not turn hooks off with --settings"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "login-check: all clear"; else echo "login-check: $FAILS problem(s)"; exit 1; fi
