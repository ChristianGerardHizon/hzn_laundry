/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ]
  }, collection)

  collection.fields.removeById("text1483516233")

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_DiodYfwMRw` ON `users` (`username`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ]
  }, collection)

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
})
