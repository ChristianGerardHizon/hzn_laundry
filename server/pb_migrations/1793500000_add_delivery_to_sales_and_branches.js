/// <reference path="../pb_data/types.d.ts" />
// Delivery support (additive only; safe with the `delivery` feature flag off).
//  - sales.orderStatus gains "forDelivery"
//  - sales gains fulfillmentType (empty == pickup) and delivery fields
//  - branches gain default delivery fee settings
//  - vw_sale_service_totals includes forDelivery orders
migrate((app) => {
  const sales = app.findCollectionByNameOrId("pbc_2697449135");

  const orderStatus = sales.fields.getByName("orderStatus");
  const values = orderStatus.values || [];
  if (values.indexOf("forDelivery") === -1) {
    orderStatus.values = ["pending", "processing", "ready", "forDelivery", "pickedUp"];
  }

  const addField = (collection, id, def) => {
    if (!collection.fields.getById(id)) {
      collection.fields.add(
        new Field(
          Object.assign(
            { hidden: false, id: id, presentable: false, required: false, system: false },
            def
          )
        )
      );
    }
  };

  addField(sales, "select_fulfillmentType_sales", {
    name: "fulfillmentType",
    type: "select",
    maxSelect: 1,
    values: ["pickup", "delivery"],
  });
  addField(sales, "text_deliveryAddress_sales", {
    name: "deliveryAddress",
    type: "text",
    autogeneratePattern: "",
    max: 0,
    min: 0,
    pattern: "",
    primaryKey: false,
  });
  addField(sales, "text_deliveryNotes_sales", {
    name: "deliveryNotes",
    type: "text",
    autogeneratePattern: "",
    max: 0,
    min: 0,
    pattern: "",
    primaryKey: false,
  });
  addField(sales, "number_distanceKm_sales", {
    name: "distanceKm",
    type: "number",
    max: null,
    min: 0,
    onlyInt: false,
  });
  addField(sales, "number_deliveryRatePerKm_sales", {
    name: "deliveryRatePerKm",
    type: "number",
    max: null,
    min: 0,
    onlyInt: false,
  });
  addField(sales, "number_deliveryFee_sales", {
    name: "deliveryFee",
    type: "number",
    max: null,
    min: 0,
    onlyInt: false,
  });
  addField(sales, "bool_deliveryFeeOverridden_sales", {
    name: "deliveryFeeOverridden",
    type: "bool",
  });
  addField(sales, "date_forDeliveryAt_sales", {
    name: "forDeliveryAt",
    type: "date",
    max: "",
    min: "",
  });
  addField(sales, "date_forDeliveryNotificationSentAt_sales", {
    name: "forDeliveryNotificationSentAt",
    type: "date",
    max: "",
    min: "",
  });
  addField(sales, "bool_resendForDeliveryNotification_sales", {
    name: "resendForDeliveryNotification",
    type: "bool",
  });
  addField(sales, "file_deliveryPhoto_sales", {
    name: "deliveryPhoto",
    type: "file",
    maxSelect: 1,
    maxSize: 5242880,
    mimeTypes: ["image/jpeg", "image/png", "image/webp"],
    protected: false,
    thumbs: [],
  });
  app.save(sales);

  const branches = app.findCollectionByNameOrId("pbc_2358601297");
  addField(branches, "number_deliveryBaseFee_branches", {
    name: "deliveryBaseFee",
    type: "number",
    max: null,
    min: 0,
    onlyInt: false,
  });
  addField(branches, "number_deliveryIncludedKm_branches", {
    name: "deliveryIncludedKm",
    type: "number",
    max: null,
    min: 0,
    onlyInt: false,
  });
  addField(branches, "number_deliveryRatePerKm_branches", {
    name: "deliveryRatePerKm",
    type: "number",
    max: null,
    min: 0,
    onlyInt: false,
  });
  app.save(branches);

  // Include forDelivery in the service totals view (was processing/ready/pickedUp).
  const view = app.findCollectionByNameOrId("pbc_384506597");
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, s.processedDate, COALESCE(NULLIF(s.postedDate, ''), s.created) AS effectivePostedDate, COALESCE(NULLIF(s.processedDate, ''), NULLIF(s.postedDate, ''), s.created) AS effectiveProcessedDate, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"processing\", \"ready\", \"forDelivery\", \"pickedUp\") GROUP BY s.id"
  }, view);
  app.save(view);
}, (app) => {
  const view = app.findCollectionByNameOrId("pbc_384506597");
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, s.processedDate, COALESCE(NULLIF(s.postedDate, ''), s.created) AS effectivePostedDate, COALESCE(NULLIF(s.processedDate, ''), NULLIF(s.postedDate, ''), s.created) AS effectiveProcessedDate, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"processing\", \"ready\", \"pickedUp\") GROUP BY s.id"
  }, view);
  app.save(view);

  const branches = app.findCollectionByNameOrId("pbc_2358601297");
  branches.fields.removeById("number_deliveryBaseFee_branches");
  branches.fields.removeById("number_deliveryIncludedKm_branches");
  branches.fields.removeById("number_deliveryRatePerKm_branches");
  app.save(branches);

  const sales = app.findCollectionByNameOrId("pbc_2697449135");
  [
    "select_fulfillmentType_sales",
    "text_deliveryAddress_sales",
    "text_deliveryNotes_sales",
    "number_distanceKm_sales",
    "number_deliveryRatePerKm_sales",
    "number_deliveryFee_sales",
    "bool_deliveryFeeOverridden_sales",
    "date_forDeliveryAt_sales",
    "date_forDeliveryNotificationSentAt_sales",
    "bool_resendForDeliveryNotification_sales",
    "file_deliveryPhoto_sales",
  ].forEach((id) => sales.fields.removeById(id));
  sales.fields.getByName("orderStatus").values = ["pending", "processing", "ready", "pickedUp"];
  app.save(sales);
});
