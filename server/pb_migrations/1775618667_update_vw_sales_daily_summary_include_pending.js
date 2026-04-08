/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("vw_sales_daily_summary")

  // Include all non-voided sales (pending, completed, etc.) to match dashboard behavior
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
  `

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("vw_sales_daily_summary")

  // Revert to completed-only filter
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
      AND s.status = 'completed'
    GROUP BY DATE(s.created), p.paymentMethod, s.branch
    ORDER BY sale_date DESC
  `

  return app.save(collection)
})
