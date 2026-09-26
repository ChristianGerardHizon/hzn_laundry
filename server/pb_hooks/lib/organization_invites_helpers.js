/// <reference path="../../pb_data/types.d.ts" />

// Helpers for organization_invites.pb.js — org create/update + invite lifecycle.
//
// Direct REST create/update/delete on organizations, organizationMemberships,
// and organizationInvites is blocked (rules are null). Writes go through these
// hook-backed routes. app.save() is not subject to collection API rules.
//
// ES5 only — no const, let, arrow functions, or async/await.
// `permissions` is a JSON-typed field; record.get() returns types.JSONRaw.

var INVITE_TTL_DAYS = 7;

var ALL_BRANCHES_SLUG = "all";

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
  if (seed === ALL_BRANCHES_SLUG) {
    seed = "all-branch";
  }
  var candidate = seed;
  var n = 2;
  while (true) {
    if (candidate === ALL_BRANCHES_SLUG) {
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

var DEFAULT_FEATURE_FLAGS = [
  {
    key: "emailUpdatesEnabled",
    enabled: true,
    description: "Send order history link emails to customers",
  },
  {
    key: "requireMachine",
    enabled: false,
    description: "Block moving to Processing if no machine is assigned",
  },
  {
    key: "requirePack",
    enabled: false,
    description: "Block moving to Ready if no packs are set on the order",
  },
  {
    key: "requireStorage",
    enabled: false,
    description: "Block moving to Ready if no storage location is assigned",
  },
  {
    key: "consumableUsage",
    enabled: false,
    description: "Record detergent and fabric-conditioner usage on orders",
  },
];

function seedOrgFeatureFlags(app, orgId) {
  var collection = app.findCollectionByNameOrId("featureFlags");
  var i;
  for (i = 0; i < DEFAULT_FEATURE_FLAGS.length; i++) {
    var def = DEFAULT_FEATURE_FLAGS[i];
    try {
      app.findFirstRecordByFilter(
        "featureFlags",
        "organization = {:org} && key = {:key}",
        { org: orgId, key: def.key }
      );
      continue;
    } catch (_) {}
    var record = new Record(collection);
    record.set("key", def.key);
    record.set("enabled", def.enabled);
    record.set("description", def.description);
    record.set("organization", orgId);
    app.save(record);
  }
}

function isSuperuser(authRecord) {
  try {
    return authRecord.collection().name === "_superusers";
  } catch (_) {
    return false;
  }
}

function readPermissions(role) {
  if (!role) return [];
  var raw = role.get("permissions");
  if (!raw) return [];
  if (Array.isArray(raw) && raw.length > 0 && typeof raw[0] === "string") {
    return raw;
  }
  try {
    var jsonString = typeof raw.string === "function" ? raw.string() : String(raw);
    var parsed = JSON.parse(jsonString);
    if (Array.isArray(parsed) && parsed.length > 0 && typeof parsed[0] === "string") {
      return parsed;
    }
    if (typeof parsed === "string") {
      var nested = JSON.parse(parsed);
      if (Array.isArray(nested)) return nested;
    }
  } catch (_) {}
  if (Array.isArray(raw) && raw.length > 0 && typeof raw[0] === "number") {
    try {
      var fromCodes = String.fromCharCode.apply(null, raw);
      var parsedCodes = JSON.parse(fromCodes);
      if (Array.isArray(parsedCodes)) return parsedCodes;
    } catch (_) {}
  }
  return [];
}

function exportRecord(record) {
  if (record && typeof record.publicExport === "function") {
    return record.publicExport();
  }
  return record;
}

function hasPermission(app, roleId, permissionKey) {
  if (!roleId) return false;
  var permissions = [];
  try {
    var role = app.findRecordById("userRoles", roleId);
    permissions = readPermissions(role);
    console.log("[ORG] readPermissions for role " + roleId + ": " + JSON.stringify(permissions));
  } catch (_) {
    return false;
  }
  return Array.isArray(permissions) && permissions.indexOf(permissionKey) !== -1;
}

function findAdminSystemRole(app) {
  return app.findFirstRecordByFilter(
    "userRoles",
    "name = {:name} && isSystem = true",
    { name: "Admin" }
  );
}

function canManageOrgMembers(e, orgId) {
  var authRecord = e.auth;
  if (!authRecord) return false;
  if (isSuperuser(authRecord)) return true;

  var membership;
  try {
    membership = e.app.findFirstRecordByFilter(
      "organizationMemberships",
      "organization = {:org} && user = {:user} && status = 'active'",
      { org: orgId, user: authRecord.id }
    );
  } catch (_) {
    return false;
  }
  if (!membership) return false;
  return hasPermission(e.app, membership.getString("role"), "members.manage");
}

function requireManageOrgMembers(e, orgId) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }
  if (!canManageOrgMembers(e, orgId)) {
    throw new ForbiddenError("members.manage permission required for this organization");
  }
}

