/// <reference path="../../pb_data/types.d.ts" />

// Helpers for organization_subscriptions.pb.js
// ES5 only — no const, let, arrow functions, or async/await.

var orgHelpers = require(__hooks + "/lib/organization_invites_helpers.js");
var historyConfig = require(__hooks + "/send_history_link_config.js");

function exportRecord(record) {
  if (record && typeof record.publicExport === "function") {
    return record.publicExport();
  }
  return record;
}

function requireSystemAdmin(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }
  if (isAuthSuperuser(e.auth)) {
    throw new ForbiddenError("use the Admin UI as a superuser");
  }
  if (!orgHelpers.hasPermission(e.app, e.auth.getString("role"), "system.admin")) {
    throw new ForbiddenError("system.admin permission required");
  }
}

function isAuthSuperuser(authRecord) {
  try {
    return authRecord.collection().name === "_superusers";
  } catch (_) {
    return false;
  }
}

function requireAuthUser(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }
  if (isAuthSuperuser(e.auth)) {
    throw new ForbiddenError("use the Admin UI as a superuser");
  }
}

function isOrgMember(app, orgId, userId) {
  try {
    var membership = app.findFirstRecordByFilter(
      "organizationMemberships",
      "organization = {:org} && user = {:user} && status = 'active'",
      { org: orgId, user: userId }
    );
    return !!membership;
  } catch (_) {
    return false;
  }
}

function requireOrgMember(e, orgId) {
  requireAuthUser(e);
  if (!isOrgMember(e.app, orgId, e.auth.id)) {
    // system.admin can also access pay info
    if (!orgHelpers.hasPermission(e.app, e.auth.getString("role"), "system.admin")) {
      throw new ForbiddenError("organization membership required");
    }
  }
}

function trimStr(value) {
  return String(value || "").trim();
}

function parseBody(e) {
  var info = e.requestInfo();
  return (info && info.body) || {};
}

function toIsoDate(d) {
  if (!d) return null;
  var date = d instanceof Date ? d : new Date(d);
  if (isNaN(date.getTime())) return null;
  return date.toISOString().replace("T", " ").substring(0, 19) + ".000Z";
}

function addInterval(startDate, count, unit) {
  var d = new Date(startDate.getTime());
  var n = Number(count) || 1;
  if (unit === "day") {
    d.setUTCDate(d.getUTCDate() + n);
  } else if (unit === "year") {
    d.setUTCFullYear(d.getUTCFullYear() + n);
  } else {
    // month default
    d.setUTCMonth(d.getUTCMonth() + n);
  }
  return d;
}

function getBillingSettingsRecord(app) {
  var rows = app.findRecordsByFilter(
    "platformBillingSettings",
    "id != ''",
    "-created",
    1,
    0
  );
  if (!rows || rows.length === 0) {
    throw new NotFoundError("billing settings not found");
  }
  return rows[0];
}

function readReminderDays(settings) {
  var raw = settings.get("reminderDaysBeforeDue");
  if (!raw) return [3, 0];
  try {
    if (Array.isArray(raw)) return raw;
    var jsonString = typeof raw.string === "function" ? raw.string() : String(raw);
    var parsed = JSON.parse(jsonString);
    if (Array.isArray(parsed)) return parsed;
  } catch (_) {}
  return [3, 0];
}

function readBoolSetting(settings, key, fallback) {
  try {
    if (typeof settings.getBool === "function") {
      // getBool returns false when unset; detect missing via get().
      var raw = settings.get(key);
      if (raw === null || raw === undefined || raw === "") {
        return fallback;
      }
      return settings.getBool(key);
    }
  } catch (_) {}
  var v = settings.get(key);
  if (v === null || v === undefined || v === "") return fallback;
  return !!v;
}

function readWarningDays(settings) {
  var n = 7;
  try {
    n = settings.getInt("warningDaysBeforeDue");
  } catch (_) {
    n = 7;
  }
  if (n === null || n === undefined || isNaN(Number(n)) || Number(n) < 0) {
    return 7;
  }
  return Number(n);
}

