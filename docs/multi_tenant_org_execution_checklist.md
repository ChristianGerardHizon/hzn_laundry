# Multi-Tenant Organizations + Email Auth — Execution Checklist

> **Purpose:** a strictly sequential, self-contained task list for implementing the design in [`docs/multi_tenant_org_email_auth_plan.md`](multi_tenant_org_email_auth_plan.md). That document has the full rationale, decisions, and precedent; this one exists so an execution agent (human or AI) can work top-to-bottom without needing to re-derive ordering or re-read the whole design doc first. If anything here conflicts with the design doc, the design doc wins — update this checklist to match, don't silently diverge.
>
> **Repo:** `D:\Projects\hzn_laundry` (Flutter + PocketBase). Read `CLAUDE.md` at the repo root first for house conventions (code-gen commands, PR rules, PocketBase API-first verification policy, `grepai` usage) before starting.
>
> **Ground rules for whoever executes this:**
> - Do each numbered task in order. Do not skip ahead — later tasks assume earlier ones landed.
> - Before writing any new PocketBase migration, run `ls server/pb_migrations | sort | tail` to confirm the next-available timestamp — the numbers below are planning placeholders and may need to shift if other migrations landed since this checklist was written.
> - Before trusting any PocketBase filter-rule syntax below, know that it was verified live in a sibling project (`D:\Projects\hzn_gyms`, PocketBase 0.39.10) — check hzn_laundry's own pinned PocketBase version is the same or compatible before assuming it "just works" here too.
> - After every schema change, verify it against the running PocketBase instance via the Admin API (per `CLAUDE.md`'s "PocketBase API Access" section) — don't trust a migration file compiles cleanly as proof it's correct.
> - Stop and flag to a human at every step marked **MANUAL GATE** — do not attempt to automate past those.

---

## Phase 0 — Orientation (read-only, no changes)

1. Read `docs/multi_tenant_org_email_auth_plan.md` in full.
2. Read `server/pb_migrations/1770395107_updated_users.js` — proven JSON shape for the later identity-field flip (Phase 6).
3. Read `server/pb_migrations/1786899856_updated_products_list_rule.js` — cautionary example of a rule that broke "All Branches" admin access. Do not repeat that mistake in Phase 3's rules.
4. Read `lib/src/features/settings/presentation/controllers/current_branch_controller.dart` — the shape Phase 5's org-switcher controller mirrors.
5. Confirm current PocketBase migration high-water mark: `ls server/pb_migrations | sort | tail`.

---

## Phase 1 — Core organization schema (PocketBase)

6. Create migration `1787100000_created_organizations.js` — new `organizations` collection, id `pbc_organizations01`.
   - Fields: `name` (text, required), `contactNumber` (text, optional), `address` (text, optional), `onboardingCompletedAt` (date, optional), `isDeleted` (bool, default false), `created`/`updated` (autodate) — copy the standard id/autodate field-block JSON shape from an existing collection (e.g. `customers`).
   - `listRule`/`viewRule`: `"@request.auth.id != \"\" && organizationMemberships_via_organization.user ?= @request.auth.id"`
   - `createRule`/`updateRule`/`deleteRule`: `null` (hook-mediated only — see Phase 2).

7. Create migration `1787100100_created_organizationMemberships.js` — join collection `organizationMemberships`, id `pbc_org_memberships01`.
   - Fields: `user` (relation → `users` `pbc_3841632486`, maxSelect 1, required), `organization` (relation → `organizations`, maxSelect 1, required), `role` (relation → existing `userRoles` collection, maxSelect 1, required), `status` (select `["active","suspended"]`, required), `invitedBy` (relation → `users`, optional), `joinedAt` (date, required), `created`/`updated` (autodate).
   - Unique index on `(user, organization)`.
   - `listRule`/`viewRule`: `"@request.auth.id != \"\" && (user = @request.auth.id || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"`
   - `createRule`/`updateRule`/`deleteRule`: `null`.

8. Create migration `1787100150_created_organizationInvites.js` — collection `organizationInvites`, id `pbc_org_invites0001`.
   - Fields: `email` (email, required), `organization` (relation → `organizations`, required), `role` (relation → `userRoles`, required), `token` (text, required, `autogeneratePattern: "[a-zA-Z0-9]{32}"`, min 32, max 32, **`hidden: true`**), `status` (select `["pending","accepted","expired","revoked"]`, required), `invitedBy` (relation → `users`, required), `acceptedBy` (relation → `users`, optional), `expiresAt` (date, required), `created`/`updated` (autodate).
   - Unique index on `token`.
   - `listRule`/`viewRule`: `"@request.auth.id != \"\" && (invitedBy = @request.auth.id || email = @request.auth.email || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"`
   - `createRule`/`updateRule`/`deleteRule`: `null`.

9. **Verify all three collections via the PocketBase Admin API** (not just that migrations run) before moving on — list collections, confirm fields/rules match.

---

## Phase 2 — Authorization hook

10. Check existing files under `server/pb_hooks/` for this repo's own `routerAdd`/error-response conventions (don't assume hzn_gyms's style matches).

11. Create `server/pb_hooks/organization_invites.pb.js`:
    - Helper `readPermissions(record)`: `JSON.parse(record.get("permissions").string())` — use this everywhere a role's `permissions` array is read. **Do not** use `Array.isArray()`/`.indexOf()` directly on `record.get("permissions")` — on a JSON field this returns a `types.JSONRaw` wrapper, not a plain array, and those checks silently fail (confirmed bug hit and fixed in the hzn_gyms precedent).
    - `onRecordCreateRequest("organizations")`: 403 unless the caller's global `role` (existing `users.role` relation) has `organizations.create` in its permissions (Phase 4). On success, immediately create the caller's own `organizationMemberships` row for the new org (`status: "active"`, `joinedAt: now`, `role`: the same "Admin" system role used for platform-wide admin today).
    - `POST /api/organization-invites`: 401 if unauthenticated. Authorize via a direct `app.findFirstRecordByFilter("organizationMemberships", "organization = {:org} && user = {:user} && status = 'active'")` lookup (not a filter-rule chain) — the found row's role must have `members.manage` (Phase 4). Create the invite: lowercased/trimmed email, `status: "pending"`, `expiresAt: now + 7 days`, `invitedBy: e.auth.id`; let `token` auto-generate.
    - `POST /api/organization-invites/{id}/accept`: 401 unauth, 404 missing, 400 if not `pending`, expire-and-400 if `now > expiresAt`, 403 if caller's email doesn't case-insensitively match the invite's email. Idempotent if membership already exists. Otherwise create the `organizationMemberships` row and flip the invite to `accepted`/`acceptedBy`.
    - `POST /api/organization-invites/{id}/revoke`: same authorization as creation; 404/400 guards; sets `status: "revoked"`.

12. **Test the hook against the live local PocketBase instance**, not just that it loads without syntax errors: create an org via the hook path as a permitted user (should succeed + auto-membership), as a non-permitted user (should 403), create/accept/revoke an invite end-to-end, and specifically re-verify the `readPermissions()` decode actually returns a real array (log/print it during manual testing) rather than trusting it compiles.

---

## Phase 3 — Data/rule migration for existing data

13. Add permission keys to `Permissions` in `lib/src/features/users/domain/user_role.dart`: `organizations.create` (new `'Organizations'` category) and `members.manage` (new `'Organization Members'` category).

14. Create a migration to add both new keys to the seeded `Admin` system role's `permissions` array (source: `server/pb_migrations/1774000001_seed_user_roles.js` seeds `Admin` with only `["system.admin"]` today — confirm in code whether `system.admin` is ever treated as an implicit wildcard bypassing explicit-key checks; if not, this migration is required, not optional).

15. Create migration `1787100300_backfill_default_organization.js`:
    - Create one `organizations` record named `"HZN Laundry"`.
    - Backfill `organization` onto every existing `branches` row (this migration also needs `branches` to have gained the field — see Phase 3 step 16, must run before this one, or fold the field-add into this same migration file if simpler).
    - Create an `organizationMemberships` row (`status: "active"`, `joinedAt: now`, carrying over each user's existing global `role`) for every existing `users` row, against the default org.
    - Down migration: no-op (reversing a data backfill is unsafe).

16. Create migration to add required relation field `organization` → `organizations` on `branches` (`pbc_2358601297`) — do this before step 15's backfill runs, or combine into one migration.

17. Create migrations updating rules on the branch-scoped business collections — `products`, `services`, `sales`, `customers`, `machines`, `storages`, `printerConfigs`, `posGroups`, `carts` (one migration per collection). Before each: **fetch the collection's live current rule via the Admin API first** (most predate migration tracking — don't assume `""`). New rule (list/view/create/update/delete):
    ```
    @request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)
    ```

18. Create migration updating `branches`' own rules to:
    ```
    @request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id
    ```
    (list/view/create/update/delete, merged onto whatever the live rule currently is, same "fetch live first" caveat as step 17.)

19. **Known deferred gap — do not attempt to fully solve in this phase:** the base `users` collection's own list/view rule cannot be cleanly scoped to "shares an org with the caller" via a single PocketBase filter (would require comparing two different back-relation sets for overlap). Leave `users`' existing rule as-is; this is an accepted, documented gap (client-side `users.view` permission gating only), not a regression to fix here.

20. Create migration `1787100700_fix_machines_storages_branch_collectionId.js` — unrelated pre-existing bug: `machines`/`storages`' `branch` relation fields currently point at the wrong `collectionId` (`pbc_branches0001` instead of the real `pbc_2358601297`).

21. **Verify**: log in as an existing (pre-migration) user — should see identical data to before (single default org, no visible change). No regressions in "All Branches" admin mode.

---

## Phase 4 — Rename `features/organization/` → `features/management/`

22. Rename files per the table in the design doc's B.1 section: `organization_shell.dart`→`management_shell.dart` (`OrganizationShell`→`ManagementShell`), `organization_nav_panel.dart`→`management_nav_panel.dart` (`OrganizationMode`→`ManagementMode`, `OrganizationNavPanel`→`ManagementNavPanel`), `tablet_organization_layout.dart`/`empty_organization_state.dart` → `tablet_management_layout.dart`/`empty_management_state.dart`, `lib/src/core/routing/routes/organization.routes.dart` → `management.routes.dart` (`Organization*Route` → `Management*Route`, path `/organization` → `/management`).

23. Update the fan-out (grep to confirm current line numbers, they will have drifted):
    - `lib/src/core/routing/router.dart`
    - `lib/src/core/pages/app_root.dart`
    - `lib/src/core/widgets/breadcrumb_nav.dart`
    - `lib/src/core/widgets/nav_permissions.dart`
    - `lib/src/features/settings/presentation/pages/branches_page.dart` + `.../widgets/branch_detail_panel.dart`
    - `lib/src/features/users/presentation/widgets/dialogs/create_user_dialog.dart`
    - `lib/src/features/activities/presentation/pages/activities_page.dart`
    - `assets/i18n/{en,tl}/navigation.i18n.json` (key `organization` → `management`, then `dart run slang`)
    - `lib/src/core/packages/pocketbase/pocketbase_collections.dart` — add `organizations`, `organizationMemberships`, `organizationInvites` constants; rename the `// Organization` comment header to `// Management` for `branches`/`printerConfigs`.
    - `docs/app_overview.md`, `docs/folder_structure.md`, `docs/ui.md`, `docs/entities.md` — update nav/route/folder references.

24. Run `dart run build_runner build --delete-conflicting-outputs --low-resources-mode`, then `flutter analyze` — must be clean before continuing.

---

## Phase 5 — Domain models + current-organization controller

25. Create `lib/src/features/organizations/domain/organization.dart` (`@MappableClass()`: `id, name, contactNumber, address, onboardingCompletedAt`), `organization_membership.dart` (`id, organizationId, userId, role, status, joinedAt`), `organization_invite.dart` (`id, organizationId, organizationName, email, role, status, expiresAt` — no `token`, it's server-hidden).

26. Create `lib/src/features/organizations/data/dto/*` + `OrganizationRepository` (`create`, `update`, `get`), `OrganizationMembershipRepository` (`listMine`, `listForOrganization`), `OrganizationInviteRepository` (`create`, `accept`, `revoke`, `listMine`, `listForOrganization`) — the invite repo calls the Phase 2 custom hook routes via `pb.send(...)`, not raw collection CRUD.

27. Confirm `AuthDto`/`User` do **not** gain an `organization` field (superseded by the membership model) — this differs from an earlier draft of the plan; double-check the current design doc if in doubt.

28. Create `lib/src/features/organizations/presentation/controllers/current_organization_controller.dart` (`@Riverpod(keepAlive: true)`), modeled on `current_branch_controller.dart`'s shape: loads `listMine()` memberships; auto-selects if exactly one; else resolves from secure storage key `CURRENT_ORGANIZATION_ID`, falling back to the first membership if the persisted id is stale. Exposes `canSwitchOrganization()` (`memberships.length > 1`), `switchableOrganizations()`, `switchOrganization(id)`.

29. Re-scope the existing branch switcher/`CurrentBranchController` query to filter branches by the currently-selected organization.

30. Add an org-switcher UI element next to wherever the branch switcher currently renders, gated on `canSwitchOrganization()` — must stay invisible for single-org users.

31. Run `dart run build_runner build --delete-conflicting-outputs --low-resources-mode`, `flutter analyze`.

32. **Verify**: every existing (backfilled, single-org) user still sees no org switcher, unchanged branch-switcher behavior.

---

## Phase 6 — Organizations tab + self-service creation + walkthrough

33. Create `lib/src/features/organizations/presentation/pages/create_organization_page.dart` — form (name, contact number, address), submits via `OrganizationRepository.create()`, refreshes `currentOrganizationControllerProvider`.

34. Create `lib/src/features/organizations/presentation/pages/organization_setup_walkthrough_page.dart` — stepper: (1) confirm org details, (2) create first branch (required, reuse existing branch-creation form), (3) invite team (optional, via `OrganizationInviteRepository.create()`), (4) review & finish (sets `onboardingCompletedAt`).

35. Create the "Organizations" tab/page (per design doc B.7 — **not** a dashboard): list of orgs you belong to + your role in each + switch action; selected org's details (editable only if your membership role has `members.manage`); invite form (visible only with `members.manage`); your own pending invites with accept/decline.

36. Add i18n keys under a new `organizations` namespace in `assets/i18n/{en,tl}/*.i18n.json`, then `dart run slang`.

37. Add routes `CreateOrganizationRoute`, `OrganizationSetupRoute`, `OrganizationsRoute` in a new `lib/src/core/routing/routes/organizations.routes.dart`, wire into `router.dart` and nav (`nav_permissions.dart`).

38. Run `dart run build_runner build --delete-conflicting-outputs --low-resources-mode`, `flutter analyze`, `flutter test`.

39. **Verify end-to-end** (see Phase 9's checklist item 3 for the full script) before moving to email-auth phases — this is a natural release boundary; the remaining phases are independent of everything above except for sharing the same `users` collection.

---

## Phase 7 — MANUAL GATE: email backfill

40. Create `server/scripts/list_users_missing_email.py`, modeled on `server/scripts/backfill_sale_service_storage_names.py` (same real `.env` key names: `STAGING_EMAIL`/`STAGING_PASSWORD`/`STAGING_URL`, `PROD_EMAIL`/`PROD_PASSWORD`/`PROD_URL` — **not** the `PB_PROD_EMAIL`-style names in `CLAUDE.md`, which are stale). Read-only: prints every user record with blank/missing `email`. Never fabricates emails.

41. **MANUAL GATE — stop here.** Run the script against staging and prod. A human must fill in real emails for every listed user via PocketBase Admin UI. Do not proceed to Phase 8 until both environments report zero missing.

---

## Phase 8 — Email identity cutover (only after Phase 7 gate clears)

42. Create `1787200000_users_require_email_identity.js`: `unmarshal({"passwordAuth": {"identityFields": ["email"]}}, collection)` + set `email` field `required: true` (exact proven shape: the down-migration of `1770395107_updated_users.js` already contains this).

43. Create `1787200200_users_reset_password_template.js`: repoint `resetPasswordTemplate`'s link to `{APP_URL}/reset-password.html?token={TOKEN}`.

44. Rewrite the whole client auth stack per the design doc's B.4 table: `user.dart`, `auth_dto.dart`, `auth_repository.dart`, `auth_controller.dart`, `login_page.dart`, `forgot_password_page.dart` (real rewrite — email field → `requestPasswordReset`), users feature's `user.dart`/`user_dto.dart`/`user_repository.dart`/`user_search_controller.dart`/`create_user_dialog.dart`/`edit_user_dialog.dart`/`search_fields_dialog.dart`/`user_overview_tab.dart`/`user_details_tab.dart`, `assets/i18n/{en,tl}/fields.i18n.json` (drop `userName` key), `assets/i18n/{en,tl}/failures.i18n.json` (reword `invalidCredentials`), `server/pb_hooks/auto_verify_users.pb.js` (log line only).

45. Create `1787200100_users_drop_username.js`: `collection.fields.removeById("text1483516233")` + drop the `idx_DiodYfwMRw` unique index. Ship in the **same release** as step 44, not before — username must stop being read by the client before the field disappears server-side.

46. Create `web/reset-password.html` (structurally matching `web/privacy-policy.html`, vanilla-JS form posting to `/api/collections/users/confirm-password-reset`). Update `docs/deployment.md`'s URL table.

47. Run `dart run build_runner build --delete-conflicting-outputs --low-resources-mode`, `dart run slang`, `flutter analyze`, `flutter test`.

---

## Phase 9 — Final verification

48. `flutter analyze` clean, full `flutter test` pass.
49. Login with email+password succeeds; a username string now fails with "Invalid email or password."
50. Forgot-password: submit email → reset email arrives (verify PocketBase Admin UI → Settings → Mail is configured) → `reset-password.html?token=...` → new password works.
51. Existing (backfilled) users: unchanged data visibility, no org switcher.
52. **Isolation check:** create a second org (self-service) with its own branch, no shared members with org 1. A first-org user's token querying `branches`/`products` filtered to the second org's branch id must return empty.
53. `/management` routes (nav, breadcrumbs, deep links) resolve correctly post-rename.
54. Self-service org creation: permitted user creates a second org, is auto-added as a member, org switcher now appears, switching re-scopes the branch switcher correctly.
55. Invite flow end-to-end: create → recipient sees it in their Organizations tab → accept → membership granted with correct role → can switch into the new org. Also test decline/revoke, mismatched-email accept (403), and expired invite (400 + status flips).
56. Hook authorization: a raw `POST /api/collections/organizations/records` (bypassing the custom hook route) as an unpermitted user must still fail — `createRule: null` should block it regardless of payload shape.
57. Confirm `readPermissions()` in `organization_invites.pb.js` genuinely decodes a real array in production-like conditions, not just that it compiles — this exact bug class silently made every permission check false in the hzn_gyms precedent.
