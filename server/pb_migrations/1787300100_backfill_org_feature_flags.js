/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("featureFlags");
  const orgs = app.findAllRecords("organizations");
  const existing = app.findAllRecords("featureFlags");

  const defaults = [
    {
      key: "emailUpdatesEnabled",
      enabled: true,
      description: "Send order history link emails to customers",
    },
    {
      key: "requireMachine",
      enabled: false,
      description: "Block moving to Processing if no machine is assigned",
    },
    {
      key: "requirePack",
      enabled: false,
      description: "Block moving to Ready if no packs are set on the order",
    },
    {
      key: "requireStorage",
      enabled: false,
      description: "Block moving to Ready if no storage location is assigned",
    },
    {
      key: "consumableUsage",
      enabled: false,
      description: "Record detergent and fabric-conditioner usage on orders",
    },
  ];

  const globalByKey = {};
  const toDelete = [];
  for (let i = 0; i < existing.length; i++) {
    const record = existing[i];
    const orgId = record.get("organization");
    if (!orgId) {
      globalByKey[record.getString("key")] = record;
      toDelete.push(record);
    }
  }

  for (let o = 0; o < orgs.length; o++) {
    const org = orgs[o];
    for (let d = 0; d < defaults.length; d++) {
      const def = defaults[d];
      try {
        app.findFirstRecordByFilter(
          "featureFlags",
          "organization = {:org} && key = {:key}",
          { org: org.id, key: def.key },
        );
        continue;
      } catch (_) {}

      const source = globalByKey[def.key];
      const record = new Record(collection);
      record.set("key", def.key);
      record.set(
        "enabled",
        source ? !!source.get("enabled") : def.enabled,
      );
      record.set(
        "description",
        source ? source.getString("description") || def.description : def.description,
      );
      record.set("organization", org.id);
      app.save(record);
    }
  }

  for (let i = 0; i < toDelete.length; i++) {
    app.delete(toDelete[i]);
  }

  const orgField = collection.fields.getById("rel_feature_flags_org");
  if (orgField) {
    orgField.required = true;
  }

  const indexes = collection.indexes || [];
  if (indexes.every((idx) => String(idx).indexOf("idx_featureFlags_org_key") === -1)) {
    indexes.push(
      "CREATE UNIQUE INDEX `idx_featureFlags_org_key` ON `featureFlags` (`organization`, `key`)",
    );
  }
  collection.indexes = indexes;

  const memberRule =
    '@request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  collection.listRule = memberRule;
  collection.viewRule = memberRule;
  collection.updateRule = null;
  collection.createRule = null;
  collection.deleteRule = null;

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("featureFlags");
  const orgField = collection.fields.getById("rel_feature_flags_org");
  if (orgField) {
    orgField.required = false;
  }
  collection.indexes = (collection.indexes || []).filter(
    (idx) => String(idx).indexOf("idx_featureFlags_org_key") === -1,
  );
  collection.listRule = '@request.auth.role.permissions ?~ "system.admin"';
  collection.viewRule = '@request.auth.role.permissions ?~ "system.admin"';
  collection.updateRule = '@request.auth.role.permissions ?~ "system.admin"';
  return app.save(collection);
});
