/// <reference path="../pb_data/types.d.ts" />

// Reject OAuth flows that would create a new user (invite-only accounts).
onRecordAuthWithOAuth2Request((e) => {
    require(`${__hooks}/lib/oauth_helpers.js`).rejectOAuthAccountCreation(e);
}, "users");
