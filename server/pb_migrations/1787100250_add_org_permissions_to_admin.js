/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const roles = app.findRecordsByFilter("userRoles", "name = {:name} && isSystem = true", "", 1, 0, {
    name: "Admin",
  });
  if (!roles || roles.length === 0) {
    throw new Error("Admin system role not found");
  }

  const role = roles[0];
  const permissions = parsePermissionKeys(role.get("permissions"));
  const extras = ["organizations.create", "members.manage"];
  for (let i = 0; i < extras.length; i++) {
    if (permissions.indexOf(extras[i]) === -1) {
      permissions.push(extras[i]);
    }
  }

  role.set("permissions", permissions);
  app.save(role);
}, (app) => {
  const roles = app.findRecordsByFilter("userRoles", "name = {:name} && isSystem = true", "", 1, 0, {
    name: "Admin",
  });
  if (!roles || roles.length === 0) return;

  const role = roles[0];
  const permissions = parsePermissionKeys(role.get("permissions")).filter(
    (p) => p !== "organizations.create" && p !== "members.manage"
  );
  role.set("permissions", permissions);
  app.save(role);
});

// JSONRaw must be decoded via .string() + JSON.parse. Array.isArray(raw) is true
// for the underlying bytes and would persist character codes instead of keys.
function parsePermissionKeys(raw) {
  if (!raw) return [];
  if (Array.isArray(raw) && raw.length > 0 && typeof raw[0] === "string") {
    return raw.slice();
  }
  try {
    const jsonString = typeof raw.string === "function" ? raw.string() : String(raw);
    const parsed = JSON.parse(jsonString);
    if (Array.isArray(parsed) && parsed.every((p) => typeof p === "string")) {
      return parsed.slice();
    }
    if (typeof parsed === "string") {
      const nested = JSON.parse(parsed);
      if (Array.isArray(nested)) return nested.slice();
    }
  } catch (_) {}
  if (Array.isArray(raw) && raw.length > 0 && typeof raw[0] === "number") {
    try {
      const fromCodes = String.fromCharCode.apply(null, raw);
      const parsed = JSON.parse(fromCodes);
      if (Array.isArray(parsed)) return parsed.slice();
    } catch (_) {}
  }
  return [];
}
