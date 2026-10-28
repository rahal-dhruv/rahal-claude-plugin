#!/usr/bin/env bash
# Runs the repo-detection block from init's checks.md (Workspace) in a workspace whose name has a
# space. Passes when it names each found repo with its family, counts a linked worktree (whose .git
# is a file) as found, and reports the absent repos as missing.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/init/references/checks.md}"
export GIT_AUTHOR_NAME=probe GIT_AUTHOR_EMAIL=probe@example.com GIT_COMMITTER_NAME=probe GIT_COMMITTER_EMAIL=probe@example.com
T="$(mktemp -d)/rahal work"; mkdir -p "$T" && cd "$T" || exit 1
git init -q -b main rahal-orbit-backend
git -C rahal-orbit-backend -c commit.gpgsign=false commit -q --allow-empty -m base
git init -q -b corporate main-clone
git -C main-clone -c commit.gpgsign=false commit -q --allow-empty -m base
git -C main-clone worktree add -q "$T/rahal-corporate-backend" -b feat/orb-782-x
awk '/^## Workspace/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" | grep -v '^git clone' \
  | sed -e "s#<workspace>#$T#g" > "$T/block.sh"
[ -s "$T/block.sh" ] || { echo "FAIL no workspace block found in ${MD##*/}"; exit 1; }
out="$(bash "$T/block.sh" 2>&1)"
FAILS=0
expect() { printf '%s\n' "$out" | grep -qxF "$1" || { echo "FAIL expected the line: $1"; FAILS=$((FAILS + 1)); }; }
expect 'found orbit rahal-orbit-backend'
expect 'missing orbit rahal-orbit-dashboard'
expect 'missing orbit rahal-orbit-docs'
expect 'found corporate rahal-corporate-backend'
expect 'missing corporate rahal-corporate-app'
expect 'missing corporate rahal-corporate-dashboard'
if [ "$FAILS" -eq 0 ]; then echo "init-repos: all clear"; else echo "init-repos: $FAILS problem(s)"; printf '%s\n' "$out" | sed 's/^/    /'; exit 1; fi
