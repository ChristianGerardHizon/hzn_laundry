/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851")

  // Allow any authenticated user to list products. The app already filters
  // by the selected branch; the previous rule hid other-branch products from
  // admins whose assigned branch did not match (e.g. Hi-Zone → Magsaysay).
  unmarshal({
    "listRule": "@request.auth.id != \"\""
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851")

  unmarshal({
    "listRule": "(@request.auth.id != null &&  @request.auth.branch.id = branch.id && @request.auth.collectionName = \"users\") || (@request.auth.id != null && @request.auth.collectionName = \"admins\")"
  }, collection)

  return app.save(collection)
})
