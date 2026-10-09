#!/usr/bin/env bash
# Checks the rahal plugin repo: Claude Code's validator, required files and lines,
# skill and agent front-matter, ${CLAUDE_PLUGIN_ROOT} references, and no personal data.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN="$ROOT/plugins/rahal"
FAILS=0
fail() { printf 'FAIL: %s\n' "$*"; FAILS=$((FAILS + 1)); }

# 1. Claude Code's own validator, strict, on the marketplace and on the plugin
if command -v claude >/dev/null 2>&1; then
  for target in "$ROOT" "$PLUGIN"; do
    if ! out="$(claude plugin validate --strict "$target" 2>&1)"; then
      fail "claude plugin validate --strict ${target#"$ROOT"/}"
      printf '%s\n' "$out" | sed 's/^/    /'
    fi
  done
else
  fail "claude is not on PATH (needed for claude plugin validate)"
fi

# 2. Required files, one repo-relative path per line
while IFS= read -r path || [ -n "$path" ]; do
  [ -z "$path" ] && continue
  [ -f "$ROOT/$path" ] || fail "missing file $path"
done < "$ROOT/scripts/required-files.txt"

# 3. Required lines: "path|exact line the file must contain"
while IFS='|' read -r path line || [ -n "$path" ]; do
  [ -z "$path" ] && continue
  [ -f "$ROOT/$path" ] || continue
  grep -qxF -- "$line" "$ROOT/$path" || fail "$path lacks the line: $line"
done < "$ROOT/scripts/required-headings.txt"

# 4. Skills: only the user may start them, and each documents its argument
for skill in "$PLUGIN"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  front="$(sed -n '2,/^---$/p' "$skill")"
  for key in name description argument-hint; do
    printf '%s\n' "$front" | grep -q "^$key:" || fail "${skill#"$ROOT"/} lacks $key"
  done
  printf '%s\n' "$front" | grep -qx 'disable-model-invocation: true' \
    || fail "${skill#"$ROOT"/} must set disable-model-invocation: true"
done

# 5. The reviewer agent is read-only and takes its model from the caller
agent="$PLUGIN/agents/rahal-reviewer.md"
if [ -f "$agent" ]; then
  front="$(sed -n '2,/^---$/p' "$agent")"
  printf '%s\n' "$front" | grep -qx 'name: rahal-reviewer' || fail "rahal-reviewer.md: name must be rahal-reviewer"
  tools="$(printf '%s\n' "$front" | grep '^tools:')"
  [ -n "$tools" ] || fail "rahal-reviewer.md lacks tools"
  printf '%s\n' "$tools" | grep -qE '(^|[ ,:])(Edit|Write|NotebookEdit)([ ,]|$)' \
    && fail "rahal-reviewer.md must not have Edit, Write or NotebookEdit"
  model="$(printf '%s\n' "$front" | grep '^model:')"
  [ -n "$model" ] && [ "$model" != "model: inherit" ] && fail "rahal-reviewer.md must not pin a model"
  flags="$(grep -nE -- '--fix|--comment' "$agent" | grep -v 'Never add')"
  [ -n "$flags" ] && fail "rahal-reviewer.md mentions --fix or --comment outside the rule forbidding them: $flags"
fi

# 6. Every ${CLAUDE_PLUGIN_ROOT}/<path> named in the plugin exists
if [ -d "$PLUGIN" ]; then
  refs="$(grep -rhoE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]*[A-Za-z0-9_/-]' "$PLUGIN" 2>/dev/null | sort -u)"
  for ref in $refs; do
    path="${ref#'${CLAUDE_PLUGIN_ROOT}/'}"
    [ -e "$PLUGIN/$path" ] || fail "broken reference $ref"
  done
fi

# 7. No personal data in any file git would commit (ignored files such as *.local.md
#    and tool scratch folders are skipped): absolute local paths, other accounts,
#    local ports, a filled-in gh config folder
personal='(^|[^A-Za-z0-9])[A-Za-z]:[\\/]|/Users/[A-Za-z]|/home/[a-z]|propelius|(^|[^0-9])(5442|6389)([^0-9]|$)|GH_CONFIG_DIR=[^<"$ ]'
hits=""; acct=""
while IFS= read -r f; do
  [ -n "$f" ] && [ -f "$ROOT/$f" ] && [ "$f" != scripts/check.sh ] || continue
  if h="$(grep -nIE -- "$personal" "$ROOT/$f")"; then
    hits="$hits$(printf '%s\n' "$h" | sed "s|^|$f:|")"$'\n'
  fi
  if [ "${f##*/}" != README.md ] && a="$(grep -nI -- 'rahal-dhruv' "$ROOT/$f")"; then
    acct="$acct$(printf '%s\n' "$a" | sed "s|^|$f:|")"$'\n'
  fi
