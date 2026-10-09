#!/usr/bin/env bash
# Runs every probe in tests/probes/ and reports each. A probe exits 0 when it passes.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILS=0; COUNT=0
for p in "$ROOT"/tests/probes/*.sh; do
  [ -f "$p" ] || continue
  COUNT=$((COUNT + 1))
  name="$(basename "$p" .sh)"
  if out="$(bash "$p" 2>&1)"; then
    echo "ok   $name"
  else
    echo "FAIL $name"; printf '%s\n' "$out" | sed 's/^/    /'; FAILS=$((FAILS + 1))
  fi
done
[ "$COUNT" -eq 0 ] && { echo "test-probes: no probes found"; exit 1; }
if [ "$FAILS" -eq 0 ]; then echo "test-probes: all clear"; else echo "test-probes: $FAILS problem(s)"; exit 1; fi
