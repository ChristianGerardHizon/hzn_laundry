/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": "@request.auth.id != \"\"",
    "deleteRule": "@request.auth.id != \"\"",
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
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text4232930610",
        "max": 0,
        "min": 0,
        "name": "collection",
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
        "id": "text576187720",
        "max": 0,
        "min": 0,
        "name": "recordId",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "select1204587666",
        "maxSelect": 1,
        "name": "action",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "create",
          "update",
          "delete"
        ]
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
      },
      {
        "hidden": false,
        "id": "json539015229",
        "maxSize": 0,
        "name": "changes",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_3841632486",
        "hidden": false,
        "id": "relation2375276105",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "user",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      }
    ],
    "id": "pbc_947366428",
    "indexes": [
      "CREATE INDEX idx_activityLogs_collection ON activityLogs (collection)",
      "CREATE INDEX idx_activityLogs_user ON activityLogs (user)",
      "CREATE INDEX idx_activityLogs_recordId ON activityLogs (recordId)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "name": "activityLogs",
    "system": false,
    "type": "base",
    "updateRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428");

  return app.delete(collection);
})
