# Organizations (Multi-Tenancy) + Email/Password Auth — Implementation Plan

> Status: **Approved, implementation in progress.** This document is the working plan for adding real multi-tenant organization support and switching authentication from username+password to email+password. Revised from the original plan mode approval to a **multi-organization-per-user membership model** (see "Decisions" below) — keep this file updated as sections land.

## Context

HZN Laundry (this Flutter + PocketBase app) is currently single-tenant: one business operating multiple **branches** (e.g. "Hi-Zone", "Magsaysay"), with `branch` acting as the only scoping boundary — applied inconsistently and enforced almost entirely client-side (nearly every PocketBase collection rule is wide open, `""`). Auth is username-only: the `users` collection requires a unique `username` and treats `email` as optional/unused across the whole client.

Goals:
1. **Real multi-tenant organization support** — a proper tenant boundary above branches, with actual server-side data isolation (not just client-side filtering). A user can belong to **multiple organizations**, invited into each with its own role.
2. **Auth switched from username+password to email+password**, with username removed entirely.

Decisions already made (do not re-litigate):
- The new tenant entity is literally called **"Organization"** (`organizations` collection). This collides with the *existing* `features/organization/` admin section (branch/user/role/machines/storages management UI), so that existing feature is renamed to **"Management"** to free up the name.
- **Many-to-many, not one org per user** (revised from the original single-relation-field decision). A user can be a member of multiple organizations, each membership carrying its own role. Membership is a join collection (`organizationMemberships`), not a field on `users`.
- **Organization creation is permission-gated, in-app self-service — not superuser-only.** User *accounts* are still provisioned only via PocketBase Admin or an existing org's admin (no public sign-up in this release), but any authenticated user whose role grants a new `organizations.create` permission can create an organization from within the app — becoming its first member — instead of a superuser doing it through PocketBase Admin UI. Creating an org walks the user through a **setup walkthrough** to finish configuring it before it's marked ready.
- **Invites, not direct add.** Adding a person to an org — including the walkthrough's "invite your team" step — always goes through an `organizationInvites` record (email + role + expiry), accepted by the invited user, never a direct membership insert from the client.
- **Org switcher only appears with 2+ memberships.** A user in exactly one organization never sees an org selector — only the branch switcher, scoped to that org's branches, exactly as today. The org switcher (when it exists) is a peer to the existing branch switcher, not a full "organization dashboard" — see B.7.
- **No organization dashboard.** Instead: one more tab/page — "Organizations" — listing the orgs the current user belongs to, their details, and an invite-people-to-this-org flow (plus the user's own pending invites, with accept/decline). Nothing more elaborate than that in this release.
- **Hard cutover** to email auth: a migration will make `email` required and switch `passwordAuth.identityFields` to `["email"]`, and `username` is fully removed from schema + client. This requires every existing user to have a real email on file first — a manual, human-gated step (cannot be automated/fabricated).

### Precedent: sibling project `hzn_gyms`

`D:\Projects\hzn_gyms` (a separate Flutter+PocketBase app) just implemented and **live-tested** an equivalent membership/invite system — independent parallel work, not a shared backend, but its migrations/hooks are a verified reference for exact PocketBase syntax that would otherwise be unverified here:

- `D:\Projects\hzn_gyms\server\pb_migrations\1788389510_created_organizationMemberships.js` (+ `1788389528_updated_organizationMemberships.js`) — `organizationMemberships` collection, id `pbc_5182934071`.
- `D:\Projects\hzn_gyms\server\pb_migrations\1788389537_created_organizationInvites.js` (+ `1788389545_updated_organizationInvites.js`) — `organizationInvites` collection, id `pbc_5182934182`.
- `D:\Projects\hzn_gyms\server\pb_hooks\organization_invites.pb.js` + `server\pb_hooks\lib\organization_invites_helpers.js` — create/accept/revoke routes.
- **Confirmed live** (impersonation-tested against PocketBase 0.39.10, the version hzn_gyms pins — verify hzn_laundry's own pinned version matches/is compatible before trusting this without a local check): the back-relation filter `organization.organizationMemberships_via_organization.user ?= @request.auth.id` correctly scopes to "orgs/records the caller shares an org with." Also confirmed: `role.permissions ?~ "some.key"` is valid syntax for "JSON array contains string" in a rule.
- **Confirmed live bug to avoid repeating:** inside a JS hook, `record.get("permissions")` on a JSON-typed field returns a `types.JSONRaw` byte-wrapper, **not** a plain JS array — `Array.isArray()`/`.indexOf()` silently fail against it. Must decode via `record.get("permissions").string()` then `JSON.parse(...)` before checking membership. Apply this from the start in `organization_invites.pb.js` below (A.4) rather than discovering it the same way hzn_gyms did.
- hzn_gyms deliberately did **not** solve "scope the base `users` collection's own list/view rule by shared org membership" — it only scoped `organizations`/`organizationMemberships`/`organizationInvites`/`branches`. hzn_laundry has the same open gap; see A.6's note.

---

## A. PocketBase schema/migrations (`server/pb_migrations/`)

Re-check `ls server/pb_migrations | sort | tail` right before writing — this plan was drafted against `1787000000_add_minimumCharge_to_services.js` as the latest; use increasing timestamps from `1787100000` onward, adjusting if newer migrations have landed since.

**Rule semantics confirmed in this repo:** `null` = superuser-only; `""` = public (incl. guests); non-empty expression = must match for non-superuser auth records.

1. **`1787100000_created_organizations.js`** — new `organizations` collection (id `pbc_organizations01`). Fields: `name` (text, required), `contactNumber`, `address` (optional text), `onboardingCompletedAt` (date, optional — null means the setup walkthrough isn't finished yet), `isDeleted` (bool, default false), plus standard `created`/`updated` autodate fields (copy the field-block shape from an existing collection like `customers` or `incentiveTiers`). Rules:
   - `listRule`/`viewRule` = `"@request.auth.id != \"\" && organizationMemberships_via_organization.user ?= @request.auth.id"` — visible only to members (back-relation into the new A.2 collection).
   - `createRule`/`updateRule`/`deleteRule` = `null` — writes are hook-mediated only (A.4), same reasoning as hzn_gyms: creating an org must atomically also create the creator's first membership row, which a raw collection rule can't express.

2. **`1787100100_created_organizationMemberships.js`** — new join collection `organizationMemberships` (id `pbc_org_memberships01`). Fields, mirroring hzn_gyms's proven shape:
   - `user`: relation → `users` (`pbc_3841632486`), maxSelect 1, required.
   - `organization`: relation → `organizations` (`pbc_organizations01`), maxSelect 1, required.
   - `role`: relation → `userRoles` (existing collection this repo already has — reuse it as-is; roles stay global/shared across orgs, not per-org, matching hzn_gyms's choice and this repo's existing single `userRoles` table), maxSelect 1, required.
   - `status`: select `["active","suspended"]`, maxSelect 1, required.
   - `invitedBy`: relation → `users`, maxSelect 1, optional.
   - `joinedAt`: date, required.
   - `created`/`updated`: autodate.
   - Unique index on `(user, organization)`.
   - Rules: `listRule`/`viewRule` = `"@request.auth.id != \"\" && (user = @request.auth.id || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"` (self, or any fellow member of the same org — a visible team roster). `createRule`/`updateRule`/`deleteRule` = `null` — hook-mediated only (A.4); hook code calling `app.save()` is not subject to collection API rules, so this is intentional.

3. **`1787100150_created_organizationInvites.js`** — new collection `organizationInvites` (id `pbc_org_invites0001`). Fields:
   - `email`: type `email`, required.
   - `organization`: relation → `organizations`, maxSelect 1, required.
   - `role`: relation → `userRoles`, maxSelect 1, required.
   - `token`: text, required, `autogeneratePattern: "[a-zA-Z0-9]{32}"`, min 32, max 32, **`hidden: true`** (never serialize it into list/view API responses to other org members who can see the invite row via `listRule` — hook code can still read it internally).
   - `status`: select `["pending","accepted","expired","revoked"]`, maxSelect 1, required.
   - `invitedBy`: relation → `users`, maxSelect 1, required.
   - `acceptedBy`: relation → `users`, maxSelect 1, optional.
   - `expiresAt`: date, required.
   - `created`/`updated`: autodate.
   - Unique index on `token`.
   - Rules: `listRule`/`viewRule` = `"@request.auth.id != \"\" && (invitedBy = @request.auth.id || email = @request.auth.email || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"`. `createRule`/`updateRule`/`deleteRule` = `null`.

4. **`server/pb_hooks/organization_invites.pb.js`** (new hook, not a migration — write alongside the above). Adapt directly from `D:\Projects\hzn_gyms\server\pb_hooks\organization_invites.pb.js` and `lib\organization_invites_helpers.js` (check this repo's existing hook files first for its own `routerAdd`/error-response house style before copying verbatim — don't assume it matches hzn_gyms's). Three routes:
   - `POST /api/organization-invites` — create an invite. 401 if unauthenticated. Authorize: caller has an `active` `organizationMemberships` row for the target org whose role's `permissions` contains a new `members.manage` permission (A.5), looked up via a single `app.findFirstRecordByFilter("organizationMemberships", "organization = {:org} && user = {:user} && status = 'active'", {...})` — not a filter-rule chain, to avoid ANDing conditions across different back-relation rows. 403 otherwise. Create the invite: lowercased/trimmed `email`, `organization`, `role`, `invitedBy = e.auth.id`, `status = "pending"`, `expiresAt = now + 7 days`; let `token` auto-generate.
   - `POST /api/organization-invites/{id}/accept` — 401 if unauthenticated. 404 if missing. 400 if `status != "pending"`. If expired: flip `status = "expired"`, save, 400. 403 if caller's email (case-insensitive) doesn't match the invite's `email`. If a membership already exists for `(user, organization)`, treat as idempotent (still mark invite accepted, return the existing row). Otherwise create the `organizationMemberships` row (`status = "active"`, `joinedAt = now`, `role = invite.role`). Update the invite: `status = "accepted"`, `acceptedBy = e.auth.id`.
   - `POST /api/organization-invites/{id}/revoke` — same authorization as creation. 404 if missing, 400 if not pending. Set `status = "revoked"`.
   - **Apply the JSON-decode fix from the start** (see hzn_gyms precedent above): write a small `readPermissions(record)` helper — `JSON.parse(record.get("permissions").string())` — reused everywhere a role's `permissions` array is checked in this hook, rather than `Array.isArray`/`.indexOf` directly on `record.get(...)`.
   - Also handle organization creation authorization here (or in a second small hook file) for A.1's `createRule: null`: `onRecordCreateRequest("organizations")` — check caller's role (`e.auth`'s `role` relation on `users`, via the *existing* global-role field, not a membership — org creation happens before the creator has any membership) has `organizations.create` (A.5), 403 otherwise; on success, immediately create the creator's own `organizationMemberships` row for the new org (role = the same "Admin" system role used for platform-level admin today — see A.5's note on why this is a deliberate simplification, not a full per-org role model).

5. **New permissions in `Permissions` (`lib/src/features/users/domain/user_role.dart`):**
   - `organizations.create` — new `'Organizations'` category, lets a user self-serve create an org (A.4's org-create hook check).
   - `members.manage` — new `'Organization Members'` category (kept distinct from any existing per-branch "Employees" category to avoid taxonomy collision), lets a user invite/revoke/manage members within an org they already belong to (A.4's invite-hook check).
   - Add both to the seeded `Admin` system role's permission list via a data migration (`server/pb_migrations/1774000001_seed_user_roles.js` only seeds `system.admin` for Admin today — confirm whether checks elsewhere ever special-case `system.admin` as an implicit wildcard, or are always explicit-key lookups; if explicit, both new keys must be added to Admin's stored `permissions` array explicitly, not assumed).
   - **Open simplification, flag don't hide:** because roles stay global (not scoped per-org, matching hzn_gyms's own choice), the role assigned to a new org's creator/first member is the same shared "Admin" role used for platform-wide admin today — there's no distinct "Org Owner" role in this release. Acceptable for now; revisit if a real need for per-org role differentiation shows up.

6. **`1787100300_backfill_default_organization.js`** — data migration: create one default `Organization` named `"HZN Laundry"` (matches `Constants.appName`), backfill `organization` onto every existing `branches` row via `app.findAllRecords(...)` + `app.save(...)`, and create an `organizationMemberships` row (`status: "active"`, `joinedAt: now`) for every existing `users` row against that default org, carrying over each user's existing `role`. Down migration is a no-op (reversing a data backfill is unsafe). Must run after #1–#3, before #7.

7. **Org-scoping rules on branch-scoped business collections** (`products`, `services`, `sales`, `customers`, `machines`, `storages`, `printerConfigs`, `posGroups`, `carts`) — one migration per collection. Since `branch` is optional on these (unassigned records must stay visible per `docs/app_overview.md`), use:
   ```
   @request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)
   ```
   for list/view **and** create/update/delete (today's write rules are mostly wide open too — this closes a real gap, since currently anyone unauthenticated could write cross-branch/cross-org data). Before writing each migration, fetch the collection's *live* current rule via Admin UI/API (most aren't in tracked migration history) and merge onto it rather than assuming `""`.

8. **`1787100500_updated_branches_org_rule.js`** — `branches`' own `listRule`/`viewRule`/write rules get `organization.organizationMemberships_via_organization.user ?= @request.auth.id` — membership-based, not the old single-field `organization = @request.auth.organization` comparison (no longer possible now that org is multi-valued per user). Deliberately org-membership-only (not branch-specific) so the existing "All Branches" admin UX keeps working — this is exactly the trap that broke the earlier `1786899856_updated_products_list_rule.js` attempt (that one checked a *specific* branch match); this design avoids it.

   **A.6 note — `users` collection scoping is a known, deliberately deferred gap.** Unlike `branches`/business collections, the base `users` collection itself can't be cleanly scoped by "shares an org with the caller" via a single PocketBase filter rule — that requires comparing two different back-relation sets (the target user's orgs vs. the caller's orgs) for overlap, which PB's filter language doesn't expressly support. hzn_gyms hit the same wall and didn't solve it either. For this release, leave `users`' existing rule as-is (already gated by app-level `users.view` permission checks client-side, not true server-side cross-org isolation) and treat this as a follow-up item, not a blocker — call it out explicitly rather than shipping a rule that looks like isolation but isn't.

9. **`1787100700_fix_machines_storages_branch_collectionId.js`** — unrelated pre-existing bug fix while touching this area: `machines`/`storages`' `branch` relation fields point at wrong `collectionId: "pbc_branches0001"` instead of the real `pbc_2358601297` (from `1770300001_created_machines.js` / `1770300002_created_storages.js`).

10. **Username removal (gated — see Section C):**
    - `1787200000_users_require_email_identity.js` — `unmarshal({"passwordAuth": {"identityFields": ["email"]}}, collection)` + set `email` field `required: true`. (Confirmed proven shape: this is literally what the *down*-migration of `1770395107_updated_users.js` already does.)
    - `1787200100_users_drop_username.js` (later, after client cutover ships) — `collection.fields.removeById("text1483516233")` (confirmed field id) + drop the `idx_DiodYfwMRw` unique index.
    - Update `server/pb_hooks/auto_verify_users.pb.js`: `e.record.getString("username")` → `e.record.getString("email")` (log line only).

11. **Password reset flow** — no schema change to enable it (`requestPasswordReset`/`confirmPasswordReset` are built into any `type: "auth"` collection). Add `1787200200_users_reset_password_template.js` to repoint `resetPasswordTemplate`'s link from PocketBase's own admin UI route to the new static page: `{APP_URL}/reset-password.html?token={TOKEN}`. Since the Flutter web build is deployed into PocketBase's own `pb_public/` (same as `web/privacy-policy.html` today), this is same-origin — no CORS config needed.

12. **`server/scripts/list_users_missing_email.py`** — new helper script, modeled on `server/scripts/backfill_sale_service_storage_names.py` (same `.env` keys: `STAGING_EMAIL`/`STAGING_PASSWORD`/`STAGING_URL`, `PROD_EMAIL`/`PROD_PASSWORD`/`PROD_URL` — these are the real `.env` key names, not the `PB_PROD_EMAIL`-style names documented in `CLAUDE.md`, which is stale). Auths as superuser, pages through `users`, prints every record with blank/missing `email` (id, username, name) so a human can fill them in. **Never fabricates emails** — this is a read-only reporting tool used as a manual pre-flight gate before step 10's first migration.

---

## B. Flutter client changes

### B.1 — Rename `features/organization/` → `features/management/`

| Old | New |
|---|---|
| `lib/src/features/organization/presentation/pages/organization_shell.dart` (`OrganizationShell`) | `.../management/presentation/pages/management_shell.dart` (`ManagementShell`) |
| `organization_nav_panel.dart` (`OrganizationMode` enum, `OrganizationNavPanel`) | `management_nav_panel.dart` (`ManagementMode`, `ManagementNavPanel`) |
| `tablet_organization_layout.dart` / `empty_organization_state.dart` | `tablet_management_layout.dart` / `empty_management_state.dart` |
| `lib/src/core/routing/routes/organization.routes.dart` (all `Organization*Route` classes, `part 'organization.routes.g.dart'`) | `management.routes.dart` (`Management*Route`, regenerated `.g.dart`); path `/organization` → `/management` |

Fan-out to update (verified via grep):
- `lib/src/core/routing/router.dart` — import + `$organizationShellRoute` → `$managementShellRoute`.
- `lib/src/core/pages/app_root.dart` — line 11 import, line 81 `OrganizationRoute.path`, line 96 `OrganizationRoute()`, line 178 `'organization' => t.navigation.organization`.
- `lib/src/core/widgets/breadcrumb_nav.dart` — import + `case 'organization':` block.
- `lib/src/core/widgets/nav_permissions.dart` — line 95 `t('organization')` key.
- `lib/src/features/settings/presentation/pages/branches_page.dart` and `.../widgets/branch_detail_panel.dart` — `OrganizationBranch*Route` imports/usages.
- `lib/src/features/users/presentation/widgets/dialogs/create_user_dialog.dart` — `isOrganization` var + `'/organization'` prefix check + `OrganizationUserDetailRoute` (line ~104).
- `lib/src/features/activities/presentation/pages/activities_page.dart` — line 47 tab `label: 'Organization'` → `'Management'`.
- `assets/i18n/{en,tl}/navigation.i18n.json` — key `organization` → `management`, regenerate via `dart run slang`.
- `lib/src/core/packages/pocketbase/pocketbase_collections.dart` — line 10 `// Organization` comment now legitimately belongs to the new `organizations` collection; add `static const String organizations = 'organizations';`, `organizationMemberships`, `organizationInvites`, and move `branches`/`printerConfigs` under a renamed `// Management` header.
- Docs: `docs/app_overview.md`, `docs/folder_structure.md`, `docs/ui.md`, `docs/entities.md` — update nav trees/route tables/folder trees accordingly.

### B.2 — Real `Organization` + membership domain concepts

- New `lib/src/features/organizations/domain/organization.dart` — `@MappableClass()` model `{id, name, contactNumber, address, onboardingCompletedAt}`.
- New `lib/src/features/organizations/domain/organization_membership.dart` — `@MappableClass()` model `{id, organizationId, userId, role, status, joinedAt}` (embed the `Organization` object too where convenient for list UIs, or keep it a bare relation id + a repository method that expands it — match how existing repos in this codebase handle relation expansion).
- New `lib/src/features/organizations/domain/organization_invite.dart` — `{id, organizationId, organizationName, email, role, status, expiresAt}` (no `token` field client-side — it's server-hidden and never needed by the client, which calls `/accept`/`/revoke` by invite id, not token).
- New `lib/src/features/organizations/data/dto/*` + a small `OrganizationRepository` (`create()`, `update()`, `get(id)`), `OrganizationMembershipRepository` (`listMine()`, `listForOrganization(orgId)`), and `OrganizationInviteRepository` (`create()`, `accept()`, `revoke()`, `listMine()` for the current user's pending invites, `listForOrganization(orgId)`) — the latter two call the custom hook routes from A.4 (`pb.send('/api/organization-invites', ...)`), not raw collection CRUD, since `createRule`/`updateRule` are `null`.
- `AuthDto`/`User` — **no `organization` field** (dropped from the earlier single-org plan; membership is no longer carried on the auth record at all — it's derived from `organizationMemberships` at runtime via B.3 below).
- **No client-side org filtering anywhere else for branch-scoped business data** — the new PocketBase rules (A.7/A.8) enforce isolation server-side, so `PBFilters`/existing queries need no changes there.

### B.3 — Current-organization + org switcher (new)

Modeled structurally on the existing `CurrentBranchController` (`lib/src/features/settings/presentation/controllers/current_branch_controller.dart`) — same allowed-ids/persist/switch shape, re-parented onto a membership list instead of a single field. **Not** a port of hzn_gyms's `CurrentOrganizationController` — that one is a superadmin single-tenant-inspection fallback, a different problem; only the code *shape* (secure-storage persistence, `AsyncLoading` guard to avoid flicker) is worth reusing.

- New `lib/src/features/organizations/presentation/controllers/current_organization_controller.dart` (`@Riverpod(keepAlive: true)`): loads the current user's active `organizationMemberships` (via `listMine()`). Resolution: if exactly one, auto-select it (no UI). If multiple, resolve from secure storage (key `CURRENT_ORGANIZATION_ID`) falling back to the first membership if the persisted id is no longer valid (e.g. membership was revoked). Exposes `canSwitchOrganization()` (`memberships.length > 1`), `switchableOrganizations()`, `switchOrganization(id)` (persist + refetch, same `AsyncLoading` guard pattern as `CurrentBranchController`).
- Branch switcher (existing `CurrentBranchController`) is re-scoped to only the branches under the currently-selected organization — its branch list query gains a filter on the current org id.
- UI: the existing branch-switcher widget location (wherever `CurrentBranchController` is surfaced in nav/app bar today — check that widget) gets a sibling org switcher that **only renders when `canSwitchOrganization()` is true** — a user in one org sees just the branch switcher, unchanged from today.

### B.7 — "Organizations" tab (new — explicitly not a dashboard)

A single new page/tab, reachable from nav (placement: wherever makes sense alongside the renamed Management section — decide based on `nav_permissions.dart`'s existing structure once B.1 lands), showing:
- **Organizations you're in** — list from `OrganizationMembershipRepository.listMine()`: org name, your role in it, a "switch to this org" affordance if it isn't already current.
- **Details** for the selected org — name/contact/address (editable if the caller's membership role has `members.manage` or better; read-only otherwise).
- **Invite people** — email + role picker, calls `OrganizationInviteRepository.create()`. Visible only if the caller's membership in that org has `members.manage`.
- **Pending invites for you** — from `OrganizationInviteRepository.listMine()` (matches by the caller's email), each with Accept/Decline calling `accept()`/`revoke()`.

No branding/DNS/subdomain fields (that's hzn_gyms-specific, not relevant here), no member-removal/role-change UI in this first pass unless it turns out trivial once membership CRUD exists — keep this page intentionally small per the "no dashboard" instruction.

### B.5 — Self-service organization creation + setup walkthrough

Reachable only by an authenticated user (account still provisioned by a superuser or an existing org's admin — no public sign-up) whose global role has the `organizations.create` permission.

- **Entry point** — a "Create Organization" action available wherever B.7's Organizations tab lives (not a forced full-screen gate anymore, since a user can already belong to zero-or-more orgs rather than exactly zero-or-one — creating an additional org is just one more action, not an onboarding requirement). A user with **zero** memberships and no `organizations.create` permission sees the same "contact your administrator" state inside that tab instead of a blocking full-screen page.
- **`lib/src/features/organizations/presentation/pages/create_organization_page.dart`** — single form (name, contact number, address) using `flutter_form_builder`. On submit: `OrganizationRepository.create(...)` (authorized + auto-membership-created server-side by the A.4 hook), refresh `currentOrganizationControllerProvider`, then proceed into the walkthrough.
- **`lib/src/features/organizations/presentation/pages/organization_setup_walkthrough_page.dart`** — a stepper (check for an existing step/wizard pattern in this codebase before introducing a new one) with:
  1. **Confirm organization details** — pre-filled from creation, editable.
  2. **Create your first branch** — required to advance; reuses the existing branch-creation form from `lib/src/features/settings/presentation/pages/branches_page.dart` (or its dialog).
  3. **Invite your team** (optional/skippable) — this now goes through the real `OrganizationInviteRepository.create()` flow from B.7, not `create_user_dialog.dart` directly (that dialog creates a full user record; inviting creates a token-based invite that an existing-or-new account holder later accepts).
  4. **Review & finish** — calls `OrganizationRepository.update(orgId, {'onboardingCompletedAt': DateTime.now().toUtc()})`.
- New i18n keys under a new `organizations` namespace in `assets/i18n/{en,tl}/*.i18n.json` for all walkthrough + Organizations-tab copy.
- New routes: `lib/src/core/routing/routes/organizations.routes.dart` (`CreateOrganizationRoute`, `OrganizationSetupRoute`, `OrganizationsRoute` for B.7's tab), wired into `router.dart`.

### B.4 — Username → email replacement (full file list, old → new)

| File | Change |
|---|---|
| `lib/src/features/auth/domain/user.dart` | `username` field → `email` |
| `lib/src/features/auth/data/auth_dto.dart` | `username` → `email` throughout (field, `fromAuthResult`, `toUser()`, `toRecordModel()`) |
| `lib/src/features/auth/data/auth_repository.dart` | `login(String username, ...)` → `login(String email, ...)`; drop the username-lowercase-normalization comment/logic, keep email trim/lowercase |
| `lib/src/features/auth/presentation/controllers/auth_controller.dart` | rename `login` param + Sentry breadcrumb keys `'username'` → `'email'` |
| `lib/src/features/auth/presentation/pages/login_page.dart` | field `name: 'username'` → `'email'`; label `t.fields.userName` → `t.fields.email`; add `FormBuilderValidators.email()`, `keyboardType: TextInputType.emailAddress` |
| `lib/src/features/auth/presentation/pages/forgot_password_page.dart` | **rewrite** from the current "contact an administrator" dead-end into a real form: email field → `AuthRepository.requestPasswordReset(email)` (new method calling `pb.collection('users').requestPasswordReset(email)`) → success state. **No new i18n needed** — `assets/i18n/en/auth.i18n.json` already has unused `forgotPasswordSubtitle`, `sendResetLink`, `checkEmail`, `resetLinkSent(email)` keys ready to wire up (confirmed present, unused, in both en/tl) |
| `lib/src/features/users/domain/user.dart`, `lib/src/features/users/data/dto/user_dto.dart` | `username` → `email` |
| `lib/src/features/users/data/repositories/user_repository.dart` | `create()`/`update()` POST body `'username'` → `'email'`; default search fields `['name','username']` → `['name','email']` |
| `lib/src/features/users/presentation/controllers/user_search_controller.dart` | `userSearchableFields` → `['name','email']` |
| `lib/src/features/users/presentation/widgets/dialogs/create_user_dialog.dart`, `edit_user_dialog.dart` | replace `username` field (`minLength(3)` validator) with `email` field (`required()` + `email()` validators); update `_fieldLabels` |
| `.../dialogs/search_fields_dialog.dart` | `case 'username':` → `case 'email':` |
| `.../widgets/tabs/user_overview_tab.dart`, `user_details_tab.dart` | display `user.email` instead of `user.username` |
| `assets/i18n/{en,tl}/fields.i18n.json` | remove `"userName"` key entirely (existing `"email"` key is reused) |
| `assets/i18n/{en,tl}/failures.i18n.json` | `invalidCredentials` wording: "Invalid username or password." → "Invalid email or password." (+ tl translation) |
| `server/pb_hooks/auto_verify_users.pb.js` | log line `getString("username")` → `getString("email")` |

Regenerate with `dart run slang` after every `.i18n.json` edit — never hand-edit `strings_en.g.dart`/`strings_tl.g.dart`.

### B.6 — New static reset-password page

New `web/reset-password.html`, structurally matching `web/privacy-policy.html` (same head/meta/theme boilerplate) but with a vanilla-JS form: reads `?token=` from the URL, collects new password + confirmation, `fetch('/api/collections/users/confirm-password-reset', {...})` (relative URL — same origin as PocketBase, since the web build deploys into `pb_public/`). No Flutter build step needed. Update `docs/deployment.md`'s privacy-policy URL table to also list this page.

---

## C. Ordering / manual gates

1. **A.1–A.4** (organizations + organizationMemberships + organizationInvites collections + hook) — no client-visible change yet, ships safely anytime.
2. **A.5** (`organizations.create` + `members.manage` permissions + Admin role backfill) — ship with or right after step 1.
3. **A.6–A.8** (org-scoping rules on business collections + branches + machines/storages bug fix) — ship together; verify nothing regresses (single default org today, so no visible behavior change expected for existing users).
4. **B.1–B.2** (Management rename + Organization/membership/invite domain models) — can ship independently, any time after step 3. Requires `dart run build_runner build --delete-conflicting-outputs --low-resources-mode` (new mapper classes + regenerated `management.routes.g.dart`).
5. **B.3** (current-org controller + org switcher) — ship after step 4. Verify the switcher stays hidden for every existing user (all backfilled into exactly one org in A.6, so `canSwitchOrganization()` should be false for everyone at first).
6. **B.7 + B.5** (Organizations tab, invite flow, self-service org creation + walkthrough) — ship after step 5.
7. **MANUAL GATE (blocking, human-only):** run `server/scripts/list_users_missing_email.py --env staging` and `--env prod`; a human fills in real emails for every listed user via PocketBase Admin UI. Do not proceed until both report zero missing.
8. **A.10 (email-identity migration) + A.11 (reset-password template)** — deploy only after step 7 is confirmed. The moment this lands, username stops working as a login identity — schedule this in the same release window as step 9's client update.
9. **B.4 (full client username→email rewrite) + A.10's username-drop migration + B.6 (reset page)** — ship together as one release.
10. Verify per Section D.

---

## D. Verification

- `flutter analyze` — clean after all renames.
- `dart run build_runner build --delete-conflicting-outputs --low-resources-mode` — required for `AuthDto`, `User` (both auth + users feature), new `Organization`/`OrganizationMembership`/`OrganizationInvite` mappers, and `management.routes.g.dart`.
- `dart run slang` after i18n edits, then re-run `flutter analyze`.
- `flutter test` for any existing auth/users tests (check `test/` structure first — `test/src/core/config/app_environment_test.dart` and similar exist).
- **Manual smoke test:**
  1. Login with email+password succeeds; old username string fails with the updated "Invalid email or password." message.
  2. Forgot-password: submit email → PocketBase sends reset email (verify PocketBase's own Admin UI → Settings → Mail is configured — separate from the Resend-based `send_history_link_config.js` mailer) → link opens `reset-password.html` with valid token → new password works.
  3. Existing users (single default org after backfill) see the same records as before, no org switcher visible.
  4. **Isolation sanity check:** create a second org via self-service creation (or Admin UI) with its own branch, no shared members. Using a first-org user's token, query `branches`/`products` filtered to the second org's branch id — must return empty.
  5. `/management` routes (nav, breadcrumbs, user detail deep links) all resolve correctly post-rename.
  6. **Self-service org creation:** a user whose role has `organizations.create` creates a second org from the Organizations tab — confirm they're auto-added as a member, the org switcher now appears (2 orgs), and switching correctly re-scopes the branch switcher.
  7. **Invite flow end-to-end:** from org A, invite a second existing user's email with some role. That user sees the pending invite in their Organizations tab, accepts it — confirm they gain org A membership with the assigned role and can now switch into it. Test decline/revoke too. Test accepting with a mismatched-email account → 403. Test an expired invite → 400 + status flips to `expired`.
  8. **Hook authorization:** attempt a raw `POST /api/collections/organizations/records` (bypassing the hook route) as a user whose role lacks `organizations.create` — must still be blocked (createRule is `null`, so even superuser-shaped payloads without the hook's own auth path should fail for non-superusers). Same for a raw membership/invite REST create.
  9. Confirm the `record.get("permissions")` JSON-decode helper in `organization_invites.pb.js` actually works (not just compiles) — the hzn_gyms precedent shows this is easy to get subtly wrong (silently-always-false permission checks look like "everything is 403" rather than an obvious crash).

---

## Critical files (most important to get right)

- `server/pb_migrations/1770395107_updated_users.js` — proven exact JSON shape for the identity-field flip + username field id (`text1483516233`) reused in step A.10.
- `server/pb_migrations/1786899856_updated_products_list_rule.js` — the cautionary example of a rule that broke "All Branches" admin access; the org rules in this plan are deliberately coarser to avoid repeating that mistake.
- `D:\Projects\hzn_gyms\server\pb_migrations\1788389510_created_organizationMemberships.js` / `1788389537_created_organizationInvites.js` / `server\pb_hooks\organization_invites.pb.js` — live-tested precedent for the exact collection shapes, back-relation filter syntax, and the JSON-permissions-decode gotcha this plan's A.2–A.4 are built from.
- `lib/src/features/settings/presentation/controllers/current_branch_controller.dart` — the shape B.3's `CurrentOrganizationController` and org switcher should structurally mirror.
- `lib/src/features/auth/data/auth_dto.dart` / `lib/src/features/auth/domain/user.dart` — root of the username→email rewrite (no longer also carries an `organization` field, per the revised B.2).
- `lib/src/core/routing/routes/organization.routes.dart` / `lib/src/core/pages/app_root.dart` — root of the Organization→Management rename fan-out.
- `lib/src/features/users/presentation/widgets/dialogs/create_user_dialog.dart` / `edit_user_dialog.dart` — largest concentration of username-field UI to rewrite.
