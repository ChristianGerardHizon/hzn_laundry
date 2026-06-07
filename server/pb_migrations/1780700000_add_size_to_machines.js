/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_machines0001")

  // Add machine size classification (small / large). Optional so legacy
  // machines without a size keep loading; UI treats empty as "unspecified".
  collection.fields.add(new Field({
    "hidden": false,
    "id": "select_machines_size",
    "maxSelect": 1,
    "name": "size",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "small",
      "large"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_machines0001")

  collection.fields.removeById("select_machines_size")

  return app.save(collection)
})
