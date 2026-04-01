/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const usersCollection = app.findCollectionByNameOrId("users")
  const rolesCollection = app.findCollectionByNameOrId("userRoles")

  const testUsers = [
    { name: "Admin User", username: "admin", roleName: "Admin" },
    { name: "Manager User", username: "manager", roleName: "Manager" },
    { name: "Cashier User", username: "cashier", roleName: "Cashier" },
    { name: "Attendant User", username: "attendant", roleName: "Attendant" },
  ]

  for (const user of testUsers) {
    // Skip if user with same username already exists
    try {
      app.findFirstRecordByFilter(usersCollection, `username = "${user.username}"`)
      continue // User already exists, skip
    } catch (_) {
      // User doesn't exist, create it
    }

    // Look up the role record
    let roleId = ""
    try {
      const roleRecord = app.findFirstRecordByFilter(rolesCollection, `name = "${user.roleName}"`)
      roleId = roleRecord.id
    } catch (_) {
      // Role not found, skip this user
      continue
    }

    const record = new Record(usersCollection)
    record.set("name", user.name)
    record.set("username", user.username)
    record.set("password", "password101")
    record.set("verified", true)
    record.set("isDeleted", false)
    record.set("role", roleId)
    app.save(record)
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("users")
  const usernames = ["admin", "manager", "cashier", "attendant"]

  for (const username of usernames) {
    try {
      const record = app.findFirstRecordByFilter(collection, `username = "${username}"`)
      app.delete(record)
    } catch (_) {
      // Record doesn't exist, skip
    }
  }
})
