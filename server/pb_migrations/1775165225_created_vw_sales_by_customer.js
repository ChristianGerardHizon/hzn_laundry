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
        "cascadeDelete": false,
        "collectionId": "pbc_customers001",
        "hidden": false,
        "id": "_clone_rFgj",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "customer",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_3j60",
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
        "id": "_clone_aLSX",
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
        "id": "json1865448975",
        "maxSize": 1,
        "name": "saleDate",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "number1422664042",
        "max": null,
        "min": null,
        "name": "orderCount",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "json328858555",
        "maxSize": 1,
        "name": "totalSpent",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json3107479025",
        "maxSize": 1,
        "name": "totalPaid",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json1163669686",
        "maxSize": 1,
        "name": "paidOrderCount",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_3594358520",
    "indexes": [],
    "listRule": "",
    "name": "vw_sales_by_customer",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  s.customer,\n  s.customerName,\n  s.branch,\n  DATE(s.created) AS saleDate,\n  COUNT(s.id) AS orderCount,\n  SUM(s.totalAmount) AS totalSpent,\n  SUM(CASE WHEN s.isPaid = true THEN s.totalAmount ELSE 0 END) AS totalPaid,\n  SUM(CASE WHEN s.isPaid = true THEN 1 ELSE 0 END) AS paidOrderCount\nFROM sales s\nWHERE s.status != 'voided'\nGROUP BY s.customer, s.customerName, s.branch, DATE(s.created)\nORDER BY totalSpent DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3594358520");

  return app.delete(collection);
})
