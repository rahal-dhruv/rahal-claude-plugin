#!/usr/bin/env bash
# Runs start-work's code-check block (phase-1-understand.md §3) for a ticket stacked on a blocker's
# branch. Passes when the path the blocker added is found on origin/<base>, its content is shown, and
# the drift log lists the blocker's commit.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/start-work/references/phase-1-understand.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
G="git -c commit.gpgsign=false"
# The Windows form on Git Bash, as workspace_root is: the block's MSYS_NO_PATHCONV lines pass the path unconverted.
T="$(mktemp -d)"; if pwd -W > /dev/null 2>&1; then T="$(cd "$T" && pwd -W)"; fi
T="$T/code checks"; mkdir -p "$T"; cd "$T" || exit 1
git init -q --bare -b main remote.git && git clone -q remote.git other 2>/dev/null && cd other || exit 1
git symbolic-ref HEAD refs/heads/main && echo 'export const a = 1;' > a.ts && git add -A && $G commit -qm base && git push -q origin main
TICKET_BASE="$(git rev-parse HEAD)"
git switch -qc orb-103-search && mkdir -p src/search && echo 'export const search = () => [];' > src/search/search.service.ts
git add -A && $G commit -qm "feat(ORB-103): add search" && git push -q origin orb-103-search
cd .. && git clone -q remote.git local 2>/dev/null
P=src/search/search.service.ts
awk '/^## 3\. Check the ticket against the code/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" \
  | sed -e "s#<repo>#\"$T/local\"#g" -e 's#<base>#orb-103-search#g' -e "s#<ticket base sha>#$TICKET_BASE#g" \
        -e "s#<files the ticket names>#$P#g" -e "s#<path>#$P#g" > "$T/block.sh"
[ -s "$T/block.sh" ] || { echo "FAIL no code-check block found in ${MD##*/}"; exit 1; }
out="$(bash "$T/block.sh" 2>&1)"
FAILS=0
printf '%s\n' "$out" | grep -qx 'ok' || { echo "FAIL the blocker's $P was not found on the base"; FAILS=$((FAILS + 1)); }
printf '%s\n' "$out" | grep -qx 'missing' && { echo "FAIL a cited path was reported missing"; FAILS=$((FAILS + 1)); }
printf '%s\n' "$out" | grep -qF 'export const search' || { echo "FAIL the file's content was not shown from the base"; FAILS=$((FAILS + 1)); }
printf '%s\n' "$out" | grep -qF 'feat(ORB-103): add search' || { echo "FAIL the drift log did not list the blocker's commit"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "code-checks: all clear"; else echo "code-checks: $FAILS problem(s)"; exit 1; fi
