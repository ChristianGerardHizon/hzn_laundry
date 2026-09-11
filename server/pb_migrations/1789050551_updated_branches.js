/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // add field
  collection.fields.addAt(12, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "text_branch_slug",
    "max": 64,
    "min": 1,
    "name": "slug",
    "pattern": "^[a-z0-9]+(?:-[a-z0-9]+)*$",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // remove field
  collection.fields.removeById("text_branch_slug")

  return app.save(collection)
})
