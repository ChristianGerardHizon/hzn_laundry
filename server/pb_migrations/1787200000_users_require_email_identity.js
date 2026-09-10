/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  unmarshal({
    "passwordAuth": {
      "identityFields": ["email"]
    }
  }, collection)

  collection.fields.addAt(3, new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "email3885137012",
    "name": "email",
    "onlyDomains": null,
    "presentable": false,
    "required": true,
    "system": true,
    "type": "email"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  unmarshal({
    "passwordAuth": {
      "identityFields": ["username", "email"]
    }
  }, collection)

  collection.fields.addAt(3, new Field({
    "exceptDomains": null,
    "hidden": false,
    "id": "email3885137012",
    "name": "email",
    "onlyDomains": null,
    "presentable": false,
    "required": false,
    "system": true,
    "type": "email"
  }))

  return app.save(collection)
})
