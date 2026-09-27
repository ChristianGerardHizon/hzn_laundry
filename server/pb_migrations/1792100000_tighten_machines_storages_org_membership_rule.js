/// <reference path="../pb_data/types.d.ts" />
/**
 * Tighten machines/storages org membership rules:
 * - Require a non-empty branch + membership in that branch's organization
 * - Drop the previous `branch = ""` bypass (cross-org leak for blank-branch rows)
 * - Keep soft-delete hardening from 1792000001 (list/view/update exclude deleted;
 *   hard delete superuser-only)
 */
migrate((app) => {
  const notDeleted = "(isDeleted = false || isDeleted = null)";
  const membership =
    '@request.auth.id != "" && branch != "" && branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  const withNotDeleted = membership + " && " + notDeleted;

  function tighten(collectionNameOrId) {
    const collection = app.findCollectionByNameOrId(collectionNameOrId);
    unmarshal({
      listRule: withNotDeleted,
      viewRule: withNotDeleted,
      createRule: membership,
      updateRule: withNotDeleted,
      deleteRule: null,
    }, collection);
    app.save(collection);
  }

  tighten("pbc_machines0001");
  tighten("pbc_storages0001");
}, (app) => {
  const notDeleted = "(isDeleted = false || isDeleted = null)";
  const previous =
    '@request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';
  const withNotDeleted = previous + " && " + notDeleted;

  function restore(collectionNameOrId) {
    const collection = app.findCollectionByNameOrId(collectionNameOrId);
    unmarshal({
      listRule: withNotDeleted,
      viewRule: withNotDeleted,
      createRule: previous,
      updateRule: withNotDeleted,
      deleteRule: null,
    }, collection);
    app.save(collection);
  }

  restore("pbc_machines0001");
  restore("pbc_storages0001");
});
