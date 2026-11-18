# Ditstar

Ditstar finds Reddit conversations where people ask for a product like yours, separates buying intent from noise, and drafts a reply for you to post.

## Language

### Tenancy

**Account**:
The tenant: everything in Ditstar is owned by one Account. During the internal phase the Accounts are our own.
_Avoid_: Customer (as a model name), tenant, organization

**User**:
A person who signs in to Ditstar with a magic link sent to their email.

**Membership**:
The link between a User and an Account; a User acts in the Account of their first Membership. No roles yet.

**Sign-up**:
Creating an account from the landing page: submitting an email creates a User, their Account and the Membership, and sends a sign-in link. Open to anyone, used right away.
_Avoid_: Early access, waitlist, registration

**Product**:
Something an Account sells and wants Reddit replies for; its description is the context for scoring and drafting.
_Avoid_: Brand, project

**Current Product**:
The Product the app is showing, chosen in the product switcher and remembered in the session.

**Default Poster**:
Who posts replies for a Product unless changed per Opportunity: the Account's own Reddit account, or a Managed Account (only when managed posting is enabled).

**Keyword**:
A search term watched for a Product.
_Avoid_: Search term, query

**Watched Subreddit**:
A subreddit monitored for a Product.
_Avoid_: Community, channel

**Competitor**:
A rival product whose mentions are watched for a Product.

### Pipeline

**Thread**:
A Reddit post or comment pulled in by ingest and considered as an opportunity.
_Avoid_: Post (for the domain record), conversation, item

**Intent**:
The classification of what a Thread's author wants, e.g. looking for a recommendation or unhappy with a Competitor.

**Opportunity**:
A Thread scored above the threshold for a Product, shown in the Inbox.
_Avoid_: Lead, match

**Draft**:
An LLM-written first version of a reply to an Opportunity, in the Account's voice.
_Avoid_: Suggestion, response

**Inbox**:
The ranked list of Opportunities for an Account, each opening the Thread with its Draft.
_Avoid_: Feed, dashboard

**Tracked Link**:
A tagged link placed in a reply so visits and signups can be attributed to the Thread.
_Avoid_: UTM link, referral link

### Posting

**Managed Account**:
A Reddit account operated by Ditstar that posts approved Drafts on a customer's behalf as a disclosed paid placement.
_Avoid_: Bot account, shill account

**Paid Placement**:
A reply posted from a Managed Account, disclosed as paid in the reply text and on the account profile.
