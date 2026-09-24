# Copy local orgs/users/roles/services to staging

One-shot ops script: [`server/scripts/copy_local_orgs_to_staging.py`](../server/scripts/copy_local_orgs_to_staging.py).

Copies a curated slice of **local** PocketBase data onto **staging** (`https://staging.hznlaundry.hznsystems.com`) via the superuser API. It does **not** touch production or Hi-Zone Laundry hosts.

## What it copies

| Collection | Behavior |
|---|---|
| `userRoles` | Upsert by id (permissions from local) |
| `organizations` | Only **HZN Laundry**, **Sunrise Laundry**, **Private Cleaners** (fixed ids) |
| `branches` | Branches belonging to those three orgs |
| `quantityUnits` / `serviceCategories` | Upsert by id |
| `users` | Only records with a non-empty email |
| `organizationMemberships` | Only rows for those orgs whose `user` was copied/remapped |
| `services` | Services whose `branch` is one of the copied branches |

**Skipped:** blank-email users (and their memberships), demo orgs (e.g. “Expiring Soon Demo”), staging-only records (left alone).

## Christian user remap

Local and staging already had `christiangerardhizon@gmail.com` under **different** record ids. The script keeps the staging user id and remaps membership FKs to it. It does **not** reset that account’s password.

Other emailed users (e.g. `private.cashier@demo.local`) are created with the local record id and `TEST_ACCOUNT_PASSWORD` from `.env`.

## Prerequisites

- Local PocketBase running (`LOCAL_API_URL`, usually `http://127.0.0.1:8088`)
- `.env` keys: `LOCAL_EMAIL`, `LOCAL_PASSWORD`, `STAGING_URL`, `STAGING_EMAIL`, `STAGING_PASSWORD`, and `TEST_ACCOUNT_PASSWORD` (required for `--apply` when creating auth users)

Auth uses `/api/collections/_superusers/auth-with-password` (same pattern as other `server/scripts/*` helpers).

## Usage

```bash
# Preview creates/updates/skips (no writes)
python server/scripts/copy_local_orgs_to_staging.py

# Write to staging
python server/scripts/copy_local_orgs_to_staging.py --apply
```

Dry-run is the default. Re-running with `--apply` is idempotent for the targeted ids (create if missing, PATCH if present).

## Insert order

`userRoles` → `organizations` → `branches` → `quantityUnits` / `serviceCategories` → `users` → `organizationMemberships` → `services`

IDs are preserved where possible so branch/service/membership relations stay valid. Passwords cannot be exported from PocketBase; only newly created users get `TEST_ACCOUNT_PASSWORD`.

## Out of scope

- Production
- Subscriptions, invites, sales, customers, price tiers, consumable recipes
- Deleting staging-only data
- Filesystem/`pb_data` copies
