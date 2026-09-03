/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Organizations + Invites
// ============================================================================
// Registration only — see pb_hooks/lib/organization_invites_helpers.js.
// require() inside each callback (goja scope isolation).
//
// organizations / organizationMemberships / organizationInvites all have
// create/update/delete rules set to null — writes go through these routes.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

routerAdd(
  "POST",
  "/api/organizations",
  function(e) {
    return require(__hooks + "/lib/organization_invites_helpers.js").createOrganization(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "PATCH",
  "/api/organizations/{id}",
  function(e) {
    return require(__hooks + "/lib/organization_invites_helpers.js").updateOrganization(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/organization-invites",
  function(e) {
    return require(__hooks + "/lib/organization_invites_helpers.js").createInvite(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/organization-invites/{id}/accept",
  function(e) {
    return require(__hooks + "/lib/organization_invites_helpers.js").acceptInvite(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/organization-invites/{id}/revoke",
  function(e) {
    return require(__hooks + "/lib/organization_invites_helpers.js").revokeInvite(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/organization-invites/{id}/decline",
  function(e) {
    return require(__hooks + "/lib/organization_invites_helpers.js").declineInvite(e);
  },
  $apis.requireAuth("users")
);
