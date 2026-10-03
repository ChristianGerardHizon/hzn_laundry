/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Delivery defaults (isDefault)
// ============================================================================
// branchDeliveryRates (per branch) and customerAddresses (per customer) each
// keep exactly one default among their non-deleted rows:
//   - the first row created becomes the default automatically
//   - marking a row default clears the flag on its siblings
//   - deleting (isDeleted) the default promotes the oldest remaining row
//
// Helpers are written inline in each handler (goja scope isolation: top-level
// functions are not visible inside handlers).
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordCreate(function (e) {
  try {
    var parentField = e.record.collection().name === "branchDeliveryRates" ? "branch" : "customer";
    var collection = e.record.collection().name;
    var parentId = e.record.getString(parentField);
    if (parentId && !e.record.getBool("isDeleted")) {
      var existing = [];
      try {
        existing = $app.findRecordsByFilter(
          collection,
          parentField + " = {:p} && isDefault = true && (isDeleted = false || isDeleted = null)",
          "",
          1,
          0,
          { p: parentId }
        );
      } catch (_) {
        existing = [];
      }
      if (!existing || existing.length === 0) {
        e.record.set("isDefault", true);
      }
    }
  } catch (err) {
    console.error("[DELIVERY_DEFAULTS] create failed:", err);
  }
  e.next();

  // After save: a new default clears its siblings.
  try {
    var coll = e.record.collection().name;
    var pf = coll === "branchDeliveryRates" ? "branch" : "customer";
    var pid = e.record.getString(pf);
    if (pid && e.record.getBool("isDefault")) {
      var others = $app.findRecordsByFilter(
        coll,
        pf + " = {:p} && isDefault = true && id != {:id} && (isDeleted = false || isDeleted = null)",
        "",
        0,
        0,
        { p: pid, id: e.record.id }
      );
      for (var i = 0; i < others.length; i++) {
        others[i].set("isDefault", false);
        $app.save(others[i]);
      }
    }
  } catch (err2) {
    console.error("[DELIVERY_DEFAULTS] clear siblings failed:", err2);
  }
}, "branchDeliveryRates", "customerAddresses");

onRecordUpdate(function (e) {
  var coll = e.record.collection().name;
  var pf = coll === "branchDeliveryRates" ? "branch" : "customer";
  var pid = e.record.getString(pf);
  var wasDeletedNow = e.record.getBool("isDeleted");

  // A deleted row can't stay the default.
  var needPromote = false;
  if (wasDeletedNow && e.record.getBool("isDefault")) {
    e.record.set("isDefault", false);
    needPromote = true;
  }

  e.next();

  try {
    if (!pid) return;
    if (e.record.getBool("isDefault") && !wasDeletedNow) {
      // New default: clear siblings.
      var others = $app.findRecordsByFilter(
        coll,
        pf + " = {:p} && isDefault = true && id != {:id} && (isDeleted = false || isDeleted = null)",
        "",
        0,
        0,
        { p: pid, id: e.record.id }
      );
      for (var i = 0; i < others.length; i++) {
        others[i].set("isDefault", false);
        $app.save(others[i]);
      }
    } else if (needPromote) {
      // Promote the oldest remaining row so there is still a default.
      var remaining = $app.findRecordsByFilter(
        coll,
        pf + " = {:p} && id != {:id} && (isDeleted = false || isDeleted = null)",
        "created",
        1,
        0,
        { p: pid, id: e.record.id }
      );
      if (remaining && remaining.length > 0) {
        remaining[0].set("isDefault", true);
        $app.save(remaining[0]);
      }
    }
  } catch (err) {
    console.error("[DELIVERY_DEFAULTS] update failed:", err);
  }
}, "branchDeliveryRates", "customerAddresses");
