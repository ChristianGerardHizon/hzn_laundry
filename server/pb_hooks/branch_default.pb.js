/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Branch default (isDefault)
// ============================================================================
// Ensures at most one default branch per organization. When a branch is
// marked isDefault, clear the flag on siblings. On create, if the org has
// no default yet, mark the new branch as default.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

function clearOtherDefaultBranches(app, orgId, keepId) {
  if (!orgId) return;
  var others = [];
  try {
    others = app.findRecordsByFilter(
      "branches",
      "organization = {:org} && isDefault = true && id != {:id} && (isDeleted = false || isDeleted = null)",
      "",
      0,
      0,
      { org: orgId, id: keepId || "" }
    );
  } catch (_) {
    others = [];
  }
  var i;
  for (i = 0; i < others.length; i++) {
    try {
      others[i].set("isDefault", false);
      app.save(others[i]);
    } catch (err) {
      console.error(
        "[BRANCH_DEFAULT] Failed to clear isDefault on " + others[i].id + ":",
        err
      );
    }
  }
}

function orgHasDefaultBranch(app, orgId) {
  if (!orgId) return false;
  var rows = [];
  try {
    rows = app.findRecordsByFilter(
      "branches",
      "organization = {:org} && isDefault = true && (isDeleted = false || isDeleted = null)",
      "",
      1,
      0,
      { org: orgId }
    );
  } catch (_) {
    rows = [];
  }
  return rows && rows.length > 0;
}

onRecordCreate(function (e) {
  try {
    var orgId = e.record.getString("organization");
    if (e.record.getBool("isDefault")) {
      clearOtherDefaultBranches(e.app, orgId, e.record.id);
    } else if (!orgHasDefaultBranch(e.app, orgId)) {
      e.record.set("isDefault", true);
    }
  } catch (err) {
    console.error("[BRANCH_DEFAULT] onRecordCreate failed:", err);
  }
  e.next();
}, "branches");

onRecordUpdate(function (e) {
  try {
    if (e.record.getBool("isDefault")) {
      clearOtherDefaultBranches(
        e.app,
        e.record.getString("organization"),
        e.record.id
      );
    }
  } catch (err) {
    console.error("[BRANCH_DEFAULT] onRecordUpdate failed:", err);
  }
  e.next();
}, "branches");
