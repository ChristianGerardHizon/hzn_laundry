/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    const collection = new Collection({
      "createRule": "",
      "deleteRule": "",
      "fields": [
        {
          "autogeneratePattern": "[a-z0-9]{15}",
          "hidden": false,
          "id": "text3208210256",
          "max": 15,
          "min": 15,
          "name": "id",
          "pattern": "^[a-z0-9]+$",
          "presentable": false,
          "primaryKey": true,
          "required": true,
          "system": true,
          "type": "text"
        },
        {
          "cascadeDelete": true,
          "collectionId": "pbc_2358601297",
          "hidden": false,
          "id": "relation_branch",
          "maxSelect": 1,
          "minSelect": 0,
          "name": "branch",
          "presentable": false,
          "required": true,
          "system": false,
          "type": "relation"
        },
        {
          "hidden": false,
          "id": "number_min_amount",
          "max": null,
          "min": 0,
          "name": "minAmount",
          "onlyInt": false,
          "presentable": false,
          "required": true,
          "system": false,
          "type": "number"
        },
        {
          "hidden": false,
          "id": "number_max_amount",
          "max": null,
          "min": 0,
          "name": "maxAmount",
          "onlyInt": false,
          "presentable": false,
          "required": false,
          "system": false,
          "type": "number"
        },
        {
          "hidden": false,
          "id": "number_incentive_amount",
          "max": null,
          "min": 0,
          "name": "incentiveAmount",
          "onlyInt": false,
          "presentable": false,
          "required": true,
          "system": false,
          "type": "number"
        },
        {
          "hidden": false,
          "id": "number_sort_order",
          "max": null,
          "min": 0,
          "name": "sortOrder",
          "onlyInt": true,
          "presentable": false,
          "required": false,
          "system": false,
          "type": "number"
        }
      ],
      "id": "pbc_895593372",
      "indexes": [],
      "listRule": "",
      "name": "incentiveTiers",
      "system": false,
      "type": "base",
      "updateRule": "",
      "viewRule": ""
    });

    return app.save(collection);
  } catch (e) {
    // Collection may already exist (e.g. created via API)
    console.log("incentiveTiers already exists, skipping:", e);
  }
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_895593372");
    return app.delete(collection);
  } catch (e) {
    // Collection may not exist
  }
})
