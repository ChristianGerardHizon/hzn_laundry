/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const flags = [
    {
      key: "emailUpdatesEnabled",
      enabled: true,
      description: "Send order history link emails to customers",
    },
    {
      key: "requireMachine",
      enabled: false,
      description: "Block moving to Processing if no machine is assigned",
    },
    {
      key: "requirePack",
      enabled: false,
      description: "Block moving to Ready if no packs are set on the order",
    },
    {
      key: "requireStorage",
      enabled: false,
      description: "Block moving to Ready if no storage location is assigned",
    },
  ];

  const collection = app.findCollectionByNameOrId("featureFlags");

  for (const flag of flags) {
    try {
      // Skip if already exists (idempotent)
      app.findFirstRecordByFilter(collection, `key = "${flag.key}"`);
    } catch (_) {
      const record = new Record(collection);
      record.set("key", flag.key);
      record.set("enabled", flag.enabled);
      record.set("description", flag.description);
      app.save(record);
    }
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("featureFlags");
  const keys = ["emailUpdatesEnabled", "requireMachine", "requirePack", "requireStorage"];
  for (const key of keys) {
    try {
      const record = app.findFirstRecordByFilter(collection, `key = "${key}"`);
      app.delete(record);
    } catch (_) {}
  }
})
