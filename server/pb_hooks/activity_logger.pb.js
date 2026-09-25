/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Activity Logger Hook
// ============================================================================
// Automatically logs CRUD operations on tracked collections into the
// activityLogs collection. Captures changes, user info, and descriptions.
//
// Uses onRecord*Request (not AfterSuccess) so e.auth is available.
// Call e.next() first, then write the activity log.
//
// Config and shared logic loaded via require() inside each handler
// (goja scope isolation — top-level vars are NOT accessible in handlers).
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

// -- Create --
onRecordCreateRequest(function(e) {
  e.next();
  try {
    var c = require(__hooks + "/activity_logger_config.js");
    c.logCreate(e);
  } catch (err) {
    console.error("[ACTIVITY_LOGGER] create error:", err);
  }
}, "sales", "products", "services", "customers", "employees", "users", "userRoles", "branches", "machines", "storages", "promos", "payments", "employeeAttendances", "employeeDeductions", "saleItems", "saleServiceItems");

// -- Update --
// Snapshot original() before e.next() — after next it may match the new record.
onRecordUpdateRequest(function(e) {
  var original = e.record.original();
  e.next();
  try {
    var c = require(__hooks + "/activity_logger_config.js");
    c.logUpdate(e, original);
  } catch (err) {
    console.error("[ACTIVITY_LOGGER] update error:", err);
  }
}, "sales", "products", "services", "customers", "employees", "users", "userRoles", "branches", "machines", "storages", "promos", "payments", "employeeAttendances", "employeeDeductions", "saleItems", "saleServiceItems");

// -- Delete --
onRecordDeleteRequest(function(e) {
  e.next();
  try {
    var c = require(__hooks + "/activity_logger_config.js");
    c.logDelete(e);
  } catch (err) {
    console.error("[ACTIVITY_LOGGER] delete error:", err);
  }
}, "sales", "products", "services", "customers", "employees", "users", "userRoles", "branches", "machines", "storages", "promos", "payments", "employeeAttendances", "employeeDeductions", "saleItems", "saleServiceItems");
