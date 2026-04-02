/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Sync Customer Name to Sales
// ============================================================================
// When a customer's name is updated, propagate the change to all sales
// records linked to that customer so order lists always show the current name.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordAfterUpdateSuccess(function(e) {
  var oldName = e.record.original().getString("name");
  var newName = e.record.getString("name");

  // Only run when the name actually changed
  if (oldName === newName) {
    return;
  }

  var customerId = e.record.id;

  console.log(
    "[SYNC_CUSTOMER_NAME] Customer " + customerId +
    " name changed: \"" + oldName + "\" -> \"" + newName + "\""
  );

  // Find all sales linked to this customer
  var sales = [];
  try {
    sales = $app.findRecordsByFilter(
      "sales",
      "customer = {:customerId}",
      "",   // sort
      0,    // limit (0 = all)
      0,    // offset
      { "customerId": customerId }
    );
  } catch (err) {
    console.error("[SYNC_CUSTOMER_NAME] Error finding sales:", err);
    return;
  }

  if (!sales || sales.length === 0) {
    console.log("[SYNC_CUSTOMER_NAME] No sales found for customer " + customerId);
    return;
  }

  console.log("[SYNC_CUSTOMER_NAME] Updating " + sales.length + " sale(s)");

  for (var i = 0; i < sales.length; i++) {
    try {
      sales[i].set("customerName", newName);
      $app.save(sales[i]);
    } catch (err) {
      console.error(
        "[SYNC_CUSTOMER_NAME] Failed to update sale " + sales[i].id + ":", err
      );
    }
  }
}, "customers");
