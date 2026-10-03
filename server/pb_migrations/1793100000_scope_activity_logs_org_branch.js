/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428");

  collection.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_organizations01",
    "hidden": false,
    "id": "rel_activityLogs_organization",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "organization",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));

  collection.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": "rel_activityLogs_branch",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));

  const indexes = collection.indexes || [];
  indexes.push("CREATE INDEX `idx_activityLogs_organization` ON `activityLogs` (`organization`)");
  indexes.push("CREATE INDEX `idx_activityLogs_branch` ON `activityLogs` (`branch`)");
  collection.indexes = indexes;

  // Persist new fields before any record writes.
  app.save(collection);

  // Unscoped historical logs cannot be listed under membership rules.
  // Clear the table so new hooks start with a clean org/branch-scoped trail.
  const logs = app.findAllRecords("activityLogs");
  for (let i = 0; i < logs.length; i++) {
    app.delete(logs[i]);
  }

  const memberRule =
    '@request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  collection.listRule = memberRule;
  collection.viewRule = memberRule;
  collection.createRule = null;
  collection.updateRule = null;
  collection.deleteRule = null;

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428");

  collection.indexes = (collection.indexes || []).filter(
    (idx) =>
      idx.indexOf("idx_activityLogs_organization") === -1 &&
      idx.indexOf("idx_activityLogs_branch") === -1
  );

  collection.fields.removeById("rel_activityLogs_organization");
  collection.fields.removeById("rel_activityLogs_branch");

  const openRule = '@request.auth.id != ""';
  collection.listRule = openRule;
  collection.viewRule = openRule;
  collection.createRule = openRule;
  collection.updateRule = openRule;
  collection.deleteRule = openRule;

  return app.save(collection);
});
