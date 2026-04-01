/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // Add orderStatus field (select: pending, processing, ready, pickedUp)
  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "select_orderstatus",
    "maxSelect": 1,
    "name": "orderStatus",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": ["pending", "processing", "ready", "pickedUp"]
  }))

  // Remove isPickedUp field (replaced by orderStatus=pickedUp)
  collection.fields.removeById("bool_ispickedup")

  // Remove paymentMethod field (moved to payments collection)
  collection.fields.removeById("select_paymentmethod")

  // Remove paymentRef field (moved to payments collection)
  collection.fields.removeById("text_paymentref")

  // Remove paymentProof field (moved to payments collection)
  collection.fields.removeById("file_paymentproof")

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // Remove orderStatus field
  collection.fields.removeById("select_orderstatus")

  // Re-add isPickedUp field
  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "bool_ispickedup",
    "name": "isPickedUp",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // Re-add paymentMethod field
  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "select_paymentmethod",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": ["cash", "card", "bankTransfer", "check"]
  }))

  // Re-add paymentRef field
  collection.fields.addAt(collection.fields.length, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_paymentref",
    "max": 0,
    "min": 0,
    "name": "paymentRef",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // Re-add paymentProof field
  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "file_paymentproof",
    "maxSelect": 1,
    "maxSize": 5242880,
    "mimeTypes": ["image/jpeg", "image/png", "image/gif"],
    "name": "paymentProof",
    "presentable": false,
    "protected": false,
    "required": false,
    "system": false,
    "thumbs": [],
    "type": "file"
  }))

  return app.save(collection)
})
