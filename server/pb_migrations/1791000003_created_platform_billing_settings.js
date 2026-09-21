/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    if (app.findCollectionByNameOrId("platformBillingSettings")) {
      return;
    }
  } catch (_) {}

  const collection = new Collection({
    id: "pbc_platform_billing_settings",
    name: "platformBillingSettings",
    type: "base",
    system: false,
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      {
        autogeneratePattern: "[a-z0-9]{15}",
        hidden: false,
        id: "text3208210256",
        max: 15,
        min: 15,
        name: "id",
        pattern: "^[a-z0-9]+$",
        presentable: false,
        primaryKey: true,
        required: true,
        system: true,
        type: "text"
      },
      {
        hidden: false,
        id: "file_billing_qrph",
        maxSelect: 1,
        maxSize: 5242880,
        mimeTypes: ["image/jpeg", "image/png", "image/gif", "image/webp"],
        name: "qrphImage",
        presentable: false,
        protected: false,
        required: false,
        system: false,
        thumbs: [],
        type: "file"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_billing_payee",
        max: 0,
        min: 0,
        name: "payeeName",
        pattern: "",
        presentable: true,
        primaryKey: false,
        required: false,
        system: false,
        type: "text"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_billing_instructions",
        max: 0,
        min: 0,
        name: "instructions",
        pattern: "",
        presentable: false,
        primaryKey: false,
        required: false,
        system: false,
        type: "text"
      },
      {
        hidden: false,
        id: "number_billing_grace_days",
        max: null,
        min: 0,
        name: "defaultGraceDays",
        onlyInt: true,
        presentable: false,
        required: true,
        system: false,
        type: "number"
      },
      {
        hidden: false,
        id: "json_billing_reminder_days",
        maxSize: 2000,
        name: "reminderDaysBeforeDue",
        presentable: false,
        required: false,
        system: false,
        type: "json"
      },
      {
        hidden: false,
        id: "autodate_billing_created",
        name: "created",
        onCreate: true,
        onUpdate: false,
        presentable: false,
        system: false,
        type: "autodate"
      },
      {
        hidden: false,
        id: "autodate_billing_updated",
        name: "updated",
        onCreate: true,
        onUpdate: true,
        presentable: false,
        system: false,
        type: "autodate"
      }
    ],
    indexes: []
  });

  app.save(collection);

  // Seed the singleton settings row.
  const settings = new Record(collection);
  settings.set("payeeName", "HZN Laundry");
  settings.set("instructions", "Scan the QRPH code, send the exact amount, then upload your transaction screenshot for confirmation.");
  settings.set("defaultGraceDays", 7);
  settings.set("reminderDaysBeforeDue", [3, 0]);
  return app.save(settings);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_platform_billing_settings");
    return app.delete(collection);
  } catch (_) {}
});
