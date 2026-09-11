/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851");

  collection.fields.add(new Field({
    "hidden": false,
    "id": "bool_is_consumable",
    "name": "isConsumable",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool",
  }));
  collection.fields.add(new Field({
    "hidden": false,
    "id": "bool_counts_material_cost",
    "name": "countsTowardMaterialCost",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool",
  }));
  collection.fields.add(new Field({
    "hidden": false,
    "id": "number_usage_min",
    "max": null,
    "min": 0,
    "name": "usageMin",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number",
  }));
  collection.fields.add(new Field({
    "hidden": false,
    "id": "number_usage_max",
    "max": null,
    "min": 0,
    "name": "usageMax",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number",
  }));
  collection.fields.add(new Field({
    "hidden": false,
    "id": "number_usage_step",
    "max": null,
    "min": 0,
    "name": "usageStep",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number",
  }));
  collection.fields.add(new Field({
    "hidden": false,
    "id": "number_default_usage",
    "max": null,
    "min": 0,
    "name": "defaultUsage",
    "onlyInt": false,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number",
  }));

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851");
  collection.fields.removeById("bool_is_consumable");
  collection.fields.removeById("bool_counts_material_cost");
  collection.fields.removeById("number_usage_min");
  collection.fields.removeById("number_usage_max");
  collection.fields.removeById("number_usage_step");
  collection.fields.removeById("number_default_usage");
  return app.save(collection);
});
