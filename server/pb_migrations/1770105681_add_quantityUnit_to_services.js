/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // add quantityUnit relation field
  collection.fields.addAt(12, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_quantityunits",
    "hidden": false,
    "id": "relation_quantity_unit",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "quantityUnit",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_services001")

  // remove field
  collection.fields.removeById("relation_quantity_unit")

  return app.save(collection)
})
