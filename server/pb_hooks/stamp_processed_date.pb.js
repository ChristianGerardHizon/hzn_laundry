/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Stamp Processed Date Hook
// ============================================================================
// When an order's status first changes to "ready" or "pickedUp", stamp
// processedDate with today's UTC date (YYYY-MM-DD). Only sets it once —
// does not overwrite if already set, so the date reflects the first
// transition, not subsequent edits.
// ============================================================================

onRecordAfterUpdateSuccess(function(e) {
  try {
    var newStatus = e.record.get("orderStatus");
    var processedDate = e.record.get("processedDate");

    if ((newStatus === "ready" || newStatus === "pickedUp") && !processedDate) {
      var now = new Date();
      var year = now.getUTCFullYear();
      var month = String(now.getUTCMonth() + 1).padStart(2, "0");
      var day = String(now.getUTCDate()).padStart(2, "0");
      var dateStr = year + "-" + month + "-" + day + " 00:00:00.000Z";

      e.record.set("processedDate", dateStr);
      e.app.save(e.record);
    }
  } catch(err) {
    console.error("[STAMP_PROCESSED_DATE] error:", err);
  }
}, "sales");
