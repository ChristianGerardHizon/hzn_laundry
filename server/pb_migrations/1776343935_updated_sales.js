/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // add field
  collection.fields.addAt(18, new Field({
    "hidden": false,
    "id": "date1925540082",
    "max": "",
    "min": "",
    "name": "processedDate",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // remove field
  collection.fields.removeById("date1925540082")

  return app.save(collection)
})
