---
profile: orbit
workspace_root: /srv/orbit-work
repos:
  backend: rahal-orbit-backend
  dashboard: rahal-orbit-dashboard
  docs: rahal-orbit-docs
work_folder: work
github:
  account: orbit-dev
  gh_config_dir:
  remote_prefix: git@github.com:
  commit_email: orbit-dev@example.com
linear:
  tools: ""
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
  commit_when: standing_yes_per_ticket
  commit_size: natural_seams
  attribution: none
  push: ask
  open_pr: ask
  pr_state: ready
  post_comments: ask
  re_request_review: ask
  review_model: ask
---
