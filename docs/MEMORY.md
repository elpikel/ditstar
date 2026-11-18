# Decision log

Dated decision log: what, why, what was rejected.

- 2026-11-18: Claude kit set up (copied from Ether). No issue tracker: tasks live locally in `.claude/work/<slug>/`; `/implement` may run on `main`.
- 2026-11-18: M1 Foundations built (`.claude/work/m1-foundations/`). Decisions made while building:
  - Styler, Credo `--strict` and ex_slop added at the owner's request, all run by `mix precommit`; the Credo checks that Styler rewrites are disabled.
  - A User without a Membership is treated as impossible: building the Scope fails fast (500). Users are created only through `Accounts.register_user/1`. Rejected: a nil-Account Scope that every caller would have to handle.
  - `Accounts.sign_up/2` returns `:ok` for both new and existing emails, and a concurrent duplicate sign-up falls back to the existing user, so the response never reveals whether an email is registered.
  - The Current Product lives in the session. Setup makes a newly created Product current by submitting `PUT /app/current-product` through `phx-trigger-action` (`after=inbox`). Rejected: a GET route that changes state, and leaving the old Product current.
  - Duplicate Keywords, Subreddits and Competitors within one save are caught in the Product changeset (case-insensitive), with the error on the duplicate chip. Unique indexes on `(product_id, lower(value))` back this up. No separate `product_id` indexes, since the unique index covers them.
  - Inbox and Results are static markup until M3 and M6. The "Ditstar, labelled" choice is behind `managed_posting_enabled` (off). Tests that turn the flag on live in `async: false` modules.
  - Landing copy: "Get early access" became "Create account" (owner, 2026-11-18). The managed-posting choice uses the reference copy ("Ditstar posts, labelled") rather than the stories' "Ditstar, labelled as paid".
  - The `UI.chip` `:remove` slot and the `UI.choice` `:option` slot use `validate_attrs: false`, so callers can pass `name`/`value`/`phx-*` through; their `label` attribute is no longer checked at compile time.
- 2026-11-18: Landing hero, owner design decisions during review (departing from the design handoff): floating header; faint ink dot grid behind the hero (13%); a slim wavy lime underline under "right now." that rises into a lime star mark (ink eyes, ink outline). The handoff bans lime as a line on light surfaces; the owner chose it deliberately.
- 2026-11-18: Hero chip copy changed from "Reddit lead finder" to "Reddit leads, found for you" (owner). "On autopilot" was rejected: it implies unattended posting, which Ditstar doesn't do, and it reads as spam tooling on Reddit.
- 2026-11-18: Autopilot is on the roadmap as a goal (owner). Part 1 (digest, batch review) goes in M5. Autopilot posting is M9, after M7 and M8: Managed Accounts only, labelled as paid, opt-in rules, rate limits, kill switch, quality fallback to manual approval. Reddit's terms are checked first. Rejected for now: unattended posting from customers' own accounts.
- 2026-11-18: Target user flow set (owner): paste URL → we suggest channels → pick reply count and schedule → get Drafts → accept or autopilot. Added M3b Instant setup (URL → Product and suggested subreddits, keywords and competitors) and a per-Product posting schedule in M5, which also caps M9 autopilot. M1's manual Setup stays as the review and edit screen.
- 2026-11-18: Landing copy rewritten around the target flow (owner): new hero subhead, four "How it works" cards (Set up, Pace, Reply, Track), autopilot in "We post, labelled", and "only in subreddits that allow promotion" removed from the page (the guardrail stays in the product). Not live yet, so no "Coming soon" labels. Sign-up stays email-only; the URL or description is asked in a guided onboarding step after sign-up (M3b).
- 2026-11-18: Go-live gate (owner): onboarding (URL or description after sign-up), suggestions, posting schedule, batch approval, autopilot, tracking, production email and deploy, and the real founder note and placeholders must all be done before going public. Listed in `docs/ROADMAP.md` under "Before going live".
- 2026-11-18: Hero headline changed from "Someone on Reddit is asking for your product right now." to "Your next customers are on Reddit. Answer them first." (owner), with the lime wave and star under "Answer them first."
- 2026-11-18: Founder photo removed from the landing page (owner); the founder note is text and signature only.
- 2026-11-18: The "Work email" label is hidden on the landing sign-up forms (owner). It stays as an sr-only label so the input is still labelled.
- 2026-11-18: Closing band headline changed from "Stop scrolling Reddit. Start answering it." to "Fresh Reddit leads, every day." (owner). The page closes on the outcome, leads, rather than on replying.
- 2026-11-18: The "From the founder" section was removed from the landing page (owner); `founder_note/1` was deleted with it.
