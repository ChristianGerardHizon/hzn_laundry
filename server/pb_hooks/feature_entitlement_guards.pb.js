/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Feature entitlement guards
// ============================================================================
// Rejects create/update requests on collections whose feature is not enabled
// for the record's organization (subscription package + Super Admin override).
// Logic lives in lib/feature_entitlements_helpers.js (GUARDED_COLLECTIONS).
// require() inside each handler (goja scope isolation).
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordCreateRequest(function(e) {
  require(__hooks + "/lib/feature_entitlements_helpers.js").guardRecordWrite(e);
  e.next();
}, "employees", "employeeAttendances", "employeeDeductions", "promos", "customerPromos", "saleConsumableUsages", "posGroups");

onRecordUpdateRequest(function(e) {
  require(__hooks + "/lib/feature_entitlements_helpers.js").guardRecordWrite(e);
  e.next();
}, "employees", "employeeAttendances", "employeeDeductions", "promos", "customerPromos", "saleConsumableUsages", "posGroups");

// Extra branches require the multiBranch feature.
onRecordCreateRequest(function(e) {
  require(__hooks + "/lib/feature_entitlements_helpers.js").guardBranchCreate(e);
  e.next();
}, "branches");
