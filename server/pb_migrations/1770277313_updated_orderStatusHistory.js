/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_orderstatushistory")

  // update field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2697449135",
    "hidden": false,
    "id": "relation4004369230",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "sale",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_orderstatushistory")

  // update field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2697449135",
    "hidden": false,
    "id": "relation4004369230",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "sales",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
})