function trimStr(value) {
  return String(value || "").trim();
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function parseSetupBranch(body) {
  var branch = body.branch;
  if (!branch || typeof branch !== "object") {
    throw new BadRequestError("branch is required");
  }

  var name = trimStr(branch.name);
  var address = trimStr(branch.address);
  var contactNumber = trimStr(branch.contactNumber);
  if (!name) {
    throw new BadRequestError("branch name is required");
  }
  if (!address) {
    throw new BadRequestError("branch address is required");
  }
  if (!contactNumber) {
    throw new BadRequestError("branch contactNumber is required");
  }

  return {
    name: name,
    address: address,
    contactNumber: contactNumber,
    operatingHours: trimStr(branch.operatingHours),
    cutOffTime: trimStr(branch.cutOffTime)
  };
}

function parseSetupInvites(body, app) {
  var raw = body.invites;
  if (raw === undefined || raw === null || raw === "") {
    return [];
  }
  if (!Array.isArray(raw)) {
    throw new BadRequestError("invites must be an array");
  }

  var invites = [];
  var seen = {};
  var i;
  for (i = 0; i < raw.length; i++) {
    var item = raw[i] || {};
    var email = trimStr(item.email).toLowerCase();
    var role = trimStr(item.role || item.roleId);
    if (!email || !role) {
      throw new BadRequestError("each invite requires email and role");
    }
    if (!isValidEmail(email)) {
      throw new BadRequestError("invalid invite email: " + email);
    }
    try {
      app.findRecordById("userRoles", role);
    } catch (_) {
      throw new BadRequestError("invite role not found: " + role);
    }
    if (seen[email]) {
      continue;
    }
    seen[email] = true;
    invites.push({ email: email, role: role });
  }
  return invites;
}

function createOrganization(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }
  if (isSuperuser(e.auth)) {
    throw new ForbiddenError("use the Admin UI to create organizations as a superuser");
  }

  if (!hasPermission(e.app, e.auth.getString("role"), "organizations.create")) {
    throw new ForbiddenError("organizations.create permission required");
  }

  var body = e.requestInfo().body || {};
  var name = trimStr(body.name);
  if (!name) {
    throw new BadRequestError("name is required");
  }

  var packageId = trimStr(body.packageId);
  var customPackage =
    body.customPackage && typeof body.customPackage === "object"
      ? body.customPackage
      : null;
  if (!packageId && !customPackage) {
    throw new BadRequestError("packageId or customPackage is required");
  }

  var isSystemAdmin = hasPermission(
    e.app,
    e.auth.getString("role"),
    "system.admin"
  );
  if (customPackage && !isSystemAdmin) {
    throw new ForbiddenError("customPackage requires system.admin");
  }

  var branch = parseSetupBranch(body);
  var invites = parseSetupInvites(body, e.app);

  var adminRole = findAdminSystemRole(e.app);
  if (!adminRole) {
    throw new ApiError(500, "Admin system role not found");
  }

  // Lazy require to avoid circular load with organization_subscriptions_helpers.
  var subHelpers = require(__hooks + "/lib/organization_subscriptions_helpers.js");

  var createdOrg = null;
  var authId = e.auth.id;
  var contactNumber = trimStr(body.contactNumber);
  var address = trimStr(body.address);
  var nowIso = new Date().toISOString();
  var inviteExpiresAt = new Date(
    Date.now() + INVITE_TTL_DAYS * 24 * 60 * 60 * 1000
  ).toISOString();

  e.app.runInTransaction(function(txApp) {
    var orgCollection = txApp.findCollectionByNameOrId("organizations");
    var org = new Record(orgCollection);
    org.set("name", name);
    org.set("slug", uniqueOrgSlug(txApp, slugify(name), null));
    org.set("contactNumber", contactNumber);
    org.set("address", address);
    org.set("isDeleted", false);
    org.set("onboardingCompletedAt", nowIso);
    txApp.save(org);

    var memberships = txApp.findCollectionByNameOrId("organizationMemberships");
    var membership = new Record(memberships);
    membership.set("user", authId);
    membership.set("organization", org.id);
    membership.set("role", adminRole.id);
    membership.set("status", "active");
    membership.set("joinedAt", nowIso);
    txApp.save(membership);

    var branches = txApp.findCollectionByNameOrId("branches");
    var branchRecord = new Record(branches);
    branchRecord.set("name", branch.name);
    branchRecord.set(
      "slug",
      uniqueBranchSlug(txApp, org.id, slugify(branch.name), null)
    );
    branchRecord.set("address", branch.address);
    branchRecord.set("contactNumber", branch.contactNumber);
    branchRecord.set("organization", org.id);
    branchRecord.set("operatingHours", branch.operatingHours);
    branchRecord.set("cutOffTime", branch.cutOffTime);
    branchRecord.set("isDeleted", false);
    txApp.save(branchRecord);

    if (invites.length > 0) {
      var invitesCollection = txApp.findCollectionByNameOrId("organizationInvites");
      var i;
      for (i = 0; i < invites.length; i++) {
        var invite = invites[i];
        var inviteEmail = String(invite.email || "").trim().toLowerCase();
        ensureUserAccountForInvite(txApp, inviteEmail);
        var inviteRecord = new Record(invitesCollection);
        inviteRecord.set("email", inviteEmail);
        inviteRecord.set("organization", org.id);
        inviteRecord.set("role", invite.role);
        inviteRecord.set("invitedBy", authId);
        inviteRecord.set("status", "pending");
        inviteRecord.set("expiresAt", inviteExpiresAt);
        txApp.save(inviteRecord);
      }
    }

    seedOrgFeatureFlags(txApp, org.id);

    subHelpers.assignSubscriptionInApp(txApp, org.id, {
      packageId: packageId,
      customPackage: customPackage,
      allowCustom: isSystemAdmin,
      requirePremade: !isSystemAdmin || !customPackage
    });

    createdOrg = org;
  });

  return e.json(200, exportRecord(createdOrg));
}

