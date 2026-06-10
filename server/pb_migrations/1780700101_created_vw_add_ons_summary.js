/// <reference path="../pb_data/types.d.ts" />

// View: vw_add_ons_summary
// Per (sale, product) add-on totals for the dashboard "Add-ons Sold" KPI.
//
// Add-ons are the product line items (`saleItems`) attached to sales. The
// view collapses multiple line items of the same product within a sale into
// one row, carrying the sale's `branch` and full `postedDate` timestamp so
// the controller can range-filter by the (timezone-correct) day boundaries
// exactly like the other dashboard KPIs. The controller then folds the rows
// per product to produce the per-product breakdown.
//
// Grouping by sale (not by UTC date) keeps day-boundary filtering correct
// across the PHT/UTC offset. Mirrors the controller semantics: voided sales
// excluded.
migrate((app) => {
  // Delete existing view if it exists (idempotent re-run / prior partial apply)
  try {
    const existing = app.findCollectionByNameOrId("vw_add_ons_summary");
    app.delete(existing);
  } catch (e) {
    // Collection doesn't exist, safe to proceed
  }

  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 0,
        "min": 0,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_4092854851",
        "hidden": false,
        "id": "_clone_ao01",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "product",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "autogeneratePattern": "",
        "hidden": false,
        "id": "_clone_ao02",
        "max": 0,
        "min": 0,
        "name": "productName",
        "pattern": "",
        "presentable": false,
        "primaryKey": false,
        "required": false,
        "system": false,
        "type": "text"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2358601297",
        "hidden": false,
        "id": "_clone_ao03",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "branch",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "hidden": false,
        "id": "_clone_ao04",
        "name": "postedDate",
        "onCreate": true,
        "onUpdate": false,
        "presentable": false,
        "system": false,
        "type": "autodate"
      },
      {
        "cascadeDelete": false,
        "collectionId": "pbc_2697449135",
        "hidden": false,
        "id": "_clone_ao05",
        "maxSelect": 1,
        "minSelect": 0,
        "name": "sale",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "relation"
      },
      {
        "hidden": false,
        "id": "json_ao_qty",
        "maxSize": 1,
        "name": "quantity",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "hidden": false,
        "id": "json_ao_revenue",
        "maxSize": 1,
        "name": "revenue",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_addonssum01",
    "indexes": [],
    "listRule": "",
    "name": "vw_add_ons_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.product,\n  si.productName,\n  s.branch,\n  s.postedDate,\n  s.id AS sale,\n  SUM(si.quantity) AS quantity,\n  SUM(si.subtotal) AS revenue\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE s.status != 'voided'\nGROUP BY s.id, si.product, si.productName, s.branch, s.postedDate",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  try {
    const collection = app.findCollectionByNameOrId("vw_add_ons_summary");
    return app.delete(collection);
  } catch (e) {
    // View may not exist; nothing to roll back
  }
})
