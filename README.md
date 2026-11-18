# Ditstar — project overview

## What it is

Ditstar finds Reddit conversations where people are asking for a product like yours and helps you answer them well.

Reddit threads are where buyers ask for recommendations, and those threads keep ranking in Google and getting cited by AI assistants long after they are posted. Finding the right ones by hand takes hours of scrolling. Ditstar does the finding and the first draft.

## What it does

- **Monitors Reddit.** Watches the subreddits and keywords that matter for your product, plus mentions of competitors.
- **Scores intent.** Separates "looking for a recommendation" and "unhappy with a competitor" from noise, so the inbox holds only threads worth a reply.
- **Drafts replies.** Writes a first draft from the thread and your product context, in your voice.
- **Delivers an inbox.** Shows ranked opportunities with alerts, and opens the thread with the draft ready to paste.
- **Tracks results.** Tags links so you can see which threads brought visits and signups.

## How it works

A thread moves through five steps, from Reddit to a tracked reply.

1. **Ingest.** New posts and comments are pulled from the watched subreddits and keywords through Reddit's official API.
2. **Score.** Each post is embedded and matched against the product description, then an LLM classifies its intent.
3. **Draft.** For threads above the threshold, an LLM writes a reply using the thread and the product context.
4. **Deliver.** The thread and draft land in the user's inbox, with an alert.
5. **Track.** Tagged links report which replies brought traffic and signups.

Planned stack: Elixir and Phoenix, with a background job pipeline for ingest and scoring.

## Managed accounts

Customers who don't want to post themselves can have Ditstar post for them from accounts Ditstar operates. These are labelled paid placements.

- **Disclosed in every reply.** Each reply says it is a paid placement for the product, in the reply text itself.
- **Disclosed on the account.** The account profile states that it is operated by Ditstar and posts on behalf of customers.
- **Where it's allowed.** Managed replies go only to subreddits whose rules permit promotional replies.
- **Customer approval.** The customer approves each draft before it is posted.

Posting from the customer's own Reddit account stays available as the alternative.

## Who it's for

Solo founders and small teams who sell a product that people ask about on Reddit, and who have no time to watch it all day. Agencies running Reddit outreach for several clients are a second audience.

## Rollout

Ditstar is built for our own products first and designed to become a SaaS later.

1. **Internal.** Runs for our own products. No billing, signup or onboarding; products and keywords are configured directly.
2. **SaaS.** Opened to outside customers once it brings measurable traffic for us.

To keep the second step cheap, the data model is multi-tenant from day one: account → products → keywords and subreddits, with every thread, draft and tracked link scoped to an account. Billing, self-serve onboarding and plan limits are left out until phase 2.