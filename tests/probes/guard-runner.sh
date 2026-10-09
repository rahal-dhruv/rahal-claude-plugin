#!/usr/bin/env bash
# Runs the guard-check runner from phase-2-execute.md §6 against a repo whose task change is
# uncommitted and partly untracked. Passes when every file is restored exactly, every mutation
# was seen, and the runner reports the tree as before.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/start-work/references/phase-2-execute.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
T="$(mktemp -d)/guard runner"; mkdir -p "$T/repo/src" "$T/scratch"
cd "$T/repo" && git init -q -b main
printf 'export const isLive = (row) => {\n  return true;\n};\n' > src/svc.ts
git add -A && git -c commit.gpgsign=false commit -qm base
printf 'export const isLive = (row) => {\n  return row.deletedAt === null;\n};\n' > src/svc.ts
printf 'export const live = (r) => r.deletedAt === null;\n' > src/new-helper.ts
fake_e2e() { echo '   × keeps deleted rows out'; echo '      Tests  1 failed'; return 1; }
export -f fake_e2e
awk '/^## 6\. Guard checks/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" \
  | sed -e "s#\"<repo>\"#<repo>#g" -e "s#<repo>#\"$T/repo\"#g" -e "s#<scratchpad>#$T/scratch#g" \
        -e 's#NODE_OPTIONS=[^ ]* pnpm test:e2e <e2e file>#fake_e2e#' > "$T/runner.sh"
mut() { printf "sed 's/%s/true/' %s > \"$T/tmp\" && cp \"$T/tmp\" %s\n" "$2" "$1" "$1"; }
{ echo 'snap guard1 src/svc.ts'; mut src/svc.ts 'row.deletedAt === null'; echo 'run guard1 src/svc.ts'
  echo 'snap guard2 src/new-helper.ts'; mut src/new-helper.ts 'r.deletedAt === null'; echo 'run guard2 src/new-helper.ts'; } > "$T/blocks"
awk -v b="$T/blocks" '{print} /^# one block per guard/{while((getline l < b)>0) print l}' "$T/runner.sh" > "$T/runner2.sh"
bash "$T/runner2.sh" > /dev/null 2>&1
FAILS=0
grep -q 'return row.deletedAt === null;' src/svc.ts || { echo "FAIL svc.ts lost the uncommitted change"; FAILS=$((FAILS + 1)); }
grep -q 'r.deletedAt === null' src/new-helper.ts || { echo "FAIL new-helper.ts was left mutated"; FAILS=$((FAILS + 1)); }
grep -q 'MUTATION NOT APPLIED' "$T/scratch/mutations.md" 2>/dev/null && { echo "FAIL a mutation went unseen"; FAILS=$((FAILS + 1)); }
[ "$(grep -c '^exit=' "$T/scratch/mutations.md" 2>/dev/null)" = 2 ] || { echo "FAIL expected 2 e2e runs"; FAILS=$((FAILS + 1)); }
grep -q '^tree: as before$' "$T/scratch/mutations.md" 2>/dev/null || { echo "FAIL the runner did not report the tree as before"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "guard-runner: all clear"; else echo "guard-runner: $FAILS problem(s)"; exit 1; fi
