# Demo Account

email: test@test.com
password: password101

# Multi-org test account (local)

Seeded by `python server/scripts/seed_multi_org_demo.py`. Also stored in `.env` as `TEST_ACCOUNT_EMAIL` / `TEST_ACCOUNT_PASSWORD`.

To mirror the three real local orgs (plus users/roles/services) onto staging, see [copy_local_orgs_to_staging.md](copy_local_orgs_to_staging.md).

| Account | Email | Password | Orgs |
|---------|-------|----------|------|
| Admin (multi-org) | `christiangerardhizon@gmail.com` | `password101` | HZN Laundry + Sunrise Laundry |
| Isolation cashier | `private.cashier@demo.local` | `password101` | Private Cleaners only |

**What to verify after login as Christian**
- Org switcher shows **HZN Laundry** and **Sunrise Laundry** (not Private Cleaners)
- Sunrise: customers Ben/Cara, services Sunrise Wash / Dry Fold, orders `DEMO-SUN-001` / `DEMO-SUN-002`
- HZN: customer Ana, service HZN Demo Wash, order `DEMO-HZN-001`
- Private Cleaners data (`Private Secret Wash`, Dee, `DEMO-PRIV-001`) is hidden

# Soybean Laundry (local / staging / prod)

Seeded by `python server/scripts/seed_soybean_full_store.py --env <local|staging|prod> [--apply]` (or `--all`). Dry-run is the default. Uses `.env` superuser keys (`LOCAL_*`, `STAGING_*`, `PROD_*`). Idempotent; uploads logo from `server/scripts/assets/soybean_laundry_logo.jpg`. Does **not** add Manager login users — Christian remains sole Admin. Future staff invites should use the global **Manager** role.

**What to verify after switching to Soybean Laundry**
- Org picker shows **Soybean Laundry** with the dachshund laundry-shop logo
- Subscription: **Basic Package Semi Annually** (₱12,000 / 6 months, active)
- Feature access: **Consumable usage** enabled (Super Admin override; not in Basic package)
- Service: **Wash and Dry** at ₱22/kg
- Products: Powder Scoop, Fabcon Scoop, Color Safe, Baking Soda, Extra Soak + house Detergent / Softener / Bleach
- POS **Main Menu** lists Wash and Dry + five retail products
- Machines: Washer 1–2 + Dryer 1–2; storages Front Shelf / Back Shelf
- No employees and no promos
- Settings → Team: only Christian as Admin member
- New order: Wash and Dry prefills Detergent + Softener

# Sunrise full store (production)

Seeded by `python server/scripts/seed_sunrise_full_store.py --apply` (dry-run without `--apply`). Uses `PROD_URL` / `PROD_EMAIL` / `PROD_PASSWORD` from `.env`. Idempotent; does **not** add Manager/Cashier/Attendant login users — Christian remains sole Admin.

**What to verify after switching to Sunrise Laundry on prod**
- Org picker / subscription shows **Basic** (active)
- Services: Regular Wash, Wash Dry Fold, Full Service, Dry Only, Comforter / Bulky (demo Sunrise Wash / Dry Fold soft-deleted)
- Products: Powder Scoop, Fabcon Scoop, Color Safe, Baking Soda, Extra Soak + house Detergent / Softener / Bleach
- POS **Main Menu** lists the five services + five retail products
- Machines: Washer 1–2 + Dryer 1–2; storages Front Shelf / Back Shelf
- Employees: Rosa, Miguel, Liza, Carlo (no linked user accounts)
- Promo: **Sunrise Loyal 5** (free 5kg after 5 orders)
- New order: add service + retail product; Full Service / Wash Dry Fold prefill Detergent + Softener
- Settings → Team: only Christian as member

# Other Test Accounts

Login is email + password. Use the email stored on each role's user record in PocketBase Admin (formerly usernames `admin` / `manager` / `cashier` / `attendant`).

| Role | Email | Password |
|------|-------|----------|
| Admin | *(email on the Admin user)* | password101 |
| Manager | *(email on the Manager user)* | password101 |
| Cashier | *(email on the Cashier user)* | password101 |
| Attendant | *(email on the Attendant user)* | password101 |
