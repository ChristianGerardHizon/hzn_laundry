/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_payments001")

  // add field
  collection.fields.addAt(11, new Field({
    "hidden": false,
    "id": "bool_payment_isVoided",
    "name": "isVoided",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(12, new Field({
    "hidden": false,
    "id": "date_payment_voidedAt",
    "max": "",
    "min": "",
    "name": "voidedAt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(13, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text_payment_voidReason",
    "max": 0,
    "min": 0,
    "name": "voidReason",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_payments001")

  // remove field
  collection.fields.removeById("bool_payment_isVoided")

  // remove field
  collection.fields.removeById("date_payment_voidedAt")

  // remove field
  collection.fields.removeById("text_payment_voidReason")

  return app.save(collection)
})
