/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "passwordAuth": {
      "identityFields": [
        "userName",
        "email"
      ]
    }
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "passwordAuth": {
      "identityFields": [
        "userName"
      ]
    }
  }, collection)

  return app.save(collection)
})
