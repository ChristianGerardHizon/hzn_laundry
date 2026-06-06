/// <reference path="../pb_data/types.d.ts" />

// Fix vw_sales_by_customer: use PHT (UTC+8) date instead of UTC date.
// Orders created 12:00–7:59 AM PHT have a UTC timestamp on the previous
// calendar day, causing them to be grouped under the wrong day.

migrate(function(db) {
  var dao = new Dao(db);
  var collection = dao.findCollectionByNameOrId("vw_sales_by_customer");

  collection.viewQuery = `SELECT
  (ROW_NUMBER() OVER()) AS id,
  s.customer,
  s.customerName,
  s.branch,
  DATE(datetime(s.created, '+8 hours')) AS saleDate,
  COUNT(s.id) AS orderCount,
  SUM(s.totalAmount) AS totalSpent,
  SUM(CASE WHEN s.isPaid = true THEN s.totalAmount ELSE 0 END) AS totalPaid,
  SUM(CASE WHEN s.isPaid = true THEN 1 ELSE 0 END) AS paidOrderCount
FROM sales s
WHERE s.status != 'voided'
GROUP BY s.customer, s.customerName, s.branch, DATE(datetime(s.created, '+8 hours'))
ORDER BY totalSpent DESC`;

  dao.saveCollection(collection);
}, function(db) {
  var dao = new Dao(db);
  var collection = dao.findCollectionByNameOrId("vw_sales_by_customer");

  collection.viewQuery = `SELECT
  (ROW_NUMBER() OVER()) AS id,
  s.customer,
  s.customerName,
  s.branch,
  DATE(s.created) AS saleDate,
  COUNT(s.id) AS orderCount,
  SUM(s.totalAmount) AS totalSpent,
  SUM(CASE WHEN s.isPaid = true THEN s.totalAmount ELSE 0 END) AS totalPaid,
  SUM(CASE WHEN s.isPaid = true THEN 1 ELSE 0 END) AS paidOrderCount
FROM sales s
WHERE s.status != 'voided'
GROUP BY s.customer, s.customerName, s.branch, DATE(s.created)
ORDER BY totalSpent DESC`;

  dao.saveCollection(collection);
});
