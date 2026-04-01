/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Delete existing view if it exists (may not have been deleted by prior migration)
  try {
    const existing = app.findCollectionByNameOrId("vw_top_selling_products");
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
        "id": "_clone_D8Dh",
        "max": 0,
        "min": 0,
        "name": "productName",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_4092854851",
        "hidden": false,
        "id": "_clone_rww4",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "product_id",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_0Dez",
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
        "id": "json382747551",
        "maxSize": 1,
        "name": "sale_date",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json2081462908",
        "maxSize": 1,
        "name": "total_quantity_sold",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
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
      }
    ],
    "id": "pbc_3971230533",
    "indexes": [],
    "listRule": "",
    "name": "vw_top_selling_products",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.productName,\n  si.product AS product_id,\n  s.branch,\n  DATE(s.created) AS sale_date,\n  SUM(si.quantity) AS total_quantity_sold,\n  SUM(si.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY si.productName, si.product, s.branch, DATE(s.created)\nORDER BY total_revenue DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_3971230533");
    return app.delete(collection);
  } catch (e) {
    // Already deleted
  }
})
