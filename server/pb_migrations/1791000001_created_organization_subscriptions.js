/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    if (app.findCollectionByNameOrId("organizationSubscriptions")) {
      return;
    }
  } catch (_) {}

  const collection = new Collection({
    id: "pbc_organization_subscriptions",
    name: "organizationSubscriptions",
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
        cascadeDelete: false,
        collectionId: "pbc_organizations01",
        hidden: false,
        id: "relation_orgsub_org",
        maxSelect: 1,
        minSelect: 0,
        name: "organization",
        presentable: false,
        required: true,
        system: false,
        type: "relation"
      },
      {
        cascadeDelete: false,
        collectionId: "pbc_subscription_packages",
        hidden: false,
        id: "relation_orgsub_package",
        maxSelect: 1,
        minSelect: 0,
        name: "package",
        presentable: false,
        required: true,
        system: false,
        type: "relation"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_orgsub_pkg_name",
        max: 0,
        min: 0,
        name: "packageName",
        pattern: "",
        presentable: true,
        primaryKey: false,
        required: true,
        system: false,
        type: "text"
      },
      {
        hidden: false,
        id: "number_orgsub_price",
        max: null,
        min: 0,
        name: "price",
        onlyInt: false,
        presentable: true,
        required: true,
        system: false,
        type: "number"
      },
      {
        hidden: false,
        id: "number_orgsub_interval_count",
        max: null,
        min: 1,
        name: "intervalCount",
        onlyInt: true,
        presentable: false,
        required: true,
        system: false,
        type: "number"
      },
      {
        hidden: false,
        id: "select_orgsub_interval_unit",
        maxSelect: 1,
        name: "intervalUnit",
        presentable: false,
        required: true,
        system: false,
        type: "select",
        values: ["day", "month", "year"]
      },
      {
        hidden: false,
        id: "select_orgsub_status",
        maxSelect: 1,
        name: "status",
        presentable: true,
        required: true,
        system: false,
        type: "select",
        values: ["active", "grace", "locked", "cancelled"]
      },
      {
        hidden: false,
        id: "date_orgsub_period_start",
        max: "",
        min: "",
        name: "periodStart",
        presentable: false,
        required: true,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "date_orgsub_period_end",
        max: "",
        min: "",
        name: "periodEnd",
        presentable: false,
        required: true,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "date_orgsub_grace_ends",
        max: "",
        min: "",
        name: "graceEndsAt",
        presentable: false,
        required: false,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "date_orgsub_next_reminder",
        max: "",
        min: "",
        name: "nextReminderAt",
        presentable: false,
        required: false,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "date_orgsub_manual_unlock",
        max: "",
        min: "",
        name: "manualUnlockUntil",
        presentable: false,
        required: false,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "date_orgsub_last_reminder",
        max: "",
        min: "",
        name: "lastReminderSentAt",
        presentable: false,
        required: false,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "bool_orgsub_deleted",
        name: "isDeleted",
        presentable: false,
        required: false,
        system: false,
        type: "bool"
      },
      {
        hidden: false,
        id: "autodate_orgsub_created",
        name: "created",
        onCreate: true,
        onUpdate: false,
        presentable: false,
        system: false,
        type: "autodate"
      },
      {
        hidden: false,
        id: "autodate_orgsub_updated",
        name: "updated",
        onCreate: true,
        onUpdate: true,
        presentable: false,
        system: false,
        type: "autodate"
      }
    ],
    indexes: [
      "CREATE INDEX `idx_orgsub_org` ON `organizationSubscriptions` (`organization`)",
      "CREATE INDEX `idx_orgsub_status` ON `organizationSubscriptions` (`status`)",
      "CREATE UNIQUE INDEX `idx_orgsub_org_active` ON `organizationSubscriptions` (`organization`) WHERE `isDeleted` = false AND `status` != 'cancelled'"
    ]
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_organization_subscriptions");
    return app.delete(collection);
  } catch (_) {}
});
