/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Send public order-view link email after a sale is created (Resend).
// Replaces the older customer-history link email for create-order.
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordAfterCreateSuccess(function (e) {
  console.log("[ORDER_VIEW] create-email fired for sale " + e.record.id);

  var customerId = e.record.getString("customer");
  if (!customerId) {
    console.log("[ORDER_VIEW] no customer linked, skipping");
    return;
  }

  var customer;
  try {
    customer = $app.findRecordById("customers", customerId);
  } catch (err) {
    console.error("[ORDER_VIEW] Customer not found: " + customerId, err);
    return;
  }

  var email = customer.getString("email");
  if (!email) {
    return;
  }

  var helpers = require(__hooks + "/lib/order_view_helpers.js");
  var token = helpers.ensureViewToken($app, e.record);
  if (!token) {
    console.error("[ORDER_VIEW] Failed to mint viewToken for sale " + e.record.id);
    return;
  }

  var link = helpers.buildOrderViewUrl(token);
  var orgName = helpers.resolveOrganizationName($app, e.record);
  var brand = helpers.brandWithEnv(orgName);
  var customerName = customer.getString("name") || "Customer";

  try {
    helpers.sendOrderViewEmail(email, {
      brand: brand,
      customerName: customerName,
      receiptNumber: e.record.getString("receiptNumber") || "",
      orderViewLink: link,
      branchName: helpers.resolveBranchName($app, e.record)
    });
    console.log("[ORDER_VIEW] Sent to " + email + " for sale " + e.record.id);
  } catch (err) {
    console.error("[ORDER_VIEW] Failed to send email:", err);
  }
}, "sales");
