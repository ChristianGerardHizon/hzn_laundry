/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_storages0001")

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "bool2382110195",
    "name": "isDeleted",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_storages0001")

  // remove field
  collection.fields.removeById("bool2382110195")

  return app.save(collection)
})
