/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_384506597")

  // Broaden the view to include processing orders (exclude only pending),
  // and add effectiveProcessedDate = COALESCE(processedDate, postedDate, created)
  // so the dashboard can attribute in-progress work to the day it was posted
  // and completed work to the day it was actually processed.
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, s.processedDate, COALESCE(NULLIF(s.postedDate, ''), s.created) AS effectivePostedDate, COALESCE(NULLIF(s.processedDate, ''), NULLIF(s.postedDate, ''), s.created) AS effectiveProcessedDate, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"processing\", \"ready\", \"pickedUp\") GROUP BY s.id"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_384506597")

  // Revert to prior view (ready + pickedUp only, no effectiveProcessedDate).
  unmarshal({
    "viewQuery": "SELECT s.id, s.receiptNumber, s.branch, s.customerName, s.orderStatus, s.postedDate, s.created, s.updated, s.processedDate, COALESCE(s.postedDate, s.created) AS effectivePostedDate, COALESCE(SUM(si.subtotal), 0) AS serviceTotalAmount FROM sales s LEFT JOIN saleServiceItems si ON si.sale = s.id WHERE s.orderStatus IN (\"ready\", \"pickedUp\") GROUP BY s.id"
  }, collection)

  return app.save(collection)
})
