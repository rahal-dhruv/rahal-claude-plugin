# init — commands for each step

Start Node and pnpm commands in Git Bash with `export PATH="<node folder>:$PATH";` once the folder is known (step 4).

## Workspace

```bash
cd "<workspace>"
for r in rahal-orbit-backend rahal-orbit-dashboard rahal-orbit-docs rahal-corporate-backend rahal-corporate-app rahal-corporate-dashboard; do
  case "$r" in rahal-orbit-*) family=orbit ;; *) family=corporate ;; esac
  [ -e "$r/.git" ] && echo "found $family $r" || echo "missing $family $r"   # -e: a linked worktree's .git is a file
done
git clone "<remote_prefix>DigitalZoneApp/<repo>.git" "<workspace>/<repo>"     # only with a yes
```

## GitHub

```bash
gh --version
GH_CONFIG_DIR="<folder or unset>" gh auth status
GH_CONFIG_DIR="<folder or unset>" gh api user --jq .login
GH_CONFIG_DIR="<folder or unset>" gh repo view DigitalZoneApp/<each found repo> --json name --jq .name
git -C "<workspace>/<a found repo>" remote get-url origin      # remote_prefix = everything before "DigitalZoneApp/"
git -C "<workspace>/<a found repo>" config user.email      # commit_email
```

## Linear

- ToolSearch with the query `linear get_issue`, max 10 results. A Linear tool set has names ending `get_issue`, `list_comments`, `list_issues`, `extract_images`. The prefix is everything before `get_issue`, for example `mcp__<connector id>__` or `mcp__plugin_productivity_linear__`.
- Load `select:<prefix>get_issue`, then call it with the ticket id the user gives.
- If the only Linear server listed needs authentication, it is not usable yet. Say how to connect it, and continue.

## Toolchain

```bash
node -v; cat "<workspace>/rahal-orbit-backend/.nvmrc"     # corporate repos have no .nvmrc: the profile names their Node
pnpm -v; corepack --version; npm -v                # npm only for the corporate backend
docker info --format '{{.ServerVersion}}'
docker ps --format '{{.Names}} {{.Ports}}'      # another container on a family's ports is a clash
```

`corepack enable` writes pnpm shims into the global Node install, so it is a change, not a check: offer it only when `pnpm -v` fails, and run it only with a yes.

Orbit's ports can move; the corporate backend's are fixed in its `docker-compose.yml`, so record them as they are. To pick free ports for Orbit, add 10 to each default and check the result with `docker ps`; keep adding 10 until both are free, and clear of the corporate ones when both families are configured. Start Orbit with `ORBIT_POSTGRES_PORT=<p> ORBIT_REDIS_PORT=<r> docker compose up --wait` from the backend folder. Prisma dev commands then need `DATABASE_URL` with that port, passed in the shell; never edit `.env`. Record each family's `dev_database_url_port` (the corporate one is its compose Postgres port).

Git Bash on Windows does not read PowerShell Node managers (fnm, nvm-windows):
- Find the folder holding `node.exe` with `where.exe node` in PowerShell, or under the manager's install folder (fnm: `<fnm dir>/node-versions/v<x>/installation`).
- Record it in Git Bash form (`/c/...`) as `bash_node_path`.

## Windows e2e shim

The Orbit backend's e2e global setup spawns `pnpm` without a shell, which fails on Windows (`spawnSync pnpm ENOENT`). With a yes, write `<workspace>/.claude/rahal/win-pnpm-shim.cjs`:

```js
// Test-run-only shim: routes execFileSync('pnpm', …) through cmd.exe on Windows.
const childProcess = require('node:child_process');
const { syncBuiltinESMExports } = require('node:module');

const original = childProcess.execFileSync;
childProcess.execFileSync = function execFileSync(file, args, options) {
  if (process.platform === 'win32' && file === 'pnpm') {
    return original.call(this, process.env.ComSpec || 'cmd.exe', ['/d', '/s', '/c', 'pnpm', ...(args ?? [])], options);
  }
  return original.apply(this, arguments);
};
syncBuiltinESMExports();
```

Record `families.orbit.e2e_node_options: --require "<Windows-form path to that file, forward slashes>"`, double quotes included: Node reads them, and they keep a path with a space in one piece. On macOS and Linux leave it empty.

## Extras

```bash
[ -d "<workspace>/docs" ] && echo docs; [ -d "<workspace>/reflector" ] && echo reflector
claude plugin list 2>/dev/null | grep -i superpowers
claude plugin install superpowers@claude-plugins-official     # only with a yes
```
