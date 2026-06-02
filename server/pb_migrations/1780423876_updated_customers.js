/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_customers_historyToken` ON `customers` (`historyToken`) WHERE `historyToken` != \"\""
    ]
  }, collection)

  // add field
  collection.fields.addAt(7, new Field({
    "exceptDomains": null,
    "help": "",
    "hidden": false,
    "id": "email3885137012",
    "name": "email",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "email"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "autogeneratePattern": "",
    "help": "",
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

  // add field
  collection.fields.addAt(9, new Field({
    "help": "",
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

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001")

  // update collection data
  unmarshal({
    "indexes": []
  }, collection)

  // remove field
  collection.fields.removeById("email3885137012")

  // remove field
  collection.fields.removeById("text3370552920")

  // remove field
  collection.fields.removeById("date3146614014")

  return app.save(collection)
})
