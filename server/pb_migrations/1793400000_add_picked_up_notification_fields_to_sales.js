/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");

  if (!collection.fields.getById("date_pickedUpNotificationSentAt_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "date_pickedUpNotificationSentAt_sales",
        max: "",
        min: "",
        name: "pickedUpNotificationSentAt",
        presentable: false,
        required: false,
        system: false,
        type: "date",
      })
    );
  }

  if (!collection.fields.getById("bool_resendPickedUpNotification_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "bool_resendPickedUpNotification_sales",
        name: "resendPickedUpNotification",
        presentable: false,
        required: false,
        system: false,
        type: "bool",
      })
    );
  }

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");
  collection.fields.removeById("date_pickedUpNotificationSentAt_sales");
  collection.fields.removeById("bool_resendPickedUpNotification_sales");
  return app.save(collection);
});
