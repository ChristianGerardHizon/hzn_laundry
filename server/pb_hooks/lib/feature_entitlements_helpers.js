/// <reference path="../../pb_data/types.d.ts" />

// Feature entitlements: subscription package base + Super Admin overrides.
// ES5 only — no const, let, arrow functions, or async/await.
//
// Resolution per organization + feature key:
//   1. organizationFeatureOverrides row exists -> its `enabled` value wins.
//   2. Otherwise the active subscription's package `features` array decides.
//   3. No active subscription (legacy org) -> everything on.
// Dependencies (`requires`) are applied last: a feature is off when its
// parent feature is off.
//
// Keep FEATURE_CATALOG in sync with
// lib/src/features/entitlements/domain/feature_key.dart

var orgHelpers = require(__hooks + "/lib/organization_invites_helpers.js");

var FEATURE_CATALOG = [
  { key: "employees", label: "Employees", category: "module", requires: null },
  { key: "attendance", label: "Attendance", category: "module", requires: "employees" },
  { key: "products", label: "Products & inventory", category: "module", requires: null },
  { key: "promos", label: "Promos", category: "module", requires: null },
  { key: "reports", label: "Reports", category: "module", requires: null },
  { key: "activities", label: "Activity log", category: "module", requires: null },
  { key: "consumableUsage", label: "Consumable usage", category: "subFeature", requires: "products" },
  { key: "machineLoadRules", label: "Machine load rules", category: "subFeature", requires: null },
  { key: "storages", label: "Storage locations", category: "subFeature", requires: null },
  { key: "posGroups", label: "Cashier layout groups", category: "subFeature", requires: null },
  { key: "customerHistoryLink", label: "Customer history link", category: "subFeature", requires: null },
  { key: "multiBranch", label: "Multiple branches", category: "subFeature", requires: null }
];

// Collections whose writes are blocked when the feature is not entitled.
// `orgVia` describes how to find the organization from the record.
var GUARDED_COLLECTIONS = {
  employees: { feature: "employees", orgVia: "organization" },
  employeeAttendances: { feature: "attendance", orgVia: "employee>organization" },
  employeeDeductions: { feature: "employees", orgVia: "employee>organization" },
  promos: { feature: "promos", orgVia: "branch>organization" },
  customerPromos: { feature: "promos", orgVia: "customer>branch>organization" },
  saleConsumableUsages: { feature: "consumableUsage", orgVia: "sale>branch>organization" },
  posGroups: { feature: "posGroups", orgVia: "branch>organization" }
};

// Numeric limits. Package value (`packageField`, 0 = unlimited) unless a
// organizationLimitOverrides row exists (its `value`, 0 = unlimited).
// `used` counts non-deleted records of `collection` in the organization.
// Keep in sync with lib/src/features/entitlements/domain/limit_key.dart
var LIMIT_CATALOG = [
  { key: "branches", label: "Branches", collection: "branches", packageField: "maxBranches" },
  { key: "employees", label: "Employees", collection: "employees", packageField: "maxEmployees" }
];

function limitEntry(key) {
  var i;
  for (i = 0; i < LIMIT_CATALOG.length; i++) {
    if (LIMIT_CATALOG[i].key === key) return LIMIT_CATALOG[i];
  }
  return null;
}

function catalogKeys() {
  var out = [];
  var i;
  for (i = 0; i < FEATURE_CATALOG.length; i++) out.push(FEATURE_CATALOG[i].key);
  return out;
}

function catalogEntry(key) {
  var i;
  for (i = 0; i < FEATURE_CATALOG.length; i++) {
    if (FEATURE_CATALOG[i].key === key) return FEATURE_CATALOG[i];
  }
  return null;
}

function isValidKey(key) {
  return catalogEntry(key) !== null;
}

function subscriptionHelpers() {
  // Lazy require: organization_subscriptions_helpers requires this module.
  return require(__hooks + "/lib/organization_subscriptions_helpers.js");
}

/**
 * Parses a JSON array field. Returns null when unset/unparseable so callers
 * can distinguish "not configured" from an empty array.
 */
function readJsonArray(record, field) {
  // A JSON field comes back from record.get() as raw bytes (types.JSONRaw),
  // which goja exposes as a Go slice: Array.isArray() is true but the items
  // are byte values, not our keys. getString() returns the JSON text, so parse
  // that instead of trusting record.get().
  var text = "";
  try {
    text = record.getString(field);
  } catch (_) {
    return null;
  }
  if (!text || text === "null") return null;
  try {
    var parsed = JSON.parse(text);
    return Array.isArray(parsed) ? parsed : null;
  } catch (_) {
    return null;
  }
}

