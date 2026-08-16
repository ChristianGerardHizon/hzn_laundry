/// <reference path="../pb_data/types.d.ts" />

// Remove vw_add_ons_summary. The dashboard Add-ons Sold KPI now aggregates
// today's saleItems in the app; this view scanned all historical sales.
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_addonssum01");

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
        "cascadeDelete": false,
        "collectionId": "pbc_4092854851",
        "help": "",
        "hidden": false,
        "id": "_clone_U9ev",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "product",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "_clone_a8kY",
        "max": 0,
        "min": 0,
        "name": "productName",
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
        "id": "_clone_qBr3",
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
        "id": "_clone_qcRi",
        "name": "postedDate",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2697449135",
        "help": "",
        "hidden": false,
        "id": "relation3846946821",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "sale",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json2683508278",
        "maxSize": 1,
        "name": "quantity",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json3910233221",
        "maxSize": 1,
        "name": "revenue",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_addonssum01",
    "indexes": [],
    "listRule": "",
    "name": "vw_add_ons_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.product,\n  si.productName,\n  s.branch,\n  s.postedDate,\n  s.id AS sale,\n  SUM(si.quantity) AS quantity,\n  SUM(si.subtotal) AS revenue\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE s.status != 'voided'\nGROUP BY s.id, si.product, si.productName, s.branch, s.postedDate",
    "viewRule": ""
  });

  return app.save(collection);
})
