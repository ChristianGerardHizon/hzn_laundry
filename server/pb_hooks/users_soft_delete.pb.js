/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Soft-delete users with blank email
// ============================================================================
// Auth collection `email` is required. Soft-delete is an update that only
// sets isDeleted=true; PocketBase re-validates the merged record and rejects
// users who somehow have an empty email (Sentry HZN-LAUNDRY-8).
//
// Fill a unique placeholder before e.next() so validation sees a non-blank
// email. Placeholder keeps uniqueness and is clearly non-login.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordUpdateRequest(function(e) {
  try {
    var body = (e.requestInfo() && e.requestInfo().body) || {};
    var deleting =
      e.record.getBool("isDeleted") === true ||
      body.isDeleted === true ||
      body.isDeleted === "true";
    var email = (e.record.getString("email") || "").trim();

    if (deleting && !email) {
      e.record.set("email", "deleted+" + e.record.id + "@deleted.local");
      console.log(
        "[USERS] Soft-delete filled blank email for user " + e.record.id
      );
    }
  } catch (err) {
    console.error("[USERS] Soft-delete email fill error:", err);
  }

  e.next();
}, "users");