/** Normalizes a client-provided features list to unique, valid keys. */
function sanitizeFeatureList(list) {
  var out = [];
  var seen = {};
  var i;
  if (!Array.isArray(list)) return out;
  for (i = 0; i < list.length; i++) {
    var key = String(list[i] || "");
    if (isValidKey(key) && !seen[key]) {
      seen[key] = true;
      out.push(key);
    }
  }
  return out;
}

function findActiveSubscription(app, orgId) {
  try {
    return app.findFirstRecordByFilter(
      "organizationSubscriptions",
      "organization = {:org} && isDeleted = false && status != 'cancelled'",
      { org: orgId }
    );
  } catch (_) {
    return null;
  }
}

function loadOverrides(app, orgId) {
  var map = {};
  var rows = [];
  try {
    rows = app.findRecordsByFilter(
      "organizationFeatureOverrides",
      "organization = {:org}",
      "",
      200,
      0,
      { org: orgId }
    );
  } catch (_) {
    rows = [];
  }
  var i;
  for (i = 0; i < rows.length; i++) {
    map[rows[i].getString("featureKey")] = rows[i];
  }
  return map;
}

/**
 * Resolves every catalog feature for an organization.
 * Returns { hasSubscription, packageId, packageName, items: [...] }.
 * Each item: { key, enabled, source, planIncluded, overrideEnabled, note, blockedBy }
 * source: plan | notInPlan | superAdminEnabled | superAdminDisabled
 */
function resolveEntitlements(app, orgId) {
  var sub = findActiveSubscription(app, orgId);
  var pkg = null;
  var planKeys = null;
  var packageName = "";
  var packageId = "";
  if (sub) {
    packageName = sub.getString("packageName");
    packageId = sub.getString("package");
    try {
      pkg = app.findRecordById("subscriptionPackages", packageId);
      planKeys = readJsonArray(pkg, "features");
      if (pkg && !packageName) packageName = pkg.getString("name");
    } catch (_) {
      pkg = null;
    }
  }
  // No subscription, or package with no configured list => all features.
  var allIncluded = !sub || planKeys === null;
  var overrides = loadOverrides(app, orgId);

  var byKey = {};
  var items = [];
  var i;
  for (i = 0; i < FEATURE_CATALOG.length; i++) {
    var entry = FEATURE_CATALOG[i];
    var planIncluded = allIncluded || planKeys.indexOf(entry.key) !== -1;
    var override = overrides[entry.key];
    var enabled = planIncluded;
    var source = planIncluded ? "plan" : "notInPlan";
    var overrideEnabled = null;
    var note = "";
    if (override) {
      overrideEnabled = override.getBool("enabled");
      note = override.getString("note");
      enabled = overrideEnabled;
      source = overrideEnabled ? "superAdminEnabled" : "superAdminDisabled";
    }
    var item = {
      key: entry.key,
      enabled: enabled,
      source: source,
      planIncluded: planIncluded,
      overrideEnabled: overrideEnabled,
      note: note,
      blockedBy: null
    };
    byKey[entry.key] = item;
    items.push(item);
  }

  // Dependencies: catalog is ordered so parents precede children.
  for (i = 0; i < FEATURE_CATALOG.length; i++) {
    var e = FEATURE_CATALOG[i];
    if (e.requires && byKey[e.key].enabled && !byKey[e.requires].enabled) {
      byKey[e.key].enabled = false;
      byKey[e.key].blockedBy = e.requires;
    }
  }

  return {
    hasSubscription: !!sub,
    packageId: packageId,
    packageName: packageName,
    items: items
  };
}

function isFeatureEntitled(app, orgId, key) {
  if (!orgId) return true;
  var result = resolveEntitlements(app, orgId);
  var i;
  for (i = 0; i < result.items.length; i++) {
    if (result.items[i].key === key) return result.items[i].enabled;
  }
  return true;
}

function countActive(app, collection, orgId) {
  try {
    return app.findRecordsByFilter(
      collection,
      "organization = {:org} && (isDeleted = false || isDeleted = null)",
      "",
      0,
      0,
      { org: orgId }
    ).length;
  } catch (_) {
    return 0;
  }
}

