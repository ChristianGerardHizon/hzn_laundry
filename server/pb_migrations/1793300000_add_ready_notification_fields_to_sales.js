/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");

  if (!collection.fields.getById("bool_sendNotification_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "bool_sendNotification_sales",
        name: "sendNotification",
        presentable: false,
        required: false,
        system: false,
        type: "bool",
      })
    );
  }

  if (!collection.fields.getById("date_readyNotificationSentAt_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "date_readyNotificationSentAt_sales",
        max: "",
        min: "",
        name: "readyNotificationSentAt",
        presentable: false,
        required: false,
        system: false,
        type: "date",
      })
    );
  }

  if (!collection.fields.getById("bool_resendReadyNotification_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "bool_resendReadyNotification_sales",
        name: "resendReadyNotification",
        presentable: false,
        required: false,
        system: false,
        type: "bool",
      })
    );
  }

  app.save(collection);

  // Default ON for existing orders (new creates also send true from the client).
  const sales = app.findAllRecords("sales");
  for (let i = 0; i < sales.length; i++) {
    const sale = sales[i];
    if (!sale.getBool("sendNotification")) {
      sale.set("sendNotification", true);
      app.save(sale);
    }
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");
  collection.fields.removeById("bool_sendNotification_sales");
  collection.fields.removeById("date_readyNotificationSentAt_sales");
  collection.fields.removeById("bool_resendReadyNotification_sales");
  return app.save(collection);
});
