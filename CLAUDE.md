# Ditstar

@AGENTS.md

Finds Reddit threads where people ask for a product like yours, scores their intent and drafts replies into an inbox. Overview: `README.md`. Domain language: `CONTEXT.md`. Architecture: `ARCHITECTURE.md`.

## Commands

- `mix setup` - install deps, create and migrate the DB, build assets
- `mix phx.server` - run the app at http://localhost:4000
- `mix test` - run all tests
- `mix test path/to/test.exs:LINE` - run one test
- `mix precommit` - compile with warnings as errors, unlock unused deps, format, test

## Agent skills

### Work tracking

No issue tracker: tasks are local, with plans and working docs in `.claude/work/<slug>/` (git-ignored). Flow: `/brainstorm` → review → `/implement` (uncommitted, may run on `main`) → review → "yes, commit". See `.claude/README.md`; repo settings in `.claude/project.md`.

### Domain docs

Single-context layout: one `CONTEXT.md` + `docs/adr/` at the repo root.
