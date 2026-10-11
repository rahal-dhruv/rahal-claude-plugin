# Orbit profile — team facts

The same for every Orbit engineer. Personal values live in `.claude/rahal.local.md`.

## Linear

- Workspace `digitalzone`, team key `ORB`. Ticket links look like `https://linear.app/digitalzone/issue/ORB-<n>/<slug>`.

## GitHub and repos

- Org `DigitalZoneApp`.
- `rahal-orbit-backend`: default branch `main`. NestJS 12 (ESM), Prisma 7, Postgres 17, Redis 7, BullMQ, Vitest.
- `rahal-orbit-dashboard`: default branch `main`. React 18, Vite 8, TanStack Router/Query on pinned `@DigitalZoneApp/admin-framework-*`.
- `rahal-orbit-docs`: default branch `docs-main` (`origin/main` there is a dead ref). The team's design plan: decisions, contracts, screen specs.
- `CODEOWNERS` lists the files a code owner must approve: `AGENTS.md`, `CLAUDE.md`, `eslint.config.js`, `lefthook.yml`, `test/lint/`, `package.json`, `pnpm-lock.yaml`, and others. Check it on `origin/main`.
- PR template: `.github/pull_request_template.md`. Build every PR body from the version on `origin/main`.

## Package manager and gates

- pnpm only (via corepack), never npm or yarn. Node from the repo's `.nvmrc`.
- Gate in both code repos: `pnpm check`. The backend's needs Docker and regenerates `openapi/*.json`.
- Backend commands: `pnpm typecheck`, `pnpm lint`, `pnpm format`, `pnpm test`, `pnpm test:e2e <file>`, `pnpm test:contract`, `pnpm db:generate`, `pnpm db:migrate`, `pnpm db:migrate:dev --name <verb>_<object>`, `pnpm openapi`.
- Local services: `docker compose up --wait` from the backend. `ORBIT_POSTGRES_PORT` and `ORBIT_REDIS_PORT` move the ports.
- The e2e suite starts its own containers (testcontainers). Its global setup spawns `pnpm`, which needs a shim on Windows (`toolchain.e2e_node_options`).

## The standard

- Each code repo's `AGENTS.md` is the code standard. It wins over everything else on code. Read it on `origin/main` at the start of every ticket and review, and diff it from the merge-base before pushing a follow-up.
- Generated files are never hand-edited or hand-merged: `openapi/*.json` and `src/generated/`. Regenerate with `pnpm db:generate` and `pnpm openapi`.

## Branch practice

- Branch: `feat/orb-<n>-<two to four words>`, e.g. `feat/orb-183-visa-destinations`.
- Commit: `type(ORB-<n>): lowercase imperative title`. Accurate type (`feat`, `test`, `fix`, `refactor`, `docs`, `chore`), ≤72 characters, title only. commitlint enforces the shape.
- PR title: `feat(ORB-<n>): <ticket title as a lowercase imperative>`.
- A PR branch behind `main` is updated by merging `origin/main` into it: `chore(ORB-<n>): merge main into the <branch words> branch`, e.g. `chore(ORB-183): merge main into the visa destinations branch`. Never rebase a pushed branch and never force push.
- A stacked PR, whose base is its blocker's branch, is updated the same way from `origin/<base>`, titled with the blocker's ticket id: `chore(ORB-<n>): merge orb-<blocker n> into the <branch words> branch`, e.g. `chore(ORB-196): merge orb-194 into the visa provider admin routes branch`.
- A PR's migration folders keep their names when `main` lands later-timestamped ones. Recreate one only when its ticket says so.
- Git hooks (lefthook):
  - pre-commit: eslint and prettier on staged files, plus `pnpm openapi` when controllers or DTOs are staged;
  - commit-msg: commitlint;
  - pre-push: typecheck, format, knip, `openapi:check`, unit tests.

## Rules that bind every ticket

These come from `AGENTS.md`; check the live file for additions.
- The PR body names each existing definition the change reuses.
- Each added or changed test case is named in the PR body with the decision it proves.
- Each guard checked once outside the suite is listed with its mutation, command and observed failure.
- A dependency's behaviour for an input is measured, never assumed, and the command and result are named in the PR body.
- Ask before a migration, a new package, a new environment variable, a route or DTO change, or a `CODEOWNERS` file change, unless the ticket names it.
