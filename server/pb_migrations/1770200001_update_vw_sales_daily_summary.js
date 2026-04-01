/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Drop and recreate the view with updated query that joins payments table
  const collection = app.findCollectionByNameOrId("vw_sales_daily_summary")

  // Update the view query to use payments table instead of sales.paymentMethod
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
}, (app) => {
  const collection = app.findCollectionByNameOrId("vw_sales_daily_summary")

  // Revert to old query (note: this won't work after paymentMethod is removed from sales)
  collection.viewQuery = `
    SELECT
      (ROW_NUMBER() OVER()) AS id,
      DATE(s.created) AS sale_date,
      s.paymentMethod,
      s.branch,
      COUNT(*) AS transaction_count,
      SUM(s.totalAmount) AS total_revenue,
      AVG(s.totalAmount) AS avg_transaction_value
    FROM sales s
    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)
      AND s.status = 'completed'
    GROUP BY DATE(s.created), s.paymentMethod, s.branch
    ORDER BY sale_date DESC
  `

  return app.save(collection)
})
