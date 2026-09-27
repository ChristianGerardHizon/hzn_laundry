# Consumable usage — Implementation Plan

> Status: **Implemented.** This is the working spec for per-order chemical/supply usage (scoops, ml), org Features, and related KPIs/reports.

## Context

HZN Laundry already sells **add-ons** as `saleItems` (revenue, receipts, Add-ons Sold KPI). A customer needs staff to record **how much house detergent / fabcon was used** on each order so the shop can see daily consumption, average usage per order, and material cost — without putting those quantities on the customer receipt.

This is **not** a second inventory catalog. Products remain the catalog. Usage is a child of the sale.

**Supersedes** the multi-tenant note “No organization dashboard” in `docs/multi_tenant_org_email_auth_plan.md`: this feature adds a real org display page with sections (Overview, Features).

## Locked decisions (do not re-litigate)

- Reuse **Product** as the catalog. Do not invent a parallel Materials inventory. Do not put usage on `saleItems`.
- **Create Order + order detail only.** Not POS.
- One usage block **per order**. The selected service’s recipe is the template at create; the order then owns the numbers. Scale is **per order**, not per kg/load. Min **0**, never negative.
- Recipe line is **prefill** or **staff must enter**. Empty must-enter lines **block Create Order**.
- **Copy last recipe**: one button. Latest sale on the **current branch** with the **same service**; if it matches, instantly prefill quantities for products still on the current recipe. No picker.
- Add-ons stay revenue. Only products with **counts toward material cost** fold add-on qty into that order’s usage/cost (no double line).
- Cost = snapshotted `unitCost × qty`. Visible only with `usage.cost.view`.
- No customer receipt lines. No live stock decrement in v1. Void/cancel excluded from averages.
- Feature-flagged **per organization** (`consumableUsage`, default off).
- Org Features toggles use the same gate as org details: `membership.canManageMembers` (`members.manage` or admin).

```text
Product flags/stepper → Service recipe → Order usage section → saleConsumableUsages
                              ↗
saleItems add-on (if countsTowardMaterialCost)
```

## Out of scope (v1)

- POS cashier steppers
- Auto stock decrement / lot FEFO for usage
- Per-kg or per-load scaling
- Usage on the customer receipt or public history page

---

## A. PocketBase schema (`server/pb_migrations/`)

Use timestamps after the latest `17872*` files (this plan uses `1787300xxx`).

### A.1 Per-org `featureFlags`

Today `featureFlags` is unique on `key`, global, and list/view/update require `system.admin`.

1. Add `organization` relation → `organizations` (`pbc_organizations01`), required after backfill.
2. Drop unique index on `key`. Unique `(organization, key)`.
3. Backfill: for each existing org, clone each current global flag row; then delete rows with empty organization. Seed `consumableUsage` (enabled=false) per org.
4. Rules:
   - `listRule` / `viewRule`: member of that org.
   - `updateRule`: member of that org **and** (`members.manage` or `system.admin`) on `@request.auth.role` **or** hook-mediated PATCH if the membership-role vs global-role distinction is unsafe (prefer hook + `requireManageOrgMembers` matching org update).
   - `createRule` / `deleteRule`: `null` (seeded by migration and org-create hook).
5. New org create (`createOrganization` in `organization_invites_helpers.js`) must insert the five flag rows for the new org.

Keys:

| Key | Default | Fail |
|-----|---------|------|
| `emailUpdatesEnabled` | true | open (missing → true) |
| `requireMachine` | false | closed (missing → false) |
| `requirePack` | false | closed |
| `requireStorage` | false | closed |
| `consumableUsage` | false | closed |

### A.2 Product fields (`pbc_4092854851`)

- `isConsumable` (bool, default false)
- `countsTowardMaterialCost` (bool, default false)
- `usageMin` (number, default 0)
- `usageMax` (number, optional)
- `usageStep` (number, optional; treat 0/null as 1)
- `defaultUsage` (number, optional)

Keep existing `quantityUnit`, `unitCost`.

### A.3 `serviceConsumableRecipes`

Join: service recipe lines.

- `service` → services, required, cascade
- `product` → products, required
- `defaultQuantity` (number, default 0)
- `prefill` (bool, default true)
- Unique `(service, product)`
- Rules: same org-membership pattern as services via `service.branch.organization...`

