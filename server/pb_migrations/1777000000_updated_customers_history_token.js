/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001")

  // add email
  collection.fields.add(new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "email3885137012",
    "name": "email",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "email"
  }))

  // add historyToken
  collection.fields.add(new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text3370552920",
    "max": 0,
    "min": 0,
    "name": "historyToken",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add historyTokenExpiresAt
  collection.fields.add(new Field({
    "hidden": false,
    "id": "date3146614014",
    "max": "",
    "min": "",
    "name": "historyTokenExpiresAt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // unique index on historyToken (partial — ignore empty)
  collection.indexes = [
    "CREATE UNIQUE INDEX `idx_customers_historyToken` ON `customers` (`historyToken`) WHERE `historyToken` != \"\""
  ]

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001")

  collection.fields.removeById("email3885137012")
  collection.fields.removeById("text3370552920")
  collection.fields.removeById("date3146614014")
  collection.indexes = []

  return app.save(collection)
})
