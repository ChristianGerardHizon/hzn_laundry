/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const orgs = app.findCollectionByNameOrId("organizations");
  const org = new Record(orgs);
  org.set("name", "HZN Laundry");
  org.set("isDeleted", false);
  app.save(org);

  const now = new Date().toISOString();

  const branches = app.findAllRecords("branches");
  for (let i = 0; i < branches.length; i++) {
    branches[i].set("organization", org.id);
    app.save(branches[i]);
  }

  const users = app.findAllRecords("users");
  const memberships = app.findCollectionByNameOrId("organizationMemberships");
  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const roleId = user.getString("role");
    if (!roleId) continue;

    const membership = new Record(memberships);
    membership.set("user", user.id);
    membership.set("organization", org.id);
    membership.set("role", roleId);
    membership.set("status", "active");
    membership.set("joinedAt", now);
    app.save(membership);
  }

  const branchesCollection = app.findCollectionByNameOrId("pbc_2358601297");
  const orgField = branchesCollection.fields.getById("relation_branches_org");
  if (orgField) {
    orgField.required = true;
    app.save(branchesCollection);
  }
}, (app) => {
  // Reversing a data backfill is unsafe.
});
