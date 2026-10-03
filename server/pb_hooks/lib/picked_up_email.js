// Order picked-up email body builder + Resend send.
// NOT .pb.js — require()d from the order notifications dispatcher.
// ES5 only — no const, let, arrow functions, or async/await.

function buildPickedUpEmail(opts) {
  var brand = opts.brand || "HZN Laundry";
  var customerName = opts.customerName || "Customer";
  var receiptNumber = opts.receiptNumber || "";
  var orderViewLink = opts.orderViewLink || opts.historyLink || "";

  var emailLayout = require(__hooks + "/lib/email_layout.js");

  var preheader = "Your laundry order has been picked up.";
  var intro =
    "Thank you — your laundry order has been marked as picked up. We hope to see you again soon.";

  var rows = [
    { label: "Receipt", value: receiptNumber || "—" },
    {
      label: "Status",
      valueHtml: emailLayout.pill("Picked Up", "ok")
    }
  ];
  if (opts.branchName) {
    rows.push({ label: "Branch", value: opts.branchName });
  }

  var button = null;
  if (orderViewLink) {
    button = { label: "View order", url: orderViewLink };
  }

  var html = emailLayout.renderEmail({
    brand: brand,
    platformTag: "",
    signOff: false,
    disclaimer: "Generated using HZN Laundry System",
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
    "Thank you — your laundry order has been marked as picked up. We hope to see you again soon.\n\n" +
    "Order details:\n" +
    "  Receipt: " + (receiptNumber || "—") + "\n" +
    "  Status: Picked Up\n";
  if (opts.branchName) {
    text += "  Branch: " + opts.branchName + "\n";
  }
  text += "\n";
  if (orderViewLink) {
    text += "View order:\n" + orderViewLink + "\n\n";
  }
  text +=
    "If you have questions about this order, please contact the shop directly.\n\n" +
    "Generated using HZN Laundry System";

  return {
    subject: brand + ": Order " + receiptNumber + " has been picked up",
    html: html,
    text: text
  };
}

function sendPickedUpEmail(toEmail, opts) {
  var historyConfig = require(__hooks + "/send_history_link_config.js");
  var apiKey = $os.getenv("RESEND_API_KEY");
  if (!apiKey) {
    throw new Error("RESEND_API_KEY env var not set");
  }

  var body = buildPickedUpEmail({
    brand: opts.brand || historyConfig.getAppDisplayName(),
    customerName: opts.customerName,
    receiptNumber: opts.receiptNumber,
    orderViewLink: opts.orderViewLink || opts.historyLink,
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
  buildPickedUpEmail: buildPickedUpEmail,
  sendPickedUpEmail: sendPickedUpEmail
};
