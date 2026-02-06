/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("saleServiceItems")

  // Add status field (select: pending, in_progress, completed)
  // Tracks the completion status of individual service items
  // independently from the overall order status
  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "select_ssi_status",
    "maxSelect": 1,
    "name": "status",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": ["pending", "in_progress", "completed"]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("saleServiceItems")

  // Remove status field
  collection.fields.removeById("select_ssi_status")

  return app.save(collection)
})
