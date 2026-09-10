/// <reference path="../pb_data/types.d.ts" />
// Org/branch URL routing requires slug. Collection create + backfill never
// added the field, so authenticated users stay on /splash forever
// (homePathFor returns /splash when slug is empty).

function slugify(input) {
  var lower = String(input || "").trim().toLowerCase();
  var dashed = lower.replace(/[^a-z0-9]+/g, "-");
  return dashed.replace(/-+/g, "-").replace(/^-|-$/g, "");
}

function uniqueOrgSlug(app, base, excludeId) {
  var candidate = base || "org";
  var n = 2;
  while (true) {
    try {
      var existing = app.findFirstRecordByFilter(
        "organizations",
        "slug = {:slug}",
        { slug: candidate }
      );
      if (!existing || (excludeId && existing.id === excludeId)) {
        return candidate;
      }
    } catch (_) {
      return candidate;
    }
    candidate = base + "-" + n;
    n++;
  }
}

function uniqueBranchSlug(app, orgId, base, excludeId) {
  var seed = base || "branch";
  if (seed === "all") {
    seed = "all-branch";
  }
  var candidate = seed;
  var n = 2;
  while (true) {
    if (candidate === "all") {
      candidate = seed + "-" + n;
      n++;
      continue;
    }
    try {
      var existing = app.findFirstRecordByFilter(
        "branches",
        "organization = {:org} && slug = {:slug}",
        { org: orgId, slug: candidate }
      );
      if (!existing || (excludeId && existing.id === excludeId)) {
        return candidate;
      }
    } catch (_) {
      return candidate;
    }
    candidate = seed + "-" + n;
    n++;
  }
}

migrate((app) => {
  // 1) Add nullable slug fields (no unique index yet — empty values collide).
  const orgs = app.findCollectionByNameOrId("pbc_organizations01");
  if (!orgs.fields.getById("text_org_slug")) {
    orgs.fields.add(new Field({
      "autogeneratePattern": "",
      "hidden": false,
      "id": "text_org_slug",
      "max": 64,
      "min": 1,
      "name": "slug",
      "pattern": "^[a-z0-9]+(?:-[a-z0-9]+)*$",
      "presentable": false,
      "primaryKey": false,
      "required": false,
      "system": false,
      "type": "text"
    }));
    app.save(orgs);
  }

  const branches = app.findCollectionByNameOrId("pbc_2358601297");
  if (!branches.fields.getById("text_branch_slug")) {
    branches.fields.add(new Field({
      "autogeneratePattern": "",
      "hidden": false,
      "id": "text_branch_slug",
      "max": 64,
      "min": 1,
      "name": "slug",
      "pattern": "^[a-z0-9]+(?:-[a-z0-9]+)*$",
      "presentable": false,
      "primaryKey": false,
      "required": false,
      "system": false,
      "type": "text"
    }));
    app.save(branches);
  }

  // 2) Backfill unique slugs from names.
  const orgRecords = app.findAllRecords("organizations");
  for (let i = 0; i < orgRecords.length; i++) {
    const org = orgRecords[i];
    if (org.getString("slug")) continue;
    org.set(
      "slug",
      uniqueOrgSlug(app, slugify(org.getString("name")), org.id)
    );
    app.save(org);
  }

  const branchRecords = app.findAllRecords("branches");
  for (let i = 0; i < branchRecords.length; i++) {
    const branch = branchRecords[i];
    if (branch.getString("slug")) continue;
    const orgId = branch.getString("organization");
    branch.set(
      "slug",
      uniqueBranchSlug(
        app,
        orgId,
        slugify(branch.getString("name")),
        branch.id
      )
    );
    app.save(branch);
  }

  // 3) Unique indexes + required now that every row has a slug.
  const orgIndexes = orgs.indexes || [];
  if (!orgIndexes.some((i) => String(i).indexOf("idx_organizations_slug") !== -1)) {
    orgs.indexes.push(
      "CREATE UNIQUE INDEX idx_organizations_slug ON organizations (slug)"
    );
  }
  const orgSlug = orgs.fields.getById("text_org_slug");
  if (orgSlug) orgSlug.required = true;
  app.save(orgs);

  const branchIndexes = branches.indexes || [];
  if (!branchIndexes.some((i) => String(i).indexOf("idx_branches_org_slug") !== -1)) {
    branches.indexes.push(
      "CREATE UNIQUE INDEX idx_branches_org_slug ON branches (organization, slug)"
    );
  }
  const branchSlug = branches.fields.getById("text_branch_slug");
  if (branchSlug) branchSlug.required = true;
  app.save(branches);
}, (app) => {
  const orgs = app.findCollectionByNameOrId("pbc_organizations01");
  orgs.fields.removeById("text_org_slug");
  orgs.indexes = (orgs.indexes || []).filter(
    (i) => String(i).indexOf("idx_organizations_slug") === -1
  );
  app.save(orgs);

  const branches = app.findCollectionByNameOrId("pbc_2358601297");
  branches.fields.removeById("text_branch_slug");
  branches.indexes = (branches.indexes || []).filter(
    (i) => String(i).indexOf("idx_branches_org_slug") === -1
  );
  app.save(branches);
});
