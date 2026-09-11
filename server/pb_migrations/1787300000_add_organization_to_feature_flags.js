/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2454967760");

  collection.fields.add(new Field({
    "cascadeDelete": true,
    "collectionId": "pbc_organizations01",
    "hidden": false,
    "id": "rel_feature_flags_org",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "organization",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));

  const indexes = collection.indexes || [];
  collection.indexes = indexes.filter((idx) =>
    String(idx).indexOf("idx_featureFlags_key") === -1
  );

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2454967760");
  collection.fields.removeById("rel_feature_flags_org");
  const indexes = collection.indexes || [];
  if (indexes.every((idx) => String(idx).indexOf("idx_featureFlags_key") === -1)) {
    indexes.push("CREATE UNIQUE INDEX `idx_featureFlags_key` ON `featureFlags` (`key`)");
  }
  collection.indexes = indexes;
  return app.save(collection);
});
