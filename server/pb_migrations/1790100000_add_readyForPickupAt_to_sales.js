/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  collection.fields.add(new Field({
    "hidden": false,
    "id": "date_readyForPickupAt_sales",
    "max": "",
    "min": "",
    "name": "readyForPickupAt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  collection.fields.removeById("date_readyForPickupAt_sales")

  return app.save(collection)
})
