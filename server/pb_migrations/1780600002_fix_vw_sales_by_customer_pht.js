/// <reference path="../pb_data/types.d.ts" />

// Fix vw_sales_by_customer: use PHT (UTC+8) date instead of UTC date.
// Orders created 12:00–7:59 AM PHT have a UTC timestamp on the previous
// calendar day, causing them to be grouped under the wrong day.

migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3594358520");

  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  s.customer,\n  s.customerName,\n  s.branch,\n  DATE(datetime(s.created, '+8 hours')) AS saleDate,\n  COUNT(s.id) AS orderCount,\n  SUM(s.totalAmount) AS totalSpent,\n  SUM(CASE WHEN s.isPaid = true THEN s.totalAmount ELSE 0 END) AS totalPaid,\n  SUM(CASE WHEN s.isPaid = true THEN 1 ELSE 0 END) AS paidOrderCount\nFROM sales s\nWHERE s.status != 'voided'\nGROUP BY s.customer, s.customerName, s.branch, DATE(datetime(s.created, '+8 hours'))\nORDER BY totalSpent DESC"
  }, collection);

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3594358520");

  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  s.customer,\n  s.customerName,\n  s.branch,\n  DATE(s.created) AS saleDate,\n  COUNT(s.id) AS orderCount,\n  SUM(s.totalAmount) AS totalSpent,\n  SUM(CASE WHEN s.isPaid = true THEN s.totalAmount ELSE 0 END) AS totalPaid,\n  SUM(CASE WHEN s.isPaid = true THEN 1 ELSE 0 END) AS paidOrderCount\nFROM sales s\nWHERE s.status != 'voided'\nGROUP BY s.customer, s.customerName, s.branch, DATE(s.created)\nORDER BY totalSpent DESC"
  }, collection);

  return app.save(collection);
});
