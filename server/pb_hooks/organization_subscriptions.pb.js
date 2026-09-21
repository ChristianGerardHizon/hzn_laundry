/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Organization subscriptions / platform billing
// ============================================================================
// Registration only — see pb_hooks/lib/organization_subscriptions_helpers.js.
// require() inside each callback (goja scope isolation).
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

routerAdd(
  "GET",
  "/api/subscription-packages",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").listPackages(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/super-admin/subscription-packages",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").createPackage(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "PATCH",
  "/api/super-admin/subscription-packages/{id}",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").updatePackage(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "DELETE",
  "/api/super-admin/subscription-packages/{id}",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").softDeletePackage(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/organizations/{id}/subscription",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").assignSubscription(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "GET",
  "/api/organizations/{id}/subscription",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").getOrgSubscription(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "GET",
  "/api/organizations/{id}/subscription/pay-info",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").getPayInfo(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/organizations/{id}/subscription/payments",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").submitPayment(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "GET",
  "/api/super-admin/subscription-payments",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").listPendingPayments(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/super-admin/subscription-payments/{id}/review",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").reviewPayment(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "POST",
  "/api/super-admin/organizations/{id}/unlock",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").unlockOrganization(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "GET",
  "/api/super-admin/billing-settings",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").getBillingSettings(e);
  },
  $apis.requireAuth("users")
);

routerAdd(
  "PATCH",
  "/api/super-admin/billing-settings",
  function(e) {
    return require(__hooks + "/lib/organization_subscriptions_helpers.js").updateBillingSettings(e);
  },
  $apis.requireAuth("users")
);

// Daily billing: grace/lock transitions + reminder emails (01:00 UTC)
cronAdd("organizationSubscriptionBilling", "0 1 * * *", function() {
  require(__hooks + "/lib/organization_subscriptions_helpers.js").runDailyBillingJob();
});
