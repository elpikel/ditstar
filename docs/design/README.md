# Ditstar design handoff

Read this file before any UI work. It tells you what to build, which files are the source of truth, and what is deliberately left undecided.

Ditstar finds Reddit threads where people ask for a product like the customer's, drafts a reply, and tracks what each reply brought in. `product-overview.md` has the full description.

## What to build

| Screen | Reference | Screenshot | Suggested route |
| --- | --- | --- | --- |
| Landing page | `reference/landing.html` | `reference/screenshots/landing.png`, `landing-mobile.png` | `/` |
| App: Inbox | `reference/app-inbox.html` | `reference/screenshots/app-inbox.png`, `app-inbox-mobile.png` | `/app` |
| App: Results | `reference/app-results.html` | `reference/screenshots/app-results.png` | `/app/results` |
| App: Setup | `reference/app-setup.html` | `reference/screenshots/app-setup.png` | `/app/setup` |

Routes are suggestions. Follow the repo's routing conventions.

## How to use these files

1. Open each reference HTML file in a browser next to its screenshot. They are the visual source of truth for layout, spacing and copy.
2. Use `tokens.css` for every colour, font, radius and layout constant. Import it as it is, or map it into the repo's theme system. Do not write hex values in components.
3. The reference files use inline styles so that every value is visible in one place. Do not copy inline styles into production code. Build the components listed below in the repo's own styling approach.
4. Self-host the fonts from `fonts/` with `fonts.css`. Do not load fonts from a third-party CDN.
5. `product-overview.md` plans Elixir and Phoenix. If this repo is Phoenix, the app screens are LiveViews, shared pieces are function components, and the landing page is a plain rendered page.

If the repo's own agent instructions (`CLAUDE.md`, `AGENTS.md`) conflict with this file about code structure, the repo wins. On visual design and copy, this file wins.

## Hard rules

- **Copy is final.** Use the text in the reference files word for word. Do not add sections, testimonials, customer logos, statistics or pricing.
- **Bracketed placeholders stay visible** until the owner supplies the real value: `[YOUR PRODUCT]`, `[COMPETITOR]`, `[YOUR PHOTO]`.
- **Example data is example data.** Every thread, draft, date and number in the references is invented. The app must render real data. The landing page preview keeps the example data and its "Example data" label.
- **Replies posted by Ditstar are always described as labelled paid placements.** Wherever the UI mentions Ditstar posting for the customer, keep the wording from the references ("labelled as paid", "Ditstar, labelled"). Do not build posting from accounts that hide who runs them, and do not build voting features.
- **The lime accent is for dark surfaces.** Use `--accent` on slate or ink backgrounds, or as a fill with `--on-accent` text. Never use it as text or a border on a light background.
- **Use real elements.** Buttons are `<button>`, links are `<a href>`, inputs have a `<label>`. Buttons and links are at least 44px tall; the only exceptions are filter tabs and chips, which are 36px.
- **Contrast.** Body text meets 4.5:1. Do not put `--on-slate-muted` text on `--slate-selected`.

## Tokens

All values are in `tokens.css`. The ones you will use most:

| Token | Value | Use |
| --- | --- | --- |
| `--page` | `#FBFBFA` | Landing page background |
| `--ink` | `#171A21` | Headings, primary button on light, closing band |
| `--text` / `--text-muted` | `#3D4246` / `#5C6166` | Body and caption text on light |
| `--slate` | `#262C38` | App background, app preview on the landing page |
| `--slate-raised` / `--slate-selected` | `#2E3542` / `#323947` | Draft box and selected rows / selected nav and choices |
| `--slate-line` / `--slate-line-strong` | `#3D4554` / `#4A5364` | Dividers / control borders in the app |
| `--on-slate`, `--on-slate-2`, `--on-slate-muted` | `#E8EDF0`, `#C9D2D8`, `#9AA7B0` | Text on slate, strongest to weakest |
| `--accent` / `--on-accent` | `#B8F04A` / `#171A21` | Primary action in the app, highlights on dark |
| `--warn` | `#F2B66B` | "Unhappy with a competitor" tag, competitor chips |

## Typography

| Role | Font | Size / line height | Weight | Letter spacing |
| --- | --- | --- | --- | --- |
| Landing h1 | `--font-sans` | `clamp(40px, 5.8vw, 84px)` / 0.98 | 800 | -0.045em |
| Landing h2 | `--font-sans` | `clamp(32px, 4vw, 54px)` / 1 | 800 | -0.04em |
| Landing h3 (cards) | `--font-sans` | 26px / 1.15 | 700 | -0.02em |
| Landing body | `--font-sans` | 16 to 18px / 1.6 | 400 | 0 |
| Section label | `--font-mono` | 12px, uppercase | 400 | 0.1em |
| App page title | `--font-sans` | 30px | 800 | -0.03em |
| App greeting | `--font-sans` | 20px | 700 | -0.02em |
| Thread title (detail) | `--font-sans` | 26px / 1.25 | 700 | -0.02em |
| Thread title (list) | `--font-sans` | 15px / 1.4 | 600 selected, 500 otherwise | 0 |
| App meta (subreddit, age) | `--font-mono` | 11 to 12px | 400 | 0 |
| Founder signature | `--font-hand` | 44px / 1 | 600 | 0 |

Inter covers everything except labels and data (JetBrains Mono) and the one signature (Caveat).

## Layout

**Landing page.** Content sits in a centred container, `--container` wide with `--gutter` side padding. Sections have `--section-y` padding top and bottom and a 1px `--line` divider. The page has one breakpoint: at 640px and below the two text links in the header are hidden. Everything else reflows by wrapping: card grids use `repeat(auto-fit, minmax(min(320px, 100%), 1fr))`, and two-column rows are wrapping flex rows.

