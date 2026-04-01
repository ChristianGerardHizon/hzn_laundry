/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // add field
  collection.fields.addAt(13, new Field({
    "hidden": false,
    "id": "bool3989496142",
    "name": "showPrompt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // remove field
  collection.fields.removeById("bool3989496142")

  return app.save(collection)
})
