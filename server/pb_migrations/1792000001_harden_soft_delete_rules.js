/// <reference path="../pb_data/types.d.ts" />
/**
 * Harden soft-delete for master-data collections:
 * - list/view/update require record is not soft-deleted
 * - deleteRule null → hard delete only for superusers
 * Soft delete remains an update({ isDeleted: true }) while the record is still active.
 */
migrate((app) => {
  const notDeleted = "(isDeleted = false || isDeleted = null)";

  const branchScoped =
    '@request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';
  const orgScoped =
    '@request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  const authOnly = '@request.auth.id != ""';

  function harden(collectionNameOrId, authRule) {
    const collection = app.findCollectionByNameOrId(collectionNameOrId);
    const withNotDeleted = authRule + " && " + notDeleted;
    unmarshal({
      listRule: withNotDeleted,
      viewRule: withNotDeleted,
      createRule: authRule,
      updateRule: withNotDeleted,
      deleteRule: null,
    }, collection);
    app.save(collection);
  }

  // Org / branch scoped (existing membership rules preserved)
  harden("pbc_customers001", branchScoped);
  harden("pbc_2358601297", orgScoped); // branches
  harden("pbc_machines0001", branchScoped);
  harden("pbc_storages0001", branchScoped);

  // Auth-only collections (restore auth if previously open/empty, then AND notDeleted)
  harden("productCategories", authOnly);
  harden("serviceCategories", authOnly);
  harden("quantityUnits", authOnly);
  harden("userRoles", authOnly);
}, (app) => {
  const branchScoped =
    '@request.auth.id != "" && (branch = "" || branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';
  const orgScoped =
    '@request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  const authOnly = '@request.auth.id != ""';

  function restore(collectionNameOrId, authRule) {
    const collection = app.findCollectionByNameOrId(collectionNameOrId);
    unmarshal({
      listRule: authRule,
      viewRule: authRule,
      createRule: authRule,
      updateRule: authRule,
      deleteRule: authRule,
    }, collection);
    app.save(collection);
  }

  restore("pbc_customers001", branchScoped);
  restore("pbc_2358601297", orgScoped);
  restore("pbc_machines0001", branchScoped);
  restore("pbc_storages0001", branchScoped);
  restore("productCategories", authOnly);
  restore("serviceCategories", authOnly);
  restore("quantityUnits", authOnly);
  restore("userRoles", authOnly);
});
