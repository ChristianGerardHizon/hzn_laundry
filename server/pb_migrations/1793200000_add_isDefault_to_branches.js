/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297");

  if (!collection.fields.getById("bool_branch_is_default")) {
    collection.fields.add(
      new Field({
        hidden: false,
        id: "bool_branch_is_default",
        name: "isDefault",
        presentable: false,
        required: false,
        system: false,
        type: "bool",
      })
    );
    app.save(collection);
  }

  // Backfill: one default branch per organization (oldest created, then id).
  const branches = app.findAllRecords("branches");
  const byOrg = {};
  for (let i = 0; i < branches.length; i++) {
    const b = branches[i];
    if (b.getBool("isDeleted")) continue;
    const orgId = b.getString("organization");
    if (!orgId) continue;
    if (!byOrg[orgId]) byOrg[orgId] = [];
    byOrg[orgId].push(b);
  }

  const orgIds = Object.keys(byOrg);
  for (let o = 0; o < orgIds.length; o++) {
    const list = byOrg[orgIds[o]];
    list.sort((a, b) => {
      const ac = a.get("created") || "";
      const bc = b.get("created") || "";
      if (ac < bc) return -1;
      if (ac > bc) return 1;
      if (a.id < b.id) return -1;
      if (a.id > b.id) return 1;
      return 0;
    });
    for (let j = 0; j < list.length; j++) {
      const wantDefault = j === 0;
      if (list[j].getBool("isDefault") !== wantDefault) {
        list[j].set("isDefault", wantDefault);
        app.save(list[j]);
      }
    }
  }
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297");
  collection.fields.removeById("bool_branch_is_default");
  return app.save(collection);
});
