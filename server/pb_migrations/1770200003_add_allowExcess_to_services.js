/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // add field
  collection.fields.addAt(15, new Field({
    "hidden": false,
    "id": "bool3849275849",
    "name": "allowExcess",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // remove field
  collection.fields.removeById("bool3849275849")

  return app.save(collection)
})
