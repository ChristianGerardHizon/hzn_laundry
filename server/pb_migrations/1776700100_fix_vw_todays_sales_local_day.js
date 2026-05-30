/// <reference path="../pb_data/types.d.ts" />
//
// Fix vw_todays_sales so "today" is the Philippine local calendar day, not the
// UTC day, and so it matches the client-side filters used everywhere else.
//
// Previous query used:
//   WHERE DATE(s.created) = DATE('now')   AND s.status = 'completed'
//
// Two bugs:
//   1. DATE('now') and s.created are both UTC. Philippine local midnight is
//      16:00 UTC of the previous day, so orders created between 00:00 and
//      08:00 PHT fell on the PREVIOUS UTC date and were counted under
//      yesterday's summary — i.e. the first orders of each morning showed up
//      on the previous day. Shifting both sides by +8 hours pins the boundary
//      to Philippine local midnight.
//   2. It filtered on `created` (server insert time) + status = 'completed',
//      while the Dart filters use `postedDate` + status != 'voided'. Align to
//      postedDate / status != 'voided' so the summary matches the order lists.
const VIEW_QUERY =
  "SELECT\n" +
  "  (ROW_NUMBER() OVER()) AS id,\n" +
  "  s.branch,\n" +
  "  COUNT(*) AS transaction_count,\n" +
  "  COALESCE(SUM(s.totalAmount), 0) AS total_revenue\n" +
  "FROM sales s\n" +
  "WHERE DATE(s.postedDate, '+8 hours') = DATE('now', '+8 hours')\n" +
  "  AND s.status != 'voided'\n" +
  "  AND (s.isDeleted = false OR s.isDeleted IS NULL)\n" +
  "GROUP BY s.branch";

migrate((app) => {
  try {
    const existing = app.findCollectionByNameOrId("vw_todays_sales");
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
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_N20Q",
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
        "id": "number619353122",
        "max": null,
        "min": null,
        "name": "transaction_count",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "json487443959",
        "maxSize": 1,
        "name": "total_revenue",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_1231561320",
    "indexes": [],
    "listRule": "",
    "name": "vw_todays_sales",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": VIEW_QUERY,
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  // Revert to the prior (UTC-based) definition.
  try {
    const existing = app.findCollectionByNameOrId("vw_todays_sales");
    app.delete(existing);
  } catch (e) {
    // Already deleted
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
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_N20Q",
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
        "id": "number619353122",
        "max": null,
        "min": null,
        "name": "transaction_count",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "json487443959",
        "maxSize": 1,
        "name": "total_revenue",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_1231561320",
    "indexes": [],
    "listRule": "",
    "name": "vw_todays_sales",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  s.branch,\n  COUNT(*) AS transaction_count,\n  COALESCE(SUM(s.totalAmount), 0) AS total_revenue\nFROM sales s\nWHERE DATE(s.created) = DATE('now')\n  AND s.status = 'completed'\n  AND (s.isDeleted = false OR s.isDeleted IS NULL)\nGROUP BY s.branch",
    "viewRule": ""
  });

  return app.save(collection);
})
