---
profile: orbit
workspace_root: <root>
repos:
  backend: rahal-orbit-backend
work_folder: work
github:
  account: <login>
  gh_config_dir:
  remote_prefix: git@github.com:
  commit_email: <email>
linear:
  tools:
toolchain:
  bash_node_path:
  e2e_node_options:
  docker_ports: { postgres: 5432, redis: 6379 }
  dev_database_url_port: 5432
workspace_extras:
  docs_folder: false
  reflector: false
  superpowers: false
choices:
  commit_when: ask_each
  commit_size: single
  attribution: none
  open_pr: ask
  pr_state: ready
  post_comments: ask
  re_request_review: ask
  review_model: ask
---
