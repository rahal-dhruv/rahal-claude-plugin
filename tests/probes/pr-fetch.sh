#!/usr/bin/env bash
# Runs the PR-head fetch line twice, with the PR force-pushed in between. Passes when origin/pr-<n>
# follows the rewritten head. Without an argument it checks both files that carry the line.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
if [ $# -gt 0 ]; then FILES="$1"; else
  FILES="$ROOT/plugins/rahal/skills/review-pr/references/review-steps.md
$ROOT/plugins/rahal/skills/pr-followup/references/phase-1-analyse.md"; fi
FAILS=0
while IFS= read -r MD; do
  [ -n "$MD" ] || continue
  T="$(mktemp -d)/pr fetch"; mkdir -p "$T"; cd "$T" || exit 1
  git init -q -b main remote && cd remote || exit 1
  echo a > a && git add -A && git -c commit.gpgsign=false commit -qm base
  echo b > b && git add -A && git -c commit.gpgsign=false commit -qm pr1 && git update-ref refs/pull/7/head HEAD
  cd .. && git clone -q remote local
  line="$(grep -m1 'pull/<n>/head' "$MD")"; line="${line//<repo>/\"$T/local\"}"; line="${line//<n>/7}"
  eval "$line" > /dev/null 2>&1
  cd remote && git -c commit.gpgsign=false commit -q --amend -m "pr1 amended" && git update-ref refs/pull/7/head HEAD && want="$(git rev-parse HEAD)" && cd ..
  eval "$line" > /dev/null 2>&1
  got="$(git -C local rev-parse -q --verify origin/pr-7)"
  [ "$got" = "$want" ] || { echo "FAIL ${MD##*/}: origin/pr-7 is stuck at ${got:0:7}, the head is ${want:0:7}"; FAILS=$((FAILS + 1)); }
done <<EOF
$FILES
EOF
if [ "$FAILS" -eq 0 ]; then echo "pr-fetch: all clear"; else echo "pr-fetch: $FAILS problem(s)"; exit 1; fi
