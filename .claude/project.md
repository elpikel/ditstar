# 🔧 Project settings for the Claude kit

The kit's commands, agents and skills are generic Elixir/Phoenix. Everything specific to this repo lives here. Edit by hand when a fact changes.

## App

| Setting | Value |
|---|---|
| Name | Ditstar: finds Reddit threads where people ask for a product like yours, scores their intent and drafts replies into an inbox |
| Stage | new (no domain code yet) |
| OTP app | `:ditstar` |
| Context root | `lib/ditstar/` (`Ditstar.*`) |
| Web root | `lib/ditstar_web/` (`DitstarWeb.*`) |
| Repo | `Ditstar.Repo` |

## Git and tracking

| Setting | Value |
|---|---|
| Trunk branch | `main` |
| Work on trunk | Allowed: `/implement` runs on the trunk |
| Issue tracker | None: tasks are local, in `.claude/work/<slug>/` |
| Slug | short kebab-case name, e.g. `reddit-ingest` |
| Commit reference | None |

## Databases

| Setting | Value |
|---|---|
| Dev DB (never migrate or roll back) | `ditstar_dev` |
| Test DB (`mix test` migrates it) | `ditstar_test` |
| Table prefixes (by owner) | None yet |

## Tooling

Detected from `mix.exs` and `test/`. A tool marked "none" is never run or required by the agents.

| Tool | Value |
|---|---|
| Formatter | `mix format` (with `Phoenix.LiveView.HTMLFormatter`) |
| Linter | none |
| Background jobs | none (Oban planned for the ingest/score pipeline; workers go in `lib/ditstar/workers/` once added) |
| Test data | none yet |
| External API mocks | none |
| API spec | none |
| Web UI | LiveView (only the generated `PageController` so far) |

## Tests

| Setting | Value |
|---|---|
| Endpoint test case | `DitstarWeb.ConnCase` |
| Data test case | `Ditstar.DataCase` |
| Endpoint test file | `test/ditstar_web/controllers/<controller>/<action>_test.exs`, module `DitstarWeb.Controllers.<Controller>.<Action>Test` |
| LiveView test file | `test/ditstar_web/live/<live_view>_test.exs` |
| Module test file | `test/ditstar/…` mirroring `lib/ditstar/…` |
| Test-data rules | none |
| Known flaky | none |

## Web

| Setting | Value |
|---|---|
| Router | `lib/ditstar_web/router.ex` |
| Path prefixes | `/` (browser), `/dev` (LiveDashboard and mailbox preview, dev only) |
| Pipelines (reviewer checks placement) | `:browser` (session, CSRF, secure headers), `:api` (JSON, no auth; not mounted yet) |
| API docs for clients | none (no external API clients) |

## Access rules (reviewer fails on any leak)

None yet: no authentication. The data model is multi-tenant from day one (account → products → keywords and subreddits), so every thread, draft and tracked link must be scoped to an account.

## Style overrides

The builder and reviewer enforce the kit's default Elixir style (`.claude/agents/builder.md`). List any default this repo turns off or changes; leave "none" to keep them all.

- none

## Docs

| Doc | Path |
|---|---|
| Domain language | `CONTEXT.md` |
| ADRs | `docs/adr/` |
| Architecture | `ARCHITECTURE.md` |
| Decision log | `docs/MEMORY.md` |
