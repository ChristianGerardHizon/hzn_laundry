/// <reference path="../pb_data/types.d.ts" />

// View: vw_loads_summary
// Per-sale machine-load totals for the dashboard "Loads" KPI.
//
// A load is a machine cycle stored in `saleServiceItems.machineLoadCounts`,
// a JSON map of { machineId: count }. We unroll that map with json_each and
// sum every value across all service items of a sale, so the dashboard can
// read one pre-aggregated row per order instead of fetching all service
// items and summing in Dart.
//
// Mirrors the controller semantics: voided sales excluded; filtered by
// branch + postedDate day-range on the client.
migrate((app) => {
  // Delete existing view if it exists (idempotent re-run / prior partial apply)
  try {
    const existing = app.findCollectionByNameOrId("vw_loads_summary");
    app.delete(existing);
  } catch (e) {
    // Collection doesn't exist, safe to proceed
  }

  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 0,
        "min": 0,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_ls01",
        "max": 0,
        "min": 0,
        "name": "receiptNumber",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_ls02",
        "max": 0,
        "min": 0,
        "name": "customerName",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_ls03",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "branch",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "hidden": false,
        "id": "_clone_ls04",
        "name": "postedDate",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "json_ls_loads",
        "maxSize": 1,
        "name": "loads",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_loadssum001",
    "indexes": [],
    "listRule": "",
    "name": "vw_loads_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  s.id,\n  s.receiptNumber,\n  s.customerName,\n  s.branch,\n  s.postedDate,\n  COALESCE(SUM(le.value), 0) AS loads\nFROM sales s\nLEFT JOIN saleServiceItems si ON si.sale = s.id\nLEFT JOIN json_each(si.machineLoadCounts) le ON 1=1\nWHERE s.status != 'voided'\nGROUP BY s.id",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("vw_loads_summary");
    return app.delete(collection);
  } catch (e) {
    // View may not exist; nothing to roll back
  }
})
