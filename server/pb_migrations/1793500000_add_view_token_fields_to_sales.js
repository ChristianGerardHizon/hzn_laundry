/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");

  if (!collection.fields.getById("text_viewToken_sales")) {
    collection.fields.add(
      new Field({
        autogeneratePattern: "",
        hidden: false,
        id: "text_viewToken_sales",
        max: 128,
        min: 0,
        name: "viewToken",
        pattern: "",
        presentable: false,
        primaryKey: false,
        required: false,
        system: false,
        type: "text",
      })
    );
  }

  if (!collection.fields.getById("date_viewTokenCreatedAt_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "date_viewTokenCreatedAt_sales",
        max: "",
        min: "",
        name: "viewTokenCreatedAt",
        presentable: false,
        required: false,
        system: false,
        type: "date",
      })
    );
  }

  if (!collection.fields.getById("date_viewTokenFirstOpenedAt_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "date_viewTokenFirstOpenedAt_sales",
        max: "",
        min: "",
        name: "viewTokenFirstOpenedAt",
        presentable: false,
        required: false,
        system: false,
        type: "date",
      })
    );
  }

  if (!collection.fields.getById("date_viewTokenExpiresAt_sales")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "date_viewTokenExpiresAt_sales",
        max: "",
        min: "",
        name: "viewTokenExpiresAt",
        presentable: false,
        required: false,
        system: false,
        type: "date",
      })
    );
  }

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135");
  collection.fields.removeById("text_viewToken_sales");
  collection.fields.removeById("date_viewTokenCreatedAt_sales");
  collection.fields.removeById("date_viewTokenFirstOpenedAt_sales");
  collection.fields.removeById("date_viewTokenExpiresAt_sales");
  return app.save(collection);
});
