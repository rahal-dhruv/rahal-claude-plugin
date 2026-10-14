# PR #1 follow-up — 2 comments to handle

Base: main · Branch: 2 behind main; trial merge conflicts: openapi/admin.json · Ticket: unchanged · New rules since the branch on main: none
Instruction: "merge the blocker branch first; keep replies under 3 lines" · Model: opus

## Comments at a glance

1. Amr — search can't find a destination by its name. Recommend: fix (blocking).
   In plain words: an operator who types part of a country's name finds nothing and thinks it was never set up.
   Example: someone searches "emir" → sees an empty list today → would see United Arab Emirates after.
2. Muntadher — % and _ in a search act as wildcards. Recommend: fix (not blocking); departs from the ticket.
   In plain words: a search for an underscore matches every destination instead of none.
   Example: someone searches "_" → sees all 40 destinations today → would see none after.
0. Branch update — merge main first; only openapi/admin.json conflicts (generated).

## Detailed fixes

### 1. Amr · src/visas/destinations.service.ts:42 · comment 101

- **Before this PR:** did not exist; `origin/main` has no destination search.
- **Now:** at head abc1234, `where: { code: { contains: q, mode: 'insensitive' } }` matches the country code only.
- **What they raised:** the search ignores the name; "match the label too".
- **How checked:** `GET /admin/v1/visas/destinations?q=emir` on the dev database → `{ codes: [], total: 0 }`.
- **Ticket:** matches.
- **Fix we should apply:** test first — `listed('?q=emir')` expects `['AE']`, red result `[]`; then add `{ label: { contains: q, mode: 'insensitive' } }` to an `OR`. Commit: `fix(ORB-1): match destinations by label`
- **Dry run:**
  1. Now: `?q=emir` → `WHERE code ILIKE '%emir%'` → 0 rows → `{ codes: [], total: 0 }`.
  2. After: `?q=emir` → `WHERE code ILIKE '%emir%' OR label ILIKE '%emir%'` → 1 row (AE) → `{ codes: ['AE'], total: 1 }`.
- **Alternative:** none worth considering.
- **Reply draft:** Fixed: the search now matches the label as well as the code, so `?q=emir` returns `AE`.
  ```suggestion
  where: { OR: [{ code: { contains: q } }, { label: { contains: q } }] },
  ```

### 2. Muntadher · src/visas/destinations.service.ts:42 · comment 102

- **Before this PR:** did not exist; `origin/main` has no destination search.
- **Now:** at head abc1234, `contains: q` passes `_` through, and Postgres reads it as "any one character".
- **What they raised:** escape `%` and `_` before the search.
  ```suggestion
  const term = q.replace(/[\%_]/g, (c) => `\${c}`);
  ```
- **How checked:** `GET /admin/v1/visas/destinations?q=_` → `total: 40`.
- **Ticket:** departs: the ticket says "free-text search" only; list the escaping as a departure in the PR body.
- **Fix we should apply:** test first — `listed('?q=_')` expects `[]`, red result 40 codes; then escape `\`, `%` and `_` in `q`. Commit: `fix(ORB-1): escape wildcards in the destination search`
- **Dry run:**
  1. Now: `?q=_` → `WHERE code ILIKE '%_%'` → 40 rows → `total: 40`.
  2. After: `?q=_` → `WHERE code ILIKE '%\_%'` → 0 rows → `total: 0`.
- **Alternative:** keep wildcards as a feature; no user asked for them.
- **Reply draft:** Fixed: `%` and `_` are now matched literally; `?q=_` returns no destinations.

### 0. Branch update

- Merge `origin/main`; regenerate generated files; typecheck and lint.

Which do you accept? e.g. "0, 1, 2" · "1 only, push back on 2"
