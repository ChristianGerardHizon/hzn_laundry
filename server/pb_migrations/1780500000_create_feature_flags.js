/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  var collection = new Collection({
    "id": "pbc_2454967760",
    "name": "featureFlags",
    "type": "base",
    "system": false,
    "fields": [
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text2324736937",
        "max": 0,
        "min": 0,
        "name": "key",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "bool1358543748",
        "name": "enabled",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text1843675174",
        "max": 0,
        "min": 0,
        "name": "description",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX `idx_featureFlags_key` ON `featureFlags` (`key`)"
    ],
    "listRule": "@request.auth.role.permissions ?~ \"system.admin\"",
    "viewRule": "@request.auth.role.permissions ?~ \"system.admin\"",
    "createRule": null,
    "updateRule": "@request.auth.role.permissions ?~ \"system.admin\"",
    "deleteRule": null
  })

  return app.save(collection)
}, (app) => {
  var collection = app.findCollectionByNameOrId("pbc_2454967760")
  return app.delete(collection)
})
