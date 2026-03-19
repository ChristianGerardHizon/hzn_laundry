/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_DiodYfwMRw` ON `users` (`username`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ],
    "passwordAuth": {
      "identityFields": [
        "username",
        "email"
      ]
    }
  }, collection)

  // update field
  collection.fields.addAt(11, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "text1483516233",
    "max": 255,
    "min": 3,
    "name": "username",
    "pattern": "",
    "presentable": true,
    "primaryKey": false,
    "required": true,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_DiodYfwMRw` ON `users` (`userName`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ],
    "passwordAuth": {
      "identityFields": [
        "userName",
        "email"
      ]
    }
  }, collection)

  // update field
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

  return app.save(collection)
})
