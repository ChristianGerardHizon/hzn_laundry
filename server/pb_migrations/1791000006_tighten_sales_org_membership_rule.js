/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");
  // Require a branch and membership in that branch's organization.
  // Drops the previous `branch = ""` bypass so blank-branch sales are not
  // readable by any authenticated user.
  const rule =
    '@request.auth.id != "" && branch != "" && branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  unmarshal({
    listRule: rule,
    viewRule: rule,
    createRule: rule,
    updateRule: rule,
    deleteRule: rule,
  }, collection);
  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");
  const previous =
    '@request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';
  unmarshal({
    listRule: previous,
    viewRule: previous,
    createRule: previous,
    updateRule: previous,
    deleteRule: previous,
  }, collection);
  return app.save(collection);
});
