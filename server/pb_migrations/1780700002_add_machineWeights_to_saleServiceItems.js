/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  // Add machineWeights JSON field storing the entered weight (kg) per machine
  // that produced the auto load count. Supplementary/auditable; machineLoadCounts
  // remains the source of truth for the actual load count.
  collection.fields.add(new Field({
    "hidden": false,
    "id": "json_ssi_machineWeights",
    "maxSize": 2000,
    "name": "machineWeights",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_salesvcitm01")

  collection.fields.removeById("json_ssi_machineWeights")

  return app.save(collection)
})
