#!/usr/bin/env bash
# Proves check-output.sh accepts every good fixture and refuses every bad one.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILS=0
for kind in brief plan ledger review followup reply config; do
  if "$ROOT/scripts/check-output.sh" "$kind" "$ROOT/tests/fixtures/good-$kind.md" >/dev/null 2>&1; then
    echo "ok   good-$kind accepted"
  else
    echo "FAIL good-$kind refused"; FAILS=$((FAILS + 1))
  fi
  if "$ROOT/scripts/check-output.sh" "$kind" "$ROOT/tests/fixtures/bad-$kind.md" >/dev/null 2>&1; then
    echo "FAIL bad-$kind accepted"; FAILS=$((FAILS + 1))
  else
    echo "ok   bad-$kind refused"
  fi
done
if [ "$FAILS" -eq 0 ]; then echo "test-check-output: all clear"; else echo "test-check-output: $FAILS problem(s)"; exit 1; fi
