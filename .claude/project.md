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
| Formatter | `mix format` with Styler (and `Phoenix.LiveView.HTMLFormatter`) |
| Linter | `mix credo --strict`, with ex_slop checks |
| Background jobs | none (Oban planned for the ingest/score pipeline; workers go in `lib/ditstar/workers/` once added) |
| Test data | fixture modules in `test/support/fixtures/` (`Ditstar.AccountsFixtures`: `user_fixture/1`, `user_scope_fixture/1`; `Ditstar.ProductsFixtures`: `product_fixture/2`) |
| External API mocks | none |
| API spec | none |
| Web UI | LiveView app under `/app` (`Layouts.app/1` shell, `DitstarWeb.UI` components); controller-rendered landing page at `/` |

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
| Path prefixes | `/` (landing, sign-up, sign-in), `/app` (signed-in app), `/users/settings`, `/dev` (LiveDashboard and mailbox preview, dev only) |
| Pipelines (reviewer checks placement) | `:browser` (session, CSRF, secure headers, current scope), `:require_authenticated_user` (signed-in User; every `/app` route and Settings), `:api` (JSON, no auth; not mounted yet). `live_session :app` mounts `UserAuth :require_authenticated` then `CurrentProduct :assign_current_product`. |
| API docs for clients | none (no external API clients) |

## Access rules (reviewer fails on any leak)

- Every Product, Keyword, Watched Subreddit and Competitor belongs to one Account. A User sees and changes only their Scope's Account's data: `Ditstar.Products` functions take the `Scope` and filter by `scope.account`.
- `account_id` is never cast from params; it comes from the Scope.
- Ids from params or the session (e.g. the Current Product) are resolved through the Scope; a foreign id is "not found" and changes nothing.
- Sign-up never reveals whether an email is already registered.
- The "Ditstar, labelled" (Managed Account) default poster is accepted only when `managed_posting_enabled` is on.

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
