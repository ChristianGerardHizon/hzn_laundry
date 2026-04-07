/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // add field
  collection.fields.addAt(17, new Field({
    "hidden": false,
    "id": "select_paymentstatus",
    "maxSelect": 1,
    "name": "paymentStatus",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "unpaid",
      "partial",
      "paid"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // remove field
  collection.fields.removeById("select_paymentstatus")

  return app.save(collection)
})
