/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Activity Logger Hook
// ============================================================================
// Automatically logs all CRUD operations on tracked collections into the
// activityLogs collection. Captures changes, user info, and descriptions.
//
// Config and shared logic loaded via require() inside each handler
// (goja scope isolation — top-level vars are NOT accessible in handlers).
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

// -- Create hooks --
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "sales");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "products");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "services");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "customers");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "employees");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "users");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "userRoles");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "branches");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "machines");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "storages");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "promos");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "payments");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "employeeAttendances");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "employeeDeductions");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "saleItems");
onRecordAfterCreateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logCreate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] create error:", err); }
}, "saleServiceItems");

// -- Update hooks --
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "sales");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "products");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "services");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "customers");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "employees");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "users");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "userRoles");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "branches");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "machines");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "storages");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "promos");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "payments");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "employeeAttendances");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "employeeDeductions");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "saleItems");
onRecordAfterUpdateSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logUpdate(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] update error:", err); }
}, "saleServiceItems");

// -- Delete hooks --
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "sales");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "products");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "services");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "customers");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "employees");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "users");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "userRoles");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "branches");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "machines");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "storages");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "promos");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "payments");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "employeeAttendances");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "employeeDeductions");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "saleItems");
onRecordAfterDeleteSuccess(function(e) {
  try { var c = require(__hooks + "/activity_logger_config.js"); c.logDelete(e); }
  catch(err) { console.error("[ACTIVITY_LOGGER] delete error:", err); }
}, "saleServiceItems");
