/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // update field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_machines0001",
    "hidden": false,
    "id": "relation_ssi_machine",
    "maxSelect": 99,
    "minSelect": 0,
    "name": "machine",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // update field
  collection.fields.addAt(9, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_machines0001",
    "hidden": false,
    "id": "relation_ssi_machine",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "machine",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
})
