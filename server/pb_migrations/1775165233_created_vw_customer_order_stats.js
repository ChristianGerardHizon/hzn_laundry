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
        "id": "relation2168032777",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "customer",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
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
      }
    ],
    "id": "pbc_2455048456",
    "indexes": [],
    "listRule": "",
    "name": "vw_customer_order_stats",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  c.id AS id,\n  c.id AS customer,\n  COUNT(s.id) AS orderCount,\n  COALESCE(SUM(CASE WHEN s.status != 'voided' THEN s.totalAmount ELSE 0 END), 0) AS totalSpent\nFROM customers c\nLEFT JOIN sales s ON s.customer = c.id\nGROUP BY c.id",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2455048456");

  return app.delete(collection);
})
