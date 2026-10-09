#!/usr/bin/env bash
# Runs the merge line from phase-2-fix.md §2 on a branch behind main, with no terminal. Passes when
# nothing is committed yet and the merge stays open for the checks and the titled commit.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/pr-followup/references/phase-2-fix.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
T="$(mktemp -d)/merge step"; mkdir -p "$T"; cd "$T" || exit 1
git init -q -b main repo && cd repo || exit 1
G="git -c commit.gpgsign=false"
echo a > a.txt && git add -A && $G commit -qm base
git switch -qc feat/orb-1-x && echo b > b.txt && git add -A && $G commit -qm "feat(ORB-1): b"
git switch -q main && echo c > c.txt && git add -A && $G commit -qm "feat(ORB-2): c"
git switch -q feat/orb-1-x && git update-ref refs/remotes/origin/main main
BEFORE="$(git rev-parse HEAD)"
line="$(awk '/^## 2\. Branch update/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" | grep 'merge ' | head -n 1)"
line="${line//<repo>/\"$T/repo\"}"; line="${line//<base>/main}"
eval "$line" < /dev/null > /dev/null 2>&1
FAILS=0
[ "$(git rev-parse HEAD)" = "$BEFORE" ] || { echo "FAIL the merge committed at once: $(git log -1 --format=%s)"; FAILS=$((FAILS + 1)); }
git rev-parse -q --verify MERGE_HEAD > /dev/null || { echo "FAIL no merge is in progress"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "merge-step: all clear"; else echo "merge-step: $FAILS problem(s)"; exit 1; fi
