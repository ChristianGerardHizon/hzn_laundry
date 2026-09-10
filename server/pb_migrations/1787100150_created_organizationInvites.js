/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const userRoles = app.findCollectionByNameOrId("userRoles");

  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "[a-z0-9]{15}",
        "hidden": false,
        "id": "text3208210256",
        "max": 15,
        "min": 15,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "exceptDomains": null,
        "hidden": false,
        "id": "email_orginv_email",
        "name": "email",
        "onlyDomains": null,
        "presentable": false,
        "required": true,
        "system": false,
        "type": "email"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_organizations01",
        "hidden": false,
        "id": "relation_orginv_org",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "organization",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": userRoles.id,
        "hidden": false,
        "id": "relation_orginv_role",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "role",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "[a-zA-Z0-9]{32}",
        "hidden": true,
        "id": "text_orginv_token",
        "max": 32,
        "min": 32,
        "name": "token",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": true,
        "system": false,
        "type": "text"
      },
      {
        "hidden": false,
        "id": "select_orginv_status",
        "maxSelect": 1,
        "name": "status",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "select",
        "values": [
          "pending",
          "accepted",
          "expired",
          "revoked"
        ]
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_3841632486",
        "hidden": false,
        "id": "relation_orginv_invitedby",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "invitedBy",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_3841632486",
        "hidden": false,
        "id": "relation_orginv_acceptedby",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "acceptedBy",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "hidden": false,
        "id": "date_orginv_expires",
        "max": "",
        "min": "",
        "name": "expiresAt",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "date"
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": true,
        "onUpdate": true,
        "presentable": false,
        "system": false,
        "type": "autodate"
      }
    ],
    "id": "pbc_org_invites0001",
    "indexes": [
      "CREATE UNIQUE INDEX idx_token_organizationInvites ON organizationInvites (token)"
    ],
    "listRule": "@request.auth.id != \"\" && (invitedBy = @request.auth.id || email = @request.auth.email || organization.organizationMemberships_via_organization.user ?= @request.auth.id)",
    "name": "organizationInvites",
    "system": false,
    "type": "base",
    "updateRule": null,
    "viewRule": "@request.auth.id != \"\" && (invitedBy = @request.auth.id || email = @request.auth.email || organization.organizationMemberships_via_organization.user ?= @request.auth.id)"
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_org_invites0001");
  return app.delete(collection);
});