function loadLimitOverrides(app, orgId) {
  var map = {};
  var rows = [];
  try {
    rows = app.findRecordsByFilter(
      "organizationLimitOverrides",
      "organization = {:org}",
      "",
      50,
      0,
      { org: orgId }
    );
  } catch (_) {
    rows = [];
  }
  var i;
  for (i = 0; i < rows.length; i++) {
    map[rows[i].getString("limitKey")] = rows[i];
  }
  return map;
}

/** Active subscription package record for the org, or null. */
function loadLimitPackage(app, orgId) {
  var sub = findActiveSubscription(app, orgId);
  if (!sub) return null;
  try {
    return app.findRecordById("subscriptionPackages", sub.getString("package"));
  } catch (_) {
    return null;
  }
}

/**
 * Resolves one limit. `ctx` ({ pkg, overrides }) can be shared across keys.
 * Returns { key, limit (null = unlimited), used, planLimit, overrideValue,
 * source: plan | superAdmin | unlimited, note }.
 */
function resolveLimit(app, orgId, key, ctx) {
  var entry = limitEntry(key);
  ctx = ctx || {
    pkg: loadLimitPackage(app, orgId),
    overrides: loadLimitOverrides(app, orgId)
  };
  var planLimit = null;
  if (ctx.pkg) {
    var pv = ctx.pkg.getInt(entry.packageField);
    if (pv > 0) planLimit = pv;
  }
  var limit = planLimit;
  var source = planLimit === null ? "unlimited" : "plan";
  var overrideValue = null;
  var note = "";
  var row = ctx.overrides[key];
  if (row) {
    overrideValue = row.getInt("value");
    limit = overrideValue > 0 ? overrideValue : null;
    source = "superAdmin";
    note = row.getString("note");
  }
  return {
    key: key,
    limit: limit,
    used: countActive(app, entry.collection, orgId),
    planLimit: planLimit,
    overrideValue: overrideValue,
    source: source,
    note: note
  };
}

function resolveLimits(app, orgId) {
  var ctx = {
    pkg: loadLimitPackage(app, orgId),
    overrides: loadLimitOverrides(app, orgId)
  };
  var out = [];
  var i;
  for (i = 0; i < LIMIT_CATALOG.length; i++) {
    out.push(resolveLimit(app, orgId, LIMIT_CATALOG[i].key, ctx));
  }
  return out;
}

/** Throws ForbiddenError when creating one more record would exceed the limit. */
function assertWithinLimit(app, orgId, key) {
  var r = resolveLimit(app, orgId, key);
  if (r.limit !== null && r.used >= r.limit) {
    throw new ForbiddenError(
      limitEntry(key).label + " limit reached (" + r.limit + ")"
    );
  }
}

/** Follows a "field>field>organization" path from a record to an org id. */
function resolveOrgId(app, record, orgVia) {
  var parts = orgVia.split(">");
  var current = record;
  var i;
  for (i = 0; i < parts.length; i++) {
    var field = parts[i];
    if (field === "organization") {
      return current.getString("organization");
    }
    var id = current.getString(field);
    if (!id) return "";
    var collectionName = relationCollection(field);
    try {
      current = app.findRecordById(collectionName, id);
    } catch (_) {
      return "";
    }
  }
  return "";
}

function relationCollection(field) {
  if (field === "employee") return "employees";
  if (field === "branch") return "branches";
  if (field === "customer") return "customers";
  if (field === "sale") return "sales";
  return field;
}

/**
 * Request-hook guard. Throws ForbiddenError when the record's organization is
 * not entitled to the collection's feature. Superusers bypass.
 */
function guardRecordWrite(e) {
  if (!e.auth) return;
  try {
    if (orgHelpers.isSuperuser(e.auth)) return;
  } catch (_) {}
  var collectionName = e.record.collection().name;
  var rule = GUARDED_COLLECTIONS[collectionName];
  if (!rule) return;
  var orgId = resolveOrgId(e.app, e.record, rule.orgVia);
  if (!orgId) return;
  if (!isFeatureEntitled(e.app, orgId, rule.feature)) {
    throw new ForbiddenError(
      "The " + rule.feature + " feature is not enabled for this organization"
    );
  }
  if (collectionName === "employees") guardEmployeeLimit(e, orgId);
}

/**
 * Employee limit: applies to new employees and to restoring a soft-deleted
 * one (isDeleted true -> false). Other updates are never blocked.
 */
