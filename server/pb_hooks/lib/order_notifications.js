// Channel-ready order notification dispatcher.
// NOT .pb.js — require()d from order status notification hooks.
// ES5 only — no const, let, arrow functions, or async/await.
//
// Channels today: email. Future: sms (see TODO below).
// Events: ready | pickedUp

function isDateSet(value) {
  if (!value) return false;
  if (typeof value.isZero === "function") {
    return !value.isZero();
  }
  return !!value;
}

function nowIsoUtc() {
  return new Date().toISOString().replace("T", " ").substring(0, 19) + ".000Z";
}

function resolveChannels(customer) {
  var channels = [];
  var email = customer.getString("email");
  if (email) {
    channels.push("email");
  }
  // TODO: When SMS is enabled, also push "sms" when customer has a phone.
  return channels;
}

function ensureHistoryLink(app, customer) {
  var historyConfig = require(__hooks + "/send_history_link_config.js");
  var token = customer.getString("historyToken");
  var expiresAt = customer.getString("historyTokenExpiresAt");
  var tokenChanged = false;

  if (!token || historyConfig.isExpired(expiresAt)) {
    token = historyConfig.generateToken();
    customer.set("historyToken", token);
    customer.set("historyTokenExpiresAt", historyConfig.getExpiryDateString());
    tokenChanged = true;
  } else {
    customer.set("historyTokenExpiresAt", historyConfig.getExpiryDateString());
    tokenChanged = true;
  }

  if (tokenChanged) {
    try {
      app.save(customer);
    } catch (err) {
      console.error("[ORDER_NOTIFY] Failed to save customer token:", err);
      return "";
    }
  }

  return historyConfig.getAppBaseUrl() + "/history/" + token;
}

function resolveBranchName(app, sale) {
  var branchId = sale.getString("branch");
  if (!branchId) return "";
  try {
    var branch = app.findRecordById("branches", branchId);
    return branch.getString("name") || "";
  } catch (err) {
    return "";
  }
}

function resolveHistoryLink(app, customer) {
  try {
    var entitlements = require(__hooks + "/lib/feature_entitlements_helpers.js");
    if (entitlements.isCustomerHistoryEntitled(app, customer)) {
      return ensureHistoryLink(app, customer);
    }
  } catch (err) {
    console.error("[ORDER_NOTIFY] history link entitlement check failed:", err);
  }
  return "";
}

function emailPayload(app, sale, customer) {
  return {
    customerName: customer.getString("name") || "Customer",
    receiptNumber: sale.getString("receiptNumber") || "",
    historyLink: resolveHistoryLink(app, customer),
    branchName: resolveBranchName(app, sale)
  };
}

function sendReadyEmailChannel(app, sale, customer) {
  var readyEmail = require(__hooks + "/lib/ready_pickup_email.js");
  var email = customer.getString("email");
  if (!email) return false;
  readyEmail.sendReadyPickupEmail(email, emailPayload(app, sale, customer));
  return true;
}

function sendPickedUpEmailChannel(app, sale, customer) {
  var pickedUpEmail = require(__hooks + "/lib/picked_up_email.js");
  var email = customer.getString("email");
  if (!email) return false;
  pickedUpEmail.sendPickedUpEmail(email, emailPayload(app, sale, customer));
  return true;
}

// TODO: Implement SMS channel (Twilio or similar) when product is ready.
function sendSmsChannel(app, sale, customer, event) {
  console.log(
    "[ORDER_NOTIFY] SMS channel not implemented (" +
      event +
      "); skipping for sale " +
      sale.id
  );
  return false;
}

function dispatchChannels(app, sale, customer, event) {
  var channels = resolveChannels(customer);
  if (!channels.length) {
    console.log("[ORDER_NOTIFY] no channels available for sale " + sale.id);
    return false;
  }

  var anySent = false;
  var i;
  for (i = 0; i < channels.length; i++) {
    var channel = channels[i];
    try {
      if (channel === "email") {
        var emailOk =
          event === "pickedUp"
            ? sendPickedUpEmailChannel(app, sale, customer)
            : sendReadyEmailChannel(app, sale, customer);
        if (emailOk) anySent = true;
      } else if (channel === "sms") {
        if (sendSmsChannel(app, sale, customer, event)) {
          anySent = true;
        }
      }
    } catch (err) {
      console.error(
        "[ORDER_NOTIFY] " +
          channel +
          " (" +
          event +
          ") failed for sale " +
          sale.id +
          ":",
        err
      );
    }
  }
  return anySent;
}

function notifyOrderReady(app, sale, customer) {
  return dispatchChannels(app, sale, customer, "ready");
}

function notifyOrderPickedUp(app, sale, customer) {
  return dispatchChannels(app, sale, customer, "pickedUp");
}

function stampReadyNotificationSent(app, sale) {
  sale.set("readyNotificationSentAt", nowIsoUtc());
  sale.set("resendReadyNotification", false);
  app.save(sale);
}

function stampPickedUpNotificationSent(app, sale) {
  sale.set("pickedUpNotificationSentAt", nowIsoUtc());
  sale.set("resendPickedUpNotification", false);
  app.save(sale);
}

// Back-compat alias used by earlier ready-only hook.
function stampNotificationSent(app, sale) {
  stampReadyNotificationSent(app, sale);
}

module.exports = {
  isDateSet: isDateSet,
  resolveChannels: resolveChannels,
  notifyOrderReady: notifyOrderReady,
  notifyOrderPickedUp: notifyOrderPickedUp,
  stampReadyNotificationSent: stampReadyNotificationSent,
  stampPickedUpNotificationSent: stampPickedUpNotificationSent,
  stampNotificationSent: stampNotificationSent
};