**App.** A wrapping flex row: sidebar (`--sidebar` wide) and content. Below about 780px the sidebar stacks above the content at full width. In the Inbox, the thread list (minimum 320px) and the detail pane (minimum 480px) sit side by side and stack when they no longer fit.

## Components

Build these once and reuse them. The reference file in brackets shows each one.

| Component | Variants and states |
| --- | --- |
| Star mark (`assets/ditstar-mark.svg`) | The brand character: a four-point star with two eyes. Ink on light, `--accent` with `--on-accent` eyes on dark. Used in the logo, the app greeting, the Results callout and the closing band. |
| Button (all) | Primary on light: `--ink` fill, white text. Primary on dark: `--accent` fill, `--on-accent` text. Secondary: 1px border, transparent. Quiet: text only. Heights: 56px on the landing page, 52px for main actions in the app, 44px elsewhere. |
| Text input (landing, Setup) | Label above, 13px. Light: white fill, `--line-strong` border. Slate: `--slate-raised` fill, `--slate-line-strong` border. |
| Label chip (landing hero) | Mono, uppercase, `--chip` fill, 6px radius. |
| Keyword chip (Inbox, Setup) | Matched keyword: `--accent` fill. Subreddit: outlined. Competitor: outlined, `--warn` text. "Add" chip: dashed outline, is a button. |
| Intent tag (Inbox) | Three kinds: "Asking for a recommendation" in `--accent`, "Unhappy with a competitor" in `--warn`, "Related question" in `--on-slate-2`. |
| Sidebar nav item (app) | Icon, label, optional count badge. Current page: `--slate-selected` fill, weight 600, `aria-current="page"`. |
| Thread list row (Inbox) | Subreddit and age, title, intent tag. Selected: `--slate-raised` fill. |
| Filter tabs (Inbox) | Pills. Active: `--on-slate` fill with `--ink` text. |
| Draft box (Inbox, landing) | `--slate-raised` fill, `--slate-line-strong` border, 14px radius, 17px text. |
| Choice (Inbox, Setup) | Two options, one selected. Selected: `--slate-selected` fill and a 1.5px `--on-slate` border, `aria-pressed="true"`. |
| Callout bar (Inbox greeting, Results) | Star mark plus one sentence in Ditstar's first-person voice. |
| Stat tile (Results) | Label and one large number. Only the Signups number uses `--accent`. |
| Data table (Results) | Mono uppercase header, numbers right-aligned in mono, horizontal scroll inside its own box on narrow screens. |
| Feature card (landing) | Mono step label, question heading, one paragraph, small slate preview pinned to the bottom. |
| Founder note (landing) | Photo placeholder, large first-person paragraph, handwritten signature. |

## Behaviour

The references are static. This is what each screen should do.

**Landing page**
- Header links scroll to `#how`, `#replying` and `#access`.
- The hero form and the closing form are the same early-access form. Validate the email and store it. The confirmation state is not designed; see "Not designed yet".
- The app preview is static markup, not the live app.

**Inbox**
- The greeting states how many new threads there are.
- The tabs filter the list: New, Posted, Skipped.
- Selecting a row shows that thread in the detail pane. The first row is selected on load.
- "Matched" lists the keywords that matched this thread.
- The draft is read-only until "Edit draft", which makes it editable.
- "Who posts this one" defaults to the choice saved in Setup.
- "Copy and open thread" copies the draft to the clipboard, opens the Reddit thread in a new tab and moves the thread to Posted.
- "Skip" moves the thread to Skipped.
- "Open on Reddit" opens the thread in a new tab without changing its state.

**Results**
- The range button switches the period for the whole page.
- The callout names the subreddit with the most signups in the period. Hide it when there is no data.
- The table lists posted replies, newest first. The "By" column reads "You" or "Ditstar, labelled".

**Setup**
- Three numbered cards: the product, where to look, who posts by default.
- The dashed "Add" chips add a subreddit, keyword or competitor.
- "Save and start watching" saves and goes to the Inbox.

## Not designed yet

Do not invent these silently. Build the simplest sensible version, keep it within the tokens and components above, and list what you added in your summary.

- Early-access confirmation and error states
- Empty, loading and error states in the app, including an Inbox with no new threads
- Removing a chip in Setup
- The product switcher menu
- Focus styles: use a 2px outline with 2px offset, `--accent` on dark and `--ink` on light
- Sign-in and accounts (the first release is for internal use; see `product-overview.md`, Rollout)
- The approval flow for replies posted by Ditstar

## Open questions for the owner

Ask before building the parts these affect.

1. Where should early-access emails be stored or sent?
2. Is posting by Ditstar part of the first build? Until answered, keep the "Ditstar, labelled as paid" choice behind a feature flag and build only "You post".
3. The founder note is a draft, and the photo is missing. Both need the owner's final version.

## Done when

- Each screen matches its screenshot at 1440px wide, and the two mobile screenshots at 390px.
- All copy matches the reference files.
- No hex colour appears outside `tokens.css`.
- Every control works from the keyboard and shows a focus outline.
- No request leaves the site for fonts or other assets.

## Files

```
docs/design/
  README.md              this file
  product-overview.md    what Ditstar is and does
  tokens.css             colours, fonts, radii, layout constants
  fonts.css              @font-face rules for the fonts below
  fonts/                 Inter, JetBrains Mono, Caveat (latin and latin-ext, woff2) with their licences
  assets/ditstar-mark.svg
  reference/
    landing.html
    app-inbox.html
    app-results.html
    app-setup.html
    screenshots/         desktop renders of all four, mobile renders of the landing page and Inbox
```
