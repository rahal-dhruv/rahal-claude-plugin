# Ticket queue — Visas — 2026-10-12

**For:** Alex · **Lanes saved:** all · **Read:** 4 of your open tickets, 1 linked ticket, open PRs in backend and dashboard at 10:40

A suggestion only: nothing in Linear or GitHub was changed.

## At a glance

- Start ORB-901 now: it unblocks two tickets. ORB-904 can run beside it in its own worktree.
- ORB-903 waits on Sam's ORB-905, but could start today on top of Sam's PR #12.

## What the order rests on

3 blocking links · priority set on 2 of 4 tickets · ticket number breaks the remaining ties · estimates, due dates and descriptions are not used

## Finish first

None.

## Pick order

1. ORB-901 [Backend] Add the visa product list — can start now · unblocks 2 (your ORB-902, Lee's ORB-910) · High
2. ORB-904 [Backend] Add the nationality filter
3. ORB-902 [Backend] Add visa product activation — after your ORB-901 (step 1)
4. ORB-903 [Backend] Serve the visa product page — waits on Sam's ORB-905 (Code Review, #12)

## Lanes

- **Lane A:** ORB-901 (start now) → ORB-902
- **Lane B:** ORB-904 (start now)
- **Lane C:** ORB-903

Which files each ticket touches is unknown until `/rahal:start-work` reads the code.
Backend lanes that add or change routes all regenerate `openapi/admin.json`: expect a conflict there at merge, fixed by regenerating.

## Stack candidates

- **ORB-903** can stack on #12 (`feat/orb-905-visa-product-reads`, ORB-905, Sam's) · not a draft · review required · clean. Stack if you can't wait.
  Run `/rahal:start-work ORB-903` and answer **Stack** when it asks *Wait or stack?*.
  When #12 changes, merge its branch into yours (never rebase). When #12 merges, GitHub moves your PR to `main`; merge `origin/main` in once.

## Blocking you

- **ORB-905** [Backend] Read the visa product store — Sam · Code Review · PR #12 · holds up your ORB-903. It has PR #12 (review required): offer to help review it, or stack on it: see Stack candidates.

## Waiting on you

- Lee's **ORB-910** waits on your ORB-901.

## Can't order

None.

## Data gaps

None.
