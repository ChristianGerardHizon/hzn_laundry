/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("saleServiceItems")

  // add machine relation field
  collection.fields.addAt(collection.fields.length, new Field({
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

  // add machineName text field (snapshot)
  collection.fields.addAt(collection.fields.length, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_ssi_machineName",
    "max": 200,
    "min": 0,
    "name": "machineName",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add storage relation field
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

  // add storageName text field (snapshot)
  collection.fields.addAt(collection.fields.length, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_ssi_storageName",
    "max": 200,
    "min": 0,
    "name": "storageName",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("saleServiceItems")

  // remove fields in reverse order
  collection.fields.removeById("text_ssi_storageName")
  collection.fields.removeById("relation_ssi_storage")
  collection.fields.removeById("text_ssi_machineName")
  collection.fields.removeById("relation_ssi_machine")

  return app.save(collection)
})
