#!/usr/bin/env bash
# Runs the reviewer's scratch-clone block (rahal-reviewer.md step 1) twice: for a PR on main while the
# user's local main is behind origin/main, and for a PR stacked on another open PR's branch. Passes when
# each clone's diff holds only that PR's own file, the clone has no remote, and the user's repo is untouched.
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
git switch -qc feat/blocker && echo 'export const blocker = 1;' > blocker.js && git add -A && $G commit -qm "add blocker"
git push -q origin feat/blocker feat/blocker:refs/pull/8/head
git switch -qc feat/stacked && echo 'export const stacked = 1;' > stacked.js && git add -A && $G commit -qm "add stacked"
git push -q origin feat/stacked:refs/pull/9/head
cd ../local && git fetch -q && git switch -qc feat/x origin/main
printf 'export const first = (xs, n) => xs.slice(0, n - 1);\n' > first.js && git add -A && $G commit -qm "add first"
git push -q origin feat/x:refs/pull/7/head
git fetch -q origin "+pull/7/head:refs/remotes/origin/pr-7" "+pull/9/head:refs/remotes/origin/pr-9" && git switch -q main
MAIN_BEFORE="$(git rev-parse main)"; BRANCHES_BEFORE="$(git branch | wc -l)"
awk '/^1\. \*\*`code-review` first/{s=1} s&&/^   ```bash$/{p=1;next} p&&/^   ```$/{exit} p' "$MD" \
  | sed -e 's/^   //' -e "s#<scratchpad folder>#$T/scratch#g" -e "s#<repo folder>#$T/local#g" -e 's#<default>#main#g' > "$T/block.tmpl"
[ -s "$T/block.tmpl" ] || { echo "FAIL no clone block found in ${MD##*/}"; exit 1; }
FAILS=0
# review <case> <head SHA> <base branch> <the PR's only file> <the file a wrong base adds>
review() {
  sed -e "s#<head SHA>#$2#g" -e "s#<base>#$3#g" "$T/block.tmpl" > "$T/block-$2.sh"
  bash "$T/block-$2.sh" > /dev/null 2>&1
  clone="$T/scratch/review-$2"
  scope="$(git -C "$clone" diff --name-only main...review-target 2>/dev/null | tr '\n' ' ')"
  [ "$scope" = "$4 " ] || { echo "FAIL $1: the review scope is [$scope], expected [$4 ] (a wrong base adds $5)"; FAILS=$((FAILS + 1)); }
  [ -z "$(git -C "$clone" remote 2>/dev/null)" ] || { echo "FAIL $1: the clone still has a remote"; FAILS=$((FAILS + 1)); }
}
review "stale local main" "$(git rev-parse origin/pr-7)" main first.js mainonly.js
review "stacked PR" "$(git rev-parse origin/pr-9)" feat/blocker stacked.js blocker.js
[ "$(git -C "$T/local" rev-parse main)" = "$MAIN_BEFORE" ] || { echo "FAIL the user's main moved"; FAILS=$((FAILS + 1)); }
[ "$(git -C "$T/local" branch | wc -l)" = "$BRANCHES_BEFORE" ] || { echo "FAIL the user's branch list changed"; FAILS=$((FAILS + 1)); }
[ -z "$(git -C "$T/local" status --porcelain=v1)" ] || { echo "FAIL the user's tree changed"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "review-clone: all clear"; else echo "review-clone: $FAILS problem(s)"; exit 1; fi
