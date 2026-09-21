/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    if (app.findCollectionByNameOrId("subscriptionPackages")) {
      return;
    }
  } catch (_) {}

  const collection = new Collection({
    id: "pbc_subscription_packages",
    name: "subscriptionPackages",
    type: "base",
    system: false,
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
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
        autogeneratePattern: "",
        hidden: false,
        id: "text_subpkg_name",
        max: 0,
        min: 1,
        name: "name",
        pattern: "",
        presentable: true,
        primaryKey: false,
        required: true,
        system: false,
        type: "text"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_subpkg_desc",
        max: 0,
        min: 0,
        name: "description",
        pattern: "",
        presentable: false,
        primaryKey: false,
        required: false,
        system: false,
        type: "text"
      },
      {
        hidden: false,
        id: "number_subpkg_price",
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
        id: "number_subpkg_interval_count",
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
        id: "select_subpkg_interval_unit",
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
        id: "bool_subpkg_premade",
        name: "isPremade",
        presentable: false,
        required: false,
        system: false,
        type: "bool"
      },
      {
        cascadeDelete: false,
        collectionId: "pbc_organizations01",
        hidden: false,
        id: "relation_subpkg_org",
        maxSelect: 1,
        minSelect: 0,
        name: "organizationId",
        presentable: false,
        required: false,
        system: false,
        type: "relation"
      },
      {
        hidden: false,
        id: "bool_subpkg_active",
        name: "isActive",
        presentable: false,
        required: false,
        system: false,
        type: "bool"
      },
      {
        hidden: false,
        id: "bool_subpkg_deleted",
        name: "isDeleted",
        presentable: false,
        required: false,
        system: false,
        type: "bool"
      },
      {
        hidden: false,
        id: "autodate_subpkg_created",
        name: "created",
        onCreate: true,
        onUpdate: false,
        presentable: false,
        system: false,
        type: "autodate"
      },
      {
        hidden: false,
        id: "autodate_subpkg_updated",
        name: "updated",
        onCreate: true,
        onUpdate: true,
        presentable: false,
        system: false,
        type: "autodate"
      }
    ],
    indexes: [
      "CREATE INDEX `idx_subpkg_premade` ON `subscriptionPackages` (`isPremade`)",
      "CREATE INDEX `idx_subpkg_org` ON `subscriptionPackages` (`organizationId`)"
    ]
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_subscription_packages");
    return app.delete(collection);
  } catch (_) {}
});
