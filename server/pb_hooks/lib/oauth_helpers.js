/// <reference path="../../pb_data/types.d.ts" />

/**
 * Reject Google/OAuth sign-in that would create a new users record.
 * Existing users (email already provisioned) may link/sign in via OAuth.
 *
 * @param {core.RecordAuthWithOAuth2RequestEvent} e
 */
function rejectOAuthAccountCreation(e) {
    if (e.isNewRecord || !e.record) {
        throw new ForbiddenError(
            "No account for this Google email. Ask an admin to create your user first.",
        );
    }
    e.next();
}

module.exports = {
    rejectOAuthAccountCreation: rejectOAuthAccountCreation,
};
