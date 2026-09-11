/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297");

  collection.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_organizations01",
    "hidden": false,
    "id": "relation_branches_org",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "organization",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297");
  collection.fields.removeById("relation_branches_org");
  return app.save(collection);
});
