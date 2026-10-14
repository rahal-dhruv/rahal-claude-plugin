#!/usr/bin/env bash
# Proves check.sh section 13 bites: on a branch cut from main, an edited or a new file under
# plugins/rahal/ without a version bump fails; the same change with a bump passes.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
T="$(mktemp -d)/version bump"; mkdir -p "$T"
git clone -q "$ROOT" "$T/repo" 2>/dev/null || { echo "FAIL could not clone the repo"; exit 1; }
cd "$T/repo" || exit 1
base=main; git rev-parse -q --verify "main^{commit}" >/dev/null 2>&1 || base=origin/main
git switch -q -c probe-branch "$base" 2>/dev/null || { echo "FAIL could not branch from $base"; exit 1; }
cp -R "$ROOT/scripts/." scripts/
want='plugins/rahal/ changed since'   # only section 13 prints this; pinned-line failures can quote other wording
FAILS=0
bash scripts/check.sh 2>&1 | grep -qF -- "$want" && { echo "FAIL a branch with no plugin change is reported"; FAILS=$((FAILS + 1)); }
printf '\n' >> plugins/rahal/skills/init/SKILL.md
bash scripts/check.sh 2>&1 | grep -qF -- "$want" || { echo "FAIL an edit under plugins/rahal/ without a bump passed"; FAILS=$((FAILS + 1)); }
git checkout -q -- plugins/rahal/skills/init/SKILL.md
printf '# new\n' > plugins/rahal/shared/probe-new.md
bash scripts/check.sh 2>&1 | grep -qF -- "$want" || { echo "FAIL a new file under plugins/rahal/ without a bump passed"; FAILS=$((FAILS + 1)); }
awk '/"version":/ { sub(/"version": *"[^"]*"/, "\"version\": \"9.9.9\"") } { print }' \
  plugins/rahal/.claude-plugin/plugin.json > "$T/plugin.json" && cp "$T/plugin.json" plugins/rahal/.claude-plugin/plugin.json
bash scripts/check.sh 2>&1 | grep -qF -- "$want" && { echo "FAIL a change with a bumped version is still reported"; FAILS=$((FAILS + 1)); }
if [ "$FAILS" -eq 0 ]; then echo "version-bump: all clear"; else echo "version-bump: $FAILS problem(s)"; exit 1; fi
