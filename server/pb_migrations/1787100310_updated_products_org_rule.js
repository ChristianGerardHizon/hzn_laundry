/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851");
  const rule =
    '@request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';
  unmarshal({
    listRule: rule,
    viewRule: rule,
    createRule: rule,
    updateRule: rule,
    deleteRule: rule,
  }, collection);
  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851");
  unmarshal({
    listRule: '@request.auth.id != ""',
    viewRule: "",
    createRule: "",
    updateRule: "",
    deleteRule: "",
  }, collection);
  return app.save(collection);
});
