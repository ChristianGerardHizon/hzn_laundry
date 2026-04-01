// download_config.js — shared config for download hooks
// NOT .pb.js so it won't auto-load as a hook

var VERSION_MANAGER_URL = "https://version-manager.fly.dev";
var HIZONELAUNDRY_APP_ID = "ex29s5w2t8j8v29";
var SUPERUSER_EMAIL = "test@test.com";
var SUPERUSER_PASSWORD = "password101";

/**
 * Authenticates with version-manager and returns the GitHub PAT + repo.
 * Returns { githubPat, githubRepo } or throws an error.
 */
function getGithubConfig() {
  // 1. Authenticate with version-manager to get a superuser token
  var authRes = $http.send({
    url: VERSION_MANAGER_URL + "/api/collections/_superusers/auth-with-password",
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      identity: SUPERUSER_EMAIL,
      password: SUPERUSER_PASSWORD
    }),
    timeout: 10
  });

  if (authRes.statusCode !== 200) {
    throw new Error("Failed to auth with version-manager: " + authRes.statusCode);
  }

  var vmToken = authRes.json.token;

  // 2. Fetch the application record (includes hidden githubPat field for superusers)
  var appRes = $http.send({
    url: VERSION_MANAGER_URL + "/api/collections/applications/records/" + HIZONELAUNDRY_APP_ID,
    method: "GET",
    headers: { "Authorization": "Bearer " + vmToken },
    timeout: 10
  });

  if (appRes.statusCode !== 200) {
    throw new Error("Failed to fetch app record: " + appRes.statusCode);
  }

  var githubPat = appRes.json.githubPat;
  var githubRepo = appRes.json.githubRepo;

  if (!githubPat || !githubRepo) {
    throw new Error("Missing githubPat or githubRepo on application record");
  }

  return { githubPat: githubPat, githubRepo: githubRepo };
}

/**
 * Fetches version info from the version-manager service.
 * Returns the version record or throws an error.
 */
function getVersionInfo() {
  var versionRes = $http.send({
    url: VERSION_MANAGER_URL + "/api/collections/versions/records?filter=application%3D%22" + HIZONELAUNDRY_APP_ID + "%22&perPage=1",
    method: "GET",
    timeout: 10
  });

  if (versionRes.statusCode !== 200 || !versionRes.json.items || versionRes.json.items.length === 0) {
    throw new Error("Version info not found");
  }

  return versionRes.json.items[0];
}

module.exports = {
  getGithubConfig: getGithubConfig,
  getVersionInfo: getVersionInfo
};
