/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Stamp Processed Date Hook
// ============================================================================
// Stamps processedDate when an order transitions FROM "processing" to
// "ready" or "pickedUp". Only sets it once — does not overwrite if already
// set. Orders that skip the processing step (e.g. pending → ready) are
// excluded and will not count toward incentives.
// ============================================================================

onRecordAfterUpdateSuccess(function(e) {
  try {
    var oldStatus = e.record.original().get("orderStatus");
    var newStatus = e.record.get("orderStatus");
    var processedDate = e.record.get("processedDate");

    if (
      oldStatus === "processing" &&
      (newStatus === "ready" || newStatus === "pickedUp") &&
      !processedDate
    ) {
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
