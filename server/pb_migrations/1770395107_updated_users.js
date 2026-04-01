/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "authAlert": {
      "enabled": false
    },
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_DiodYfwMRw` ON `users` (`userName`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ],
    "passwordAuth": {
      "identityFields": [
        "userName"
      ]
    }
  }, collection)

  // add field
  collection.fields.addAt(11, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1483516233",
    "max": 255,
    "min": 3,
    "name": "userName",
    "pattern": "",
    "presentable": true,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  // update field
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
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "authAlert": {
      "enabled": true
    },
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ],
    "passwordAuth": {
      "identityFields": [
        "email"
      ]
    }
  }, collection)

  // remove field
  collection.fields.removeById("text1483516233")

  // update field
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
})
