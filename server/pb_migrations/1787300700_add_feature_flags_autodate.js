/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2454967760");

  collection.fields.add(new Field({
    "hidden": false,
    "id": "autodate_feature_flags_created",
    "name": "created",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate",
  }));

  collection.fields.add(new Field({
    "hidden": false,
    "id": "autodate_feature_flags_updated",
    "name": "updated",
    "onCreate": true,
    "onUpdate": true,
    "presentable": false,
    "system": false,
    "type": "autodate",
  }));

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2454967760");
  collection.fields.removeById("autodate_feature_flags_created");
  collection.fields.removeById("autodate_feature_flags_updated");
  return app.save(collection);
});
