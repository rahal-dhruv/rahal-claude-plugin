---
workspace_root: <absolute workspace path, forward slashes; on Windows the drive form <drive>:/…, never Git Bash's /c/… form, which MSYS_NO_PATHCONV passes to git unconverted>
work_folder: work
github:
  account: <github login>
  gh_config_dir: <gh config folder; may be empty>
  remote_prefix: <e.g. git@github.com: or git@<alias>:>
  commit_email: <git user.email inside the repos>
linear:
  tools: <tool name prefix ending in __; may be empty only while Linear is not connected, which step 0 reports>
toolchain:
  bash_node_path: <Git Bash form of the Node folder; may be empty>
families:
  orbit:
    repos:
      backend: rahal-orbit-backend
      dashboard: rahal-orbit-dashboard
      docs: rahal-orbit-docs
    docker_ports: { postgres: <port>, redis: <port> }
    dev_database_url_port: <port>
    e2e_node_options: <--require "<shim path>"; may be empty>
  corporate:
    repos:
      backend: rahal-corporate-backend
      app: rahal-corporate-app
      dashboard: rahal-corporate-dashboard
    docker_ports: { postgres: <port>, redis: <port> }
    dev_database_url_port: <port>
    e2e_node_options: <may be empty; the corporate e2e suites need no shim>
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
