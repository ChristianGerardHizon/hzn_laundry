/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("userRoles")

  const roles = [
    {
      name: "Admin",
      description: "Full system access. Business owner or IT administrator.",
      isSystem: true,
      permissions: ["system.admin"],
    },
    {
      name: "Manager",
      description: "Full operational access. Cannot manage users, roles, or branches.",
      isSystem: false,
      permissions: [
        "patients.view", "patients.create", "patients.edit", "patients.delete",
        "records.view", "records.create", "records.edit", "records.delete",
        "prescriptions.view", "prescriptions.create", "prescriptions.edit", "prescriptions.delete",
        "appointments.view", "appointments.create", "appointments.edit", "appointments.delete",
        "products.view", "products.create", "products.edit", "products.delete",
        "inventory.view", "inventory.adjust",
        "sales.view", "sales.create",
        "settings.view", "settings.edit",
      ],
    },
    {
      name: "Cashier",
      description: "POS operations, customer management, and inventory viewing.",
      isSystem: false,
      permissions: [
        "patients.view", "patients.create", "patients.edit",
        "records.view", "records.create",
        "prescriptions.view",
        "appointments.view", "appointments.create", "appointments.edit",
        "products.view",
        "inventory.view",
        "sales.view", "sales.create",
        "settings.view",
      ],
    },
    {
      name: "Attendant",
      description: "Floor operations, order status updates, and view-only access.",
      isSystem: false,
      permissions: [
        "patients.view",
        "records.view", "records.create", "records.edit",
        "prescriptions.view",
        "appointments.view",
        "products.view",
        "inventory.view",
        "sales.view",
        "settings.view",
      ],
    },
  ]

  for (const role of roles) {
    // Skip if role with same name already exists
    try {
      app.findFirstRecordByFilter(collection, `name = "${role.name}"`)
      continue // Role already exists, skip
    } catch (_) {
      // Role doesn't exist, create it
    }

    const record = new Record(collection)
    record.set("name", role.name)
    record.set("description", role.description)
    record.set("isSystem", role.isSystem)
    record.set("isDeleted", false)
    record.set("permissions", JSON.stringify(role.permissions))
    app.save(record)
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("userRoles")
  const names = ["Admin", "Manager", "Cashier", "Attendant"]

  for (const name of names) {
    try {
      const record = app.findFirstRecordByFilter(collection, `name = "${name}"`)
      app.delete(record)
    } catch (_) {
      // Record doesn't exist, skip
    }
  }
})
