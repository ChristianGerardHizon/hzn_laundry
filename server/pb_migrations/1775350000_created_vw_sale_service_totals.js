/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
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
          "id": "_clone_R7A4",
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
          "cascadeDelete": false,
          "collectionId": "pbc_2358601297",
          "hidden": false,
          "id": "_clone_uDgZ",
          "maxSelect": 1,
          "minSelect": 0,
          "name": "branch",
          "presentable": false,
          "required": false,
          "system": false,
          "type": "relation"
        },
        {
          "autogeneratePattern": "",
          "hidden": false,
          "id": "_clone_Th3r",
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
          "hidden": false,
          "id": "_clone_0FCw",
          "maxSelect": 1,
          "name": "orderStatus",
          "presentable": false,
          "required": false,
          "system": false,
          "type": "select",
          "values": [
            "pending",
            "processing",
            "ready",
            "pickedUp"
          ]
        },
        {
          "hidden": false,
          "id": "_clone_BmnZ",
          "name": "postedDate",
          "onCreate": true,
          "onUpdate": false,
          "presentable": false,
          "system": false,
          "type": "autodate"
        },
        {
          "hidden": false,
          "id": "_clone_D5c4",
          "name": "created",
          "onCreate": true,
          "onUpdate": false,
          "presentable": false,
          "system": false,
          "type": "autodate"
        },
        {
          "hidden": false,
          "id": "json3015788993",
          "maxSize": 1,
          "name": "serviceTotalAmount",
          "presentable": false,
          "required": false,
          "system": false,
          "type": "json"
        }
      ],
      "id": "pbc_384506597",
      "indexes": [],
      "listRule": "",
      "name": "vw_sale_service_totals",
      "system": false,
      "type": "view",
      "updateRule": null,
      "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"ready\", \"pickedUp\") GROUP BY s.id",
      "viewRule": ""
    });

    return app.save(collection);
  } catch (e) {
    // View may already exist (e.g. created via API)
    console.log("vw_sale_service_totals already exists, skipping:", e);
  }
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_384506597");
    return app.delete(collection);
  } catch (e) {
    // View may not exist
  }
})
