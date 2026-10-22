# AGENTS.md

Guidance for AI coding agents (and people) working in this repository. Org-wide conventions for branches, commits,
pull requests and AI disclosure live in [`openaustralia/.github`](https://github.com/openaustralia/.github); follow
those rather than anything assumed here.

## Docker development environment

One stack, defined in `.devcontainer/compose.yaml`, serves every way of working: `make`, plain `docker compose`
(through the root `compose.yaml`), and the dev container in VS Code, RubyMine, Codespaces or
`devcontainer up --workspace-folder .`. They all share the same containers and data.

```
make up           # everything, including the app at http://localhost:3000, once it's ready
make services-up  # everything except `web`
make status       # each container's health and host ports
make logs         # follow the logs (SERVICE=<name> for one container)
make shell        # a shell in the app container, or a fresh one if it has stopped
make test         # the specs, after resetting the test database (ARGS=spec/models/app_spec.rb:42 to narrow)
make lint         # RuboCop (ARGS=<paths> to narrow)
make console      # a Rails console
make down         # stop and remove the containers, keeping the data
make clean        # also remove built images and dependencies, so the next start rebuilds; keeps the data
make clobber      # also remove the data, and prune unused Docker images and cache machine-wide
```

`make up` and `make services-up` return once every service passes its healthcheck. Run `make` for the full list.
A start that takes longer than `START_LIMIT` (in `.devcontainer/compose.yaml`) counts as failed, and stops loudly on purpose;
see "If the app won't start" in the README.

Development runs entirely in Docker, so there's no `make setup`: `make up` does it. `config/database.yml` points at
the `db` container. The `web` container prepares the database before Rails starts. Committed development settings live
in `.devcontainer/app.env`, which the app containers load; your own `.env` overrides them.

### Port clashes

| Variable           | Default | Publishes           |
|--------------------|---------|---------------------|
| `WEB_PORT`         | 3000    | the app             |
| `SMTP_PORT`        | 2525    | Cuttlefish SMTP     |
| `MAILCATCHER_PORT` | 1080    | mailcatcher web UI  |

Put overrides in `.env` at the repo root, which is gitignored, with different values in each worktree. Compose reads
it however you start the stack. Containers and data are named `cuttlefish` (`name:` in `compose.yaml`), so a second checkout of
this repo, such as a worktree, shares them unless its `.env` also sets its own `COMPOSE_PROJECT_NAME`. For
host-side commands to see the same values, put `dotenv` in a gitignored `.envrc` if you use direnv, or
run `set -a; . ./.env; set +a`. Services you rarely need from the host get a random port, which `make status` shows.
To see what holds a port, use `ss -ltnp | grep 3306` (Linux) or `lsof -iTCP:3306 -sTCP:LISTEN` (macOS); a database
server installed on the host is the usual culprit.
