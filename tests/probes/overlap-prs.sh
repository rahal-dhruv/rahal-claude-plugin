#!/usr/bin/env bash
# Runs start-work's open-PR overlap block (phase-1-understand.md, "Open PRs on the same files") with a
# stand-in gh that prints what the real one's --jq would. Passes when exactly the open PRs that change a
# path the ticket names are listed: a near-miss path (a longer name) and a path with a space are judged
# by the whole path.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MD="${1:-$ROOT/plugins/rahal/skills/start-work/references/phase-1-understand.md}"
T="$(mktemp -d)/overlap prs"; mkdir -p "$T"
gh() {
  printf '146\torb-103-search\topenapi/admin.json\n146\torb-103-search\tsrc/search/search.service.ts\n'
  printf '150\tfeat/orb-150-near\tsrc/visas/visa.service.ts.bak\n151\tfeat/orb-151-same\tsrc/visas/visa.service.ts\n'
  printf '152\tfeat/orb-152-space\tdocs/visa notes.md\n'
}
export -f gh
awk '/^### Open PRs on the same files/{s=1} s&&/^```bash$/{p=1;next} p&&/^```$/{exit} p' "$MD" \
  | sed -e "s#<scratchpad>#$T#g" -e 's#<gh_config_dir>#gh-config#g' -e 's#<repo name>#rahal-orbit-backend#g' \
        -e "s#<each path the ticket names>#src/visas/visa.service.ts openapi/admin.json 'docs/visa notes.md'#g" > "$T/block.sh"
[ -s "$T/block.sh" ] || { echo "FAIL no overlap block found in ${MD##*/}"; exit 1; }
got="$(bash "$T/block.sh" 2>&1)"
want="#146 (orb-103-search): openapi/admin.json
#151 (feat/orb-151-same): src/visas/visa.service.ts
#152 (feat/orb-152-space): docs/visa notes.md"
FAILS=0
[ "$got" = "$want" ] || { echo "FAIL the overlap list is:"; printf '%s\n' "$got" | sed 's/^/    /'; echo "  expected:"; printf '%s\n' "$want" | sed 's/^/    /'; FAILS=1; }
if [ "$FAILS" -eq 0 ]; then echo "overlap-prs: all clear"; else echo "overlap-prs: $FAILS problem(s)"; exit 1; fi