function updateOrganization(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }

  var id = e.request.pathValue("id");
  var record;
  try {
    record = e.app.findRecordById("organizations", id);
  } catch (_) {
    throw new NotFoundError("organization not found");
  }
  if (!record) {
    throw new NotFoundError("organization not found");
  }

  requireManageOrgMembers(e, record.id);

  var body = e.requestInfo().body || {};
  if (body.name !== undefined) {
    var name = String(body.name).trim();
    if (!name) {
      throw new BadRequestError("name is required");
    }
    record.set("name", name);
  }
  if (body.contactNumber !== undefined) {
    record.set("contactNumber", String(body.contactNumber).trim());
  }
  if (body.address !== undefined) {
    record.set("address", String(body.address).trim());
  }
  if (body.onboardingCompletedAt !== undefined) {
    record.set("onboardingCompletedAt", body.onboardingCompletedAt);
  }

  e.app.save(record);
  return e.json(200, exportRecord(record));
}

function updateFeatureFlag(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }

  var id = e.request.pathValue("id");
  var record;
  try {
    record = e.app.findRecordById("featureFlags", id);
  } catch (_) {
    throw new NotFoundError("feature flag not found");
  }
  if (!record) {
    throw new NotFoundError("feature flag not found");
  }

  requireManageOrgMembers(e, record.getString("organization"));

  var body = e.requestInfo().body || {};
  if (body.enabled === undefined) {
    throw new BadRequestError("enabled is required");
  }
  record.set("enabled", !!body.enabled);
  e.app.save(record);
  return e.json(200, exportRecord(record));
}

function createInvite(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }

  var body = e.requestInfo().body || {};
  var organization = (body.organization || "").trim();
  var role = (body.role || "").trim();
  var email = (body.email || "").trim().toLowerCase();

  if (!organization || !role || !email) {
    throw new BadRequestError("organization, role, and email are required");
  }

  requireManageOrgMembers(e, organization);

  // Ensure a login account exists so the invitee can OTP/OAuth then accept.
  // Do not assign role here — permissions come from users.role only after accept.
  ensureUserAccountForInvite(e.app, email);

  var collection = e.app.findCollectionByNameOrId("organizationInvites");
  var record = new Record(collection);
  record.set("email", email);
  record.set("organization", organization);
  record.set("role", role);
  record.set("invitedBy", e.auth.id);
  record.set("status", "pending");
  var expiresAt = new Date(Date.now() + INVITE_TTL_DAYS * 24 * 60 * 60 * 1000);
  record.set("expiresAt", expiresAt.toISOString());

  e.app.save(record);
  return e.json(200, exportRecord(record));
}