### A.4 `saleConsumableUsages`

- `sale` → sales, required, cascade
- `product` → products, required
- `productName` (text snapshot)
- `quantity` (number)
- `unitLabel` (text snapshot)
- `unitCost` (number snapshot)
- `cost` (number snapshot, qty × unitCost)
- Rules: same org-membership pattern as sales via `sale.branch.organization...`

### A.5 Permissions

Add to `Permissions` (new **Usage** category), **not** bundled with `sales.edit`:

- `usage.view` — see quantities
- `usage.edit` — change amounts
- `usage.cost.view` — see peso cost

Data-migrate Admin like `1787100250_add_org_permissions_to_admin.js`. UI checks `isAdmin || hasPermission(...)`. Do not auto-grant Cashier/Attendant.

---

## B. Client architecture

Feature-based clean architecture. `HookConsumerWidget`. `@riverpod`. `Either<Failure, T>`. Forms: `flutter_form_builder`. DateTime UTC to server. Currency `₱`.

### B.1 Org display page

- Keep list at `/organizations`.
- Add `/organizations/:id` with tabs: **Overview** (existing details form) and **Features** (per-org toggles). Staff invites live under Management → Users.
- Features includes the four migrated workflow flags plus **Consumable usage**.
- Feature toggles live only on Organizations → Features (Management Settings stub removed).
- Scope `feature_flag_repository` by current org.

### B.2 Catalog UI

- Product create/edit: consumable flags + stepper config (min/max/step/default).
- Service detail: recipe list (consumable products, default qty, prefill vs must-enter).

### B.3 Order UI

- Create Order: usage section under add-ons when flag on and `usage.view`. Prefill from selected service recipe. Must-enter empty → cannot create. Copy-last button. Persist via `createSale`.
- Order detail: usage section, editable at any status with `usage.edit`. Cost hidden without `usage.cost.view`.
- Fold add-on qty of `countsTowardMaterialCost` products into usage/cost (single total).
- Do not print usage on thermal receipts.

Copy-last: latest sale on current branch whose service item `serviceId` matches the currently selected service, that has usage rows; copy quantities for products still on the current recipe.

### B.4 KPI and reports

- Dashboard card **Consumables used** (mirror Add-ons Sold): qty by product, average per order, cost if permitted.
- Dashboard PDF section if add-ons already print.
- Reports tab by period. Exclude `voided` / `cancelled` / `refunded` as other sales aggregates do (`status != 'voided'` at minimum).

---

## C. Build order

1. This spec (`docs/features/consumable_usage.md`).
2. Org display + per-org Features + migrate four flags + `consumableUsage`.
3. Product fields, recipes, sale usages, permissions, catalog UI.
4. Create Order + order detail + copy-last + must-enter + add-on fold-in.
5. KPI + reports.
6. `docs/app_overview.md`, `docs/entities.md`, `docs/ui.md`.

---

## D. QA Notes (for the eventual PR)

### What changed

- Org detail page with Overview / Features; feature flags are per organization.
- Consumable products, per-service recipes, usage recorded on orders.
- Dashboard and reports for consumable consumption.

### Test steps

- [ ] Organizations list → open an org → Overview saves, Features toggles persist after refresh; staff invites work from Management → Users.
- [ ] New organization gets all five flags; Consumable usage is off.
- [ ] Management Settings no longer duplicates those toggles.
- [ ] With flag off, Create Order has no usage section.
- [ ] With flag on: mark products consumable, attach a recipe (one prefill, one must-enter), create an order — must-enter blocks until filled; prefill starts at default; min is 0.
- [ ] Copy last recipe prefills only when the last same-service order on this branch exists; does nothing useful otherwise.
- [ ] Add-on with “counts toward material cost” increases that product’s usage/cost on the order; other add-ons do not.
- [ ] Usage is not on the printed receipt.
- [ ] Role without `usage.cost.view` sees quantities, not pesos.
- [ ] Dashboard Consumables used and Reports match today’s orders; voided sales excluded.

### Regression risks

- Feature flags used to be global; orgs must not see each other’s toggles.
- Create Order / checkout still create sales if usage is skipped when the flag is off.
- Add-ons Sold KPI must not include usage rows.
