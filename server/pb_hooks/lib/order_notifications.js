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

function resolveOrderViewLink(app, sale) {
  try {
    var helpers = require(__hooks + "/lib/order_view_helpers.js");
    var token = helpers.ensureViewToken(app, sale);
    if (!token) return "";
    return helpers.buildOrderViewUrl(token);
  } catch (err) {
    console.error("[ORDER_NOTIFY] order view link failed:", err);
    return "";
  }
}

function emailPayload(app, sale, customer) {
  var helpers = require(__hooks + "/lib/order_view_helpers.js");
  var orgName = helpers.resolveOrganizationName(app, sale);
  return {
    brand: helpers.brandWithEnv(orgName),
    customerName: customer.getString("name") || "Customer",
    receiptNumber: sale.getString("receiptNumber") || "",
    orderViewLink: resolveOrderViewLink(app, sale),
    branchName: helpers.resolveBranchName(app, sale)
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
