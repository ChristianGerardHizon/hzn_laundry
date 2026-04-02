/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_812455569")

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "number_flat_price",
    "max": null,
    "min": null,
    "name": "flatPrice",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number2364876845",
    "max": null,
    "min": null,
    "name": "pricePerUnit",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_812455569")

  // remove field
  collection.fields.removeById("number_flat_price")

  // update field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number2364876845",
    "max": null,
    "min": null,
    "name": "pricePerUnit",
    "onlyInt": false,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
})
