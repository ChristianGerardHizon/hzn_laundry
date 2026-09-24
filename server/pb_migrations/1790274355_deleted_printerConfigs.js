/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_1716876360");
    return app.delete(collection);
  } catch (_) {
    // Already removed (e.g. deleted via Admin API before this migration ran).
  }
}, (app) => {
  const collection = new Collection({
    "createRule": "@request.auth.id != \"\" && (branch = \"\" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "deleteRule": "@request.auth.id != \"\" && (branch = \"\" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "help": "",
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
        "help": "",
        "hidden": false,
        "id": "text1579384326",
        "max": 0,
        "min": 0,
        "name": "name",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "select2103011799",
        "maxSelect": 1,
        "name": "connectionType",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "select",
        "values": [
          "bluetooth",
          "network"
        ]
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text223244161",
        "max": 0,
        "min": 0,
        "name": "address",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "number1133600204",
        "max": null,
        "min": null,
        "name": "port",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "help": "",
        "hidden": false,
        "id": "select3860249383",
        "maxSelect": 1,
        "name": "paperWidth",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "select",
        "values": [
          "mm58",
          "mm80"
        ]
      },
      {
        "help": "",
        "hidden": false,
        "id": "bool2241418015",
        "name": "isDefault",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "help": "",
        "hidden": false,
        "id": "bool910092356",
        "name": "isEnabled",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "help": "",
        "hidden": false,
        "id": "relation3146128159",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "branch",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "help": "",
        "hidden": false,
        "id": "bool2382110195",
        "name": "isDeleted",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool"
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": true,
        "onUpdate": true,
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "id": "pbc_1716876360",
    "indexes": [],
    "listRule": "@request.auth.id != \"\" && (branch = \"\" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "name": "printerConfigs",
    "system": false,
    "type": "base",
    "updateRule": "@request.auth.id != \"\" && (branch = \"\" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "viewRule": "@request.auth.id != \"\" && (branch = \"\" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)"
  });

  return app.save(collection);
})
