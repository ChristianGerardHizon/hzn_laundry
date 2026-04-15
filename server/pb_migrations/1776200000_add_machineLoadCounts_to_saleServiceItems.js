/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // Add machineLoadCounts JSON field to track how many times each machine
  // should run for this service item (e.g. double wash)
  collection.fields.add(new Field({
    "hidden": false,
    "id": "json_ssi_machineLoadCounts",
    "maxSize": 2000,
    "name": "machineLoadCounts",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  collection.fields.removeById("json_ssi_machineLoadCounts")

  return app.save(collection)
})
