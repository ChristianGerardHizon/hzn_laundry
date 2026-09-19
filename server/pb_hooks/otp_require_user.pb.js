/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// Require existing user for OTP
// ============================================================================
// PocketBase returns a fake otpId when no auth record matches (anti-enumeration).
// This app only allows login for admin-created users, so reject unknown emails.
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

onRecordRequestOTPRequest(function (e) {
  if (!e.record) {
    throw new BadRequestError(
      "No account for this email. Ask an admin to create your user first."
    );
  }
  e.next();
}, "users");
