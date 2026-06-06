/// <reference path="../pb_data/types.d.ts" />

// Fix vw_sales_daily_summary: use PHT (UTC+8) date instead of UTC date.
// Orders created 12:00–7:59 AM PHT have a UTC timestamp on the previous
// calendar day, causing them to appear in the wrong day's report.

migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3432702729");

  unmarshal({
    "viewQuery": "\n    SELECT\n      (ROW_NUMBER() OVER()) AS id,\n      DATE(datetime(s.created, '+8 hours')) AS sale_date,\n      p.paymentMethod,\n      s.branch,\n      COUNT(DISTINCT s.id) AS transaction_count,\n      SUM(p.amount) AS total_revenue,\n      AVG(p.amount) AS avg_transaction_value\n    FROM sales s\n    LEFT JOIN payments p ON s.id = p.sale\n    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n      AND s.status != 'voided'\n    GROUP BY DATE(datetime(s.created, '+8 hours')), p.paymentMethod, s.branch\n    ORDER BY sale_date DESC\n  "
  }, collection);

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3432702729");

  unmarshal({
    "viewQuery": "\n    SELECT\n      (ROW_NUMBER() OVER()) AS id,\n      DATE(s.created) AS sale_date,\n      p.paymentMethod,\n      s.branch,\n      COUNT(DISTINCT s.id) AS transaction_count,\n      SUM(p.amount) AS total_revenue,\n      AVG(p.amount) AS avg_transaction_value\n    FROM sales s\n    LEFT JOIN payments p ON s.id = p.sale\n    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n      AND s.status != 'voided'\n    GROUP BY DATE(s.created), p.paymentMethod, s.branch\n    ORDER BY sale_date DESC\n  "
  }, collection);

  return app.save(collection);
});
