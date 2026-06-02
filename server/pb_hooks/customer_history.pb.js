/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Public Customer Order History endpoint
// ============================================================================
// GET /api/customer-history/:token
//
// Returns { customer, sales } for the customer whose historyToken matches and
// whose historyTokenExpiresAt is in the future. No auth required — the link
// IS the auth.
//
// Exposes only fields safe to share with the customer.
// ES5 only.
// ============================================================================

routerAdd("GET", "/api/customer-history/{token}", function(e) {
  var token = e.request.pathValue("token");
  if (!token || token.length < 16) {
    return e.json(404, { success: false, error: "Invalid link" });
  }

  var customer;
  try {
    customer = $app.findFirstRecordByFilter(
      "customers",
      "historyToken = {:token}",
      { "token": token }
    );
  } catch (err) {
    return e.json(404, { success: false, error: "Link not found or expired" });
  }

  if (!customer) {
    return e.json(404, { success: false, error: "Link not found or expired" });
  }

  // Expiry check
  var expiresAt = customer.getString("historyTokenExpiresAt");
  if (expiresAt) {
    var expires = new Date(expiresAt);
    if (!isNaN(expires.getTime()) && expires.getTime() <= Date.now()) {
      return e.json(410, { success: false, error: "Link expired" });
    }
  }

  // Fetch the customer's sales (most recent first)
  var sales = [];
  try {
    sales = $app.findRecordsByFilter(
      "sales",
      "customer = {:customerId} && (isDeleted = false || isDeleted = null)",
      "-created",
      100,  // cap
      0,
      { "customerId": customer.id }
    );
  } catch (err) {
    console.error("[CUSTOMER_HISTORY] Failed to fetch sales:", err);
    return e.json(500, { success: false, error: "Internal error" });
  }

  var saleDtos = [];
  for (var i = 0; i < sales.length; i++) {
    var s = sales[i];
    saleDtos.push({
      id: s.id,
      receiptNumber: s.getString("receiptNumber"),
      totalAmount: s.get("totalAmount"),
      orderStatus: s.getString("orderStatus"),
      paymentStatus: s.getString("paymentStatus"),
      isPaid: s.getBool("isPaid"),
      packs: s.get("packs"),
      pickedUpAt: s.getString("pickedUpAt"),
      postedDate: s.getString("postedDate"),
      created: s.getString("created")
    });
  }

  return e.json(200, {
    success: true,
    customer: {
      id: customer.id,
      name: customer.getString("name"),
      phone: customer.getString("phone")
    },
    sales: saleDtos
  });
});

// ============================================================================
// GET /api/customer-history/:token/sales/:saleId
// Returns full sale detail with items + service items.
// Verifies sale.customer matches token's customer.
// ============================================================================
routerAdd("GET", "/api/customer-history/{token}/sales/{saleId}", function(e) {
  var token = e.request.pathValue("token");
  var saleId = e.request.pathValue("saleId");
  if (!token || token.length < 16 || !saleId) {
    return e.json(404, { success: false, error: "Invalid link" });
  }

  var customer;
  try {
    customer = $app.findFirstRecordByFilter(
      "customers",
      "historyToken = {:token}",
      { "token": token }
    );
  } catch (err) {
    return e.json(404, { success: false, error: "Link not found or expired" });
  }
  if (!customer) {
    return e.json(404, { success: false, error: "Link not found or expired" });
  }

  var expiresAt = customer.getString("historyTokenExpiresAt");
  if (expiresAt) {
    var expires = new Date(expiresAt);
    if (!isNaN(expires.getTime()) && expires.getTime() <= Date.now()) {
      return e.json(410, { success: false, error: "Link expired" });
    }
  }

  var sale;
  try {
    sale = $app.findRecordById("sales", saleId);
  } catch (err) {
    return e.json(404, { success: false, error: "Order not found" });
  }

  if (sale.getString("customer") !== customer.id) {
    return e.json(404, { success: false, error: "Order not found" });
  }

  var items = [];
  try {
    var itemRecords = $app.findRecordsByFilter(
      "saleItems",
      "sale = {:saleId}",
      "created",
      0,
      0,
      { "saleId": sale.id }
    );
    for (var i = 0; i < itemRecords.length; i++) {
      var it = itemRecords[i];
      items.push({
        id: it.id,
        productName: it.getString("productName"),
        quantity: it.get("quantity"),
        unitPrice: it.get("unitPrice"),
        subtotal: it.get("subtotal")
      });
    }
  } catch (err) {
    console.error("[CUSTOMER_HISTORY] Failed to fetch items:", err);
  }

  var services = [];
  try {
    var svcRecords = $app.findRecordsByFilter(
      "saleServiceItems",
      "sale = {:saleId}",
      "created",
      0,
      0,
      { "saleId": sale.id }
    );
    for (var j = 0; j < svcRecords.length; j++) {
      var sv = svcRecords[j];
      services.push({
        id: sv.id,
        serviceName: sv.getString("serviceName"),
        quantity: sv.get("quantity"),
        unitPrice: sv.get("unitPrice"),
        subtotal: sv.get("subtotal"),
        status: sv.getString("status"),
        machineName: sv.getString("machineName"),
        storageName: sv.getString("storageName")
      });
    }
  } catch (err) {
    console.error("[CUSTOMER_HISTORY] Failed to fetch services:", err);
  }

  return e.json(200, {
    success: true,
    customer: {
      id: customer.id,
      name: customer.getString("name"),
      phone: customer.getString("phone")
    },
    sale: {
      id: sale.id,
      receiptNumber: sale.getString("receiptNumber"),
      totalAmount: sale.get("totalAmount"),
      orderStatus: sale.getString("orderStatus"),
      paymentStatus: sale.getString("paymentStatus"),
      isPaid: sale.getBool("isPaid"),
      packs: sale.get("packs"),
      notes: sale.getString("notes"),
      pickedUpAt: sale.getString("pickedUpAt"),
      postedDate: sale.getString("postedDate"),
      created: sale.getString("created")
    },
    items: items,
    services: services
  });
});
