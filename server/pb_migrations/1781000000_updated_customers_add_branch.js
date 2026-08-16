/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001")

  if (!collection.fields.getById("relation_customers_branch")) {
    collection.fields.addAt(collection.fields.length, new Field({
      "cascadeDelete": false,
      "collectionId": "pbc_2358601297",
      "hidden": false,
      "id": "relation_customers_branch",
      "maxSelect": 1,
      "minSelect": 0,
      "name": "branch",
      "presentable": false,
      "required": false,
      "system": false,
      "type": "relation"
    }))

    app.save(collection)
  }

  // Backfill unassigned customers later with
  // server/scripts/backfill_customer_branch.sh (dry-run first, then --apply).
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001")

  collection.fields.removeById("relation_customers_branch")

  return app.save(collection)
})
