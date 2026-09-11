/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_sale_con_usage");

  // PocketBase treats 0 as blank on required number fields; allow zero usage.
  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number_sale_con_qty",
    "max": null,
    "min": 0,
    "name": "quantity",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number",
  }));

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_sale_con_usage");

  collection.fields.addAt(4, new Field({
    "hidden": false,
    "id": "number_sale_con_qty",
    "max": null,
    "min": 0,
    "name": "quantity",
    "onlyInt": false,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number",
  }));

  return app.save(collection);
});
