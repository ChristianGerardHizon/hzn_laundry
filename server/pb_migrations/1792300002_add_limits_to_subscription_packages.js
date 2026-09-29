/// <reference path="../pb_data/types.d.ts" />
// Adds numeric limits to subscription packages. Empty/0 = unlimited, so
// existing packages (and the orgs on them) are not restricted.
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_subscription_packages");

  if (!collection.fields.getById("number_subpkg_max_branches")) {
    collection.fields.add(new Field({
      "hidden": false,
      "id": "number_subpkg_max_branches",
      "max": null,
      "min": 0,
      "name": "maxBranches",
      "onlyInt": true,
      "presentable": false,
      "required": false,
      "system": false,
      "type": "number"
    }));
  }
  if (!collection.fields.getById("number_subpkg_max_employees")) {
    collection.fields.add(new Field({
      "hidden": false,
      "id": "number_subpkg_max_employees",
      "max": null,
      "min": 0,
      "name": "maxEmployees",
      "onlyInt": true,
      "presentable": false,
      "required": false,
      "system": false,
      "type": "number"
    }));
  }
  app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_subscription_packages");
  collection.fields.removeById("number_subpkg_max_branches");
  collection.fields.removeById("number_subpkg_max_employees");
  return app.save(collection);
});
