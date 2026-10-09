#!/usr/bin/env bash
# Drives .claude/hooks/post-task.sh with a fake claude that records its calls. Passes when: no context
# file → no spawn; a new context file → one spawn with --agent reflector and hooks off; the same file
# again → no spawn; a reflector run → no spawn; a changed file → a second spawn.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOK="${1:-$ROOT/.claude/hooks/post-task.sh}"
[ -f "$HOOK" ] || { echo "FAIL no hook at ${HOOK#"$ROOT"/}"; exit 1; }
T="$(mktemp -d)/reflector hook"; mkdir -p "$T/bin" "$T/project/.claude"
cat > "$T/bin/claude" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$T/calls.log"
EOF
chmod +x "$T/bin/claude"
run() { PATH="$T/bin:$PATH" CLAUDE_PROJECT_DIR="$T/project" bash "$HOOK" > /dev/null 2>&1; }
calls() { [ -f "$T/calls.log" ] && grep -c . "$T/calls.log" || echo 0; }
FAILS=0
run; [ "$(calls)" = 0 ] || { echo "FAIL spawned without a context file"; FAILS=$((FAILS + 1)); }
echo '{"task":"one"}' > "$T/project/.claude/reflector-context.json"
run; [ "$(calls)" = 1 ] || { echo "FAIL a new context file did not spawn exactly once"; FAILS=$((FAILS + 1)); }
grep -q -- '--agent reflector' "$T/calls.log" 2>/dev/null || { echo "FAIL the spawn lacks --agent reflector"; FAILS=$((FAILS + 1)); }
grep -q 'disableAllHooks' "$T/calls.log" 2>/dev/null || { echo "FAIL the spawn does not turn hooks off"; FAILS=$((FAILS + 1)); }
run; [ "$(calls)" = 1 ] || { echo "FAIL the same context file spawned again"; FAILS=$((FAILS + 1)); }
echo '{"task":"two"}' > "$T/project/.claude/reflector-context.json"
PATH="$T/bin:$PATH" CLAUDE_PROJECT_DIR="$T/project" CLAUDE_REFLECTOR_RUN=1 bash "$HOOK" > /dev/null 2>&1
[ "$(calls)" = 1 ] || { echo "FAIL a reflector run spawned another reflector"; FAILS=$((FAILS + 1)); }
run; [ "$(calls)" = 2 ] || { echo "FAIL a changed context file did not spawn"; FAILS=$((FAILS + 1)); }
grep -q 'spawning Reflector' "$T/project/reflector/reflector-runs.log" 2>/dev/null || { echo "FAIL no run log"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "reflector-hook: all clear"; else echo "reflector-hook: $FAILS problem(s)"; exit 1; fi
