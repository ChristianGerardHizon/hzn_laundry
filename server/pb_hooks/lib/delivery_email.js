// Delivery order emails (ready / out for delivery / delivered) + Resend send.
// NOT .pb.js — require()d from the order notifications dispatcher.
// Pickup orders never use this file (see ready_pickup_email.js / picked_up_email.js).
// ES5 only — no const, let, arrow functions, or async/await.

var COPY = {
  ready: {
    preheader: "Your laundry order is ready for delivery.",
    intro:
      "Good news — your laundry order is ready and will be delivered to you soon.",
    pill: "Ready for Delivery",
    tone: "ok",
    subject: function (receipt, brand) {
      return brand + ": Order " + receipt + " is ready for delivery";
    }
  },
  forDelivery: {
    preheader: "Your laundry order is out for delivery.",
    intro: "Your laundry order is on its way — it is now out for delivery.",
    pill: "Out for Delivery",
    tone: "ok",
    subject: function (receipt, brand) {
      return brand + ": Order " + receipt + " is out for delivery";
    }
  },
  delivered: {
    preheader: "Your laundry order has been delivered.",
    intro:
      "Thank you — your laundry order has been delivered. We hope to see you again soon.",
    pill: "Delivered",
    tone: "ok",
    subject: function (receipt, brand) {
      return brand + ": Order " + receipt + " has been delivered";
    }
  }
};

function buildDeliveryEmail(event, opts) {
  var copy = COPY[event];
  var brand = opts.brand || "HZN Laundry";
  var customerName = opts.customerName || "Customer";
  var receiptNumber = opts.receiptNumber || "";
  var photoUrl = opts.photoUrl || "";
  var orderViewLink = opts.orderViewLink || "";

  var emailLayout = require(__hooks + "/lib/email_layout.js");

  var rows = [
    { label: "Receipt", value: receiptNumber || "—" },
    { label: "Status", valueHtml: emailLayout.pill(copy.pill, copy.tone) }
  ];
  if (opts.branchName) {
    rows.push({ label: "Branch", value: opts.branchName });
  }
  if (opts.deliveryAddress) {
    rows.push({ label: "Delivery address", value: opts.deliveryAddress });
  }

  // Order-view link CTA; the delivered email links the delivery photo instead
  // when there is one.
  var button = null;
  if (event === "delivered" && photoUrl) {
    button = { label: "View delivery photo", url: photoUrl };
  } else if (orderViewLink) {
    button = { label: "View order", url: orderViewLink };
  }

  var html = emailLayout.renderEmail({
    brand: brand,
    platformTag: "",
    signOff: false,
    disclaimer: "Generated using HZN Laundry System",
    preheader: copy.preheader,
    title: "Hi " + customerName + ",",
    intro: copy.intro,
    panelLabel: "Order details",
    rows: rows,
    button: button,
    note:
      "If you have questions about this order, please contact the shop directly."
  });

  var text =
    "Hi " + customerName + ",\n\n" +
    copy.intro + "\n\n" +
    "Order details:\n" +
    "  Receipt: " + (receiptNumber || "—") + "\n" +
    "  Status: " + copy.pill + "\n";
  if (opts.branchName) text += "  Branch: " + opts.branchName + "\n";
  if (opts.deliveryAddress) {
    text += "  Delivery address: " + opts.deliveryAddress + "\n";
  }
  text += "\n";
  if (event === "delivered" && photoUrl) {
    text += "Delivery photo:\n" + photoUrl + "\n\n";
  }
  if (orderViewLink) {
    text += "View order:\n" + orderViewLink + "\n\n";
  }
  text +=
    "If you have questions about this order, please contact the shop directly.\n\n" +
    "Generated using HZN Laundry System";

  return {
    subject: copy.subject(receiptNumber, brand),
    html: html,
    text: text
  };
}

function sendDeliveryEmail(event, toEmail, opts) {
  var historyConfig = require(__hooks + "/send_history_link_config.js");
  var apiKey = $os.getenv("RESEND_API_KEY");
  if (!apiKey) {
    throw new Error("RESEND_API_KEY env var not set");
  }

  var content = buildDeliveryEmail(event, {
    brand: opts.brand || historyConfig.getAppDisplayName(),
    customerName: opts.customerName,
    receiptNumber: opts.receiptNumber,
    orderViewLink: opts.orderViewLink,
    branchName: opts.branchName,
    deliveryAddress: opts.deliveryAddress,
    photoUrl: opts.photoUrl
  });

  var payload = {
    from: historyConfig.getFromEmail(),
    to: [toEmail],
    subject: content.subject,
    html: content.html,
    text: content.text
  };
  // Optional delivery photo: Resend fetches it from the (public) file URL.
  if (event === "delivered" && opts.photoUrl) {
    payload.attachments = [
      { path: opts.photoUrl, filename: opts.photoFilename || "delivery-photo.jpg" }
    ];
  }

  var res = $http.send({
    url: "https://api.resend.com/emails",
    method: "POST",
    headers: {
      Authorization: "Bearer " + apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload),
    timeout: 15
  });

  if (res.statusCode >= 400) {
    throw new Error(
      "Resend API error " + res.statusCode + ": " + JSON.stringify(res.json)
    );
  }

  return res.json;
}

module.exports = {
  buildDeliveryEmail: buildDeliveryEmail,
  sendDeliveryEmail: sendDeliveryEmail
};
