/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "number565159659",
    "max": null,
    "min": 0,
    "name": "incentiveAmount",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "number3808722339",
    "max": null,
    "min": 1,
    "name": "incentivePerServiceItems",
    "onlyInt": true,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // remove field
  collection.fields.removeById("number565159659")

  // remove field
  collection.fields.removeById("number3808722339")

  return app.save(collection)
})
