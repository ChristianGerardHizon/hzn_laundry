// Ready-for-pickup email body builder + Resend send.
// NOT .pb.js — require()d from the order notifications dispatcher.
// ES5 only — no const, let, arrow functions, or async/await.

function buildReadyPickupEmail(opts) {
  var brand = opts.brand || "HZN Laundry";
  var customerName = opts.customerName || "Customer";
  var receiptNumber = opts.receiptNumber || "";
  var historyLink = opts.historyLink || "";

  var emailLayout = require(__hooks + "/lib/email_layout.js");

  var preheader = "Your laundry order is ready to pick up.";
  var intro =
    "Good news — your laundry order is ready for pickup. Please visit us to claim your order.";

  var rows = [
    { label: "Receipt", value: receiptNumber || "—" },
    {
      label: "Status",
      valueHtml: emailLayout.pill("Ready", "ok")
    }
  ];
  if (opts.branchName) {
    rows.push({ label: "Branch", value: opts.branchName });
  }

  var button = null;
  if (historyLink) {
    button = { label: "View my orders", url: historyLink };
  }

  var html = emailLayout.renderEmail({
    brand: brand,
    preheader: preheader,
    title: "Hi " + customerName + ",",
    intro: intro,
    panelLabel: "Order details",
    rows: rows,
    button: button,
    note:
      "If you have questions about this order, please contact the shop directly."
  });

  var text =
    "Hi " + customerName + ",\n\n" +
    "Good news — your laundry order is ready for pickup. Please visit us to claim your order.\n\n" +
    "Order details:\n" +
    "  Receipt: " + (receiptNumber || "—") + "\n" +
    "  Status: Ready\n";
  if (opts.branchName) {
    text += "  Branch: " + opts.branchName + "\n";
  }
  text += "\n";
  if (historyLink) {
    text += "View your orders:\n" + historyLink + "\n\n";
  }
  text +=
    "If you have questions about this order, please contact the shop directly.\n\n" +
    brand;

  return {
    subject: brand + ": Order " + receiptNumber + " is ready for pickup",
    html: html,
    text: text
  };
}

function sendReadyPickupEmail(toEmail, opts) {
  var historyConfig = require(__hooks + "/send_history_link_config.js");
  var apiKey = $os.getenv("RESEND_API_KEY");
  if (!apiKey) {
    throw new Error("RESEND_API_KEY env var not set");
  }

  var body = buildReadyPickupEmail({
    brand: historyConfig.getAppDisplayName(),
    customerName: opts.customerName,
    receiptNumber: opts.receiptNumber,
    historyLink: opts.historyLink,
    branchName: opts.branchName
  });

  var res = $http.send({
    url: "https://api.resend.com/emails",
    method: "POST",
    headers: {
      Authorization: "Bearer " + apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: historyConfig.getFromEmail(),
      to: [toEmail],
      subject: body.subject,
      html: body.html,
      text: body.text
    }),
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
  buildReadyPickupEmail: buildReadyPickupEmail,
  sendReadyPickupEmail: sendReadyPickupEmail
};
