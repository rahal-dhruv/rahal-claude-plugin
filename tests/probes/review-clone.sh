#!/usr/bin/env bash
# Runs the reviewer's scratch-clone block (rahal-reviewer.md step 1) against a repo whose local main
# is behind origin/main. Passes when the clone's diff holds only the PR's own file, the clone has no
# remote, and the user's repo is untouched.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/agents/rahal-reviewer.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
G="git -c commit.gpgsign=false"
T="$(mktemp -d)/review clone"; mkdir -p "$T/scratch"; cd "$T" || exit 1
git init -q --bare -b main remote.git && git clone -q remote.git local 2>/dev/null
cd local && git symbolic-ref HEAD refs/heads/main && echo 'export const a = 1;' > a.js && git add -A && $G commit -qm base && git push -q origin main
cd .. && git clone -q remote.git other && cd other
echo 'export const mainOnly = 1;' > mainonly.js && git add -A && $G commit -qm "main moves on" && git push -q origin main
cd ../local && git fetch -q && git switch -qc feat/x origin/main
printf 'export const first = (xs, n) => xs.slice(0, n - 1);\n' > first.js && git add -A && $G commit -qm "add first"
git push -q origin feat/x:refs/pull/7/head && git fetch -q origin "+pull/7/head:refs/remotes/origin/pr-7" && git switch -q main
HEADSHA="$(git rev-parse origin/pr-7)"; MAIN_BEFORE="$(git rev-parse main)"; BRANCHES_BEFORE="$(git branch | wc -l)"
awk '/^1\. \*\*`code-review` first/{s=1} s&&/^   ```bash$/{p=1;next} p&&/^   ```$/{exit} p' "$MD" \
  | sed -e 's/^   //' -e "s#<scratchpad folder>#$T/scratch#g" -e "s#<repo folder>#$T/local#g" \
        -e "s#<head SHA>#$HEADSHA#g" -e 's#<base>#main#g' > "$T/block.sh"
FAILS=0
[ -s "$T/block.sh" ] || { echo "FAIL no clone block found in ${MD##*/}"; exit 1; }
bash "$T/block.sh" > /dev/null 2>&1
W="$T/scratch/review-$HEADSHA"
scope="$(git -C "$W" diff --name-only main...review-target 2>/dev/null | tr '\n' ' ')"
[ "$scope" = "first.js " ] || { echo "FAIL the review scope is [$scope], expected [first.js ] (a stale base adds mainonly.js)"; FAILS=$((FAILS + 1)); }
[ -z "$(git -C "$W" remote 2>/dev/null)" ] || { echo "FAIL the clone still has a remote"; FAILS=$((FAILS + 1)); }
[ "$(git -C "$T/local" rev-parse main)" = "$MAIN_BEFORE" ] || { echo "FAIL the user's main moved"; FAILS=$((FAILS + 1)); }
[ "$(git -C "$T/local" branch | wc -l)" = "$BRANCHES_BEFORE" ] || { echo "FAIL the user's branch list changed"; FAILS=$((FAILS + 1)); }
[ -z "$(git -C "$T/local" status --porcelain=v1)" ] || { echo "FAIL the user's tree changed"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "review-clone: all clear"; else echo "review-clone: $FAILS problem(s)"; exit 1; fi
