/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Stamp Processed Date Hook
// ============================================================================
// Stamps processedDate whenever a sale reaches "ready" or "pickedUp" from
// any other status. Sets it once — never overwrites.
//
// Uses onRecordUpdate (pre-save) so the stamp is persisted as part of the
// same transaction — avoids re-save recursion.
//
// NOTE: record.get("processedDate") returns a DateTime object (truthy even
// when empty), so we must check .isZero() instead of JS falsiness.
// ============================================================================

onRecordUpdate(function(e) {
  try {
    var oldStatus = e.record.original().get("orderStatus");
    var newStatus = e.record.get("orderStatus");
    var processedDate = e.record.get("processedDate");
    var alreadyStamped = processedDate && typeof processedDate.isZero === "function"
      ? !processedDate.isZero()
      : !!processedDate;

    if (
      (newStatus === "ready" || newStatus === "pickedUp") &&
      oldStatus !== "ready" && oldStatus !== "pickedUp" &&
      !alreadyStamped
    ) {
      var now = new Date();
      var local = new Date(now.getTime() + 8 * 60 * 60 * 1000);
      var dateStr = local.getUTCFullYear() + "-" +
        String(local.getUTCMonth() + 1).padStart(2, "0") + "-" +
        String(local.getUTCDate()).padStart(2, "0") + " 00:00:00.000Z";

      e.record.set("processedDate", dateStr);
      console.log("[STAMP_PROCESSED_DATE] " + e.record.id + " -> " + dateStr);
    }
  } catch (err) {
    console.error("[STAMP_PROCESSED_DATE] error:", err);
  }

  e.next();
}, "sales");
