#!/usr/bin/env bash
# Checks a file the rahal plugin produced against the headings its template promises.
# Usage: scripts/check-output.sh <brief|plan|ledger|review|followup|reply|config> <file>
set -u
kind="${1:-}"; file="${2:-}"
if [ -z "$kind" ] || [ ! -f "$file" ]; then
  echo "usage: $0 <brief|plan|ledger|review|followup|reply|config> <file>"; exit 2
fi
FAILS=0
fail() { printf 'FAIL: %s\n' "$*"; FAILS=$((FAILS + 1)); }
need() { grep -qF -- "$1" "$file" || fail "$kind lacks: $1"; }
# key: the first "<name>:" line must hold a real value: not empty, "", '', a comment, or an unfilled <placeholder>.
key() {
  v="$(grep -E "^[[:space:]]*$1:" "$file" | head -n 1 | sed -E "s/^[[:space:]]*$1:[[:space:]]*//; s/[[:space:]]+#.*$//; s/[[:space:]]*$//")"
  case "$v" in
    ""|"\"\""|"''"|"<"*|"#"*) fail "$kind lacks a value for: $1" ;;
  esac
}
keyline() { grep -qE "^[[:space:]]*$1:" "$file" || fail "$kind lacks the key: $1"; }

case "$kind" in
  brief)
    for h in '## What it asks for' '## Where it sits' '## What I checked' '## The plan at a glance' '## Decision 1 of'; do need "$h"; done ;;
  plan)
    for h in '## Tasks at a glance' '## Global Constraints' '## Decisions' '## Review Focus' '## Pre-flight' '### Task 1:' '## Self-check'; do need "$h"; done
    slugs="$(grep -E '^#{1,6} ' "$file" | sed -E 's/^#+ +//' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 _-]//g; s/ /-/g')"
    for anchor in $(grep -oE '\[Details →\]\(#[^)]+\)' "$file" | sed -E 's/.*\(#([^)]+)\)/\1/'); do
      printf '%s\n' "$slugs" | grep -qxF -- "$anchor" || fail "plan link #$anchor has no matching heading"
    done ;;
  ledger)
    head -n 1 "$file" | grep -q '^# Ledger — plan: ' || fail "ledger first line must be '# Ledger — plan: <plan path>'"
    for h in '## Rulings' '## Tasks' '## Environment' '## Review' '## Remote steps'; do need "$h"; done ;;
  review)
    for h in '## 1. What the ticket is trying to solve' '## 2. What the PR does' '## 3. Issues at a glance' \
             '## 4. Issues in detail' '## 5. Already raised by other reviewers' '## 6. Considered and set aside' 'Verdict:'; do need "$h"; done ;;
  followup)
    for h in '## Comments at a glance' '## Detailed fixes' 'Which do you accept?' ' · comment '; do need "$h"; done ;;
  reply)
    if grep -nE '/pull/[0-9]+|(^|[^A-Za-z0-9`])#[0-9]+' "$file" >/dev/null; then fail "reply refers to another PR or issue"; fi
    grep -qE '[0-9a-f]{7,40}|Evidence' "$file" || fail "reply names neither a fix commit nor the evidence for a push-back" ;;
  config)   # a complete setup: an empty linear.tools (Linear not connected yet) fails on purpose
    for k in profile workspace_root work_folder account remote_prefix commit_email tools \
             commit_when commit_size attribution push open_pr pr_state post_comments re_request_review review_model; do key "$k"; done
    for k in gh_config_dir bash_node_path e2e_node_options docker_ports dev_database_url_port docs_folder reflector superpowers; do keyline "$k"; done ;;
  *)
    echo "unknown kind: $kind"; exit 2 ;;
esac

if [ "$FAILS" -eq 0 ]; then echo "check-output $kind: all clear"; else echo "check-output $kind: $FAILS problem(s)"; exit 1; fi
