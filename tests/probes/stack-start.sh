#!/usr/bin/env bash
# Runs the git lines of the plan template's Pre-flight block for a ticket stacked on a blocker's branch.
# Passes when the new branch starts at origin/<base>, is checked out, and tracks nothing, so a later
# pull or push cannot follow the blocker's branch.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/shared/templates/plan.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
G="git -c commit.gpgsign=false"
T="$(mktemp -d)/stack start"; mkdir -p "$T"; cd "$T" || exit 1
git init -q --bare -b main remote.git && git clone -q remote.git other 2>/dev/null && cd other || exit 1
git symbolic-ref HEAD refs/heads/main && echo a > a.txt && git add -A && $G commit -qm base && git push -q origin main
git switch -qc orb-103-search && echo b > b.txt && git add -A && $G commit -qm blocker && git push -q origin orb-103-search
WANT="$(git rev-parse HEAD)"
cd .. && git clone -q remote.git local 2>/dev/null
awk '/^## Pre-flight/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" | grep '^git ' \
  | sed -e "s#<repo>#\"$T/local\"#g" -e 's#<slug>#orb-167-x#g' -e 's#<base>#orb-103-search#g' > "$T/block.sh"
[ -s "$T/block.sh" ] || { echo "FAIL no git lines in the Pre-flight block of ${MD##*/}"; exit 1; }
bash "$T/block.sh" > /dev/null 2>&1
FAILS=0
[ "$(git -C "$T/local" rev-parse -q --verify feat/orb-167-x)" = "$WANT" ] || { echo "FAIL feat/orb-167-x does not start at origin/orb-103-search"; FAILS=$((FAILS + 1)); }
[ "$(git -C "$T/local" branch --show-current)" = feat/orb-167-x ] || { echo "FAIL feat/orb-167-x is not checked out"; FAILS=$((FAILS + 1)); }
up="$(git -C "$T/local" for-each-ref --format='%(upstream:short)' refs/heads/feat/orb-167-x)"
[ -z "$up" ] || { echo "FAIL feat/orb-167-x tracks $up, so a pull would follow the blocker's branch"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "stack-start: all clear"; else echo "stack-start: $FAILS problem(s)"; exit 1; fi
