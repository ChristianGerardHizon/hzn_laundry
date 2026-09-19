/// <reference path="../pb_data/types.d.ts" />

// Fix vw_payments_daily_summary: use PHT (UTC+8) on postedDate (fallback created)
// so morning payments are not attributed to the previous UTC calendar day.
// Also include gcash in the paymentMethod select values.

migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_566873343");

  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(datetime(COALESCE(p.postedDate, p.created), '+8 hours')) AS paymentDate,\n  p.paymentMethod,\n  p.type AS paymentType,\n  s.branch,\n  COUNT(p.id) AS paymentCount,\n  SUM(p.amount) AS totalAmount\nFROM payments p\nJOIN sales s ON p.sale = s.id\nWHERE s.status != 'voided'\n  AND COALESCE(p.isVoided, false) = false\nGROUP BY DATE(datetime(COALESCE(p.postedDate, p.created), '+8 hours')), p.paymentMethod, p.type, s.branch\nORDER BY paymentDate DESC"
  }, collection);

  const methodField = collection.fields.getByName("paymentMethod");
  if (methodField) {
    methodField.values = ["cash", "gcash", "card", "bankTransfer", "check"];
  }

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_566873343");

  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(COALESCE(p.postedDate, p.created)) AS paymentDate,\n  p.paymentMethod,\n  p.type AS paymentType,\n  s.branch,\n  COUNT(p.id) AS paymentCount,\n  SUM(p.amount) AS totalAmount\nFROM payments p\nJOIN sales s ON p.sale = s.id\nWHERE s.status != 'voided'\n  AND COALESCE(p.isVoided, false) = false\nGROUP BY DATE(COALESCE(p.postedDate, p.created)), p.paymentMethod, p.type, s.branch\nORDER BY paymentDate DESC"
  }, collection);

  const methodField = collection.fields.getByName("paymentMethod");
  if (methodField) {
    methodField.values = ["cash", "card", "bankTransfer", "check"];
  }

  return app.save(collection);
});
