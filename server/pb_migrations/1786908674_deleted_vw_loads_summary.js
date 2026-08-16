/// <reference path="../pb_data/types.d.ts" />

// Remove vw_loads_summary. The dashboard Loads KPI now sums
// machineLoadCounts from today's saleServiceItems in the app; this view
// scanned all historical sales with json_each.
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_loadssum001");

  return app.delete(collection);
}, (app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "help": "",
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
        "help": "",
        "hidden": false,
        "id": "_clone_7VkR",
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
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "_clone_7OcU",
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
        "help": "",
        "hidden": false,
        "id": "_clone_ileT",
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
        "id": "_clone_vN49",
        "name": "postedDate",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json2016257334",
        "maxSize": 1,
        "name": "loads",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_loadssum001",
    "indexes": [],
    "listRule": "",
    "name": "vw_loads_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  s.id,\n  s.receiptNumber,\n  s.customerName,\n  s.branch,\n  s.postedDate,\n  COALESCE(SUM(le.value), 0) AS loads\nFROM sales s\nLEFT JOIN saleServiceItems si ON si.sale = s.id\nLEFT JOIN json_each(si.machineLoadCounts) le ON 1=1\nWHERE s.status != 'voided'\nGROUP BY s.id",
    "viewRule": ""
  });

  return app.save(collection);
})
