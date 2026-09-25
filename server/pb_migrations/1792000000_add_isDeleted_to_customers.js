/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001");

  collection.fields.add(new Field({
    hidden: false,
    id: "bool_customers_is_deleted",
    name: "isDeleted",
    presentable: false,
    required: false,
    system: false,
    type: "bool",
  }));

  app.save(collection);

  // Backfill existing rows so soft-delete rules treat them as active.
  let offset = 0;
  const pageSize = 500;
  while (true) {
    const rows = app.findRecordsByFilter(
      "customers",
      "id != ''",
      "-created",
      pageSize,
      offset
    );
    if (rows.length === 0) break;

    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      if (row.get("isDeleted") === null || row.get("isDeleted") === undefined) {
        row.set("isDeleted", false);
        app.save(row);
      }
    }

    if (rows.length < pageSize) break;
    offset += pageSize;
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_customers001");
  collection.fields.removeById("bool_customers_is_deleted");
  return app.save(collection);
});
