# Demo Account

email: test@test.com
password: password101

# Multi-org test account (local)

Seeded by `python server/scripts/seed_multi_org_demo.py`. Also stored in `.env` as `TEST_ACCOUNT_EMAIL` / `TEST_ACCOUNT_PASSWORD`.

| Account | Email | Password | Orgs |
|---------|-------|----------|------|
| Admin (multi-org) | `christiangerardhizon@gmail.com` | `password101` | HZN Laundry + Sunrise Laundry |
| Isolation cashier | `private.cashier@demo.local` | `password101` | Private Cleaners only |

**What to verify after login as Christian**
- Org switcher shows **HZN Laundry** and **Sunrise Laundry** (not Private Cleaners)
- Sunrise: customers Ben/Cara, services Sunrise Wash / Dry Fold, orders `DEMO-SUN-001` / `DEMO-SUN-002`
- HZN: customer Ana, service HZN Demo Wash, order `DEMO-HZN-001`
- Private Cleaners data (`Private Secret Wash`, Dee, `DEMO-PRIV-001`) is hidden

# Other Test Accounts

Login is email + password. Use the email stored on each role's user record in PocketBase Admin (formerly usernames `admin` / `manager` / `cashier` / `attendant`).

| Role | Email | Password |
|------|-------|----------|
| Admin | *(email on the Admin user)* | password101 |
| Manager | *(email on the Manager user)* | password101 |
| Cashier | *(email on the Cashier user)* | password101 |
| Attendant | *(email on the Attendant user)* | password101 |
