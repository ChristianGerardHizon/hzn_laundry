/// <reference path="../pb_data/types.d.ts" />
// Per-organization Super Admin feature overrides.
// No row = follow the subscription package. Writes go through
// PUT /api/super-admin/organizations/{id}/feature-overrides/{key}.
//
// Also converts the legacy per-org `consumableUsage` featureFlags row into an
// override so orgs that had it enabled keep access.
migrate((app) => {
  let exists = false;
  try {
    exists = !!app.findCollectionByNameOrId("organizationFeatureOverrides");
  } catch (_) {}

  if (!exists) {
    const collection = new Collection({
      id: "pbc_org_feature_overrides",
      name: "organizationFeatureOverrides",
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
          id: "relation_feat_ovr_org",
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
          id: "text_feat_ovr_key",
          max: 0,
          min: 1,
          name: "featureKey",
          pattern: "",
          presentable: true,
          primaryKey: false,
          required: true,
          system: false,
          type: "text"
        },
        {
          hidden: false,
          id: "bool_feat_ovr_enabled",
          name: "enabled",
          presentable: false,
          required: false,
          system: false,
          type: "bool"
        },
        {
          autogeneratePattern: "",
          hidden: false,
          id: "text_feat_ovr_note",
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
          id: "relation_feat_ovr_updated_by",
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
          id: "autodate_feat_ovr_created",
          name: "created",
          onCreate: true,
          onUpdate: false,
          presentable: false,
          system: false,
          type: "autodate"
        },
        {
          hidden: false,
          id: "autodate_feat_ovr_updated",
          name: "updated",
          onCreate: true,
          onUpdate: true,
          presentable: false,
          system: false,
          type: "autodate"
        }
      ],
      indexes: [
        "CREATE UNIQUE INDEX `idx_feat_ovr_org_key` ON `organizationFeatureOverrides` (`organization`, `featureKey`)"
      ]
    });
    app.save(collection);
  }

  // Convert legacy per-org consumableUsage flags into overrides.
  const overrides = app.findCollectionByNameOrId("organizationFeatureOverrides");
  let flags = [];
  try {
    flags = app.findRecordsByFilter(
      "featureFlags",
      "key = 'consumableUsage' && enabled = true",
      "",
      0,
      0
    );
  } catch (_) {
    flags = [];
  }
  for (let i = 0; i < flags.length; i++) {
    const orgId = flags[i].getString("organization");
    if (!orgId) continue;
    try {
      app.findFirstRecordByFilter(
        "organizationFeatureOverrides",
        "organization = {:org} && featureKey = 'consumableUsage'",
        { org: orgId }
      );
      continue;
    } catch (_) {}
    const record = new Record(overrides);
    record.set("organization", orgId);
    record.set("featureKey", "consumableUsage");
    record.set("enabled", true);
    record.set("note", "Migrated from previous consumable usage setting");
    app.save(record);
  }
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_org_feature_overrides");
    return app.delete(collection);
  } catch (_) {}
});
