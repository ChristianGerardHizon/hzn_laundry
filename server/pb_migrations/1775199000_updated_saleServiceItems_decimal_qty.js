/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // update quantity field to allow decimal values
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number_ssvi_qty",
    "max": null,
    "min": 1,
    "name": "quantity",
    "onlyInt": false,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // revert: quantity back to integer only
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number_ssvi_qty",
    "max": null,
    "min": 1,
    "name": "quantity",
    "onlyInt": true,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
})
