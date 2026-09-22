/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("platformBillingSettings");

  collection.fields.add(new Field({
    hidden: false,
    id: "number_billing_warning_days",
    max: null,
    min: 0,
    name: "warningDaysBeforeDue",
    onlyInt: true,
    presentable: false,
    required: false,
    system: false,
    type: "number"
  }));

  collection.fields.add(new Field({
    hidden: false,
    id: "bool_billing_enforce_warnings",
    name: "enforceWarnings",
    presentable: false,
    required: false,
    system: false,
    type: "bool"
  }));

  collection.fields.add(new Field({
    hidden: false,
    id: "bool_billing_enforce_lockout",
    name: "enforceLockout",
    presentable: false,
    required: false,
    system: false,
    type: "bool"
  }));

  app.save(collection);

  // Backfill singleton row(s) so enforcement stays on by default.
  const rows = app.findRecordsByFilter(
    "platformBillingSettings",
    "id != ''",
    "-created",
    50,
    0
  );
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    if (!row.get("warningDaysBeforeDue")) {
      row.set("warningDaysBeforeDue", 7);
    }
    if (row.get("enforceWarnings") === null || row.get("enforceWarnings") === undefined) {
      row.set("enforceWarnings", true);
    }
    if (row.get("enforceLockout") === null || row.get("enforceLockout") === undefined) {
      row.set("enforceLockout", true);
    }
    app.save(row);
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("platformBillingSettings");
  collection.fields.removeById("number_billing_warning_days");
  collection.fields.removeById("bool_billing_enforce_warnings");
  collection.fields.removeById("bool_billing_enforce_lockout");
  return app.save(collection);
});
