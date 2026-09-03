/// <reference path="../pb_data/types.d.ts" />
// Live machines/storages were created without a branch field (the original
// create migration pointed at a non-existent branches collection id, so the
// field never landed). Add it with the real branches id before org-scope rules.
migrate((app) => {
  const branchField = (id) => new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": id,
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  });

  const machines = app.findCollectionByNameOrId("pbc_machines0001");
  if (!machines.fields.getById("relation_machines_branch")) {
    machines.fields.add(branchField("relation_machines_branch"));
  } else {
    machines.fields.getById("relation_machines_branch").collectionId = "pbc_2358601297";
  }
  app.save(machines);

  const storages = app.findCollectionByNameOrId("pbc_storages0001");
  if (!storages.fields.getById("relation_storages_branch")) {
    storages.fields.add(branchField("relation_storages_branch"));
  } else {
    storages.fields.getById("relation_storages_branch").collectionId = "pbc_2358601297";
  }
  return app.save(storages);
}, (app) => {
  const machines = app.findCollectionByNameOrId("pbc_machines0001");
  machines.fields.removeById("relation_machines_branch");
  app.save(machines);

  const storages = app.findCollectionByNameOrId("pbc_storages0001");
  storages.fields.removeById("relation_storages_branch");
  return app.save(storages);
});