function fileUrl(baseUrl, collection, recordId, filename) {
  if (!filename) return null;
  return baseUrl + "/api/files/" + collection + "/" + recordId + "/" + filename;
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

function findLatestPayment(app, subscriptionId) {
  try {
    var rows = app.findRecordsByFilter(
      "subscriptionPayments",
      "subscription = {:sub}",
      "-created",
      1,
      0,
      { sub: subscriptionId }
    );
    if (rows && rows.length > 0) return rows[0];
  } catch (_) {}
  return null;
}

function countPendingPayments(app, orgId) {
  try {
    var rows = app.findRecordsByFilter(
      "subscriptionPayments",
      "organization = {:org} && status = 'pending'",
      "-created",
      500,
      0,
      { org: orgId }
    );
    return rows ? rows.length : 0;
  } catch (_) {
    return 0;
  }
}

function exportSubscription(record) {
  if (!record) return null;
  return exportRecord(record);
}

function exportPayment(app, record, baseUrl) {
  if (!record) return null;
  var data = exportRecord(record);
  var proof = record.getString("proofImage");
  data.proofImageUrl = fileUrl(
    baseUrl,
    "subscriptionPayments",
    record.id,
    proof
  );
  return data;
}

function exportSettings(record, baseUrl) {
  var data = exportRecord(record);
  data.qrphImageUrl = fileUrl(
    baseUrl,
    "platformBillingSettings",
    record.id,
    record.getString("qrphImage")
  );
  data.reminderDaysBeforeDue = readReminderDays(record);
  data.warningDaysBeforeDue = readWarningDays(record);
  data.enforceWarnings = readBoolSetting(record, "enforceWarnings", true);
  data.enforceLockout = readBoolSetting(record, "enforceLockout", true);
  return data;
}

function getAppBaseUrl() {
  return historyConfig.getAppBaseUrl();
}

function listPackages(e) {
  requireAuthUser(e);
  var isAdmin = orgHelpers.hasPermission(
    e.app,
    e.auth.getString("role"),
    "system.admin"
  );
  var info = e.requestInfo();
  var query = (info && info.query) || {};
  var premadeOnly =
    String(query.premadeOnly || "").toLowerCase() === "true";
  var filter = "isDeleted = false";
  if (premadeOnly || !isAdmin) {
    filter += " && isPremade = true && isActive = true";
  }
  var records = e.app.findRecordsByFilter(
    "subscriptionPackages",
    filter,
    "name",
    200,
    0
  );
  var out = [];
  var i;
  for (i = 0; i < records.length; i++) {
    out.push(exportRecord(records[i]));
  }
  return e.json(200, { items: out });
}

function createPackage(e) {
  requireSystemAdmin(e);
  var body = parseBody(e);
  var name = trimStr(body.name);
  if (!name) throw new BadRequestError("name is required");
  var price = Number(body.price);
  if (isNaN(price) || price < 0) throw new BadRequestError("price is invalid");
  var intervalCount = Number(body.intervalCount) || 1;
  var intervalUnit = trimStr(body.intervalUnit) || "month";
  if (["day", "month", "year"].indexOf(intervalUnit) === -1) {
    throw new BadRequestError("intervalUnit must be day, month, or year");
  }

  var collection = e.app.findCollectionByNameOrId("subscriptionPackages");
  var record = new Record(collection);
  record.set("name", name);
  record.set("description", trimStr(body.description));
  record.set("price", price);
  record.set("intervalCount", intervalCount);
  record.set("intervalUnit", intervalUnit);
  record.set("isPremade", body.isPremade !== false && body.isPremade !== "false");
  record.set("isActive", body.isActive !== false && body.isActive !== "false");
  record.set("isDeleted", false);
  if (body.organizationId) {
    record.set("organizationId", body.organizationId);
    record.set("isPremade", false);
  }
  e.app.save(record);
  return e.json(200, exportRecord(record));
}

function updatePackage(e) {
  requireSystemAdmin(e);
  var id = e.request.pathValue("id");
  var record;
  try {
    record = e.app.findRecordById("subscriptionPackages", id);
  } catch (_) {
    throw new NotFoundError("package not found");
  }
  var body = parseBody(e);
  if (body.name !== undefined) record.set("name", trimStr(body.name));
  if (body.description !== undefined) record.set("description", trimStr(body.description));
  if (body.price !== undefined) {
    var price = Number(body.price);
    if (isNaN(price) || price < 0) throw new BadRequestError("price is invalid");
    record.set("price", price);
  }
  if (body.intervalCount !== undefined) {
    record.set("intervalCount", Number(body.intervalCount) || 1);
  }
  if (body.intervalUnit !== undefined) {
    var unit = trimStr(body.intervalUnit);
    if (["day", "month", "year"].indexOf(unit) === -1) {
      throw new BadRequestError("intervalUnit must be day, month, or year");
    }
    record.set("intervalUnit", unit);
  }
  if (body.isPremade !== undefined) {
    record.set("isPremade", body.isPremade === true || body.isPremade === "true");
  }
  if (body.isActive !== undefined) {
    record.set("isActive", body.isActive === true || body.isActive === "true");
  }
  if (body.isDeleted !== undefined) {
    record.set("isDeleted", body.isDeleted === true || body.isDeleted === "true");
  }
  e.app.save(record);
  return e.json(200, exportRecord(record));
}

function softDeletePackage(e) {
  requireSystemAdmin(e);
  var id = e.request.pathValue("id");
  var record;
  try {
    record = e.app.findRecordById("subscriptionPackages", id);
  } catch (_) {
    throw new NotFoundError("package not found");
  }
  record.set("isDeleted", true);
  record.set("isActive", false);
  e.app.save(record);
  return e.json(200, exportRecord(record));
}

/**
 * Assign (or replace) an organization subscription.
 * opts: {
 *   packageId?, customPackage?, allowCustom?, requirePremade?,
 *   periodStart?, periodEnd?  // optional ISO date overrides
 * }
 * Returns { subscription, package }.
 */
function assignSubscriptionInApp(app, orgId, opts) {
  opts = opts || {};
  var packageId = trimStr(opts.packageId);
  var customPackage = opts.customPackage;
  var allowCustom = opts.allowCustom === true;
  var requirePremade = opts.requirePremade === true;

  var pkg = null;

  if (packageId) {
    try {
      pkg = app.findRecordById("subscriptionPackages", packageId);
    } catch (_) {
      throw new NotFoundError("package not found");
    }
    if (pkg.getBool("isDeleted")) {
      throw new BadRequestError("package is deleted");
    }
    if (requirePremade) {
      if (!pkg.getBool("isPremade") || !pkg.getBool("isActive")) {
        throw new BadRequestError("package must be an active premade package");
      }
    }
  } else if (customPackage && typeof customPackage === "object") {
    if (!allowCustom) {
      throw new ForbiddenError("customPackage requires system.admin");
    }
    var cp = customPackage;
    var pkgCollection = app.findCollectionByNameOrId("subscriptionPackages");
    pkg = new Record(pkgCollection);
    var cpName = trimStr(cp.name);
    if (!cpName) throw new BadRequestError("customPackage.name is required");
    pkg.set("name", cpName);
    pkg.set("description", trimStr(cp.description));
    pkg.set("price", Number(cp.price) || 0);
    pkg.set("intervalCount", Number(cp.intervalCount) || 1);
    var unit = trimStr(cp.intervalUnit) || "month";
    if (["day", "month", "year"].indexOf(unit) === -1) {
      throw new BadRequestError("intervalUnit must be day, month, or year");
    }
    pkg.set("intervalUnit", unit);
    pkg.set("isPremade", false);
    pkg.set("organizationId", orgId);
    pkg.set("isActive", true);
    pkg.set("isDeleted", false);
    app.save(pkg);
  } else {
    throw new BadRequestError("packageId or customPackage is required");
  }

  var existing = findActiveSubscription(app, orgId);
  if (existing) {
    existing.set("status", "cancelled");
    app.save(existing);
  }

  var intervalCount = pkg.getInt("intervalCount");
  var intervalUnit = pkg.getString("intervalUnit");
  var now = new Date();
  var hasStart = trimStr(opts.periodStart) !== "";
  var hasEnd = trimStr(opts.periodEnd) !== "";
  var periodStartDate;
  var periodEndDate;

  if (hasEnd && !hasStart) {
    throw new BadRequestError("periodStart is required when periodEnd is set");
  }

  if (hasStart) {
    periodStartDate = new Date(opts.periodStart);
    if (isNaN(periodStartDate.getTime())) {
      throw new BadRequestError("periodStart is invalid");
    }
    if (hasEnd) {
      periodEndDate = new Date(opts.periodEnd);
      if (isNaN(periodEndDate.getTime())) {
        throw new BadRequestError("periodEnd is invalid");
      }
      if (periodEndDate.getTime() <= periodStartDate.getTime()) {
        throw new BadRequestError("periodEnd must be after periodStart");
      }
    } else {
      periodEndDate = addInterval(periodStartDate, intervalCount, intervalUnit);
    }
  } else {
    periodStartDate = now;
    periodEndDate = addInterval(now, intervalCount, intervalUnit);
  }

  var settings = getBillingSettingsRecord(app);
  var reminderDays = readReminderDays(settings);
  var soonestReminder = null;
  var ri;
  for (ri = 0; ri < reminderDays.length; ri++) {
    var daysBefore = Number(reminderDays[ri]) || 0;
    var reminderAt = new Date(periodEndDate.getTime());
    reminderAt.setUTCDate(reminderAt.getUTCDate() - daysBefore);
    if (!soonestReminder || reminderAt < soonestReminder) {
      if (reminderAt > now) soonestReminder = reminderAt;
    }
  }

  var subCollection = app.findCollectionByNameOrId("organizationSubscriptions");
  var sub = new Record(subCollection);
  sub.set("organization", orgId);
  sub.set("package", pkg.id);
  sub.set("packageName", pkg.getString("name"));
  sub.set("price", pkg.getFloat("price"));
  sub.set("intervalCount", intervalCount);
  sub.set("intervalUnit", intervalUnit);
  sub.set("status", "active");
  sub.set("periodStart", toIsoDate(periodStartDate));
  sub.set("periodEnd", toIsoDate(periodEndDate));
  sub.set("graceEndsAt", "");
  sub.set("manualUnlockUntil", "");
  sub.set("nextReminderAt", soonestReminder ? toIsoDate(soonestReminder) : "");
  sub.set("isDeleted", false);
  app.save(sub);

  return { subscription: sub, package: pkg };
}

function assignSubscription(e) {
  requireSystemAdmin(e);
  var orgId = e.request.pathValue("id");
  var org;
  try {
    org = e.app.findRecordById("organizations", orgId);
  } catch (_) {
    throw new NotFoundError("organization not found");
  }

  var body = parseBody(e);
  var result = assignSubscriptionInApp(e.app, orgId, {
    packageId: body.packageId,
    customPackage: body.customPackage,
    allowCustom: true,
    requirePremade: false,
    periodStart: body.periodStart,
    periodEnd: body.periodEnd
  });

  return e.json(200, {
    organization: exportRecord(org),
    subscription: exportSubscription(result.subscription),
    package: exportRecord(result.package)
  });
}

function getOrgSubscription(e) {
  requireOrgMember(e, e.request.pathValue("id"));
  var orgId = e.request.pathValue("id");
  var sub = findActiveSubscription(e.app, orgId);
  return e.json(200, { subscription: exportSubscription(sub) });
}

function getPayInfo(e) {
  var orgId = e.request.pathValue("id");
  requireOrgMember(e, orgId);
  var org;
  try {
    org = e.app.findRecordById("organizations", orgId);
  } catch (_) {
    throw new NotFoundError("organization not found");
  }
  var settings = getBillingSettingsRecord(e.app);
  var sub = findActiveSubscription(e.app, orgId);
  var latest = sub ? findLatestPayment(e.app, sub.id) : null;
  var baseUrl = getAppBaseUrl();

  return e.json(200, {
    organizationName: org.getString("name"),
    organizationId: orgId,
    subscription: exportSubscription(sub),
    settings: exportSettings(settings, baseUrl),
    latestPayment: latest ? exportPayment(e.app, latest, baseUrl) : null
  });
}

function submitPayment(e) {
  var orgId = e.request.pathValue("id");
  requireOrgMember(e, orgId);

  var sub = findActiveSubscription(e.app, orgId);
  if (!sub) {
    throw new BadRequestError("no active subscription for this organization");
  }

  // Reject if already pending
  var existingPending;
  try {
    existingPending = e.app.findFirstRecordByFilter(
      "subscriptionPayments",
      "subscription = {:sub} && status = 'pending'",
      { sub: sub.id }
    );
  } catch (_) {
    existingPending = null;
  }
  if (existingPending) {
    throw new BadRequestError("a payment proof is already pending review");
  }

  var body = parseBody(e);
  var note = trimStr(body.note);
  var amount = Number(body.amount);
  if (isNaN(amount) || amount <= 0) {
    amount = sub.getFloat("price");
  }

  var files = [];
  try {
    files = e.findUploadedFiles("proofImage") || [];
  } catch (_) {
    files = [];
  }
  files = files.filter(function(f) { return !!f; });
  if (!files.length) {
    throw new BadRequestError("proofImage is required");
  }

  var collection = e.app.findCollectionByNameOrId("subscriptionPayments");
  var record = new Record(collection);
  record.set("organization", orgId);
  record.set("subscription", sub.id);
  record.set("amount", amount);
  record.set("status", "pending");
  record.set("note", note);
  record.set("submittedBy", e.auth.id);
  record.set("proofImage", files);

  e.app.save(record);

  return e.json(200, exportPayment(e.app, record, getAppBaseUrl()));
}

function listPendingPayments(e) {
  requireSystemAdmin(e);
  var records = e.app.findRecordsByFilter(
    "subscriptionPayments",
    "status = 'pending'",
    "-created",
    200,
    0
  );
  var baseUrl = getAppBaseUrl();
  var out = [];
  var i;
  for (i = 0; i < records.length; i++) {
    var item = exportPayment(e.app, records[i], baseUrl);
    try {
      var org = e.app.findRecordById(
        "organizations",
        records[i].getString("organization")
      );
      item.organizationName = org.getString("name");
    } catch (_) {
      item.organizationName = "";
    }
    out.push(item);
  }
  return e.json(200, { items: out });
}

function reviewPayment(e) {
  requireSystemAdmin(e);
  var id = e.request.pathValue("id");
  var payment;
  try {
    payment = e.app.findRecordById("subscriptionPayments", id);
  } catch (_) {
    throw new NotFoundError("payment not found");
  }
  if (payment.getString("status") !== "pending") {
    throw new BadRequestError("payment is not pending");
  }

  var body = parseBody(e);
  var approved = body.approved === true || body.approved === "true";
  var adminNote = trimStr(body.adminNote);

  payment.set("adminNote", adminNote);
  payment.set("reviewedBy", e.auth.id);
  payment.set("reviewedAt", toIsoDate(new Date()));

  if (!approved) {
    payment.set("status", "rejected");
    e.app.save(payment);
    return e.json(200, exportPayment(e.app, payment, getAppBaseUrl()));
  }

  payment.set("status", "approved");
  e.app.save(payment);

  var sub;
  try {
    sub = e.app.findRecordById(
      "organizationSubscriptions",
      payment.getString("subscription")
    );
  } catch (_) {
    throw new NotFoundError("subscription not found");
  }

  var now = new Date();
  var periodEndRaw = sub.getString("periodEnd");
  var prevEnd = periodEndRaw ? new Date(periodEndRaw) : now;
  if (isNaN(prevEnd.getTime()) || prevEnd < now) {
    prevEnd = now;
  }
  var newStart = prevEnd;
  var newEnd = addInterval(
    newStart,
    sub.getInt("intervalCount"),
    sub.getString("intervalUnit")
  );

  sub.set("periodStart", toIsoDate(newStart));
  sub.set("periodEnd", toIsoDate(newEnd));
  sub.set("status", "active");
  sub.set("graceEndsAt", "");
  sub.set("manualUnlockUntil", "");

  var settings = getBillingSettingsRecord(e.app);
  var reminderDays = readReminderDays(settings);
  var soonestReminder = null;
  var ri;
  for (ri = 0; ri < reminderDays.length; ri++) {
    var daysBefore = Number(reminderDays[ri]) || 0;
    var reminderAt = new Date(newEnd.getTime());
    reminderAt.setUTCDate(reminderAt.getUTCDate() - daysBefore);
    if (reminderAt > now) {
      if (!soonestReminder || reminderAt < soonestReminder) {
        soonestReminder = reminderAt;
      }
    }
  }
  sub.set("nextReminderAt", soonestReminder ? toIsoDate(soonestReminder) : "");
  e.app.save(sub);

  return e.json(200, {
    payment: exportPayment(e.app, payment, getAppBaseUrl()),
    subscription: exportSubscription(sub)
  });
}

function unlockOrganization(e) {
  requireSystemAdmin(e);
  var orgId = e.request.pathValue("id");
  var sub = findActiveSubscription(e.app, orgId);
  if (!sub) {
    throw new NotFoundError("no active subscription for this organization");
  }

  var body = parseBody(e);
  var until;
  if (body.until) {
    until = new Date(body.until);
  } else {
    until = new Date();
    until.setUTCDate(until.getUTCDate() + 7);
  }
  if (isNaN(until.getTime())) {
    throw new BadRequestError("until is invalid");
  }

  sub.set("manualUnlockUntil", toIsoDate(until));
  if (sub.getString("status") === "locked") {
    sub.set("status", "grace");
    if (!sub.getString("graceEndsAt")) {
      sub.set("graceEndsAt", toIsoDate(until));
    }
  }
  e.app.save(sub);

  return e.json(200, {
    subscription: exportSubscription(sub),
    note: trimStr(body.note)
  });
}

function lockOrganization(e) {
  requireSystemAdmin(e);
  var orgId = e.request.pathValue("id");
  var sub = findActiveSubscription(e.app, orgId);
  if (!sub) {
    throw new NotFoundError("no active subscription for this organization");
  }

  var body = parseBody(e);
  sub.set("status", "locked");
  sub.set("manualUnlockUntil", "");
  e.app.save(sub);

  return e.json(200, {
    subscription: exportSubscription(sub),
    note: trimStr(body.note)
  });
}

function getBillingSettings(e) {
  requireAuthUser(e);
  var settings = getBillingSettingsRecord(e.app);
  return e.json(200, exportSettings(settings, getAppBaseUrl()));
}

function updateBillingSettings(e) {
  requireSystemAdmin(e);
  var settings = getBillingSettingsRecord(e.app);
  var body = parseBody(e);

  if (body.payeeName !== undefined) {
    settings.set("payeeName", trimStr(body.payeeName));
  }
  if (body.instructions !== undefined) {
    settings.set("instructions", trimStr(body.instructions));
  }
  if (body.defaultGraceDays !== undefined) {
    settings.set("defaultGraceDays", Number(body.defaultGraceDays) || 7);
  }
  if (body.warningDaysBeforeDue !== undefined) {
    var warningDays = Number(body.warningDaysBeforeDue);
    if (isNaN(warningDays) || warningDays < 0) warningDays = 7;
    settings.set("warningDaysBeforeDue", warningDays);
  }
  if (body.enforceWarnings !== undefined) {
    settings.set(
      "enforceWarnings",
      body.enforceWarnings === true ||
        body.enforceWarnings === "true" ||
        body.enforceWarnings === 1 ||
        body.enforceWarnings === "1"
    );
  }
  if (body.enforceLockout !== undefined) {
    settings.set(
      "enforceLockout",
      body.enforceLockout === true ||
        body.enforceLockout === "true" ||
        body.enforceLockout === 1 ||
        body.enforceLockout === "1"
    );
  }
  if (body.reminderDaysBeforeDue !== undefined) {
    var days = body.reminderDaysBeforeDue;
    if (typeof days === "string") {
      try {
        days = JSON.parse(days);
      } catch (_) {
        days = [3, 0];
      }
    }
    if (!Array.isArray(days)) days = [3, 0];
    settings.set("reminderDaysBeforeDue", days);
  }

  var files = [];
  try {
    files = e.findUploadedFiles("qrphImage") || [];
  } catch (_) {
    files = [];
  }
  files = files.filter(function(f) { return !!f; });
  if (files.length) {
    settings.set("qrphImage", files);
  }

  e.app.save(settings);
  return e.json(200, exportSettings(settings, getAppBaseUrl()));
}

function escapeHtml(s) {
  if (s === null || s === undefined) return "";
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function buildSubscriptionReminderEmail(orgName, link, periodEnd, status) {
  var brand = historyConfig.getAppDisplayName();
  var safeName = escapeHtml(orgName);
  var safeLink = escapeHtml(link);
  var subject =
    status === "locked"
      ? brand + " subscription locked — pay to restore access"
      : status === "grace"
        ? brand + " subscription overdue — grace period active"
        : brand + " subscription payment reminder";

  var html =
    "<!DOCTYPE html><html><body style=\"font-family:sans-serif;color:#0f172a\">" +
    "<p>Hello,</p>" +
    "<p>This is a billing reminder for <strong>" +
    safeName +
    "</strong>.</p>" +
    "<p>Current period ends: <strong>" +
    String(periodEnd || "") +
    "</strong></p>" +
    "<p>Status: <strong>" +
    String(status || "") +
    "</strong></p>" +
    "<p><a href=\"" +
    safeLink +
    "\" style=\"display:inline-block;padding:12px 20px;background:#45A9AB;color:#fff;text-decoration:none;border-radius:8px\">Pay subscription</a></p>" +
    "<p>Or open: " +
    safeLink +
    "</p>" +
    "<p>— " +
    escapeHtml(brand) +
    "</p></body></html>";

  var text =
    "Billing reminder for " +
    orgName +
    "\nPeriod ends: " +
    periodEnd +
    "\nStatus: " +
    status +
    "\nPay here: " +
    link +
    "\n";

  return { subject: subject, html: html, text: text };
}

function sendResendEmail(toEmail, subject, html, text) {
  var apiKey = $os.getenv("RESEND_API_KEY");
  if (!apiKey) {
    console.log("[SUBSCRIPTION] RESEND_API_KEY not set; skip email to " + toEmail);
    return;
  }
  var fromEmail = historyConfig.getFromEmail();
  var res = $http.send({
    url: "https://api.resend.com/emails",
    method: "POST",
    headers: {
      Authorization: "Bearer " + apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: fromEmail,
      to: [toEmail],
      subject: subject,
      html: html,
      text: text
    }),
    timeout: 15
  });
  if (res.statusCode >= 400) {
    console.log(
      "[SUBSCRIPTION] Resend error " +
        res.statusCode +
        ": " +
        JSON.stringify(res.json)
    );
  }
}

function collectAdminEmails(app, orgId) {
  var emails = [];
  var seen = {};
  var memberships = [];
  try {
    memberships = app.findRecordsByFilter(
      "organizationMemberships",
      "organization = {:org} && status = 'active'",
      "",
      200,
      0,
      { org: orgId }
    );
  } catch (_) {
    return emails;
  }
  var i;
  for (i = 0; i < memberships.length; i++) {
    var roleId = memberships[i].getString("role");
    var canManage =
      orgHelpers.hasPermission(app, roleId, "members.manage") ||
      orgHelpers.hasPermission(app, roleId, "system.admin");
    if (!canManage) continue;
    try {
      var user = app.findRecordById("users", memberships[i].getString("user"));
      var email = trimStr(user.getString("email")).toLowerCase();
      if (email && !seen[email]) {
        seen[email] = true;
        emails.push(email);
      }
    } catch (_) {}
  }
  return emails;
}

function sendReminderForSubscription(app, sub) {
  var orgId = sub.getString("organization");
  var org;
  try {
    org = app.findRecordById("organizations", orgId);
  } catch (_) {
    return;
  }
  var link = getAppBaseUrl() + "/subscription/pay/" + orgId;
  var emailBody = buildSubscriptionReminderEmail(
    org.getString("name"),
    link,
    sub.getString("periodEnd"),
    sub.getString("status")
  );
  var emails = collectAdminEmails(app, orgId);
  var i;
  for (i = 0; i < emails.length; i++) {
    try {
      sendResendEmail(
        emails[i],
        emailBody.subject,
        emailBody.html,
        emailBody.text
      );
    } catch (err) {
      console.log("[SUBSCRIPTION] failed to email " + emails[i] + ": " + err);
    }
  }
  sub.set("lastReminderSentAt", toIsoDate(new Date()));
  app.save(sub);
}

function runDailyBillingJob() {
  console.log("[SUBSCRIPTION] daily billing job start");
  var settings;
  try {
    settings = getBillingSettingsRecord($app);
  } catch (err) {
    console.log("[SUBSCRIPTION] no billing settings: " + err);
    return;
  }
  var graceDays = settings.getInt("defaultGraceDays") || 7;
  var reminderDays = readReminderDays(settings);
  var enforceLockout = readBoolSetting(settings, "enforceLockout", true);
  var now = new Date();

  var subs = [];
  try {
    subs = $app.findRecordsByFilter(
      "organizationSubscriptions",
      "isDeleted = false && status != 'cancelled'",
      "",
      1000,
      0
    );
  } catch (err) {
    console.log("[SUBSCRIPTION] failed to load subscriptions: " + err);
    return;
  }

  var i;
  for (i = 0; i < subs.length; i++) {
    var sub = subs[i];
    try {
      var periodEnd = new Date(sub.getString("periodEnd"));
      if (isNaN(periodEnd.getTime())) continue;

      var manualUntilRaw = sub.getString("manualUnlockUntil");
      var manualUntil = manualUntilRaw ? new Date(manualUntilRaw) : null;
      var hasManualUnlock =
        manualUntil && !isNaN(manualUntil.getTime()) && manualUntil > now;

      var status = sub.getString("status");
      var changed = false;

      // Grace / lock only when lockout enforcement is enabled.
      if (enforceLockout) {
        // Grace transition (after periodEnd / due date)
        if (now > periodEnd && status === "active") {
          var graceEnds = new Date(periodEnd.getTime());
          graceEnds.setUTCDate(graceEnds.getUTCDate() + graceDays);
          sub.set("status", "grace");
          sub.set("graceEndsAt", toIsoDate(graceEnds));
          status = "grace";
          changed = true;
        }

        // Lock transition
        var graceEndsAtRaw = sub.getString("graceEndsAt");
        var graceEndsAt = graceEndsAtRaw ? new Date(graceEndsAtRaw) : null;
        if (
          status === "grace" &&
          graceEndsAt &&
          !isNaN(graceEndsAt.getTime()) &&
          now > graceEndsAt &&
          !hasManualUnlock
        ) {
          sub.set("status", "locked");
          status = "locked";
          changed = true;
        }
      }

      // Reminder schedule
      var shouldRemind = false;
      var rd;
      for (rd = 0; rd < reminderDays.length; rd++) {
        var daysBefore = Number(reminderDays[rd]) || 0;
        var remindDay = new Date(periodEnd.getTime());
        remindDay.setUTCDate(remindDay.getUTCDate() - daysBefore);
        var sameUtcDay =
          remindDay.getUTCFullYear() === now.getUTCFullYear() &&
          remindDay.getUTCMonth() === now.getUTCMonth() &&
          remindDay.getUTCDate() === now.getUTCDate();
        if (sameUtcDay) {
          shouldRemind = true;
          break;
        }
      }
      // Also remind on grace/locked daily-ish via nextReminderAt
      if (status === "grace" || status === "locked") {
        var nextRaw = sub.getString("nextReminderAt");
        var nextAt = nextRaw ? new Date(nextRaw) : null;
        if (!nextAt || isNaN(nextAt.getTime()) || nextAt <= now) {
          shouldRemind = true;
        }
      }

      if (changed) {
        $app.save(sub);
      }

      if (shouldRemind) {
        sendReminderForSubscription($app, sub);
        // Schedule next reminder tomorrow for grace/locked
        if (status === "grace" || status === "locked") {
          var tomorrow = new Date(now.getTime());
          tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
          sub.set("nextReminderAt", toIsoDate(tomorrow));
          $app.save(sub);
        }
      }
    } catch (err) {
      console.log(
        "[SUBSCRIPTION] error processing " + sub.id + ": " + err
      );
    }
  }
  console.log("[SUBSCRIPTION] daily billing job done");
}

function enrichOrganizationStats(app, organizations) {
  var i;
  for (i = 0; i < organizations.length; i++) {
    var org = organizations[i];
    var sub = null;
    try {
      sub = findActiveSubscription(app, org.id);
    } catch (_) {
      sub = null;
    }
    if (sub) {
      org.subscriptionStatus = sub.getString("status");
      org.periodEnd = sub.getString("periodEnd") || null;
      org.graceEndsAt = sub.getString("graceEndsAt") || null;
      org.packageName = sub.getString("packageName") || null;
      org.pendingPaymentCount = countPendingPayments(app, org.id);
      org.manualUnlockUntil = sub.getString("manualUnlockUntil") || null;
      org.subscriptionPrice = sub.getFloat("price");
    } else {
      org.subscriptionStatus = null;
      org.periodEnd = null;
      org.graceEndsAt = null;
      org.packageName = null;
      org.pendingPaymentCount = 0;
      org.manualUnlockUntil = null;
      org.subscriptionPrice = null;
    }
  }
  return organizations;
}

// Wrap existing listOrganizationPlatformStats to enrich with subscription data
function listOrganizationPlatformStatsEnriched(e) {
  requireSystemAdmin(e);
  // Reuse original implementation by calling helper then enriching —
  // we duplicate the query lightly via the existing function's logic by
  // invoking the original and intercepting isn't possible; call original
  // through a synthetic approach: run original code path.
  var original = orgHelpers.listOrganizationPlatformStats;
  // The original returns e.json(...) which writes response. Instead rebuild.
  var rows = arrayOf(
    new DynamicModel({
      id: "",
      name: "",
      slug: "",
      onboardingCompletedAt: nullString(),
      branchCount: 0,
      memberCount: 0,
      orderCount: 0,
      customerCount: 0,
      revenue: -0
    })
  );

  e.app
    .db()
    .newQuery(
      "SELECT " +
        "o.id AS id, " +
        "o.name AS name, " +
        "COALESCE(o.slug, '') AS slug, " +
        "o.onboardingCompletedAt AS onboardingCompletedAt, " +
        "COALESCE((SELECT COUNT(*) FROM branches b WHERE b.organization = o.id), 0) AS branchCount, " +
        "COALESCE((SELECT COUNT(*) FROM organizationMemberships m WHERE m.organization = o.id AND m.status = 'active'), 0) AS memberCount, " +
        "COALESCE((" +
        "SELECT COUNT(*) FROM sales s " +
        "INNER JOIN branches b ON b.id = s.branch " +
        "WHERE b.organization = o.id " +
        "AND s.status != 'voided' " +
        "AND (s.isDeleted = false OR s.isDeleted IS NULL)" +
        "), 0) AS orderCount, " +
        "COALESCE((" +
        "SELECT COUNT(*) FROM customers c " +
        "INNER JOIN branches b ON b.id = c.branch " +
        "WHERE b.organization = o.id" +
        "), 0) AS customerCount, " +
        "COALESCE((" +
        "SELECT SUM(s.totalAmount) FROM sales s " +
        "INNER JOIN branches b ON b.id = s.branch " +
        "WHERE b.organization = o.id " +
        "AND s.status != 'voided' " +
        "AND (s.isDeleted = false OR s.isDeleted IS NULL)" +
        "), 0) AS revenue " +
        "FROM organizations o " +
        "WHERE COALESCE(o.isDeleted, false) = false " +
        "ORDER BY o.name COLLATE NOCASE ASC"
    )
    .all(rows);

  var organizations = [];
  var totalOrders = 0;
  var totalCustomers = 0;
  var totalRevenue = 0;
  var i;
  for (i = 0; i < rows.length; i++) {
    var row = rows[i];
    var orderCount = Number(row.orderCount) || 0;
    var customerCount = Number(row.customerCount) || 0;
    var revenue = Number(row.revenue) || 0;
    totalOrders += orderCount;
    totalCustomers += customerCount;
    totalRevenue += revenue;
    organizations.push({
      id: row.id,
      name: row.name,
      slug: row.slug || "",
      onboardingCompletedAt: row.onboardingCompletedAt || null,
      branchCount: Number(row.branchCount) || 0,
      memberCount: Number(row.memberCount) || 0,
      orderCount: orderCount,
      customerCount: customerCount,
      revenue: revenue
    });
  }

  enrichOrganizationStats(e.app, organizations);

  return e.json(200, {
    summary: {
      organizationCount: organizations.length,
      orderCount: totalOrders,
      customerCount: totalCustomers,
      revenue: totalRevenue
    },
    organizations: organizations
  });
}

module.exports = {
  listPackages: listPackages,
  createPackage: createPackage,
  updatePackage: updatePackage,
  softDeletePackage: softDeletePackage,
  assignSubscriptionInApp: assignSubscriptionInApp,
  assignSubscription: assignSubscription,
  getOrgSubscription: getOrgSubscription,
  getPayInfo: getPayInfo,
  submitPayment: submitPayment,
  listPendingPayments: listPendingPayments,
  reviewPayment: reviewPayment,
  unlockOrganization: unlockOrganization,
  lockOrganization: lockOrganization,
  getBillingSettings: getBillingSettings,
  updateBillingSettings: updateBillingSettings,
  runDailyBillingJob: runDailyBillingJob,
  listOrganizationPlatformStatsEnriched: listOrganizationPlatformStatsEnriched,
  requireSystemAdmin: requireSystemAdmin,
  hasPermission: orgHelpers.hasPermission
};
