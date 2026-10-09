#!/usr/bin/env bash
# Clones the committed repo the way Git for Windows does by default (core.autocrlf=true) and runs
# check.sh there. Passes when files arrive with LF line endings and no file or line check fails
# because of them.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
T="$(mktemp -d)/fresh clone"; mkdir -p "$T"
git -c core.autocrlf=true clone -q "$ROOT" "$T/repo" 2>/dev/null || { echo "FAIL could not clone the repo"; exit 1; }
FAILS=0
for f in AGENTS.md scripts/required-files.txt scripts/check.sh; do
  n="$(tr -cd '\r' < "$T/repo/$f" | wc -c | tr -d ' ')"   # count bytes: Git Bash grep hides carriage returns
  [ "$n" = 0 ] || { echo "FAIL $f arrives with Windows line endings ($n carriage returns)"; FAILS=$((FAILS + 1)); }
done
out="$(cd "$T/repo" && bash scripts/check.sh 2>&1)"
bad="$(printf '%s\n' "$out" | grep -E '^FAIL: (missing file |.* lacks the line: )')"
[ -z "$bad" ] || { echo "FAIL check.sh in the fresh clone: $(printf '%s\n' "$bad" | wc -l | tr -d ' ') false failures, e.g. $(printf '%s\n' "$bad" | head -n 1)"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "fresh-clone: all clear"; else echo "fresh-clone: $FAILS problem(s)"; exit 1; fi