function guardEmployeeLimit(e, orgId) {
  if (e.record.getBool("isDeleted")) return;
  if (!e.record.isNew()) {
    var wasDeleted = false;
    try {
      wasDeleted = e.record.original().getBool("isDeleted");
    } catch (_) {}
    if (!wasDeleted) return;
  }
  assertWithinLimit(e.app, orgId, "employees");
}

/** True when the customer's organization has the customer history link. */
function isCustomerHistoryEntitled(app, customer) {
  var orgId = resolveOrgId(app, customer, "branch>organization");
  if (!orgId) return true;
  return isFeatureEntitled(app, orgId, "customerHistoryLink");
}

/**
 * Blocks creating an additional branch when multiBranch is not entitled.
 * Existing branches are never touched.
 */
function guardBranchCreate(e) {
  if (!e.auth) return;
  try {
    if (orgHelpers.isSuperuser(e.auth)) return;
  } catch (_) {}
  var orgId = e.record.getString("organization");
  if (!orgId) return;
  if (isFeatureEntitled(e.app, orgId, "multiBranch")) {
    assertWithinLimit(e.app, orgId, "branches");
    return;
  }
  var existing = [];
  try {
    existing = e.app.findRecordsByFilter(
      "branches",
      "organization = {:org} && (isDeleted = false || isDeleted = null)",
      "",
      1,
      0,
      { org: orgId }
    );
  } catch (_) {
    existing = [];
  }
  if (existing.length > 0) {
    throw new ForbiddenError(
      "Multiple branches are not enabled for this organization"
    );
  }
}

function guardedCollectionNames() {
  var out = [];
  var name;
  for (name in GUARDED_COLLECTIONS) {
    if (GUARDED_COLLECTIONS.hasOwnProperty(name)) out.push(name);
  }
  return out;
}

/** Full entitlements payload: feature items plus numeric limits. */
function exportAll(app, orgId) {
  var result = resolveEntitlements(app, orgId);
  return {
    hasSubscription: result.hasSubscription,
    packageId: result.packageId,
    packageName: result.packageName,
    items: result.items,
    limits: resolveLimits(app, orgId)
  };
}

// GET /api/organizations/{id}/entitlements
function getEntitlements(e) {
  var subs = subscriptionHelpers();
  var orgId = e.request.pathValue("id");
  subs.requireOrgMember(e, orgId);
  return e.json(200, exportAll(e.app, orgId));
}

function logOverrideActivity(e, action, recordId, key, orgId, detail) {
  var orgName = orgId;
  try {
    orgName = e.app.findRecordById("organizations", orgId).getString("name") || orgId;
  } catch (_) {}
  var entry = catalogEntry(key);
  var label = entry ? entry.label : key;
  try {
    var log = new Record(e.app.findCollectionByNameOrId("activityLogs"));
    log.set("collection", "organizationFeatureOverrides");
    log.set("recordId", recordId);
    log.set("action", action);
    log.set("description", label + " for " + orgName + ": " + detail);
    if (e.auth) log.set("user", e.auth.id);
    e.app.save(log);
  } catch (err) {
    console.log("[ENTITLEMENTS] activity log failed: " + err);
  }
}

// PUT /api/super-admin/organizations/{id}/feature-overrides/{key}
// body: { enabled: true | false | null, note?: string }
function setFeatureOverride(e) {
  var subs = subscriptionHelpers();
  subs.requireSystemAdmin(e);
  var orgId = e.request.pathValue("id");
  var key = e.request.pathValue("key");
  if (!isValidKey(key)) throw new BadRequestError("unknown feature key");
  try {
    e.app.findRecordById("organizations", orgId);
  } catch (_) {
    throw new NotFoundError("organization not found");
  }

  var info = e.requestInfo();
  var body = (info && info.body) || {};
  var existing = null;
  try {
    existing = e.app.findFirstRecordByFilter(
      "organizationFeatureOverrides",
      "organization = {:org} && featureKey = {:key}",
      { org: orgId, key: key }
    );
  } catch (_) {
    existing = null;
  }

  var enabledRaw = body.enabled;
  var note = String(body.note || "").trim();

  if (enabledRaw === null || enabledRaw === undefined || enabledRaw === "") {
    if (existing) {
      var clearedId = existing.id;
      e.app.delete(existing);
      logOverrideActivity(e, "delete", clearedId, key, orgId, "now follows the subscription plan");
    }
  } else {
    var enabled = enabledRaw === true || enabledRaw === "true" || enabledRaw === 1;
    var record = existing;
    if (!record) {
      record = new Record(
        e.app.findCollectionByNameOrId("organizationFeatureOverrides")
      );
      record.set("organization", orgId);
      record.set("featureKey", key);
    }
    record.set("enabled", enabled);
    record.set("note", note);
    record.set("updatedBy", e.auth.id);
    var isNew = !existing;
    e.app.save(record);
    logOverrideActivity(
      e,
      isNew ? "create" : "update",
      record.id,
      key,
      orgId,
      enabled ? "force enabled by Super Admin" : "force disabled by Super Admin"
    );
  }

  return e.json(200, exportAll(e.app, orgId));
}

