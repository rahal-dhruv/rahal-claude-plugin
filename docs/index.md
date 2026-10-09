# rahal plugin — docs

Agent-facing documentation of what is built in this repo. Read this file first, then only the area a task needs. The contributor contract is `../AGENTS.md`.

| File | One-line description |
| --- | --- |
| [commands.md](commands.md) | The four commands: arguments, phases and stops, outputs, resume rules, known gaps. |
| [shared-rules.md](shared-rules.md) | Step 0, approval gates, evidence, the review model and single review pass, config keys, templates. |
| [checks.md](checks.md) | `check.sh` sections, `check-output.sh` kinds, fixtures, probes, the test-first practice. |
| [testing-and-release.md](testing-and-release.md) | Loading the plugin, dry runs, proving a run used the plugin, Windows traps, release steps. |

## Rules for this folder

- Start here; descend only into the file a task needs.
- Updating docs is part of every change: behaviour changed, update its area doc; new decision, add a `PD-nn` entry.
- Only document what exists. Verify a file or rule still exists before citing it.
- No task status, no tutorials, nothing derivable from `git log`.
