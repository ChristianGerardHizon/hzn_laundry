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
  var name = (body.name || "").trim();
  if (!name) {
    throw new BadRequestError("name is required");
  }

  var adminRole = findAdminSystemRole(e.app);
  if (!adminRole) {
    throw new ApiError(500, "Admin system role not found");
  }

  var collection = e.app.findCollectionByNameOrId("organizations");
  var record = new Record(collection);
  record.set("name", name);
  record.set("contactNumber", (body.contactNumber || "").trim());
  record.set("address", (body.address || "").trim());
  record.set("isDeleted", false);
  e.app.save(record);

  var memberships = e.app.findCollectionByNameOrId("organizationMemberships");
  var membership = new Record(memberships);
  membership.set("user", e.auth.id);
  membership.set("organization", record.id);
  membership.set("role", adminRole.id);
  membership.set("status", "active");
  membership.set("joinedAt", new Date().toISOString());
  e.app.save(membership);

  return e.json(200, exportRecord(record));
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
