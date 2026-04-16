/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_384506597")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"ready\", \"pickedUp\") GROUP BY s.id"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_R7A4")

  // remove field
  collection.fields.removeById("_clone_uDgZ")

  // remove field
  collection.fields.removeById("_clone_Th3r")

  // remove field
  collection.fields.removeById("_clone_0FCw")

  // remove field
  collection.fields.removeById("_clone_BmnZ")

  // remove field
  collection.fields.removeById("_clone_D5c4")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_YWuU",
    "max": 0,
    "min": 0,
    "name": "receiptNumber",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": "_clone_YVr5",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_AXPy",
    "max": 0,
    "min": 0,
    "name": "customerName",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "_clone_6Gee",
    "maxSelect": 1,
    "name": "orderStatus",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "pending",
      "processing",
      "ready",
      "pickedUp"
    ]
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "_clone_Pi9W",
    "name": "postedDate",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "_clone_ugdt",
    "name": "created",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // add field
  collection.fields.addAt(7, new Field({
    "hidden": false,
    "id": "_clone_0Y05",
    "name": "updated",
    "onCreate": true,
    "onUpdate": true,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_384506597")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"ready\", \"pickedUp\") GROUP BY s.id"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_R7A4",
    "max": 0,
    "min": 0,
    "name": "receiptNumber",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": "_clone_uDgZ",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_Th3r",
    "max": 0,
    "min": 0,
    "name": "customerName",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "_clone_0FCw",
    "maxSelect": 1,
    "name": "orderStatus",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "pending",
      "processing",
      "ready",
      "pickedUp"
    ]
  }))

  // add field
  collection.fields.addAt(5, new Field({
    "hidden": false,
    "id": "_clone_BmnZ",
    "name": "postedDate",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // add field
  collection.fields.addAt(6, new Field({
    "hidden": false,
    "id": "_clone_D5c4",
    "name": "created",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // remove field
  collection.fields.removeById("_clone_YWuU")

  // remove field
  collection.fields.removeById("_clone_YVr5")

  // remove field
  collection.fields.removeById("_clone_AXPy")

  // remove field
  collection.fields.removeById("_clone_6Gee")

  // remove field
  collection.fields.removeById("_clone_Pi9W")

  // remove field
  collection.fields.removeById("_clone_ugdt")

  // remove field
  collection.fields.removeById("_clone_0Y05")

  return app.save(collection)
})
