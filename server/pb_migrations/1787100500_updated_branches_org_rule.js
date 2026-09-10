/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297");
  const rule =
    '@request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  unmarshal({
    listRule: rule,
    viewRule: rule,
    createRule: rule,
    updateRule: rule,
    deleteRule: rule,
  }, collection);
  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297");
  unmarshal({
    listRule: "",
    viewRule: "",
    createRule: "",
    updateRule: "",
    deleteRule: "",
  }, collection);
  return app.save(collection);
});
