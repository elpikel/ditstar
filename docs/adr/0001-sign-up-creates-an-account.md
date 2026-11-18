---
status: accepted
---

# Sign-up creates an account, and tenancy goes through memberships

Anyone can sign up from the landing page and use Ditstar right away: an email creates a User, a new Account and the Membership between them, and phx.gen.auth's magic link signs them in. There is no early access, waitlist or approval, and no separate `/users/register` page. Users reach Accounts only through memberships, even though each Account has one User in phase 1, so agencies (phase 2) need no data migration. The current Account is the user's first Membership's Account, carried in the phx.gen.auth `Scope`, and every context query takes the Scope.

## Considered options

- **Early access with manual approval.** Rejected: people should be able to use the product as soon as they sign up.
- **`users.account_id`.** Simpler now, but moving to memberships later means a data migration and touching every query.
