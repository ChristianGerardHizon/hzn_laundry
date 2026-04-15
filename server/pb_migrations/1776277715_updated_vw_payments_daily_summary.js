/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_566873343")

  // remove field
  collection.fields.removeById("_clone_BT7A")

  // remove field
  collection.fields.removeById("_clone_uykn")

  // remove field
  collection.fields.removeById("_clone_VmVN")

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "_clone_Tls3",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "gcash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "_clone_9gkr",
    "maxSelect": 1,
    "name": "paymentType",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "payment",
      "deposit",
      "refund"
    ]
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": "_clone_QWG6",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_566873343")

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "_clone_BT7A",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "gcash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "_clone_uykn",
    "maxSelect": 1,
    "name": "paymentType",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "payment",
      "deposit",
      "refund"
    ]
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": "_clone_VmVN",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_Tls3")

  // remove field
  collection.fields.removeById("_clone_9gkr")

  // remove field
  collection.fields.removeById("_clone_QWG6")

  return app.save(collection)
})
