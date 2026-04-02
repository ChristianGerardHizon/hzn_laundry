/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("saleServiceItems")

  // Update machine relation field to allow multiple selections
  const machineField = collection.fields.getById("relation_ssi_machine")
  machineField.maxSelect = 99

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("saleServiceItems")

  // Revert to single selection
  const machineField = collection.fields.getById("relation_ssi_machine")
  machineField.maxSelect = 1

  return app.save(collection)
})
