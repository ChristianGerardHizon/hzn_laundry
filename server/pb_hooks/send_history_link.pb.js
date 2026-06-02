/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Send Customer Order History Link (Resend)
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordAfterCreateSuccess(function(e) {
  console.log("[HISTORY_LINK] fired for sale " + e.record.id);
  var config;
  try {
    config = require(__hooks + "/send_history_link_config.js");
  } catch (err) {
    console.error("[HISTORY_LINK] config require failed:", err);
    return;
  }

  var customerId = e.record.getString("customer");
  if (!customerId) {
    console.log("[HISTORY_LINK] no customer linked, skipping");
    return;
  }

  var customer;
  try {
    customer = $app.findRecordById("customers", customerId);
  } catch (err) {
    console.error("[HISTORY_LINK] Customer not found: " + customerId, err);
    return;
  }

  var email = customer.getString("email");
  if (!email) {
    return; // no email on file — nothing to send
  }

  var token = customer.getString("historyToken");
  var expiresAt = customer.getString("historyTokenExpiresAt");

  var tokenChanged = false;
  if (!token || config.isExpired(expiresAt)) {
    token = config.generateToken();
    customer.set("historyToken", token);
    customer.set("historyTokenExpiresAt", config.getExpiryDateString());
    tokenChanged = true;
  } else {
    // refresh expiry so active customers do not lose access
    customer.set("historyTokenExpiresAt", config.getExpiryDateString());
    tokenChanged = true;
  }

  if (tokenChanged) {
    try {
      $app.save(customer);
    } catch (err) {
      console.error("[HISTORY_LINK] Failed to save customer token:", err);
      return;
    }
  }

  var link = config.getAppBaseUrl() + "/history/" + token;
  var customerName = customer.getString("name") || "Customer";

  try {
    config.sendHistoryLinkEmail(email, customerName, link);
    console.log("[HISTORY_LINK] Sent to " + email + " for sale " + e.record.id);
  } catch (err) {
    console.error("[HISTORY_LINK] Failed to send email:", err);
  }
}, "sales");
