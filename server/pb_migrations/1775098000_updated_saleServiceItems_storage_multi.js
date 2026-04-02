/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // update storage field to allow multiple selections
  collection.fields.addAt(collection.fields.length, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_storages0001",
    "hidden": false,
    "id": "relation_ssi_storage",
    "maxSelect": 99,
    "minSelect": 0,
    "name": "storage",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // revert storage field to single selection
  collection.fields.addAt(collection.fields.length, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_storages0001",
    "hidden": false,
    "id": "relation_ssi_storage",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "storage",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
})
