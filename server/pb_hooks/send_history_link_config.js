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
  var safeBrand = escapeHtml(brand);
  var safeName = escapeHtml(customerName);
  var safeLink = escapeHtml(link);

  var preheader = "View your laundry order history and check pending or unpaid orders.";

  var html =
    "<!DOCTYPE html>" +
    "<html lang=\"en\">" +
    "<head>" +
      "<meta charset=\"UTF-8\">" +
      "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
      "<meta name=\"x-apple-disable-message-reformatting\">" +
      "<title>" + safeBrand + "</title>" +
    "</head>" +
    "<body style=\"margin:0; padding:0; background-color:#f4f6f8; font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif; color:#1f2937;\">" +
      "<div style=\"display:none; max-height:0; overflow:hidden; opacity:0; color:transparent;\">" + escapeHtml(preheader) + "</div>" +
      "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:#f4f6f8;\">" +
        "<tr>" +
          "<td align=\"center\" style=\"padding:32px 12px;\">" +
            "<table role=\"presentation\" width=\"600\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"max-width:600px; width:100%; background-color:#ffffff; border-radius:12px; overflow:hidden; box-shadow:0 1px 3px rgba(16,24,40,0.08);\">" +
              // Header bar — brand teal (#45A9AB)
              "<tr>" +
                "<td style=\"background:#45A9AB; padding:28px 32px;\">" +
                  "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">" +
                    "<tr>" +
                      "<td style=\"color:#ffffff; font-size:20px; font-weight:700; letter-spacing:0.3px;\">" + safeBrand + "</td>" +
                      "<td align=\"right\" style=\"color:#e6f5f5; font-size:13px;\">Order History</td>" +
                    "</tr>" +
                  "</table>" +
                "</td>" +
              "</tr>" +
              // Body
              "<tr>" +
                "<td style=\"padding:32px;\">" +
                  "<h1 style=\"margin:0 0 16px; font-size:22px; line-height:1.3; color:#0f172a;\">Hi " + safeName + ",</h1>" +
                  "<p style=\"margin:0 0 16px; font-size:15px; line-height:1.6; color:#334155;\">Thanks for choosing " + safeBrand + ". You can now track your laundry orders, see what is pending, and check any outstanding balances using your personal order history link below.</p>" +
                  "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"margin:24px 0;\">" +
                    "<tr>" +
                      "<td align=\"center\">" +
                        "<a href=\"" + safeLink + "\" style=\"display:inline-block; background-color:#45A9AB; color:#ffffff; font-size:15px; font-weight:600; text-decoration:none; padding:14px 28px; border-radius:8px;\">View My Orders</a>" +
                      "</td>" +
                    "</tr>" +
                  "</table>" +
                  "<p style=\"margin:0 0 8px; font-size:13px; line-height:1.5; color:#64748b;\">Button not working? Paste this link into your browser:</p>" +
                  "<p style=\"margin:0 0 24px; font-size:13px; line-height:1.5; word-break:break-all;\">" +
                    "<a href=\"" + safeLink + "\" style=\"color:#2F7A7C; text-decoration:underline;\">" + safeLink + "</a>" +
                  "</p>" +
                  "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"margin:24px 0 0; background-color:#f8fafc; border-radius:8px;\">" +
                    "<tr>" +
                      "<td style=\"padding:16px 20px; font-size:13px; line-height:1.6; color:#475569;\">" +
                        "<strong style=\"color:#0f172a;\">What you can do:</strong>" +
                        "<ul style=\"margin:8px 0 0; padding-left:20px;\">" +
                          "<li>See all your orders in one place</li>" +
                          "<li>Track status: pending, processing, ready, picked up</li>" +
                          "<li>Check unpaid balances</li>" +
                          "<li>View receipts and order details</li>" +
                        "</ul>" +
                      "</td>" +
                    "</tr>" +
                  "</table>" +
                "</td>" +
              "</tr>" +
              // Footer
              "<tr>" +
                "<td style=\"background-color:#f8fafc; padding:20px 32px; border-top:1px solid #e2e8f0;\">" +
                  "<p style=\"margin:0 0 4px; font-size:12px; line-height:1.5; color:#64748b;\">This link is private to you — please do not share it. It expires after 90 days of inactivity but is refreshed every time you place a new order.</p>" +
                  "<p style=\"margin:8px 0 0; font-size:12px; line-height:1.5; color:#94a3b8;\">&copy; " + safeBrand + ". All rights reserved.</p>" +
                "</td>" +
              "</tr>" +
            "</table>" +
          "</td>" +
        "</tr>" +
      "</table>" +
    "</body>" +
    "</html>";

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
