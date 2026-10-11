#!/usr/bin/env bash
# Runs the checkout block from phase-2-fix.md §1 on a PR stacked on another ticket's branch. Passes when
# a branch that tracks the blocker's branch still reaches the PR head, and when the switch fails (the
# branch is open in another worktree) the blocker's branch stays put and a STOP line names both branches.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/pr-followup/references/phase-2-fix.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
G="git -c commit.gpgsign=false"
T="$(mktemp -d)/pr checkout"; mkdir -p "$T"; cd "$T" || exit 1
git init -q --bare -b main remote.git && git clone -q remote.git local 2>/dev/null
cd local && git symbolic-ref HEAD refs/heads/main && echo a > a.txt && git add -A && $G commit -qm base && git push -q origin main
git switch -qc feat/orb-1-blocker && echo b > b.txt && git add -A && $G commit -qm "feat(ORB-1): b" && git push -q origin feat/orb-1-blocker
BLOCKER="$(git rev-parse HEAD)"
git switch -qc feat/orb-2-stacked && echo c > c.txt && git add -A && $G commit -qm "feat(ORB-2): c" && git push -q origin feat/orb-2-stacked
git branch -q -u origin/feat/orb-1-blocker feat/orb-2-stacked      # a stacked branch created with tracking
cd .. && git clone -q remote.git other && cd other && git switch -q feat/orb-2-stacked
echo d > d.txt && git add -A && $G commit -qm "fix(ORB-2): d" && git push -q origin feat/orb-2-stacked
HEADOID="$(git rev-parse HEAD)"
awk '/^## 1\. Step 0/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" > "$T/block.raw"
[ -s "$T/block.raw" ] || { echo "FAIL no bash block under ## 1. Step 0 in ${MD##*/}"; exit 1; }
run() { b="$(cat "$T/block.raw")"; b="${b//<repo>/\"$T/local\"}"; b="${b//<headRefName>/feat/orb-2-stacked}"; b="${b//<headRefOid>/$HEADOID}"; ( eval "$b" ) < /dev/null 2>&1; }
FAILS=0
# 1. On the blocker's branch, the PR branch tracking the blocker: the block must still reach the PR head
git -C "$T/local" switch -q feat/orb-1-blocker
out="$(run)"
[ "$(git -C "$T/local" branch --show-current)" = feat/orb-2-stacked ] || { echo "FAIL case 1: the checkout is $(git -C "$T/local" branch --show-current), not feat/orb-2-stacked"; FAILS=$((FAILS + 1)); }
[ "$(git -C "$T/local" rev-parse HEAD)" = "$HEADOID" ] || { echo "FAIL case 1: HEAD is $(git -C "$T/local" rev-parse --short HEAD), not the PR head ${HEADOID:0:7}"; FAILS=$((FAILS + 1)); }
printf '%s\n' "$out" | grep -q '^STOP' && { echo "FAIL case 1: a STOP line on the right branch: $(printf '%s\n' "$out" | grep '^STOP')"; FAILS=$((FAILS + 1)); }
# 2. The PR branch is open in another worktree, so the switch fails on the blocker's branch
git -C "$T/local" switch -q feat/orb-1-blocker && git -C "$T/local" reset -q --hard "$BLOCKER"
git -C "$T/local" branch -q -f feat/orb-2-stacked origin/feat/orb-2-stacked~1
git -C "$T/local" branch -q -u origin/feat/orb-2-stacked feat/orb-1-blocker   # an upstream that pull would follow
git -C "$T/local" worktree add -q "$T/second tree" feat/orb-2-stacked
out="$(run)"
[ "$(git -C "$T/local" rev-parse feat/orb-1-blocker)" = "$BLOCKER" ] || { echo "FAIL case 2: the blocker's branch moved to $(git -C "$T/local" rev-parse --short feat/orb-1-blocker)"; FAILS=$((FAILS + 1)); }
stop="$(printf '%s\n' "$out" | grep '^STOP')"
case "$stop" in
  *feat/orb-1-blocker*feat/orb-2-stacked*|*feat/orb-2-stacked*feat/orb-1-blocker*) ;;
  *) echo "FAIL case 2: no STOP line naming both branches (got: ${stop:-nothing})"; FAILS=$((FAILS + 1)) ;;
esac
if [ "$FAILS" -eq 0 ]; then echo "pr-checkout: all clear"; else echo "pr-checkout: $FAILS problem(s)"; exit 1; fi
