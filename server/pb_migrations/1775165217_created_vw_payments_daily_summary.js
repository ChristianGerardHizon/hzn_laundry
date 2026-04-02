/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
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
        "id": "json1889812618",
        "maxSize": 1,
        "name": "paymentDate",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "_clone_S1PH",
        "maxSelect": 1,
        "name": "paymentMethod",
        "presentable": false,
        "required": true,
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
        "hidden": false,
        "id": "_clone_7Hab",
        "maxSelect": 1,
        "name": "paymentType",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "payment",
          "deposit",
          "refund"
        ]
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_jnDG",
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
        "id": "number952011785",
        "max": null,
        "min": null,
        "name": "paymentCount",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "json3225882586",
        "maxSize": 1,
        "name": "totalAmount",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_566873343",
    "indexes": [],
    "listRule": "",
    "name": "vw_payments_daily_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(p.created) AS paymentDate,\n  p.paymentMethod,\n  p.type AS paymentType,\n  s.branch,\n  COUNT(p.id) AS paymentCount,\n  SUM(p.amount) AS totalAmount\nFROM payments p\nJOIN sales s ON p.sale = s.id\nWHERE s.status != 'voided'\nGROUP BY DATE(p.created), p.paymentMethod, p.type, s.branch\nORDER BY paymentDate DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_566873343");

  return app.delete(collection);
})
