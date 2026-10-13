#!/usr/bin/env bash
# Runs plan-tickets' gh pr list line against a stand-in gh that logs what it receives. Passes when the
# config folder (its path has a space) arrives whole, with --repo, --state open, --limit 100 and every
# JSON field the steps use. Optional argument: the Markdown file that carries the line.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/plan-tickets/references/queue-steps.md}"
T="$(mktemp -d)/pr list"; mkdir -p "$T/bin" "$T/gh config" || exit 1
cat > "$T/bin/gh" <<'EOF'
#!/usr/bin/env bash
{ printf '%s=%s\n' GH_CONFIG_DIR "${GH_CONFIG_DIR-<unset>}"; for a in "$@"; do printf 'ARG=%s\n' "$a"; done; } > "$GH_LOG"
echo '[]'
EOF
chmod +x "$T/bin/gh"
line="$(grep -m1 'GH_CONFIG_DIR[=].*gh pr list' "$MD" 2>/dev/null)"
if [ -z "$line" ]; then printf 'FAIL %s: no GH_CONFIG_DIR%s… gh pr list line\n' "${MD##*/}" '='; echo "pr-list: 1 problem(s)"; exit 1; fi
line="${line//<github.gh_config_dir>/$T/gh config}"; line="${line//<repo name>/rahal-orbit-backend}"
export GH_LOG="$T/log"
( PATH="$T/bin:$PATH"; eval "$line" ) > /dev/null 2>&1
FAILS=0
want() { grep -qxF -- "$1" "$T/log" 2>/dev/null || { echo "FAIL ${MD##*/}: gh did not receive $1"; FAILS=$((FAILS + 1)); }; }
want "GH_CONFIG_DIR=$T/gh config"
for a in pr list --repo DigitalZoneApp/rahal-orbit-backend --state open --limit 100 --json; do want "ARG=$a"; done
fields="$(grep -A1 -xF 'ARG=--json' "$T/log" 2>/dev/null | tail -n 1 | sed 's/^ARG=//')"
for f in number title headRefName baseRefName isDraft reviewDecision mergeStateStatus url; do
  printf '%s\n' "$fields" | tr ',' '\n' | grep -qxF -- "$f" || { echo "FAIL ${MD##*/}: --json lacks $f"; FAILS=$((FAILS + 1)); }
done
if [ "$FAILS" -eq 0 ]; then echo "pr-list: all clear"; else echo "pr-list: $FAILS problem(s)"; exit 1; fi
