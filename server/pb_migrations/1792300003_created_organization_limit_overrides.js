/// <reference path="../pb_data/types.d.ts" />
// Per-organization Super Admin limit overrides (max branches / max employees).
// No row = follow the subscription package. Writes go through
// PUT /api/super-admin/organizations/{id}/limit-overrides/{key}.
migrate((app) => {
  let exists = false;
  try {
    exists = !!app.findCollectionByNameOrId("organizationLimitOverrides");
  } catch (_) {}
  if (exists) return;

  const collection = new Collection({
    id: "pbc_org_limit_overrides",
    name: "organizationLimitOverrides",
    type: "base",
    system: false,
    listRule:
      '@request.auth.id != "" && (organization.organizationMemberships_via_organization.user ?= @request.auth.id)',
    viewRule:
      '@request.auth.id != "" && (organization.organizationMemberships_via_organization.user ?= @request.auth.id)',
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      {
        autogeneratePattern: "[a-z0-9]{15}",
        hidden: false,
        id: "text3208210256",
        max: 15,
        min: 15,
        name: "id",
        pattern: "^[a-z0-9]+$",
        presentable: false,
        primaryKey: true,
        required: true,
        system: true,
        type: "text"
      },
      {
        cascadeDelete: true,
        collectionId: "pbc_organizations01",
        hidden: false,
        id: "relation_lim_ovr_org",
        maxSelect: 1,
        minSelect: 0,
        name: "organization",
        presentable: false,
        required: true,
        system: false,
        type: "relation"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_lim_ovr_key",
        max: 0,
        min: 1,
        name: "limitKey",
        pattern: "",
        presentable: true,
        primaryKey: false,
        required: true,
        system: false,
        type: "text"
      },
      {
        hidden: false,
        id: "number_lim_ovr_value",
        max: null,
        min: 0,
        name: "value",
        onlyInt: true,
        presentable: false,
        required: false,
        system: false,
        type: "number"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_lim_ovr_note",
        max: 0,
        min: 0,
        name: "note",
        pattern: "",
        presentable: false,
        primaryKey: false,
        required: false,
        system: false,
        type: "text"
      },
      {
        cascadeDelete: false,
        collectionId: "pbc_3841632486",
        hidden: false,
        id: "relation_lim_ovr_updated_by",
        maxSelect: 1,
        minSelect: 0,
        name: "updatedBy",
        presentable: false,
        required: false,
        system: false,
        type: "relation"
      },
      {
        hidden: false,
        id: "autodate_lim_ovr_created",
        name: "created",
        onCreate: true,
        onUpdate: false,
        presentable: false,
        system: false,
        type: "autodate"
      },
      {
        hidden: false,
        id: "autodate_lim_ovr_updated",
        name: "updated",
        onCreate: true,
        onUpdate: true,
        presentable: false,
        system: false,
        type: "autodate"
      }
    ],
    indexes: [
      "CREATE UNIQUE INDEX `idx_lim_ovr_org_key` ON `organizationLimitOverrides` (`organization`, `limitKey`)"
    ]
  });
  app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_org_limit_overrides");
    return app.delete(collection);
  } catch (_) {}
});
