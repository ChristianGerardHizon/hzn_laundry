/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Check if collection already exists
  try {
    const existing = app.findCollectionByNameOrId("orderStatusHistory")
    if (existing) {
      // Collection already exists, skip creation
      return
    }
  } catch (e) {
    // Collection doesn't exist, proceed with creation
  }

  const collection = new Collection({
    "id": "pbc_orderstatushistory",
    "name": "orderStatusHistory",
    "type": "base",
    "system": false,
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
        "collectionId": "pbc_2697449135",
        "hidden": false,
        "id": "relation_sale",
        "maxSelect": 1,
        "minSelect": 1,
        "name": "sale",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "hidden": false,
        "id": "select_statustype",
        "maxSelect": 1,
        "name": "statusType",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": ["saleStatus", "orderStatus"]
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_fromstatus",
        "max": 0,
        "min": 0,
        "name": "fromStatus",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_tostatus",
        "max": 0,
        "min": 0,
        "name": "toStatus",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_description",
        "max": 0,
        "min": 0,
        "name": "description",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": { "enabled": true },
        "onUpdate": { "enabled": false },
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": { "enabled": true },
        "onUpdate": { "enabled": true },
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "indexes": [
      "CREATE INDEX `idx_orderstatushistory_sale` ON `orderStatusHistory` (`sale`)"
    ],
    "listRule": "@request.auth.id != ''",
    "viewRule": "@request.auth.id != ''",
    "createRule": "@request.auth.id != ''",
    "updateRule": "@request.auth.id != ''",
    "deleteRule": "@request.auth.id != ''"
  })

  return app.save(collection)
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_orderstatushistory")
    return app.delete(collection)
  } catch (e) {
    // Collection doesn't exist, nothing to delete
  }
})
