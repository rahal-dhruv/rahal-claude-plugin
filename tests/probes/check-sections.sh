#!/usr/bin/env bash
# Proves check.sh sections 7 and 9-11 bite: plants broken docs, a broken decision log, a committed
# hook setting and a local path in reflector notes inside a throwaway clone, and expects each FAIL;
# then fixes them and expects none of those FAILs.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
T="$(mktemp -d)/check sections"; mkdir -p "$T"
git clone -q "$ROOT" "$T/repo" 2>/dev/null || { echo "FAIL could not clone the repo"; exit 1; }
cp -R "$ROOT/scripts/." "$T/repo/scripts/"
cd "$T/repo" || exit 1
rm -rf docs && mkdir -p docs reflector .claude
cat > docs/index.md <<'EOF'
# Docs
- [commands.md](commands.md) — the commands
- [gone.md](gone.md) — a file that does not exist
EOF
printf '# Commands\n' > docs/commands.md
printf '# Orphan\n' > docs/orphan.md
cat > docs/decisions.md <<'EOF'
# Decisions
### PD-01 — Complete entry
- **Decision:** d
- **Why:** w
- **Cost if wrong:** c
- **Where:** `scripts/check.sh`
- **Date:** 2026-10-09
### PD-02 — Missing why
- **Decision:** d
- **Cost if wrong:** c
- **Where:** `scripts/check.sh`
### PD-01 — Repeated id
- **Decision:** d
- **Why:** w
- **Cost if wrong:** c
- **Where:** `scripts/no-such-file.sh`
EOF
printf '{ "hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "bash .claude/hooks/post-task.sh" } ] } ] } }\n' > .claude/settings.json
local_path="$(printf '%s:%s%s%s' C / Users /)someone/work"   # built at run time, so this file holds no local path
printf '# Notes\n- seen in %s\n' "$local_path" > reflector/notes.md
bash_path="$(printf '%s%s%s' / c /)work/rahal-claude-plugin"   # the Git Bash form of a local path, built at run time
email="someone$(printf '%s' @)corp-mail.net"                    # a real-looking address, built at run time
printf -- '- also %s\n- mailed %s\n' "$bash_path" "$email" >> reflector/notes.md
out="$(bash scripts/check.sh 2>&1)"
FAILS=0
for want in 'docs/index.md links a missing file: gone.md' 'docs/orphan.md is not listed in docs/index.md' \
            'docs/decisions.md: PD-02 lacks Why' 'docs/decisions.md repeats: PD-01' \
            'docs/decisions.md: PD-01 names a missing path: scripts/no-such-file.sh' \
            '.claude/settings.json turns the reflector hook on for everyone' 'reflector/notes.md:2:'             'reflector/notes.md:3:' 'reflector/notes.md:4:'; do
  printf '%s\n' "$out" | grep -qF -- "$want" || { echo "FAIL expected a check failure containing: $want"; FAILS=$((FAILS + 1)); }
done
# Now fix every planted problem: none of those failures may remain.
printf '# Docs\n- [commands.md](commands.md) — the commands\n- [orphan.md](orphan.md) — listed now\n- [decisions.md](decisions.md) — the log\n' > docs/index.md
awk 'NR<=7' docs/decisions.md > "$T/d" && cp "$T/d" docs/decisions.md
rm -f .claude/settings.json
printf '# Notes\n- seen in <workspace>\n' > reflector/notes.md
out="$(bash scripts/check.sh 2>&1)"
for bad in 'docs/index.md links a missing file' 'is not listed in docs/index.md' 'docs/decisions.md: PD-' 'docs/decisions.md repeats' 'turns the reflector hook on' 'reflector/notes.md:'; do
  printf '%s\n' "$out" | grep -qF -- "$bad" && { echo "FAIL a fixed problem still fails: $bad"; FAILS=$((FAILS + 1)); }
done
if [ "$FAILS" -eq 0 ]; then echo "check-sections: all clear"; else echo "check-sections: $FAILS problem(s)"; exit 1; fi