/**
 * Creates a users auth record when the invite email has no account yet.
 * Auto-verify hook marks verified on create. Random password — login via OTP/Google.
 * Role is intentionally omitted; acceptInvite sets users.role from the invite.
 */
function ensureUserAccountForInvite(app, email) {
  var existing;
  try {
    existing = app.findFirstRecordByFilter(
      "users",
      "email = {:email}",
      { email: email }
    );
  } catch (_) {
    existing = null;
  }
  if (existing) {
    return existing;
  }

  var collection = app.findCollectionByNameOrId("users");
  var record = new Record(collection);
  var password = $security.randomString(32);
  var localPart = email.split("@")[0] || "user";
  record.set("email", email);
  record.set("name", localPart);
  record.set("password", password);
  record.set("passwordConfirm", password);
  record.set("isDeleted", false);
  app.save(record);
  return record;
}

function acceptInvite(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }

  var id = e.request.pathValue("id");
  var invite;
  try {
    invite = e.app.findRecordById("organizationInvites", id);
  } catch (_) {
    throw new NotFoundError("invite not found");
  }
  if (!invite) {
    throw new NotFoundError("invite not found");
  }

  if (invite.getString("status") !== "pending") {
    throw new BadRequestError("invite is no longer valid");
  }

  var expiresAt = new Date(invite.getString("expiresAt"));
  if (Date.now() > expiresAt.getTime()) {
    invite.set("status", "expired");
    e.app.save(invite);
    throw new BadRequestError("invite has expired");
  }

  var authEmail = (e.auth.getString("email") || "").trim().toLowerCase();
  var inviteEmail = (invite.getString("email") || "").trim().toLowerCase();
  if (authEmail !== inviteEmail) {
    throw new ForbiddenError("this invite is for a different account");
  }

  var organizationId = invite.getString("organization");

  var existing;
  try {
    existing = e.app.findFirstRecordByFilter(
      "organizationMemberships",
      "user = {:user} && organization = {:org}",
      { user: e.auth.id, org: organizationId }
    );
  } catch (_) {
    existing = null;
  }

  var membership;
  if (existing) {
    membership = existing;
    membership.set("role", invite.getString("role"));
    membership.set("status", "active");
    e.app.save(membership);
  } else {
    var collection = e.app.findCollectionByNameOrId("organizationMemberships");
    membership = new Record(collection);
    membership.set("user", e.auth.id);
    membership.set("organization", organizationId);
    membership.set("role", invite.getString("role"));
    membership.set("status", "active");
    membership.set("invitedBy", invite.getString("invitedBy"));
    membership.set("joinedAt", new Date().toISOString());
    e.app.save(membership);
  }

  // Keep users.role in sync — nav permissions resolve from the auth user record.
  try {
    var authUser = e.app.findRecordById("users", e.auth.id);
    if (authUser) {
      authUser.set("role", invite.getString("role"));
      e.app.save(authUser);
    }
  } catch (_) {}

  invite.set("status", "accepted");
  invite.set("acceptedBy", e.auth.id);
  e.app.save(invite);

  return e.json(200, exportRecord(membership));
}

function revokeInvite(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }

  var id = e.request.pathValue("id");
  var invite;
  try {
    invite = e.app.findRecordById("organizationInvites", id);
  } catch (_) {
    throw new NotFoundError("invite not found");
  }
  if (!invite) {
    throw new NotFoundError("invite not found");
  }

  requireManageOrgMembers(e, invite.getString("organization"));

  if (invite.getString("status") !== "pending") {
    throw new BadRequestError("invite is no longer pending");
  }

  invite.set("status", "revoked");
  e.app.save(invite);
  return e.json(200, exportRecord(invite));
}

function declineInvite(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }

  var id = e.request.pathValue("id");
  var invite;
  try {
    invite = e.app.findRecordById("organizationInvites", id);
  } catch (_) {
    throw new NotFoundError("invite not found");
  }
  if (!invite) {
    throw new NotFoundError("invite not found");
  }

  if (invite.getString("status") !== "pending") {
    throw new BadRequestError("invite is no longer pending");
  }

  var authEmail = (e.auth.getString("email") || "").trim().toLowerCase();
  var inviteEmail = (invite.getString("email") || "").trim().toLowerCase();
  if (authEmail !== inviteEmail) {
    throw new ForbiddenError("this invite is for a different account");
  }

  invite.set("status", "revoked");
  e.app.save(invite);
  return e.json(200, exportRecord(invite));
}

