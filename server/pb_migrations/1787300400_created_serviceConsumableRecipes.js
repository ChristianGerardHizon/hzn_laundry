/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const rule =
    '@request.auth.id != "" && (service.branch = "" || service.branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';

  const collection = new Collection({
    "id": "pbc_svc_con_recipe",
    "name": "serviceConsumableRecipes",
    "type": "base",
    "system": false,
    "listRule": rule,
    "viewRule": rule,
    "createRule": rule,
    "updateRule": rule,
    "deleteRule": rule,
    "indexes": [
      "CREATE UNIQUE INDEX `idx_svc_con_recipe_svc_prod` ON `serviceConsumableRecipes` (`service`, `product`)",
    ],
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
        "type": "text",
      },
      {
        "cascadeDelete": true,
        "collectionId": "pbc_services001",
        "hidden": false,
        "id": "rel_svc_con_service",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "service",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation",
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_4092854851",
        "hidden": false,
        "id": "rel_svc_con_product",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "product",
        "presentable": false,
        "required": true,
        "system": false,
        "type": "relation",
      },
      {
        "hidden": false,
        "id": "number_svc_con_default_qty",
        "max": null,
        "min": 0,
        "name": "defaultQuantity",
        "onlyInt": false,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number",
      },
      {
        "hidden": false,
        "id": "bool_svc_con_prefill",
        "name": "prefill",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "bool",
      },
      {
        "hidden": false,
        "id": "autodate2990389176",
        "name": "created",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate",
      },
      {
        "hidden": false,
        "id": "autodate3332085495",
        "name": "updated",
        "onCreate": true,
        "onUpdate": true,
        "presentable": false,
        "system": false,
        "type": "autodate",
      },
    ],
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_svc_con_recipe");
  return app.delete(collection);
});
