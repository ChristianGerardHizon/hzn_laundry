/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Delete existing view if it exists
  try {
    const existing = app.findCollectionByNameOrId("vw_top_selling_services");
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
        "id": "_clone_svcname",
        "max": 0,
        "min": 0,
        "name": "serviceName",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_services001",
        "hidden": false,
        "id": "_clone_svcid",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "service_id",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_branch",
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
        "id": "json_sale_date",
        "maxSize": 1,
        "name": "sale_date",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json_total_qty",
        "maxSize": 1,
        "name": "total_quantity_sold",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json_total_rev",
        "maxSize": 1,
        "name": "total_revenue",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "number_tx_count",
        "max": null,
        "min": null,
        "name": "transaction_count",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      }
    ],
    "id": "pbc_topsellsvc1",
    "indexes": [],
    "listRule": "",
    "name": "vw_top_selling_services",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  ssi.serviceName,\n  ssi.service AS service_id,\n  s.branch,\n  DATE(s.created) AS sale_date,\n  SUM(ssi.quantity) AS total_quantity_sold,\n  SUM(ssi.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleServiceItems ssi\nJOIN sales s ON ssi.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY ssi.serviceName, ssi.service, s.branch, DATE(s.created)\nORDER BY total_revenue DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_topsellsvc1");
    return app.delete(collection);
  } catch (e) {
    // Already deleted
  }
})
