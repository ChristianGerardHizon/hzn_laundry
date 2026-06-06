/// <reference path="../pb_data/types.d.ts" />

// Fix vw_sales_daily_summary: use PHT (UTC+8) date instead of UTC date.
// Orders created 12:00–7:59 AM PHT have a UTC timestamp on the previous
// calendar day, causing them to appear in the wrong day's report.

migrate(function(db) {
  var dao = new Dao(db);
  var collection = dao.findCollectionByNameOrId("vw_sales_daily_summary");

  collection.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      DATE(datetime(s.created, '+8 hours')) AS sale_date,
      p.paymentMethod,
      s.branch,
      COUNT(DISTINCT s.id) AS transaction_count,
      SUM(p.amount) AS total_revenue,
      AVG(p.amount) AS avg_transaction_value
    FROM sales s
    LEFT JOIN payments p ON s.id = p.sale
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status != 'voided'
    GROUP BY DATE(datetime(s.created, '+8 hours')), p.paymentMethod, s.branch
    ORDER BY sale_date DESC
  `;

  dao.saveCollection(collection);
}, function(db) {
  var dao = new Dao(db);
  var collection = dao.findCollectionByNameOrId("vw_sales_daily_summary");

  collection.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      DATE(s.created) AS sale_date,
      p.paymentMethod,
      s.branch,
      COUNT(DISTINCT s.id) AS transaction_count,
      SUM(p.amount) AS total_revenue,
      AVG(p.amount) AS avg_transaction_value
    FROM sales s
    LEFT JOIN payments p ON s.id = p.sale
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status != 'voided'
    GROUP BY DATE(s.created), p.paymentMethod, s.branch
    ORDER BY sale_date DESC
  `;

  dao.saveCollection(collection);
});
