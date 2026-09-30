/// <reference path="../../pb_data/types.d.ts" />

// Shared HTML layout for hook-sent emails (subscription reminder, invite,
// order-history link). Mirrors the sign-in OTP template stored on the users
// collection: dark header, teal accent bar, white card, gray info panel.
//
// Not a .pb.js file, so PocketBase does not auto-load it. Pure string
// building (no $app / $os), so it can be require()d from anywhere.
// ES5 only — no const, let, arrow functions, or async/await.
//
// NOTE: migration 1792400000_email_theme_templates.js inlines a copy of this
// layout for the PocketBase-managed templates (reset / verify / email change).
// Keep the two visually in sync.

var ACCENT = "#45A9AB";
var INK = "#0B0B0B";
var FONT = "Arial,Helvetica,sans-serif";

function escapeHtml(s) {
  if (s === null || s === undefined) return "";
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// Text pill, e.g. status. tone: "ok" | "warn" | "danger"
function pill(label, tone) {
  var bg = "#E6F4F4";
  var fg = "#1F6F71";
  if (tone === "warn") {
    bg = "#FEF3C7";
    fg = "#92400E";
  } else if (tone === "danger") {
    bg = "#FEE2E2";
    fg = "#991B1B";
  }
  return (
    "<span style=\"display:inline-block;padding:3px 10px;border-radius:999px;background-color:" +
    bg +
    ";color:" +
    fg +
    ";font-family:" +
    FONT +
    ";font-size:12px;font-weight:bold;line-height:1.4;\">" +
    escapeHtml(label) +
    "</span>"
  );
}

function paragraph(text, size, color) {
  return (
    "<p style=\"margin:0 0 20px;font-family:" +
    FONT +
    ";font-size:" +
    (size || 15) +
    "px;color:" +
    (color || "#4B5563") +
    ";line-height:1.6;\">" +
    escapeHtml(text) +
    "</p>"
  );
}

// Gray info panel. rows: [{ label, value, valueHtml }]. valueHtml is trusted.
// extraHtml is trusted HTML shown under the rows (e.g. a bullet list).
function infoPanel(label, rows, extraHtml) {
  var out =
    "<table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"border-collapse:collapse;margin:0 0 20px;\">" +
    "<tr><td style=\"background-color:#F9FAFB;border:1px solid #E5E7EB;border-radius:8px;padding:18px 16px;\">";
  if (label) {
    out +=
      "<p style=\"margin:0 0 10px;font-family:" +
      FONT +
      ";font-size:12px;letter-spacing:0.04em;text-transform:uppercase;color:#6B7280;\">" +
      escapeHtml(label) +
      "</p>";
  }
  if (rows && rows.length) {
    out +=
      "<table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"border-collapse:collapse;\">";
    var i;
    for (i = 0; i < rows.length; i++) {
      var r = rows[i];
      var border = i === 0 ? "" : "border-top:1px solid #E5E7EB;";
      out +=
        "<tr>" +
        "<td valign=\"top\" style=\"padding:8px 12px 8px 0;" +
        border +
        "font-family:" +
        FONT +
        ";font-size:13px;color:#6B7280;line-height:1.5;\">" +
        escapeHtml(r.label) +
        "</td>" +
        "<td valign=\"top\" align=\"right\" style=\"padding:8px 0;" +
        border +
        "font-family:" +
        FONT +
        ";font-size:14px;font-weight:bold;color:" +
        INK +
        ";line-height:1.5;\">" +
        (r.valueHtml !== undefined ? r.valueHtml : escapeHtml(r.value)) +
        "</td></tr>";
    }
    out += "</table>";
  }
  if (extraHtml) out += extraHtml;
  out += "</td></tr></table>";
  return out;
}

// Bullet list for use inside an info panel.
function bulletList(items) {
  var out =
    "<ul style=\"margin:0;padding-left:20px;font-family:" +
    FONT +
    ";font-size:14px;color:#4B5563;line-height:1.7;\">";
  var i;
  for (i = 0; i < items.length; i++) {
    out += "<li>" + escapeHtml(items[i]) + "</li>";
  }
  return out + "</ul>";
}

// Teal button with dark text (about 7:1 contrast; white on teal is only ~2.9:1).
function button(label, url) {
  var safeUrl = escapeHtml(url);
  return (
    "<table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"border-collapse:collapse;margin:0 0 20px;\">" +
    "<tr><td align=\"center\" bgcolor=\"" +
    ACCENT +
    "\" style=\"background-color:" +
    ACCENT +
    ";border-radius:8px;\">" +
    "<a href=\"" +
    safeUrl +
    "\" target=\"_blank\" style=\"display:inline-block;padding:14px 28px;font-family:" +
    FONT +
    ";font-size:15px;font-weight:bold;color:" +
    INK +
    ";text-decoration:none;border-radius:8px;\">" +
    escapeHtml(label) +
    "</a></td></tr></table>"
  );
}

function fallbackLink(url) {
  var safeUrl = escapeHtml(url);
  return (
    "<p style=\"margin:0 0 4px;font-family:" +
    FONT +
    ";font-size:12px;color:#6B7280;line-height:1.5;\">Button not working? Paste this link into your browser:</p>" +
    "<p style=\"margin:0 0 20px;font-family:" +
    FONT +
    ";font-size:12px;line-height:1.5;word-break:break-all;\"><a href=\"" +
    safeUrl +
    "\" style=\"color:#2F7A7C;text-decoration:underline;\">" +
    safeUrl +
    "</a></p>"
  );
}

/**
 * opts: {
 *   brand,          // display name, e.g. "[Dev] HZN Laundry"
 *   preheader,      // hidden inbox preview text
 *   title,          // H1
 *   intro,          // paragraph under the title (plain text)
 *   panelLabel,     // optional uppercase label for the info panel
 *   rows,           // optional [{ label, value | valueHtml }]
 *   panelExtraHtml, // optional trusted HTML inside the panel
 *   button,         // optional { label, url }
 *   note,           // optional small muted paragraph (plain text)
 *   footerNote      // optional extra sentence in the disclaimer (plain text)
 * }
 * Returns an HTML string.
 */
function renderEmail(opts) {
  var brand = opts.brand || "HZN Laundry";
  var safeBrand = escapeHtml(brand);
  var body = "";

  body +=
    "<h1 style=\"margin:0 0 12px;font-family:" +
    FONT +
    ";font-size:20px;font-weight:bold;color:#111827;line-height:1.35;\">" +
    escapeHtml(opts.title) +
    "</h1>";
  if (opts.intro) body += paragraph(opts.intro, 15, "#4B5563");
  if ((opts.rows && opts.rows.length) || opts.panelExtraHtml) {
    body += infoPanel(opts.panelLabel, opts.rows, opts.panelExtraHtml);
  }
  if (opts.button) {
    body += button(opts.button.label, opts.button.url);
    body += fallbackLink(opts.button.url);
  }
  if (opts.note) {
    body +=
      "<p style=\"margin:0;font-family:" +
      FONT +
      ";font-size:14px;color:#6B7280;line-height:1.6;\">" +
      escapeHtml(opts.note) +
      "</p>";
  }

  var disclaimer =
    "This is an automated transactional message from HZN systems regarding your " +
    safeBrand +
    " account. Please do not reply to this email.";
  if (opts.footerNote) {
    disclaimer = escapeHtml(opts.footerNote) + " " + disclaimer;
  }

  return (
    "<!DOCTYPE html>\r\n" +
    "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\">\r\n" +
    "<head>\r\n" +
    "  <meta charset=\"utf-8\">\r\n" +
    "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\r\n" +
    "  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\r\n" +
    "  <meta name=\"x-apple-disable-message-reformatting\">\r\n" +
    "  <meta name=\"format-detection\" content=\"telephone=no,address=no,email=no,date=no,url=no\">\r\n" +
    "  <title>" +
    escapeHtml(opts.title) +
    "</title>\r\n" +
    "</head>\r\n" +
    "<body style=\"margin:0;padding:0;background-color:#F4F5F7;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;\">\r\n" +
    "  <div style=\"display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;\">" +
    escapeHtml(opts.preheader || opts.title) +
    "</div>\r\n" +
    "  <table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"background-color:#F4F5F7;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;\">\r\n" +
    "    <tr><td align=\"center\" style=\"padding:32px 16px;\">\r\n" +
    "      <table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"max-width:600px;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;\">\r\n" +
    "        <tr><td style=\"background-color:" +
    INK +
    ";padding:20px 28px;border-radius:8px 8px 0 0;\">\r\n" +
    "          <p style=\"margin:0;font-family:" +
    FONT +
    ";font-size:16px;font-weight:bold;color:#FFFFFF;line-height:1.3;\">" +
    safeBrand +
    "</p>\r\n" +
    "          <p style=\"margin:2px 0 0;font-family:" +
    FONT +
    ";font-size:12px;color:" +
    ACCENT +
    ";line-height:1.3;\">HZN systems</p>\r\n" +
    "        </td></tr>\r\n" +
    "        <tr><td style=\"height:3px;line-height:3px;font-size:3px;background-color:" +
    ACCENT +
    ";\">&nbsp;</td></tr>\r\n" +
    "        <tr><td style=\"background-color:#FFFFFF;padding:32px 28px;border-left:1px solid #E5E7EB;border-right:1px solid #E5E7EB;\">\r\n" +
    body +
    "\r\n        </td></tr>\r\n" +
    "        <tr><td style=\"background-color:#FFFFFF;padding:20px 28px 28px;border:1px solid #E5E7EB;border-top:0;border-radius:0 0 8px 8px;\">\r\n" +
    "          <p style=\"margin:0 0 8px;font-family:" +
    FONT +
    ";font-size:13px;color:#6B7280;line-height:1.5;\">Kind regards,<br>The " +
    safeBrand +
    " team</p>\r\n" +
    "          <p style=\"margin:16px 0 0;padding-top:16px;border-top:1px solid #F3F4F6;font-family:" +
    FONT +
    ";font-size:11px;color:#9CA3AF;line-height:1.5;\">" +
    disclaimer +
    "</p>\r\n" +
    "        </td></tr>\r\n" +
    "      </table>\r\n" +
    "    </td></tr>\r\n" +
    "  </table>\r\n" +
    "</body>\r\n</html>"
  );
}

module.exports = {
  escapeHtml: escapeHtml,
  pill: pill,
  bulletList: bulletList,
  renderEmail: renderEmail
};
