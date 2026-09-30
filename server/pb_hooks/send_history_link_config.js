// send_history_link_config.js — shared config for history link email
// NOT .pb.js so it won't auto-load as a hook

// Resend API key. Set RESEND_API_KEY env var before starting PocketBase.
function getResendApiKey() {
  var key = $os.getenv("RESEND_API_KEY");
  if (!key) {
    throw new Error("RESEND_API_KEY env var not set");
  }
  return key;
}

// Public app URL used in the email link
function getAppBaseUrl() {
  var url = $os.getenv("APP_BASE_URL");
  if (!url) {
    url = "https://hznlaundry.hznsystems.com";
  }
  return url;
}

// Env-tagged brand name for email header / From / subject.
// prod: "HZN Laundry"; staging: "[Staging] HZN Laundry"; dev/local: "[Dev] HZN Laundry"
function getAppDisplayName() {
  var env = String($os.getenv("APP_ENV") || "").toLowerCase();
  if (env === "staging" || env === "stage") {
    return "[Staging] HZN Laundry";
  }
  if (env === "dev" || env === "development" || env === "local") {
    return "[Dev] HZN Laundry";
  }
  if (env === "prod" || env === "production") {
    return "HZN Laundry";
  }
  var url = String($os.getenv("APP_BASE_URL") || "").toLowerCase();
  if (url.indexOf("staging.") >= 0) {
    return "[Staging] HZN Laundry";
  }
  if (url.indexOf("127.0.0.1") >= 0 || url.indexOf("localhost") >= 0) {
    return "[Dev] HZN Laundry";
  }
  return "HZN Laundry";
}

// "From" address for transactional emails (must be a verified domain in Resend).
// Display name always follows getAppDisplayName(); address from RESEND_FROM_EMAIL or default.
function getFromEmail() {
  var name = getAppDisplayName();
  var v = $os.getenv("RESEND_FROM_EMAIL");
  if (!v) {
    return name + " <noreply@hznsystems.com>";
  }
  var m = String(v).match(/^(.+?)\s*<([^>]+)>\s*$/);
  if (m) {
    return name + " <" + m[2] + ">";
  }
  return name + " <" + v + ">";
}

// Token lifetime in days
var TOKEN_TTL_DAYS = 90;

// Generate 32-byte hex token using PB's $security helpers
function generateToken() {
  // $security.randomStringWithAlphabet for hex chars
  return $security.randomStringWithAlphabet(64, "0123456789abcdef");
}

// Returns ISO date string TOKEN_TTL_DAYS days from now (UTC)
function getExpiryDateString() {
  var now = new Date();
  now.setUTCDate(now.getUTCDate() + TOKEN_TTL_DAYS);
  return now.toISOString().replace("T", " ").substring(0, 19) + ".000Z";
}

// Returns true if expiresAt (string or empty) is in the past or missing
function isExpired(expiresAtStr) {
  if (!expiresAtStr) return true;
  var expires = new Date(expiresAtStr);
  if (isNaN(expires.getTime())) return true;
  return expires.getTime() <= Date.now();
}

// Escape user-provided strings for safe HTML embedding.
function escapeHtml(s) {
  if (s === null || s === undefined) return "";
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// Build a transactional email body (HTML + plain text).
function buildEmail(customerName, link) {
  var brand = getAppDisplayName();

  var preheader = "View your laundry order history and check pending or unpaid orders.";

  var emailLayout = require(__hooks + "/lib/email_layout.js");
  var html = emailLayout.renderEmail({
    brand: brand,
    preheader: preheader,
    title: "Hi " + customerName + ",",
    intro: "Thanks for choosing " + brand + ". Track your laundry orders, see what is pending, and check any outstanding balances using your personal order history link below.",
    panelLabel: "What you can do",
    panelExtraHtml: emailLayout.bulletList([
      "See all your orders in one place",
      "Track status: pending, processing, ready, picked up",
      "Check unpaid balances",
      "View receipts and order details"
    ]),
    button: { label: "View my orders", url: link },
    note: "This link is private to you \u2014 please do not share it. It expires after 90 days of inactivity but is refreshed every time you place a new order."
  });

  var text =
    "Hi " + customerName + ",\n\n" +
    "Thanks for choosing " + brand + ". View your order history, track status, and check outstanding balances here:\n\n" +
    link + "\n\n" +
    "What you can do:\n" +
    "  - See all your orders in one place\n" +
    "  - Track status: pending, processing, ready, picked up\n" +
    "  - Check unpaid balances\n" +
    "  - View receipts and order details\n\n" +
    "This link is private to you — please do not share it. It expires after 90 days of inactivity but is refreshed every time you place a new order.\n\n" +
    brand;

  return { html: html, text: text };
}

// Send email via Resend
function sendHistoryLinkEmail(toEmail, customerName, link) {
  var apiKey = getResendApiKey();
  var brand = getAppDisplayName();
  var body = buildEmail(customerName, link);

  var res = $http.send({
    url: "https://api.resend.com/emails",
    method: "POST",
    headers: {
      "Authorization": "Bearer " + apiKey,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: getFromEmail(),
      to: [toEmail],
      subject: "Your " + brand + " order history",
      html: body.html,
      text: body.text
    }),
    timeout: 15
  });

  if (res.statusCode >= 400) {
    throw new Error("Resend API error " + res.statusCode + ": " + JSON.stringify(res.json));
  }

  return res.json;
}

module.exports = {
  generateToken: generateToken,
  getExpiryDateString: getExpiryDateString,
  isExpired: isExpired,
  sendHistoryLinkEmail: sendHistoryLinkEmail,
  getAppBaseUrl: getAppBaseUrl,
  getAppDisplayName: getAppDisplayName,
  getFromEmail: getFromEmail,
  TOKEN_TTL_DAYS: TOKEN_TTL_DAYS
};
