/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const usersCollectionId = "pbc_3841632486";

  const payments = app.findCollectionByNameOrId("pbc_payments001");
  payments.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": usersCollectionId,
    "hidden": false,
    "id": "relation_payment_voidedBy",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voidedBy",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));
  app.save(payments);

  const sales = app.findCollectionByNameOrId("pbc_2697449135");
  sales.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": usersCollectionId,
    "hidden": false,
    "id": "relation_sale_voidedBy",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voidedBy",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));
  sales.fields.add(new Field({
    "hidden": false,
    "id": "date_sale_voidedAt",
    "max": "",
    "min": "",
    "name": "voidedAt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }));
  return app.save(sales);
}, (app) => {
  const sales = app.findCollectionByNameOrId("pbc_2697449135");
  sales.fields.removeById("date_sale_voidedAt");
  sales.fields.removeById("relation_sale_voidedBy");
  app.save(sales);

  const payments = app.findCollectionByNameOrId("pbc_payments001");
  payments.fields.removeById("relation_payment_voidedBy");
  return app.save(payments);
});
