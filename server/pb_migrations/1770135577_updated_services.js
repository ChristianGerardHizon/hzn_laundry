/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // add field
  collection.fields.addAt(14, new Field({
    "hidden": false,
    "id": "number2252263257",
    "max": null,
    "min": null,
    "name": "maxQuantity",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // remove field
  collection.fields.removeById("number2252263257")

  return app.save(collection)
})
