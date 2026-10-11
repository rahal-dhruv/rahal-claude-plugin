#!/usr/bin/env bash
# Runs the git lines of the stacked-base block in phase-1-analyse.md §2 on a PR stacked on a blocker's
# branch, after main gained a rule in AGENTS.md that the blocker never merged. Passes when the block
# prints that rule.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/pr-followup/references/phase-1-analyse.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
G="git -c commit.gpgsign=false"
T="$(mktemp -d)/stacked rules"; mkdir -p "$T"; cd "$T" || exit 1
T="$(pwd -W 2>/dev/null || pwd)"   # the drive-letter form on Windows: MSYS_NO_PATHCONV=1 leaves a -C path unconverted
git init -q --bare -b main remote.git && git clone -q remote.git local 2>/dev/null
cd local && git symbolic-ref HEAD refs/heads/main && echo '- rule one' > AGENTS.md && git add -A && $G commit -qm base && git push -q origin main
git switch -qc feat/orb-1-blocker && echo b > b.txt && git add -A && $G commit -qm "feat(ORB-1): b" && git push -q origin feat/orb-1-blocker
git switch -qc feat/orb-2-stacked && echo c > c.txt && git add -A && $G commit -qm "feat(ORB-2): c" && git push -q origin feat/orb-2-stacked:refs/pull/7/head
git switch -q main && echo '- measure each dependency' >> AGENTS.md && git add -A && $G commit -qm "docs: add a rule" && git push -q origin main
git fetch -q origin "+pull/7/head:refs/remotes/origin/pr-7"
awk '/^## 2\. Rebuild the context/{s=1} /^## 3\./{s=0} s&&/^```bash$/{n++; if (n==2) {p=1; next}} p&&/^```$/{exit} p' "$MD" \
  | grep -v '^GH_CONFIG_DIR' > "$T/block.raw"
[ -s "$T/block.raw" ] || { echo "FAIL no second bash block (the stacked base) under ## 2 in ${MD##*/}"; exit 1; }
b="$(cat "$T/block.raw")"; b="${b//<repo>/\"$T/local\"}"; b="${b//<n>/7}"; b="${b//<base>/feat/orb-1-blocker}"; b="${b//<default>/main}"
out="$( ( eval "$b" ) < /dev/null 2>&1 )"
FAILS=0
printf '%s\n' "$out" | grep -qxF -- '+- measure each dependency' || { echo "FAIL the block does not show main's new rule; it printed: $(printf '%s' "$out" | tr '\n' ' ' | cut -c1-200)"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "stacked-rules: all clear"; else echo "stacked-rules: $FAILS problem(s)"; exit 1; fi
