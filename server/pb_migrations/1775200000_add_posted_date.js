/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Add postedDate to sales collection
  const sales = app.findCollectionByNameOrId("pbc_2697449135")
  sales.fields.add(new Field({
    "hidden": false,
    "id": "autodate_postedDate_sales",
    "name": "postedDate",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))
  app.save(sales)

  // Add postedDate to payments collection
  const payments = app.findCollectionByNameOrId("payments")
  payments.fields.add(new Field({
    "hidden": false,
    "id": "autodate_postedDate_payments",
    "name": "postedDate",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))
  app.save(payments)
}, (app) => {
  // Remove postedDate from sales
  const sales = app.findCollectionByNameOrId("pbc_2697449135")
  sales.fields.removeById("autodate_postedDate_sales")
  app.save(sales)

  // Remove postedDate from payments
  const payments = app.findCollectionByNameOrId("payments")
  payments.fields.removeById("autodate_postedDate_payments")
  app.save(payments)
})
