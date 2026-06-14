/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("featureFlags");

  const enabledField = collection.fields.getByName("enabled");
  enabledField.required = false;

  app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("featureFlags");

  const enabledField = collection.fields.getByName("enabled");
  enabledField.required = true;

  app.save(collection);
})
