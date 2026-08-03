/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Auto-verify Users
// ============================================================================
// This app does not use email verification. Always mark auth users as
// verified on create, and backfill any existing unverified users on boot.
//
// Uses onRecordCreate (DB hook) rather than onRecordCreateRequest because
// the verified field is a protected system field that fails request
// validation when set via the API/request hooks.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordCreate(function(e) {
  try {
    e.record.setVerified(true);
    console.log("[AUTO_VERIFY] Verifying new user " + e.record.getString("username"));
  } catch (err) {
    console.error("[AUTO_VERIFY] Failed to set verified on create:", err);
  }

  e.next();
}, "users");

onBootstrap(function(e) {
  e.next();

  try {
    var unverified = $app.findRecordsByFilter(
      "users",
      "verified = false",
      "",
      0,
      0
    );

    if (!unverified || unverified.length === 0) {
      console.log("[AUTO_VERIFY] No unverified users to backfill");
      return;
    }

    console.log("[AUTO_VERIFY] Backfilling " + unverified.length + " unverified user(s)");

    for (var i = 0; i < unverified.length; i++) {
      try {
        unverified[i].setVerified(true);
        $app.save(unverified[i]);
        console.log(
          "[AUTO_VERIFY] Verified existing user " +
            unverified[i].getString("username")
        );
      } catch (err) {
        console.error(
          "[AUTO_VERIFY] Failed to verify user " + unverified[i].id + ":",
          err
        );
      }
    }
  } catch (err) {
    console.error("[AUTO_VERIFY] Bootstrap backfill error:", err);
  }
});