function listOrganizationPlatformStats(e) {
  if (!e.auth) {
    throw new ForbiddenError("authentication required");
  }
  if (isSuperuser(e.auth)) {
    throw new ForbiddenError("use the Admin UI as a superuser");
  }
  if (!hasPermission(e.app, e.auth.getString("role"), "system.admin")) {
    throw new ForbiddenError("system.admin permission required");
  }

  var rows = arrayOf(
    new DynamicModel({
      id: "",
      name: "",
      slug: "",
      onboardingCompletedAt: nullString(),
      branchCount: 0,
      memberCount: 0,
      orderCount: 0,
      customerCount: 0,
      revenue: -0
    })
  );

  e.app
    .db()
    .newQuery(
      "SELECT " +
        "o.id AS id, " +
        "o.name AS name, " +
        "COALESCE(o.slug, '') AS slug, " +
        "o.onboardingCompletedAt AS onboardingCompletedAt, " +
        "COALESCE((SELECT COUNT(*) FROM branches b WHERE b.organization = o.id), 0) AS branchCount, " +
        "COALESCE((SELECT COUNT(*) FROM organizationMemberships m WHERE m.organization = o.id AND m.status = 'active'), 0) AS memberCount, " +
        "COALESCE((" +
        "SELECT COUNT(*) FROM sales s " +
        "INNER JOIN branches b ON b.id = s.branch " +
        "WHERE b.organization = o.id " +
        "AND s.status != 'voided' " +
        "AND (s.isDeleted = false OR s.isDeleted IS NULL)" +
        "), 0) AS orderCount, " +
        "COALESCE((" +
        "SELECT COUNT(*) FROM customers c " +
        "INNER JOIN branches b ON b.id = c.branch " +
        "WHERE b.organization = o.id" +
        "), 0) AS customerCount, " +
        "COALESCE((" +
        "SELECT SUM(s.totalAmount) FROM sales s " +
        "INNER JOIN branches b ON b.id = s.branch " +
        "WHERE b.organization = o.id " +
        "AND s.status != 'voided' " +
        "AND (s.isDeleted = false OR s.isDeleted IS NULL)" +
        "), 0) AS revenue " +
        "FROM organizations o " +
        "WHERE COALESCE(o.isDeleted, false) = false " +
        "ORDER BY o.name COLLATE NOCASE ASC"
    )
    .all(rows);

  var organizations = [];
  var totalOrders = 0;
  var totalCustomers = 0;
  var totalRevenue = 0;
  var i;
  for (i = 0; i < rows.length; i++) {
    var row = rows[i];
    var orderCount = Number(row.orderCount) || 0;
    var customerCount = Number(row.customerCount) || 0;
    var revenue = Number(row.revenue) || 0;
    var branchCount = Number(row.branchCount) || 0;
    var memberCount = Number(row.memberCount) || 0;
    totalOrders += orderCount;
    totalCustomers += customerCount;
    totalRevenue += revenue;
    organizations.push({
      id: row.id,
      name: row.name,
      slug: row.slug || "",
      onboardingCompletedAt: row.onboardingCompletedAt || null,
      branchCount: branchCount,
      memberCount: memberCount,
      orderCount: orderCount,
      customerCount: customerCount,
      revenue: revenue
    });
  }

  return e.json(200, {
    summary: {
      organizationCount: organizations.length,
      orderCount: totalOrders,
      customerCount: totalCustomers,
      revenue: totalRevenue
    },
    organizations: organizations
  });
}

module.exports = {
  readPermissions: readPermissions,
  hasPermission: hasPermission,
  isSuperuser: isSuperuser,
  canManageOrgMembers: canManageOrgMembers,
  requireManageOrgMembers: requireManageOrgMembers,
  createOrganization: createOrganization,
  updateOrganization: updateOrganization,
  updateFeatureFlag: updateFeatureFlag,
  createInvite: createInvite,
  acceptInvite: acceptInvite,
  revokeInvite: revokeInvite,
  declineInvite: declineInvite,
  listOrganizationPlatformStats: listOrganizationPlatformStats
};
