/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Send order status notifications (Ready + Picked Up)
// Email now; SMS later via order_notifications dispatcher.
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

function clearResendFlags(record, clearReady, clearPickedUp) {
  try {
    if (clearReady) record.set("resendReadyNotification", false);
    if (clearPickedUp) record.set("resendPickedUpNotification", false);
    $app.save(record);
  } catch (clearErr) {
    console.error("[ORDER_NOTIFY] failed to clear resend flag:", clearErr);
  }
}

onRecordAfterUpdateSuccess(function(e) {
  var notifier;
  try {
    notifier = require(__hooks + "/lib/order_notifications.js");
  } catch (err) {
    console.error("[ORDER_NOTIFY] notifier require failed:", err);
    return;
  }

  var wantsResendReady = e.record.getBool("resendReadyNotification");
  var wantsResendPickedUp = e.record.getBool("resendPickedUpNotification");
  var sendNotification = e.record.getBool("sendNotification");

  if (!sendNotification) {
    if (wantsResendReady || wantsResendPickedUp) {
      clearResendFlags(e.record, wantsResendReady, wantsResendPickedUp);
    }
    return;
  }

  var oldStatus = "";
  try {
    oldStatus = String(e.record.original().get("orderStatus") || "");
  } catch (err) {
    oldStatus = "";
  }
  var newStatus = e.record.getString("orderStatus");

  var transitionedToReady = oldStatus !== "ready" && newStatus === "ready";
  var transitionedToPickedUp =
    oldStatus !== "pickedUp" && newStatus === "pickedUp";

  var alreadyReadySent = notifier.isDateSet(
    e.record.get("readyNotificationSentAt")
  );
  var alreadyPickedUpSent = notifier.isDateSet(
    e.record.get("pickedUpNotificationSentAt")
  );

  var shouldSendReady =
    (transitionedToReady && (!alreadyReadySent || wantsResendReady)) ||
    (wantsResendReady && !transitionedToPickedUp);
  var shouldSendPickedUp =
    (transitionedToPickedUp && (!alreadyPickedUpSent || wantsResendPickedUp)) ||
    (wantsResendPickedUp && !transitionedToReady);

  // Prefer the status transition of this update when both flags are somehow set.
  if (transitionedToReady) {
    shouldSendPickedUp = false;
  } else if (transitionedToPickedUp) {
    shouldSendReady = false;
  }

  if (!shouldSendReady && !shouldSendPickedUp) {
    if (transitionedToReady && alreadyReadySent && !wantsResendReady) {
      console.log(
        "[ORDER_NOTIFY] ready already sent for sale " + e.record.id + ", skipping"
      );
    }
    if (transitionedToPickedUp && alreadyPickedUpSent && !wantsResendPickedUp) {
      console.log(
        "[ORDER_NOTIFY] pickedUp already sent for sale " +
          e.record.id +
          ", skipping"
      );
    }
    return;
  }

  var event = shouldSendPickedUp ? "pickedUp" : "ready";
  var wantsResend = event === "pickedUp" ? wantsResendPickedUp : wantsResendReady;
  var logTag = event === "pickedUp" ? "[PICKED_UP_NOTIFY]" : "[READY_NOTIFY]";

  var customerId = e.record.getString("customer");
  if (!customerId) {
    console.log(logTag + " no customer linked, skipping");
    if (wantsResend) {
      clearResendFlags(
        e.record,
        event === "ready",
        event === "pickedUp"
      );
    }
    return;
  }

  var customer;
  try {
    customer = $app.findRecordById("customers", customerId);
  } catch (err) {
    console.error(logTag + " Customer not found: " + customerId, err);
    if (wantsResend) {
      clearResendFlags(
        e.record,
        event === "ready",
        event === "pickedUp"
      );
    }
    return;
  }

  var email = customer.getString("email");
  if (!email) {
    console.log(logTag + " no customer email, skipping");
    if (wantsResend) {
      clearResendFlags(
        e.record,
        event === "ready",
        event === "pickedUp"
      );
    }
    return;
  }

  try {
    var sent =
      event === "pickedUp"
        ? notifier.notifyOrderPickedUp($app, e.record, customer)
        : notifier.notifyOrderReady($app, e.record, customer);

    if (sent) {
      if (event === "pickedUp") {
        notifier.stampPickedUpNotificationSent($app, e.record);
      } else {
        notifier.stampReadyNotificationSent($app, e.record);
      }
      console.log(logTag + " Sent to " + email + " for sale " + e.record.id);
    } else if (wantsResend) {
      clearResendFlags(
        e.record,
        event === "ready",
        event === "pickedUp"
      );
    }
  } catch (err) {
    console.error(logTag + " Failed for sale " + e.record.id + ":", err);
    if (wantsResend) {
      clearResendFlags(
        e.record,
        event === "ready",
        event === "pickedUp"
      );
    }
  }
}, "sales");
