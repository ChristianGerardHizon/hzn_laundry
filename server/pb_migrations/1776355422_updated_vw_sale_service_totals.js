/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_384506597")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, s.processedDate, COALESCE(s.postedDate, s.created) AS effectivePostedDate, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"ready\", \"pickedUp\") GROUP BY s.id"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_w5O8")

  // remove field
  collection.fields.removeById("_clone_58vh")

  // remove field
  collection.fields.removeById("_clone_ZO9r")

  // remove field
  collection.fields.removeById("_clone_khVQ")

  // remove field
  collection.fields.removeById("_clone_9dFH")

  // remove field
  collection.fields.removeById("_clone_oFzu")

  // remove field
  collection.fields.removeById("_clone_ME0q")

  // remove field
  collection.fields.removeById("_clone_8vCE")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_qqUD",
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
    "id": "_clone_Ade1",
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
    "id": "_clone_M1zH",
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
    "id": "_clone_8Vzf",
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
    "id": "_clone_jjvg",
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
    "id": "_clone_uIqr",
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
    "id": "_clone_pjPJ",
    "name": "updated",
    "onCreate": true,
    "onUpdate": true,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "_clone_l0O4",
    "max": "",
    "min": "",
    "name": "processedDate",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "json758605309",
    "maxSize": 1,
    "name": "effectivePostedDate",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_384506597")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, s.processedDate, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"ready\", \"pickedUp\") GROUP BY s.id"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "hidden": false,
    "id": "_clone_w5O8",
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
    "id": "_clone_58vh",
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
    "id": "_clone_ZO9r",
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
    "id": "_clone_khVQ",
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
    "id": "_clone_9dFH",
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
    "id": "_clone_oFzu",
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
    "id": "_clone_ME0q",
    "name": "updated",
    "onCreate": true,
    "onUpdate": true,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // add field
  collection.fields.addAt(8, new Field({
    "hidden": false,
    "id": "_clone_8vCE",
    "max": "",
    "min": "",
    "name": "processedDate",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // remove field
  collection.fields.removeById("_clone_qqUD")

  // remove field
  collection.fields.removeById("_clone_Ade1")

  // remove field
  collection.fields.removeById("_clone_M1zH")

  // remove field
  collection.fields.removeById("_clone_8Vzf")

  // remove field
  collection.fields.removeById("_clone_jjvg")

  // remove field
  collection.fields.removeById("_clone_uIqr")

  // remove field
  collection.fields.removeById("_clone_pjPJ")

  // remove field
  collection.fields.removeById("_clone_l0O4")

  // remove field
  collection.fields.removeById("json758605309")

  return app.save(collection)
})
