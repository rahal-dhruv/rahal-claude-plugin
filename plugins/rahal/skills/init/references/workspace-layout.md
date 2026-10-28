# Suggested workspace layout

```
<workspace>/                        not a git repo
  .claude/rahal.local.md            written by /rahal:init
  .claude/rahal/                    helpers init generates (the Windows e2e shim)
  rahal-orbit-backend/              the orbit family
  rahal-orbit-dashboard/
  rahal-orbit-docs/
  rahal-corporate-backend/          the corporate family; any family may be absent
  rahal-corporate-app/
  rahal-corporate-dashboard/
  work/
    orb-183-visa-destinations/      one folder per ticket; personal, never shared
      brief.md  plan.md  ledger.md  pr-body.md
      review-2026-10-07.md
      followup-2026-10-08.md
      reply-2026-10-08-amr-2417.md      one reply per review comment
  docs/                             optional notes on what was built
```

- Ticket folder slug: `orb-<n>-<two to four words from the ticket title>` (`gf-<n>-…` for a GF ticket), lower case. Commands reuse an existing `orb-<n>-*` folder before making a new one. The branch is `feat/<slug>`.
- Nothing of yours goes inside a repo: no `.claude/`, no `work/`, no notes.
