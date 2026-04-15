/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_566873343")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(COALESCE(p.postedDate, p.created)) AS paymentDate,\n  p.paymentMethod,\n  p.type AS paymentType,\n  s.branch,\n  COUNT(p.id) AS paymentCount,\n  SUM(p.amount) AS totalAmount\nFROM payments p\nJOIN sales s ON p.sale = s.id\nWHERE s.status != 'voided'\n  AND COALESCE(p.isVoided, false) = false\nGROUP BY DATE(COALESCE(p.postedDate, p.created)), p.paymentMethod, p.type, s.branch\nORDER BY paymentDate DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_2bmu")

  // remove field
  collection.fields.removeById("_clone_4Aex")

  // remove field
  collection.fields.removeById("_clone_aM9t")

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "_clone_VqQ6",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "_clone_HRAS",
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
    "id": "_clone_oEA8",
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

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(p.created) AS paymentDate,\n  p.paymentMethod,\n  p.type AS paymentType,\n  s.branch,\n  COUNT(p.id) AS paymentCount,\n  SUM(p.amount) AS totalAmount\nFROM payments p\nJOIN sales s ON p.sale = s.id\nWHERE s.status != 'voided'\nGROUP BY DATE(p.created), p.paymentMethod, p.type, s.branch\nORDER BY paymentDate DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "_clone_2bmu",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "_clone_4Aex",
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
    "id": "_clone_aM9t",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_VqQ6")

  // remove field
  collection.fields.removeById("_clone_HRAS")

  // remove field
  collection.fields.removeById("_clone_oEA8")

  return app.save(collection)
})
