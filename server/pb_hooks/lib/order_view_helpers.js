/// <reference path="../../pb_data/types.d.ts" />

// Shared helpers for public order-view links (Cloudflare Pages + Turnstile).
// NOT .pb.js — require()d from public_order + email hooks.
// ES5 only — no const, let, arrow functions, or async/await.

var UNOPENED_TTL_DAYS = 90;
var OPENED_TTL_DAYS = 30;

function nowIsoUtc() {
  return new Date().toISOString().replace("T", " ").substring(0, 19) + ".000Z";
}

function addDaysIsoUtc(days) {
  var d = new Date();
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().replace("T", " ").substring(0, 19) + ".000Z";
}

function isExpired(expiresAtStr) {
  if (!expiresAtStr) return true;
  var expires = new Date(expiresAtStr);
  if (isNaN(expires.getTime())) return true;
  return expires.getTime() <= Date.now();
}

function generateToken() {
  return $security.randomStringWithAlphabet(64, "0123456789abcdef");
}

function getOrderViewBaseUrl() {
  var explicit = $os.getenv("ORDER_VIEW_BASE_URL");
  if (explicit) {
    return String(explicit).replace(/\/$/, "");
  }

  var env = String($os.getenv("APP_ENV") || "").toLowerCase();
  var staging = $os.getenv("ORDER_VIEW_BASE_URL_STAGING");
  var prod = $os.getenv("ORDER_VIEW_BASE_URL_PROD");

  if (env === "staging" || env === "stage" || env === "dev" || env === "development" || env === "local") {
    if (staging) return String(staging).replace(/\/$/, "");
  }
  if (prod) return String(prod).replace(/\/$/, "");
  if (staging) return String(staging).replace(/\/$/, "");
  return "https://hznlaundrysystem.pages.dev";
}

function buildOrderViewUrl(token) {
  return getOrderViewBaseUrl() + "/o/" + token;
}

function getAllowedOrigins() {
  var raw = $os.getenv("ORDER_VIEW_ORIGINS");
  if (raw) {
    return String(raw)
      .split(",")
      .map(function (s) {
        return s.trim();
      })
      .filter(function (s) {
        return !!s;
      });
  }
  return [
    "https://hznlaundrysystem.pages.dev",
    "https://staging.hznlaundrysystem.pages.dev",
    "http://localhost:8788",
    "http://127.0.0.1:8788"
  ];
}

function applyCorsHeaders(e) {
  var origin = "";
  try {
    var headers = (e.requestInfo() && e.requestInfo().headers) || {};
    origin = headers.origin || headers.Origin || "";
  } catch (_) {
    origin = "";
  }

  var allowed = getAllowedOrigins();
  var i;
  var matched = "";
  for (i = 0; i < allowed.length; i++) {
    if (allowed[i] === "*" || allowed[i] === origin) {
      matched = allowed[i] === "*" ? (origin || "*") : origin;
      break;
    }
  }

  // Always allow preflight headers so browsers can POST from Pages.
  e.response.header().set(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization"
  );
  e.response.header().set("Access-Control-Allow-Methods", "POST, OPTIONS");
  if (matched) {
    e.response.header().set("Access-Control-Allow-Origin", matched);
    e.response.header().set("Vary", "Origin");
  }
}

function resolveOrganizationName(app, sale) {
  var branchId = sale.getString("branch");
  if (!branchId) return "";
  try {
    var branch = app.findRecordById("branches", branchId);
    var orgId = branch.getString("organization");
    if (!orgId) return branch.getString("name") || "";
    var org = app.findRecordById("organizations", orgId);
    return org.getString("name") || branch.getString("name") || "";
  } catch (err) {
    return "";
  }
}

function resolveBranchName(app, sale) {
  var branchId = sale.getString("branch");
  if (!branchId) return "";
  try {
    return app.findRecordById("branches", branchId).getString("name") || "";
  } catch (err) {
    return "";
  }
}

