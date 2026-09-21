/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  try {
    if (app.findCollectionByNameOrId("subscriptionPayments")) {
      return;
    }
  } catch (_) {}

  const collection = new Collection({
    id: "pbc_subscription_payments",
    name: "subscriptionPayments",
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
        id: "relation_subpay_org",
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
        collectionId: "pbc_organization_subscriptions",
        hidden: false,
        id: "relation_subpay_sub",
        maxSelect: 1,
        minSelect: 0,
        name: "subscription",
        presentable: false,
        required: true,
        system: false,
        type: "relation"
      },
      {
        hidden: false,
        id: "number_subpay_amount",
        max: null,
        min: 0,
        name: "amount",
        onlyInt: false,
        presentable: true,
        required: true,
        system: false,
        type: "number"
      },
      {
        hidden: false,
        id: "select_subpay_status",
        maxSelect: 1,
        name: "status",
        presentable: true,
        required: true,
        system: false,
        type: "select",
        values: ["pending", "approved", "rejected"]
      },
      {
        hidden: false,
        id: "file_subpay_proof",
        maxSelect: 1,
        maxSize: 5242880,
        mimeTypes: ["image/jpeg", "image/png", "image/gif", "image/webp"],
        name: "proofImage",
        presentable: false,
        protected: false,
        required: true,
        system: false,
        thumbs: [],
        type: "file"
      },
      {
        autogeneratePattern: "",
        hidden: false,
        id: "text_subpay_note",
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
        autogeneratePattern: "",
        hidden: false,
        id: "text_subpay_admin_note",
        max: 0,
        min: 0,
        name: "adminNote",
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
        id: "relation_subpay_submitted_by",
        maxSelect: 1,
        minSelect: 0,
        name: "submittedBy",
        presentable: false,
        required: true,
        system: false,
        type: "relation"
      },
      {
        cascadeDelete: false,
        collectionId: "pbc_3841632486",
        hidden: false,
        id: "relation_subpay_reviewed_by",
        maxSelect: 1,
        minSelect: 0,
        name: "reviewedBy",
        presentable: false,
        required: false,
        system: false,
        type: "relation"
      },
      {
        hidden: false,
        id: "date_subpay_reviewed_at",
        max: "",
        min: "",
        name: "reviewedAt",
        presentable: false,
        required: false,
        system: false,
        type: "date"
      },
      {
        hidden: false,
        id: "autodate_subpay_created",
        name: "created",
        onCreate: true,
        onUpdate: false,
        presentable: false,
        system: false,
        type: "autodate"
      },
      {
        hidden: false,
        id: "autodate_subpay_updated",
        name: "updated",
        onCreate: true,
        onUpdate: true,
        presentable: false,
        system: false,
        type: "autodate"
      }
    ],
    indexes: [
      "CREATE INDEX `idx_subpay_org` ON `subscriptionPayments` (`organization`)",
      "CREATE INDEX `idx_subpay_status` ON `subscriptionPayments` (`status`)",
      "CREATE INDEX `idx_subpay_subscription` ON `subscriptionPayments` (`subscription`)"
    ]
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("pbc_subscription_payments");
    return app.delete(collection);
  } catch (_) {}
});
