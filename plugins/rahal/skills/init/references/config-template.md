# init — the config file

Write exactly this structure to `<workspace>/.claude/rahal.local.md`, filling every `<…>`. Values marked "may be empty" may be left blank.

```markdown
---
profile: orbit
workspace_root: <absolute workspace path, forward slashes>
repos:
  backend: rahal-orbit-backend
  dashboard: rahal-orbit-dashboard
  docs: rahal-orbit-docs
work_folder: work
github:
  account: <github login>
  gh_config_dir: <gh config folder; may be empty>
  remote_prefix: <e.g. git@github.com: or git@<alias>:>
  commit_email: <git user.email inside the repos>
linear:
  tools: <tool name prefix ending in __>
toolchain:
  bash_node_path: <Git Bash form of the Node folder; may be empty>
  e2e_node_options: <--require "<shim path>"; may be empty>
  docker_ports: { postgres: <port>, redis: <port> }
  dev_database_url_port: <port>
workspace_extras:
  docs_folder: <true | false>
  reflector: <true | false>
  superpowers: <true | false>
choices:
  commit_when: <ask_each | standing_yes_per_ticket | never>
  commit_size: <natural_seams | per_task | single>
  attribution: <none | claude>
  push: <ask | auto>
  open_pr: <ask | auto>
  pr_state: <ready | draft>
  post_comments: <ask | auto>
  re_request_review: <ask | auto>
  review_model: ask
---
Notes from init: <port clashes found, tools missing, anything the user said>.
```