function brandWithEnv(orgName) {
  var name = orgName || "HZN Laundry";
  var env = String($os.getenv("APP_ENV") || "").toLowerCase();
  if (env === "staging" || env === "stage") {
    return "[Staging] " + name;
  }
  if (env === "dev" || env === "development" || env === "local") {
    return "[Dev] " + name;
  }
  var url = String($os.getenv("APP_BASE_URL") || "").toLowerCase();
  if (url.indexOf("staging.") >= 0) {
    return "[Staging] " + name;
  }
  if (url.indexOf("127.0.0.1") >= 0 || url.indexOf("localhost") >= 0) {
    return "[Dev] " + name;
  }
  return name;
}

/**
 * Ensure the sale has a usable view token.
 * Unopened links expire after 90 days from mint; first open switches to 30 days.
 * Remints when missing or expired.
 * Returns the token string, or "" on failure.
 */
function ensureViewToken(app, sale) {
  var token = sale.getString("viewToken");
  var expiresAt = sale.getString("viewTokenExpiresAt");

  if (token && !isExpired(expiresAt)) {
    return token;
  }

  token = generateToken();
  sale.set("viewToken", token);
  sale.set("viewTokenCreatedAt", nowIsoUtc());
  sale.set("viewTokenFirstOpenedAt", null);
  sale.set("viewTokenExpiresAt", addDaysIsoUtc(UNOPENED_TTL_DAYS));

  try {
    app.save(sale);
  } catch (err) {
    console.error("[ORDER_VIEW] Failed to save viewToken for sale " + sale.id + ":", err);
    return "";
  }
  return token;
}

function markFirstOpened(app, sale) {
  var firstOpened = sale.getString("viewTokenFirstOpenedAt");
  if (firstOpened) {
    return;
  }
  sale.set("viewTokenFirstOpenedAt", nowIsoUtc());
  sale.set("viewTokenExpiresAt", addDaysIsoUtc(OPENED_TTL_DAYS));
  try {
    app.save(sale);
  } catch (err) {
    console.error("[ORDER_VIEW] Failed to stamp firstOpened for sale " + sale.id + ":", err);
  }
}

function verifyTurnstile(turnstileToken) {
  var secret = $os.getenv("TURNSTILE_SECRET_KEY");
  if (!secret) {
    throw new Error("TURNSTILE_SECRET_KEY env var not set");
  }
  if (!turnstileToken) {
    return false;
  }

  var res = $http.send({
    url: "https://challenges.cloudflare.com/turnstile/v0/siteverify",
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      secret: secret,
      response: turnstileToken
    }),
    timeout: 10
  });

  if (res.statusCode >= 400) {
    console.error("[ORDER_VIEW] Turnstile HTTP " + res.statusCode);
    return false;
  }

  var body = res.json || {};
  return !!body.success;
}

function loadLineItems(app, saleId) {
  var lineItems = [];

  try {
    var svcRecords = app.findRecordsByFilter(
      "saleServiceItems",
      "sale = {:saleId}",
      "created",
      0,
      0,
      { saleId: saleId }
    );
    var i;
    for (i = 0; i < svcRecords.length; i++) {
      var sv = svcRecords[i];
      lineItems.push({
        name: sv.getString("serviceName") || "Service",
        qty: sv.get("quantity"),
        subtotal: sv.get("subtotal")
      });
    }
  } catch (err) {
    console.error("[ORDER_VIEW] Failed to load saleServiceItems:", err);
  }

  try {
    var itemRecords = app.findRecordsByFilter(
      "saleItems",
      "sale = {:saleId}",
      "created",
      0,
      0,
      { saleId: saleId }
    );
    var j;
    for (j = 0; j < itemRecords.length; j++) {
      var it = itemRecords[j];
      lineItems.push({
        name: it.getString("productName") || "Product",
        qty: it.get("quantity"),
        subtotal: it.get("subtotal")
      });
    }
  } catch (err) {
    console.error("[ORDER_VIEW] Failed to load saleItems:", err);
  }

  return lineItems;
}

