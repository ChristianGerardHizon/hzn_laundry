/// <reference path="../pb_data/types.d.ts" />
// Adds subscriptionPackages.features (JSON array of feature keys) and seeds
// every existing package with the catalog so nobody loses access.
//
// `consumableUsage` was an opt-in per-org flag (default off), so it is NOT
// seeded into packages; orgs that had it on get an override in the next
// migration. Super Admin can add it to a package later.
const ALL_FEATURE_KEYS = [
  "employees",
  "attendance",
  "products",
  "promos",
  "reports",
  "activities",
  "machineLoadRules",
  "storages",
  "posGroups",
  "customerHistoryLink",
  "multiBranch",
];

migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_subscription_packages");

  if (!collection.fields.getById("json_subpkg_features")) {
    collection.fields.add(new Field({
      "hidden": false,
      "id": "json_subpkg_features",
      "maxSize": 0,
      "name": "features",
      "presentable": false,
      "required": false,
      "system": false,
      "type": "json"
    }));
    app.save(collection);
  }

  const packages = app.findAllRecords("subscriptionPackages");
  for (let i = 0; i < packages.length; i++) {
    packages[i].set("features", ALL_FEATURE_KEYS);
    app.save(packages[i]);
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_subscription_packages");
  collection.fields.removeById("json_subpkg_features");
  return app.save(collection);
});
