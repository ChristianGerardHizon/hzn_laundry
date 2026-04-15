/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_payments001")

  // update field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "select_payment_method",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "gcash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_payments001")

  // update field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "select_payment_method",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  return app.save(collection)
})
