#!/usr/bin/env bash
# Checks a file the rahal plugin produced against the headings its template promises.
# Usage: scripts/check-output.sh <brief|plan|ledger|review|followup|reply|config|queue> <file>
set -u
kind="${1:-}"; file="${2:-}"
if [ -z "$kind" ] || [ ! -f "$file" ]; then
  echo "usage: $0 <brief|plan|ledger|review|followup|reply|config|queue> <file>"; exit 2
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
    grep -qE '^\*\*Base:\*\* `[^`<]+`' "$file" || fail "plan lacks a **Base:** line naming its base branch"
    slugs="$(grep -E '^#{1,6} ' "$file" | sed -E 's/^#+ +//' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9 _-]//g; s/ /-/g')"
    for anchor in $(grep -oE '\[Details →\]\(#[^)]+\)' "$file" | sed -E 's/.*\(#([^)]+)\)/\1/'); do
      printf '%s\n' "$slugs" | grep -qxF -- "$anchor" || fail "plan link #$anchor has no matching heading"
    done ;;
  ledger)
    head -n 1 "$file" | grep -q '^# Ledger — plan: ' || fail "ledger first line must be '# Ledger — plan: <plan path>'"
    for h in '## Rulings' '## Tasks' '## Environment' '## Review' '## Remote steps'; do need "$h"; done ;;
  review)
    for h in '## 1. What the ticket is trying to solve' '## 2. What the PR does' '## 3. Issues at a glance' \
             '## 4. Issues in detail' '## 5. Already raised by other reviewers' '## 6. Considered and set aside' 'Verdict:'; do need "$h"; done
    # a drafted comment (inside <details>) states the issue plus an example; the author chooses the fix
    if awk '/<details>/ { d = 1 } /<\/details>/ { d = 0 } d && /^[[:space:]]*```+[[:space:]]*suggestion/ { f = 1 } END { exit !f }' "$file"; then
      fail "review drafts a suggestion block; a drafted comment states the issue plus an example only"
    fi ;;
  followup)
    for h in '## Comments at a glance' '## Detailed fixes' 'Which do you accept?' ' · comment '; do need "$h"; done
    # Each glance entry from 1 up has "In plain words:" and "Example:". Each "### n." fix from 1 up has its
    # comment id and the five labels, and its reply draft names no other PR or issue. Item 0 is exempt.
    probs="$(awk '
      BEGIN { n = split("**Before this PR:**|**Now:**|**What they raised:**|**Fix we should apply:**|**Dry run:**", L, "|") }
      function endentry() { if (e != "") { if (!pw) print "glance entry " e " lacks: In plain words:"; if (!ex) print "glance entry " e " lacks: Example:" } e = "" }
      function endblock(  i) { if (b != "") for (i = 1; i <= n; i++) if (!(i in seen)) print "fix " b " lacks: " L[i]; b = ""; rd = 0; split("", seen) }
      /^#+ / { endentry(); endblock() }
      /^## / { g = ($0 == "## Comments at a glance"); next }
      /^### [1-9][0-9]*\. / { b = $2; sub(/\.$/, "", b); if (!index($0, " · comment ")) print "fix " b " lacks its comment id ( · comment <id>)"; next }
      g && /^[0-9]+\. / { endentry(); if ($1 != "0.") { e = $1; sub(/\.$/, "", e); pw = ex = 0 } }
      e != "" && index($0, "In plain words:") { pw = 1 }
      e != "" && index($0, "Example:") { ex = 1 }
      b != "" {
        for (i = 1; i <= n; i++) if (index($0, L[i])) seen[i] = 1
        if (index($0, "**Reply draft:**")) rd = 1; else if (rd && /^- \*\*/) rd = 0
        if (rd && ($0 ~ /\/pull\/[0-9]+/ || $0 ~ /(^|[^A-Za-z0-9`])#[0-9]+/)) print "fix " b " reply draft names another PR or issue"
        if (rd && /^[[:space:]]*```+[[:space:]]*suggestion/) print "fix " b " reply draft carries a suggestion block"
      }
      END { endentry(); endblock() }' "$file")"
    while IFS= read -r p; do [ -n "$p" ] && fail "$kind $p"; done <<EOF
$probs
EOF
    ;;
  reply)
    if grep -nE '/pull/[0-9]+|(^|[^A-Za-z0-9`])#[0-9]+' "$file" >/dev/null; then fail "reply refers to another PR or issue"; fi
    grep -qE '^[[:space:]]*```+[[:space:]]*suggestion' "$file" && fail "reply carries a suggestion block; it says what changed and how it was proved"
    grep -qE '[0-9a-f]{7,40}|Evidence' "$file" || fail "reply names neither a fix commit nor the evidence for a push-back" ;;
  config)   # a complete setup: an empty linear.tools (Linear not connected yet) fails on purpose
    for k in profile workspace_root work_folder account remote_prefix commit_email tools \
             commit_when commit_size attribution push open_pr pr_state post_comments re_request_review review_model; do key "$k"; done
    for k in gh_config_dir bash_node_path e2e_node_options docker_ports dev_database_url_port docs_folder reflector superpowers; do keyline "$k"; done ;;
  queue)
    for h in '**Lanes saved:**' '## At a glance' '## What the order rests on' '## Finish first' '## Pick order' '## Lanes' \
             '## Stack candidates' '## Blocking you' '## Waiting on you' "## Can't order" '## Data gaps'; do need "$h"; done
    grep -qE '^## Pick order' "$file" || fail "queue lacks a line starting with: ## Pick order"
    # every numbered entry under "## Pick order" names a ticket and gives its reason after " — "
    bad="$(awk '/^## / { s = (index($0, "## Pick order") == 1) } s && /^[0-9]+\. / && !/^[0-9]+\. ORB-[0-9]+ .+ — .+/' "$file")"
    [ -z "$bad" ] || fail "queue pick-order entry lacks ORB-<n> or a reason: $bad" ;;
  *)
    echo "unknown kind: $kind"; exit 2 ;;
esac

if [ "$FAILS" -eq 0 ]; then echo "check-output $kind: all clear"; else echo "check-output $kind: $FAILS problem(s)"; exit 1; fi
