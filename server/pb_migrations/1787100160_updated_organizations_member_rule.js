/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_organizations01");
  const rule =
    '@request.auth.id != "" && organizationMemberships_via_organization.user ?= @request.auth.id';
  unmarshal({
    listRule: rule,
    viewRule: rule,
  }, collection);
  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_organizations01");
  unmarshal({
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
  }, collection);
  return app.save(collection);
});
