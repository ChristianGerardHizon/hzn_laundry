/// <reference path="../pb_data/types.d.ts" />
// Creates the machineLoadRules collection (per-machine weight -> load-count tiers).
// Fields are added in the companion migration 1780809862_updated_machineLoadRules.js,
// which was generated from the PocketBase admin and is the canonical field definition.
migrate((app) => {
  const collection = new Collection({
    "id": "pbc_machineloadr1",
    "name": "machineLoadRules",
    "type": "base",
    "system": false,
    "createRule": "@request.auth.id != ''",
    "deleteRule": "@request.auth.id != ''",
    "listRule": null,
    "viewRule": null,
    "updateRule": null,
    "indexes": []
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_machineloadr1");

  return app.delete(collection);
})
