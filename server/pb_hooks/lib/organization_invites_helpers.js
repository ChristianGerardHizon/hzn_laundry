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

  var rawTiers = branch.tiers;
  if (!Array.isArray(rawTiers) || rawTiers.length < 1) {
    throw new BadRequestError("at least one incentive tier is required");
  }

  var tiers = [];
  var i;
  for (i = 0; i < rawTiers.length; i++) {
    var tier = rawTiers[i] || {};
    var minAmount = Number(tier.minAmount);
    var incentiveAmount = Number(tier.incentiveAmount);
    if (isNaN(minAmount) || minAmount < 0) {
      throw new BadRequestError("tier minAmount must be a number >= 0");
    }
    if (isNaN(incentiveAmount) || incentiveAmount < 0) {
      throw new BadRequestError("tier incentiveAmount must be a number >= 0");
    }
    var maxAmount = 0;
    if (tier.maxAmount !== undefined && tier.maxAmount !== null && tier.maxAmount !== "") {
      maxAmount = Number(tier.maxAmount);
      if (isNaN(maxAmount) || maxAmount < 0) {
        throw new BadRequestError("tier maxAmount must be a number >= 0");
      }
    }
    tiers.push({
      minAmount: minAmount,
      maxAmount: maxAmount,
      incentiveAmount: incentiveAmount
    });
  }

  var incentiveAmount = Number(branch.incentiveAmount);
  if (isNaN(incentiveAmount) || incentiveAmount < 0) {
    incentiveAmount = tiers[0].incentiveAmount;
  }
  var incentivePerServiceItems = Number(branch.incentivePerServiceItems);
  if (isNaN(incentivePerServiceItems) || incentivePerServiceItems < 0) {
    incentivePerServiceItems = tiers[0].maxAmount || 200;
  }

  return {
    name: name,
    address: address,
    contactNumber: contactNumber,
    operatingHours: trimStr(branch.operatingHours),
    cutOffTime: trimStr(branch.cutOffTime),
    incentiveAmount: incentiveAmount,
    incentivePerServiceItems: incentivePerServiceItems,
    tiers: tiers
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

  var branch = parseSetupBranch(body);
  var invites = parseSetupInvites(body, e.app);

  var adminRole = findAdminSystemRole(e.app);
  if (!adminRole) {
    throw new ApiError(500, "Admin system role not found");
  }

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
    branchRecord.set("address", branch.address);
    branchRecord.set("contactNumber", branch.contactNumber);
    branchRecord.set("organization", org.id);
    branchRecord.set("operatingHours", branch.operatingHours);
    branchRecord.set("cutOffTime", branch.cutOffTime);
    branchRecord.set("incentiveAmount", branch.incentiveAmount);
    branchRecord.set("incentivePerServiceItems", branch.incentivePerServiceItems);
    branchRecord.set("isDeleted", false);
    txApp.save(branchRecord);

    var tiersCollection = txApp.findCollectionByNameOrId("incentiveTiers");
    var t;
    for (t = 0; t < branch.tiers.length; t++) {
      var tier = branch.tiers[t];
      var tierRecord = new Record(tiersCollection);
      tierRecord.set("branch", branchRecord.id);
      tierRecord.set("minAmount", tier.minAmount);
      tierRecord.set("maxAmount", tier.maxAmount);
      tierRecord.set("incentiveAmount", tier.incentiveAmount);
      tierRecord.set("sortOrder", t);
      txApp.save(tierRecord);
    }

    if (invites.length > 0) {
      var invitesCollection = txApp.findCollectionByNameOrId("organizationInvites");
      var i;
      for (i = 0; i < invites.length; i++) {
        var invite = invites[i];
        var inviteRecord = new Record(invitesCollection);
        inviteRecord.set("email", invite.email);
        inviteRecord.set("organization", org.id);
        inviteRecord.set("role", invite.role);
        inviteRecord.set("invitedBy", authId);
        inviteRecord.set("status", "pending");
        inviteRecord.set("expiresAt", inviteExpiresAt);
        txApp.save(inviteRecord);
      }
    }

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

module.exports = {
  readPermissions: readPermissions,
  canManageOrgMembers: canManageOrgMembers,
  requireManageOrgMembers: requireManageOrgMembers,
  createOrganization: createOrganization,
  updateOrganization: updateOrganization,
  createInvite: createInvite,
  acceptInvite: acceptInvite,
  revokeInvite: revokeInvite,
  declineInvite: declineInvite
};
