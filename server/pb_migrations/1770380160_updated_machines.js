/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_machines0001")

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "bool594724188",
    "name": "strictSingleUse",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_machines0001")

  // remove field
  collection.fields.removeById("bool594724188")

  return app.save(collection)
})
