/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Public single-order detail endpoint (Cloudflare Pages + Turnstile)
// ============================================================================
// POST /api/hzn/public-order/{token}
// OPTIONS /api/hzn/public-order/{token}
//
// Body: { "turnstileToken": "..." }
//
// Returns a safe order DTO for the sale whose viewToken matches.
// On first successful open, stamps viewTokenFirstOpenedAt and shortens
// expiry to 30 days. Unopened links expire after 90 days.
// ES5 only.
// ============================================================================

routerAdd("OPTIONS", "/api/hzn/public-order/{token}", function (e) {
  var helpers = require(__hooks + "/lib/order_view_helpers.js");
  helpers.applyCorsHeaders(e);
  return e.noContent(204);
});

routerAdd("POST", "/api/hzn/public-order/{token}", function (e) {
  var helpers = require(__hooks + "/lib/order_view_helpers.js");
  helpers.applyCorsHeaders(e);

  var token = e.request.pathValue("token");
  if (!token || token.length < 16) {
    return e.json(404, { message: "Order not found." });
  }

  var body = (e.requestInfo() && e.requestInfo().body) || {};
  var turnstileToken = body.turnstileToken || body.turnstile_token || "";

  try {
    if (!helpers.verifyTurnstile(turnstileToken)) {
      return e.json(403, { message: "Verification failed. Please try again." });
    }
  } catch (err) {
    console.error("[ORDER_VIEW] Turnstile verify error:", err);
    return e.json(500, { message: "Verification unavailable." });
  }

  var sale;
  try {
    sale = $app.findFirstRecordByFilter(
      "sales",
      "viewToken = {:token}",
      { token: token }
    );
  } catch (err) {
    return e.json(404, { message: "Order not found." });
  }

  if (!sale) {
    return e.json(404, { message: "Order not found." });
  }

  if (sale.getBool("isDeleted")) {
    return e.json(404, { message: "Order not found." });
  }

  var saleStatus = sale.getString("status") || "";
  if (saleStatus === "voided" || saleStatus === "refunded") {
    return e.json(404, { message: "Order not found." });
  }

  var expiresAt = sale.getString("viewTokenExpiresAt");
  if (helpers.isExpired(expiresAt)) {
    return e.json(410, { message: "This order link has expired." });
  }

  helpers.markFirstOpened($app, sale);

  return e.json(200, helpers.buildPublicOrderDto($app, sale));
});
