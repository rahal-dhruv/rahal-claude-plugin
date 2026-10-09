# rahal-claude-plugin — contributor guide

This file is the contract for anyone, person or agent, changing this repo. `CLAUDE.md` imports it, so Claude Code and Codex read the same rules.

## 1. What this repo is

The `rahal` Claude Code plugin for the Orbit team: `/rahal:init`, `/rahal:start-work`, `/rahal:review-pr` and `/rahal:pr-followup`. Orbit (`ORB-`) tickets only for now.

| Folder | What it is |
| --- | --- |
| `.claude-plugin/` | The marketplace manifest (`marketplace.json`) that `/plugin install` reads |
| `plugins/rahal/` | The plugin itself: `skills/`, `shared/` (rules, profile, templates), `agents/`. The only folder users install |
| `scripts/` | The repo checks: `check.sh`, `check-output.sh`, `test-check-output.sh`, `test-probes.sh`, and their lists |
| `tests/` | `fixtures/` for `check-output.sh`; `probes/` that run shipped bash blocks in throwaway repos |
| `docs/` | What was built, written for agents. Start at `docs/index.md` |
| `reflector/`, `.claude/` | The opt-in self-improvement loop (`reflector/README.md`) |

## 2. Commands

The gate. Run from the repo root; each must print "all clear" before a change is done:

```bash
scripts/check.sh
scripts/test-check-output.sh
scripts/test-probes.sh
```

`check.sh` needs `claude` on PATH (it runs `claude plugin validate --strict`). In Git Bash on Windows, put your Node folder first on PATH for that shell. To try the plugin itself, see `docs/testing-and-release.md`.

## 3. How to change the plugin

- **Markdown is code: change it test-first.** Pin the new exact line in `scripts/required-headings.txt` (`path|line`), or the removed wording in `scripts/forbidden-text.txt` (`text|why`), or add a `check-output.sh` fixture (`tests/fixtures/bad-<kind>-<reason>.md`). Run `scripts/check.sh`, watch it fail, then edit until it passes. Example: the shim-quoting fix began as the forbidden string `NODE_OPTIONS="<e2e_node_options>"`.
- **A bash block that Claude runs on a user's machine gets a probe** in `tests/probes/`: the probe extracts the block from the shipped Markdown, runs it in a throwaway git repo, and is proven once against a deliberately broken copy.
- **Shared rules live once, in `plugins/rahal/shared/`,** referenced as `${CLAUDE_PLUGIN_ROOT}/…`. Every `SKILL.md` keeps `disable-model-invocation: true`, an `argument-hint`, and the sentence saying the plugin root is two folders above the skill's base directory.
- **A template's headings and `scripts/check-output.sh` change in the same commit.**
- **The reviewer agent (`plugins/rahal/agents/rahal-reviewer.md`) stays read-only and never pins a model.** It may use the Skill tool only for `code-review`, and never with `--fix` or `--comment`.
- **No personal data in any committed file:** no absolute local paths, account names, email addresses, local ports, or a filled-in gh config folder. `scripts/check.sh` catches local paths (Windows, macOS, Linux and the Git Bash `/c/…` form), email addresses other than `example.com`, the maintainer's account name outside `README.md`, the maintainer's two remapped ports and a filled-in gh config folder; any other port it cannot recognise, so keep ports out yourself.
- **Portable bash:** no `grep -P`, `\b` or `sed -i`; quote every path (workspace paths can contain spaces); never `git config` in a probe; record a new script as executable with `git update-index --chmod=+x <file>` (`check.sh` section 12).

## 4. Git and releases

- Commits: `type(scope): lowercase imperative title`, at most 72 characters, title only, no co-author line. The scope is a command (`init`, `start-work`, `review-pr`, `pr-followup`) or an area (`shared`, `agents`, `checks`, `probes`, `docs`, `reflector`).
- Work on a branch and open a pull request into `main`. Nobody pushes to `main`.
- The maintainer merges, bumps `version` in `plugins/rahal/.claude-plugin/plugin.json`, and tags with `claude plugin tag plugins/rahal`.

## 5. Docs

- Start at `docs/index.md` and open only the area you need.
- Updating docs is part of every change, unasked: change a behaviour, update its area doc; add a decision, add a `PD-nn` entry to `docs/decisions.md` (Decision, Why, Cost if wrong, Where, Date).
- Only document what exists. Check a file or rule still exists before citing it.

## 6. Reflector

- If you opted in, read your own `reflector/pending-approvals.md` and `reflector/notes.md` at the start of a session and mention any open approval. Both are git-ignored and stay on your machine.
- Before the final message of every turn, write `.claude/reflector-context.json` (schema: `reflector/README.md`), but only when your `.claude/settings.local.json` registers the reflector hook. Without it, skip this.
- Open plugin work in a session started in this repo's folder; a session opened in a parent folder does not run this repo's hook.

## 7. What not to do

- Never weaken a check to make it pass; fix the cause.
- Never commit `.superpowers/` scratch, `.claude/settings.local.json`, or the reflector's ignored files.
- Never hand-edit `reflector/improvement-log.md`.
- Never run a `/rahal:` command against a teammate's PR or ticket as a test without telling them: posting is gated, but the review still lands in their inbox of attention.
