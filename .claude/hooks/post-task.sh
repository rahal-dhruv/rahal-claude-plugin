#!/usr/bin/env bash
# Stop-hook entry point for contributors who opted in (reflector/README.md). Sole job: if the session
# left a new context file behind, spawn the Reflector agent. Runs async; never blocks the session.
set -u

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" || exit 0

CONTEXT_FILE=".claude/reflector-context.json"
RUNS_LOG="reflector/reflector-runs.log"
LAST_HASH_FILE="reflector/.last-context.hash"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p reflector 2>/dev/null || true

# Recursion guard 1: the spawned reflector carries this variable.
if [ "${CLAUDE_REFLECTOR_RUN:-0}" = "1" ]; then
  echo "[$TIMESTAMP] post-task.sh: skipped (reflector spawn)" >> "$RUNS_LOG"
  exit 0
fi

if [ ! -f "$CONTEXT_FILE" ]; then
  echo "[$TIMESTAMP] post-task.sh: skipped — no context file this turn" >> "$RUNS_LOG"
  exit 0
fi

# A turn that did not rewrite the context file must not re-reflect the previous turn.
# git hash-object works on every platform (macOS has no sha1sum).
CONTEXT_HASH="$(git hash-object "$CONTEXT_FILE" 2>/dev/null)"
if [ -z "$CONTEXT_HASH" ]; then
  echo "[$TIMESTAMP] post-task.sh: ABORT — git not on PATH" >> "$RUNS_LOG"
  exit 0
fi
if [ -f "$LAST_HASH_FILE" ] && [ "$(cat "$LAST_HASH_FILE")" = "$CONTEXT_HASH" ]; then
  echo "[$TIMESTAMP] post-task.sh: skipped — context file unchanged since last run" >> "$RUNS_LOG"
  exit 0
fi

CLAUDE_BIN="$(command -v claude || true)"
if [ -z "$CLAUDE_BIN" ]; then
  echo "[$TIMESTAMP] post-task.sh: ABORT — 'claude' not on PATH" >> "$RUNS_LOG"
  exit 0
fi

echo "$CONTEXT_HASH" > "$LAST_HASH_FILE"
echo "[$TIMESTAMP] post-task.sh: spawning Reflector" >> "$RUNS_LOG"

# Recursion guard 2: hooks are off inside the spawned session.
CLAUDE_REFLECTOR_RUN=1 "$CLAUDE_BIN" \
  --print \
  --agent reflector \
  --permission-mode acceptEdits \
  --settings '{"disableAllHooks":true}' \
  "Run a reflection pass. Read .claude/reflector-context.json for this turn's context, then act per .claude/agents/reflector.md." \
  >> "$RUNS_LOG" 2>&1 || true

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] post-task.sh: Reflector run complete" >> "$RUNS_LOG"
exit 0