function logLimitActivity(e, action, recordId, key, orgId, detail) {
  var orgName = orgId;
  try {
    orgName = e.app.findRecordById("organizations", orgId).getString("name") || orgId;
  } catch (_) {}
  var entry = limitEntry(key);
  var label = entry ? entry.label + " limit" : key;
  try {
    var log = new Record(e.app.findCollectionByNameOrId("activityLogs"));
    log.set("collection", "organizationLimitOverrides");
    log.set("recordId", recordId);
    log.set("action", action);
    log.set("description", label + " for " + orgName + ": " + detail);
    if (e.auth) log.set("user", e.auth.id);
    e.app.save(log);
  } catch (err) {
    console.log("[ENTITLEMENTS] activity log failed: " + err);
  }
}

// PUT /api/super-admin/organizations/{id}/limit-overrides/{key}
// body: { value: <whole number> | null, note?: string }
// null clears the override (follow plan); 0 forces unlimited.
function setLimitOverride(e) {
  var subs = subscriptionHelpers();
  subs.requireSystemAdmin(e);
  var orgId = e.request.pathValue("id");
  var key = e.request.pathValue("key");
  if (!limitEntry(key)) throw new BadRequestError("unknown limit key");
  try {
    e.app.findRecordById("organizations", orgId);
  } catch (_) {
    throw new NotFoundError("organization not found");
  }

  var info = e.requestInfo();
  var body = (info && info.body) || {};
  var existing = null;
  try {
    existing = e.app.findFirstRecordByFilter(
      "organizationLimitOverrides",
      "organization = {:org} && limitKey = {:key}",
      { org: orgId, key: key }
    );
  } catch (_) {
    existing = null;
  }

  var valueRaw = body.value;
  var note = String(body.note || "").trim();

  if (valueRaw === null || valueRaw === undefined || valueRaw === "") {
    if (existing) {
      var clearedId = existing.id;
      e.app.delete(existing);
      logLimitActivity(e, "delete", clearedId, key, orgId, "now follows the subscription plan");
    }
  } else {
    var value = Number(valueRaw);
    if (isNaN(value) || value < 0 || Math.floor(value) !== value) {
      throw new BadRequestError("value must be a non-negative whole number");
    }
    var record = existing;
    if (!record) {
      record = new Record(
        e.app.findCollectionByNameOrId("organizationLimitOverrides")
      );
      record.set("organization", orgId);
      record.set("limitKey", key);
    }
    record.set("value", value);
    record.set("note", note);
    record.set("updatedBy", e.auth.id);
    var isNew = !existing;
    e.app.save(record);
    logLimitActivity(
      e,
      isNew ? "create" : "update",
      record.id,
      key,
      orgId,
      value > 0 ? "set to " + value + " by Super Admin" : "set to unlimited by Super Admin"
    );
  }

  return e.json(200, exportAll(e.app, orgId));
}

module.exports = {
  FEATURE_CATALOG: FEATURE_CATALOG,
  catalogKeys: catalogKeys,
  isValidKey: isValidKey,
  sanitizeFeatureList: sanitizeFeatureList,
  readJsonArray: readJsonArray,
  resolveEntitlements: resolveEntitlements,
  isFeatureEntitled: isFeatureEntitled,
  guardRecordWrite: guardRecordWrite,
  guardBranchCreate: guardBranchCreate,
  isCustomerHistoryEntitled: isCustomerHistoryEntitled,
  guardedCollectionNames: guardedCollectionNames,
  getEntitlements: getEntitlements,
  setFeatureOverride: setFeatureOverride,
  LIMIT_CATALOG: LIMIT_CATALOG,
  resolveLimits: resolveLimits,
  setLimitOverride: setLimitOverride
};
