/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "createRule": "id = @request.auth.id || @request.auth.role.permissions ?~ \"users.create\" || @request.auth.role.permissions ?~ \"system.admin\"",
    "deleteRule": "id = @request.auth.id || @request.auth.role.permissions ?~ \"users.delete\" || @request.auth.role.permissions ?~ \"system.admin\"",
    "updateRule": "id = @request.auth.id || @request.auth.role.permissions ?~ \"users.edit\" || @request.auth.role.permissions ?~ \"system.admin\""
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "createRule": "id = @request.auth.id || @request.auth.role.permissions ?~  \"users.create\"",
    "deleteRule": "id = @request.auth.id || @request.auth.role.permissions ?~  \"users.delete\"",
    "updateRule": "id = @request.auth.id || @request.auth.role.permissions ?~  \"users.edit\""
  }, collection)

  return app.save(collection)
})
