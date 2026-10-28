# Corporate profile — team facts

The same for every engineer on the Rahal corporate repos. Personal values live in `.claude/rahal.local.md` under `families.corporate`.

## Linear

- Workspace `digitalzone`. Ticket links look like `https://linear.app/digitalzone/issue/<ID>/<slug>`.
- Teams: `ORB` (the channel integration tickets, e.g. the Corporate Airport Services project) and `GF` (the earlier corporate tickets). A `GF-` ticket is always corporate.
- An `ORB-` ticket is corporate when it names a corporate repo, its link or the `corporate` branch (step 0 → The ticket's repo). Orbit's own tickets share the team.

## GitHub and repos

- Org `DigitalZoneApp`.
- `rahal-corporate-backend`: default branch `corporate`. NestJS 11 (CommonJS), Prisma, Postgres, Redis, BullMQ, Jest. Holds the Orbit channel client (`src/orbit/`) and the Orbit stub (`test/orbit/`).
- `rahal-corporate-app`: default branch `main`. React 19, Vite, TanStack Router and Query, Vitest, Playwright.
- `rahal-corporate-dashboard`: default branch `main`. React, Vite. The admin console: companies, policies, travellers.
- Frontend rule: a `[Frontend]` ticket goes to `rahal-corporate-dashboard` when its title or Context says dashboard, admin or policy page; otherwise to `rahal-corporate-app`.
- No repo has a `CODEOWNERS` file. The backend and the app have `.github/pull_request_template.md` (What, Not In This Pull Request, How To Verify); the dashboard has none, so its PR body uses the same three sections.
- No repo has an `.nvmrc`: Node comes from CI's `node-version` (22 in the backend and the app).

## Commands

The rows every command names in bold (step 0 → How to run commands). Run each inside its repo.

| Row | backend (npm) | app (pnpm) | dashboard (pnpm) |
| --- | --- | --- | --- |
| install | `npm ci` | `pnpm install --frozen-lockfile` | `pnpm install --frozen-lockfile` |
| generate | `npm run prisma:generate` | — | — |
| services | `docker compose up -d postgres cache`; for e2e also `docker compose up -d postgres-e2e cache-e2e`, and copy `.env.test.example` to `.env.test.local` once | — | — |
| migrate | `npm run prisma:migrate` | — | — |
| new migration | `npm run prisma:migrate:dev -- --name <verb>_<object>` | — | — |
| unit file | `npx jest <file>` | `pnpm vitest run <file>` | — |
| e2e file | `npx jest --config ./test/jest-e2e.json --runInBand <file>` | `pnpm test:e2e <file>` | — |
| typecheck | `npm run check:types` | `pnpm type-check` | `pnpm type-check` |
| lint | `npm run check:lint` (`npm run lint` adds `--fix` and rewrites files) | `pnpm lint:check` | `pnpm lint:check` |
| gate | `npm run check` | `pnpm check` | none: no `check` script. Run `pnpm lint:check && pnpm format:check && pnpm type-check && pnpm build`, and say the repo has no gate |
| gate counts | lint, types, build, unit, e2e, `check:openapi`, `check:orbit-types`, `check:orbit-generated` | lint, types, unit | lint, format, types, build |
| regenerate | `npm run openapi:export`; `npm run orbit:generate` only when `src/orbit/channel.json` changed | `pnpm generate:types:committed` (reads `openapi/corporate.json` from the backend clone beside it, on the branch the task targets) | — |
| generated files | `openapi/corporate.json`, `src/orbit/generated/` | `src/types/codegen/codegen.ts` | — |
| hooks | none | pre-commit: lint-staged; commit-msg: commitlint | pre-commit: lint-staged, then `pnpm type-check` |

- The backend's local Postgres and Redis ports are fixed in its `docker-compose.yml`, with no variable to move them. A clash is another container on those ports: stopping it is the user's call.
- The backend's e2e setup refuses any database or cache but the compose test stores.
- CI runs the backend's and the app's gate on every PR into the default branch. The dashboard's CI only deploys.

## The standard

- `AGENTS.md` is the code standard in the backend and the app; it wins over everything else on code. Read it on `origin/<default>` at the start of every ticket and review, and diff it from the merge-base before pushing a follow-up.
- The dashboard has no `AGENTS.md`: say so in the brief and the review, and follow the code around the change.
- Generated files are never hand-edited or hand-merged: regenerate them with the **regenerate** row.
- Personal agent tooling (`.claude/`, `.cursor/`) stays out of every repo.

## Branch practice

- Where a process rule here would differ from `orbit.md`, Orbit's wins: the rules below are Orbit's, written for these repos. A check the repo itself runs (commitlint, a hook, CI) still binds, and is never weakened.
- Branch: `feat/<slug>`, as in Orbit, e.g. `feat/orb-782-airport-services`. The merged ORB pull requests also used `feat/ORB-<n>-<words>`; nothing checks the case.
- Commit: `type(ORB-<n>): lowercase imperative title` in the backend; `type(orb-<n>): lowercase imperative title` in the app and the dashboard, whose commitlint refuses a capital letter in the scope (`scope-case: lower-case`). A `GF-<n>` ticket follows the same rule. Accurate type, ≤72 characters, title only.
- PR title: the commit format with the ticket title as a lowercase imperative, e.g. `feat(ORB-782): <title>` in the backend, `feat(orb-705): <title>` in the app.
- A PR branch behind its base is updated by merging `origin/<base>` into it, titled `chore(<scope>): merge <default | orb-<blocker n>> into the <branch words> branch`. Never rebase a pushed branch and never force push. Pull requests merge with a merge commit.
- A migration is generated with the **new migration** row, never written by hand, and a committed migration is never edited.

## Rules that bind every ticket

These come from the backend's and the app's `AGENTS.md`; check the live file for additions.
- The ticket body's Context, Design, Scope, Symbols and Done When hold every fact the build needs. A fact behind a link that cannot be opened, or on an unmerged branch, is reported, never guessed.
- The PR body names each existing definition the change reuses.
- A test proves a decision a caller can observe; before keeping a case, name one wrong implementation it fails.
- Ask before a migration, a new package, a new environment variable, or a route or DTO change, unless the ticket names it.
