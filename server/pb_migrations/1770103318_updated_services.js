/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "bool3989496142",
    "name": "showPrompt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(11, new Field({
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
  collection.fields.removeById("bool3989496142")

  // remove field
  collection.fields.removeById("number2252263257")

  return app.save(collection)
})
