/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3432702729");

  return app.delete(collection);
}, (app) => {
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
        "id": "_clone_rDSz",
        "maxSelect": 1,
        "name": "paymentMethod",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "select",
        "values": [
          "cash",
          "card",
          "bankTransfer",
          "check"
        ]
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_5wdo",
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
      },
      {
        "hidden": false,
        "id": "json3227388031",
        "maxSize": 1,
        "name": "avg_transaction_value",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_3432702729",
    "indexes": [],
    "listRule": "",
    "name": "vw_sales_daily_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(s.created) AS sale_date,\n  s.paymentMethod,\n  s.branch,\n  COUNT(*) AS transaction_count,\n  SUM(s.totalAmount) AS total_revenue,\n  AVG(s.totalAmount) AS avg_transaction_value\nFROM sales s\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY DATE(s.created), s.paymentMethod, s.branch\nORDER BY sale_date DESC",
    "viewRule": ""
  });

  return app.save(collection);
})