function buildPublicOrderDto(app, sale) {
  var orgName = resolveOrganizationName(app, sale);
  var branchName = resolveBranchName(app, sale);
  var customerName = sale.getString("customerName") || "";
  if (!customerName) {
    var customerId = sale.getString("customer");
    if (customerId) {
      try {
        customerName = app.findRecordById("customers", customerId).getString("name") || "";
      } catch (_) {}
    }
  }

  return {
    organizationName: orgName,
    branchName: branchName,
    receiptNumber: sale.getString("receiptNumber") || "",
    orderStatus: sale.getString("orderStatus") || "",
    paymentStatus: sale.getString("paymentStatus") || "",
    isPaid: sale.getBool("isPaid"),
    customerName: customerName,
    postedDate: sale.getString("postedDate") || sale.getString("created") || "",
    pickedUpAt: sale.getString("pickedUpAt") || "",
    totalAmount: sale.get("totalAmount"),
    lineItems: loadLineItems(app, sale.id)
  };
}

function buildOrderViewEmail(opts) {
  var brand = opts.brand || "HZN Laundry";
  var customerName = opts.customerName || "Customer";
  var receiptNumber = opts.receiptNumber || "";
  var orderViewLink = opts.orderViewLink || "";
  var branchName = opts.branchName || "";

  var emailLayout = require(__hooks + "/lib/email_layout.js");

  var rows = [
    { label: "Receipt", value: receiptNumber || "—" }
  ];
  if (branchName) {
    rows.push({ label: "Branch", value: branchName });
  }

  var html = emailLayout.renderEmail({
    brand: brand,
    platformTag: "",
    signOff: false,
    disclaimer: "Generated using HZN Laundry System",
    preheader: "View details for your laundry order " + (receiptNumber || "") + ".",
    title: "Hi " + customerName + ",",
    intro:
      "Thanks for choosing " +
      brand +
      ". Use the button below to view this order's details.",
    panelLabel: "Order",
    rows: rows,
    button: orderViewLink
      ? { label: "View order", url: orderViewLink }
      : null,
    note: "This link is private to this order. It expires 30 days after you first open it (or 90 days if never opened)."
  });

  var text =
    "Hi " +
    customerName +
    ",\n\n" +
    "Thanks for choosing " +
    brand +
    ". View this order here:\n\n" +
    (orderViewLink || "") +
    "\n\n" +
    "Receipt: " +
    (receiptNumber || "—") +
    "\n";
  if (branchName) {
    text += "Branch: " + branchName + "\n";
  }
  text +=
    "\nThis link is private to this order. It expires 30 days after you first open it (or 90 days if never opened).\n\n" +
    "Generated using HZN Laundry System";

  return {
    subject: brand + ": Order " + (receiptNumber || "") + " details",
    html: html,
    text: text
  };
}

function sendOrderViewEmail(toEmail, opts) {
  var historyConfig = require(__hooks + "/send_history_link_config.js");
  var apiKey = $os.getenv("RESEND_API_KEY");
  if (!apiKey) {
    throw new Error("RESEND_API_KEY env var not set");
  }

  var body = buildOrderViewEmail(opts);

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
  UNOPENED_TTL_DAYS: UNOPENED_TTL_DAYS,
  OPENED_TTL_DAYS: OPENED_TTL_DAYS,
  isExpired: isExpired,
  getOrderViewBaseUrl: getOrderViewBaseUrl,
  buildOrderViewUrl: buildOrderViewUrl,
  applyCorsHeaders: applyCorsHeaders,
  resolveOrganizationName: resolveOrganizationName,
  resolveBranchName: resolveBranchName,
  brandWithEnv: brandWithEnv,
  ensureViewToken: ensureViewToken,
  markFirstOpened: markFirstOpened,
  verifyTurnstile: verifyTurnstile,
  buildPublicOrderDto: buildPublicOrderDto,
  buildOrderViewEmail: buildOrderViewEmail,
  sendOrderViewEmail: sendOrderViewEmail
};