done <<EOF
$(git -C "$ROOT" ls-files --cached --others --exclude-standard)
EOF
if [ -n "$hits" ]; then fail "personal data found:"; printf '%s' "$hits" | sed 's/^/    /'; fi
if [ -n "$acct" ]; then fail "account name outside README.md:"; printf '%s' "$acct" | sed 's/^/    /'; fi

# 8. Forbidden text: fixed strings that must not appear in the plugin ("text|why")
while IFS='|' read -r text why || [ -n "$text" ]; do
  [ -z "$text" ] && continue
  found="$(grep -rnF -- "$text" "$PLUGIN" 2>/dev/null)"
  if [ -n "$found" ]; then fail "forbidden text ($why): $text"; printf '%s\n' "$found" | sed 's/^/    /'; fi
done < "$ROOT/scripts/forbidden-text.txt"

# 9. The docs map: every link in docs/index.md resolves, and every docs/*.md is linked from it
if [ -f "$ROOT/docs/index.md" ]; then
  links="$(grep -oE '\]\([^)#]+\.md\)' "$ROOT/docs/index.md" | sed -E 's/^\]\(//; s/\)$//' | sort -u)"
  for l in $links; do
    [ -f "$ROOT/docs/$l" ] || fail "docs/index.md links a missing file: $l"
  done
  for f in "$ROOT"/docs/*.md; do
    n="${f##*/}"; [ "$n" = index.md ] && continue
    printf '%s\n' "$links" | grep -qxF -- "$n" || fail "docs/$n is not listed in docs/index.md"
  done
fi

# 10. The decision log: each PD entry has its fields, no id repeats, every Where path exists
D="$ROOT/docs/decisions.md"
if [ -f "$D" ]; then
  dups="$(grep -oE '^### PD-[0-9]+' "$D" | sed 's/^### //' | sort | uniq -d)"
  for id in $dups; do fail "docs/decisions.md repeats: $id"; done
  missing="$(awk '
    function check() { if (id != "") { if (!d) print id " lacks Decision"; if (!w) print id " lacks Why"; if (!c) print id " lacks Cost if wrong"; if (!p) print id " lacks Where" } }
    /^### PD-[0-9]+/ { check(); id = $2; d = w = c = p = 0; next }
    /^- \*\*Decision:\*\*/ { d = 1 }
    /^- \*\*Why:\*\*/ { w = 1 }
    /^- \*\*Cost if wrong:\*\*/ { c = 1 }
    /^- \*\*Where:\*\*/ { p = 1 }
    END { check() }' "$D")"
  while IFS= read -r m; do [ -n "$m" ] && fail "docs/decisions.md: $m"; done <<EOF
$missing
EOF
  wheres="$(awk '/^### PD-[0-9]+/ { id = $2 } /^- \*\*Where:\*\*/ { line = $0; while (match(line, /`[^`]+`/)) { print id "|" substr(line, RSTART + 1, RLENGTH - 2); line = substr(line, RSTART + RLENGTH) } }' "$D")"
  while IFS='|' read -r id path; do
    [ -z "$path" ] && continue
    [ -e "$ROOT/$path" ] || fail "docs/decisions.md: $id names a missing path: $path"
  done <<EOF
$wheres
EOF
fi

# 11. The reflector stays opt-in: no committed setting registers its hook
if [ -f "$ROOT/.claude/settings.json" ] && grep -q 'post-task.sh' "$ROOT/.claude/settings.json"; then
  fail ".claude/settings.json turns the reflector hook on for everyone; register it in .claude/settings.local.json instead"
fi

# 12. Every script is recorded as executable, so the gate runs on macOS and Linux
#     (Windows checkouts often have core.filemode=false, which hides a missing bit locally)
nonexec="$(git -C "$ROOT" ls-files -s -- '*.sh' 2>/dev/null | awk '$1 != "100755" { print $4 }')"
for f in $nonexec; do fail "$f is not recorded as executable (git update-index --chmod=+x $f)"; done

if [ "$FAILS" -eq 0 ]; then echo "check: all clear"; else echo "check: $FAILS problem(s)"; exit 1; fi
