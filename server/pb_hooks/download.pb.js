/// <reference path="../pb_data/types.d.ts" />

// ============================================================================
// GitHub Release Download Proxy
// ============================================================================
// Proxies APK downloads from a private GitHub repo using a PAT stored in the
// version-manager service (applications collection, githubPat field).
//
// Config and shared logic loaded via require() inside each handler
// (goja scope isolation — top-level vars are NOT accessible in handlers).
//
// ES5 only — no const, let, arrow functions, or async/await.
// ============================================================================

/**
 * GET /api/download/latest
 *
 * Downloads the latest APK release from the private GitHub repo.
 * No auth required — the app needs to download updates without login.
 */
routerAdd("GET", "/api/download/latest", function(e) {
  var config = require(__hooks + "/download_config.js");

  try {
    var github = config.getGithubConfig();

    // 3. Get latest release from GitHub
    var releaseRes = $http.send({
      url: "https://api.github.com/repos/" + github.githubRepo + "/releases/latest",
      method: "GET",
      headers: {
        "Authorization": "token " + github.githubPat,
        "Accept": "application/vnd.github+json",
        "User-Agent": "HznLaundry-PocketBase"
      },
      timeout: 15
    });

    if (releaseRes.statusCode !== 200) {
      console.error("[DOWNLOAD] GitHub releases API failed:", releaseRes.statusCode);
      return e.json(500, { success: false, error: "Failed to fetch release info from GitHub" });
    }

    var assets = releaseRes.json.assets;
    if (!assets || assets.length === 0) {
      return e.json(404, { success: false, error: "No assets found in latest release" });
    }

    // Find the APK asset
    var apkAsset = null;
    for (var i = 0; i < assets.length; i++) {
      if (assets[i].name && assets[i].name.indexOf(".apk") !== -1) {
        apkAsset = assets[i];
        break;
      }
    }

    if (!apkAsset) {
      return e.json(404, { success: false, error: "No APK found in latest release" });
    }

    console.log("[DOWNLOAD] Found APK asset: " + apkAsset.name + " (" + apkAsset.size + " bytes)");

    // 4. Download APK binary via the API URL with octet-stream accept header
    var downloadRes = $http.send({
      url: apkAsset.url,
      method: "GET",
      headers: {
        "Authorization": "token " + github.githubPat,
        "Accept": "application/octet-stream",
        "User-Agent": "HznLaundry-PocketBase"
      },
      timeout: 120
    });

    if (downloadRes.statusCode !== 200) {
      console.error("[DOWNLOAD] Failed to download APK:", downloadRes.statusCode);
      return e.json(500, { success: false, error: "Failed to download APK from GitHub" });
    }

    console.log("[DOWNLOAD] APK downloaded successfully: " + apkAsset.name);

    // 5. Stream the APK back to the client
    e.response.header().set("Content-Length", String(downloadRes.body.length));
    return e.blob(200, "application/vnd.android.package-archive", downloadRes.body);

  } catch (error) {
    console.error("[DOWNLOAD] Unexpected error:", error);
    return e.json(500, { success: false, error: "Internal server error: " + error.message });
  }
});

/**
 * GET /api/download/info
 *
 * Returns metadata about the latest release without downloading the APK.
 */
routerAdd("GET", "/api/download/info", function(e) {
  var config = require(__hooks + "/download_config.js");

  try {
    var version = config.getVersionInfo();

    return e.json(200, {
      success: true,
      latestVersion: version.major + "." + version.minor + "." + version.patch,
      minimumVersion: version.minimumMajor + "." + version.minimumMinor + "." + version.minimumPatch,
      buildNumber: version.buildNumber,
      downloadUrl: "/api/download/latest"
    });

  } catch (error) {
    console.error("[DOWNLOAD] Info endpoint error:", error);
    return e.json(500, { success: false, error: "Internal server error: " + error.message });
  }
});
