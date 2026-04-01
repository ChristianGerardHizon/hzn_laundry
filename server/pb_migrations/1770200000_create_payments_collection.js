/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Check if collection already exists
  try {
    const existing = app.findCollectionByNameOrId("payments")
    if (existing) {
      // Collection already exists, skip creation
      return
    }
  } catch (e) {
    // Collection doesn't exist, proceed with creation
  }

  const collection = new Collection({
    "id": "pbc_payments",
    "name": "payments",
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
        "cascadeDelete": false,
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
        "id": "number_amount",
        "max": null,
        "min": 0,
        "name": "amount",
        "onlyInt": false,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "number"
      },
      {
        "hidden": false,
        "id": "select_paymentmethod",
        "maxSelect": 1,
        "name": "paymentMethod",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": ["cash", "card", "bankTransfer", "check"]
      },
      {
        "hidden": false,
        "id": "select_type",
        "maxSelect": 1,
        "name": "type",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": ["payment", "deposit", "refund"]
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_paymentref",
        "max": 0,
        "min": 0,
        "name": "paymentRef",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "file_paymentproof",
        "maxSelect": 1,
        "maxSize": 5242880,
        "mimeTypes": ["image/jpeg", "image/png", "image/gif"],
        "name": "paymentProof",
        "presentable": false,
        "protected": false,
        "required": false,
        "system": false,
        "thumbs": [],
        "type": "file"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text_notes",
        "max": 0,
        "min": 0,
        "name": "notes",
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
      "CREATE INDEX `idx_payments_sale` ON `payments` (`sale`)"
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
    const collection = app.findCollectionByNameOrId("pbc_payments")
    return app.delete(collection)
  } catch (e) {
    // Collection doesn't exist, nothing to delete
  }
})
