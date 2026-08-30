# Deployment & CI/CD

This document describes the GitHub Actions deployment pipeline, branching strategy, and required configuration.

---

## Table of Contents

1. [Branching Strategy](#branching-strategy)
2. [Workflow Files](#workflow-files)
3. [Deployment Flows](#deployment-flows)
4. [Required GitHub Secrets](#required-github-secrets)
5. [GitHub Environment Setup](#github-environment-setup)
6. [Server-Side Requirements](#server-side-requirements)
7. [Build-Time Dart Defines](#build-time-dart-defines)
8. [Android Signing](#android-signing)
9. [Version Management](#version-management)
10. [Build Artifacts & Caching](#build-artifacts--caching)
11. [Platform Support](#platform-support)
12. [Google Play Store](#google-play-store)

---

## Branching Strategy

```
feature branch → staging → main
```

- **All development PRs** merge into `staging`.
- **Only `staging`** can merge into `main` (enforced by `branch-protection.yml`).
- Adding the `deploy` label on a staging PR auto-creates a release PR to `main`.

---

## Workflow Files

| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | Main deployment — staging + production builds and releases |
| `.github/workflows/auto-promote.yml` | Auto-creates a PR from `staging` → `main` when a merged PR has the `deploy` label |
| `.github/workflows/branch-protection.yml` | Blocks PRs to `main` that don't originate from `staging` |

---

## Deployment Flows

### Staging Deployment

**Trigger:** PR merged to `staging`, or manual `workflow_dispatch`.

```
PR merged to staging (or manual dispatch)
  │
  ├─ Validate all required secrets exist
  ├─ Setup: Java 17 (Zulu) + Flutter 3.38.3
  ├─ Restore caches (Gradle, Pub, Flutter build)
  ├─ flutter pub get
  │
  ├─ Fetch current version from Version Manager API
  │   → Increment patch → append "-staging" suffix
  │   → Resolve unique tag (append build number if tag exists)
  │
  ├─ Decode KEYSTORE_BASE64 → upload-keystore.jks
  │
  ├─ Build Web (WASM, --release)
  │   --dart-define=ENV=staging
  │   --dart-define=API_URL=$POCKETBASE_URL_STAGING
  │
  ├─ Build APK (--flavor staging, --release, signed)
  │   --dart-define=ENV=staging
  │   --dart-define=API_URL=$POCKETBASE_URL_STAGING
  │
  ├─ Setup SSH agent + known_hosts
  ├─ rsync web build → staging server pb_public/
  ├─ rsync migrations → staging server pb_migrations/
  ├─ Restart PocketBase staging service
  │
  └─ Create GitHub Release (prerelease)
      Tag: staging-X.Y.Z[-build.N]
      Artifact: app-staging-release.apk
      Body: compiled release notes from merged staging PRs

  (in parallel, only if the `build-windows` label or workflow_dispatch
   `build_windows` input is set — see "Windows Build (opt-in)" below)
  ├─ [build-windows-staging job] flutter build windows --release → zip
  └─ [attach-windows-staging job] attach zip to the release created above
```

### Production Deployment

**Trigger:** PR merged to `main` (must come from `staging`). Cannot be triggered manually.

```
PR merged to main
  │
  ├─ "Production" environment approval gate
  │
  ├─ [deploy-production job]
  │   ├─ Validate all required secrets exist
  │   ├─ Setup: Java 17 (Zulu) + Flutter 3.38.3
  │   ├─ Restore caches (Gradle, Pub, Flutter build)
  │   ├─ flutter pub get
  │   │
  │   ├─ Fetch current version from Version Manager API
  │   │   → Increment patch (no suffix)
  │   │
  │   ├─ Decode KEYSTORE_BASE64 → upload-keystore.jks
  │   │
  │   ├─ Build Web (--release, no WASM)
  │   │   --dart-define=ENV=prod
  │   │   --dart-define=API_URL=$POCKETBASE_URL_PROD
  │   │
  │   ├─ Build APK (--flavor prod, --release, signed)
  │   │   --dart-define=ENV=prod
  │   │   --dart-define=API_URL=$POCKETBASE_URL_PROD
  │   │
  │   ├─ Build App Bundle / AAB (--flavor prod, --release, signed)
  │   │   --dart-define=ENV=prod
  │   │   --dart-define=API_URL=$POCKETBASE_URL_PROD
  │   │
  │   ├─ Setup SSH agent + known_hosts
  │   ├─ rsync web build → production server pb_public/
  │   ├─ rsync migrations → production server pb_migrations/
  │   ├─ Restart PocketBase production service
  │   │
  │   ├─ Upload APK + AAB as GitHub Actions artifacts
  │   ├─ Compile user-facing release notes from merged staging PRs
  │   └─ Upload AAB to Google Play Internal testing (published, with What's new)
  │
  ├─ [release-and-sync job] (depends on deploy-production)
  │   ├─ Download APK + AAB + release notes artifacts
  │   ├─ Create GitHub Release (body = compiled release notes)
  │   │   Tag: vX.Y.Z
  │   │   Artifacts: app-prod-release.apk, app-prod-release.aab
  │   └─ PATCH Version Manager API with new version
  │
  (in parallel with deploy-production, only if the `build-windows` label is set)
  ├─ [build-windows-production job] flutter build windows --release → zip
  └─ [attach-windows-production job] (depends on release-and-sync + build-windows-production)
      attach zip to the release created above
```

### Auto-Promote Flow

**Trigger:** PR with `deploy` label merged to `staging`.

```
Labeled PR merged to staging
  │
  ├─ Check if an open staging → main PR already exists
  │   └─ If yes → skip
  │
  └─ Create PR: staging → main
      Title: "Release: promote staging to main"
      Body: includes source PR number and title
      Forwards labels: version:*, minimum version, build-windows (if present on source PR)
```

### Windows Build (opt-in)

**Trigger:** the `build-windows` PR label (or the `build_windows` boolean input on a manual `workflow_dispatch` run, staging only).

- Not part of the required PR label checklist — add it only when a Windows build is actually needed for that release.
- Produces an **unsigned ZIP** of the `flutter build windows --release` output (no MSIX/installer, no code-signing cert). Running the `.exe` inside may trigger a SmartScreen warning.
- Runs on `windows-latest`, in parallel with the Android/Web build, then attaches the ZIP to the same GitHub Release as an additional asset once it's created.
- **Carries over automatically**: if a staging PR has both `deploy` and `build-windows`, the auto-created staging→main PR also gets `build-windows`, so the production release gets a Windows build too without re-labeling.

---

## Required GitHub Secrets

These must be configured in **Settings → Secrets and variables → Actions**.

| Secret | Required | Used In | Description |
|--------|----------|---------|-------------|
| `VERSION_MANAGER_URL` | Yes | Staging & Production | PocketBase API endpoint for version tracking |
| `VERSION_COLLECTION_ID` | Yes | Staging & Production | Record ID in the version collection |
| `POCKETBASE_URL_STAGING` | Yes | Staging | Staging PocketBase backend URL |
| `POCKETBASE_URL_PROD` | Yes | Production | Production PocketBase backend URL |
| `KEYSTORE_BASE64` | Yes | Staging & Production | Base64-encoded Android signing keystore (`.jks`) |
| `KEYSTORE_PASSWORD` | Yes | Staging & Production | Keystore store password |
| `KEY_ALIAS` | Yes | Staging & Production | Key alias within the keystore |
| `KEY_PASSWORD` | Yes | Staging & Production | Key password |
| `PLAYSTORE_SERVICE_ACCOUNT_JSON` | Optional | Production | Play Console service-account JSON. If unset, Play upload is skipped (see [Google Play Store](#google-play-store)). |
| `SSH_HOST` | Yes | Staging & Production | Server hostname or IP for SSH deployment |
| `SSH_USER` | Yes | Staging & Production | SSH username (e.g., `deploy`) |
| `SSH_PRIVATE_KEY` | Yes | Staging & Production | Ed25519 or RSA private key (PEM format) for SSH authentication |
| `PB_TOKEN` | Optional | Production (release-and-sync) | Auth token for PATCH-ing the Version Manager after release |

`GITHUB_TOKEN` is provided automatically by GitHub Actions.

---

## GitHub Environment Setup

A **"Production"** environment must be created in the repository:

**Settings → Environments → New environment → "Production"**

This environment acts as an approval gate — production deploys require manual approval before running.

---

## Server-Side Requirements

Both staging and production deploy to the **same server** via SSH. The following must be configured on the server:

### SSH Access
- The `SSH_USER` must have `authorized_keys` configured with the public key matching `SSH_PRIVATE_KEY`
- `rsync` must be installed on the server

### Directory Permissions

The SSH user needs write access to:

| Path | Purpose |
|------|---------|
| `/opt/pocketbase/hizonelaundry-staging/pb_public/` | Staging web build |
| `/opt/pocketbase/hizonelaundry-staging/pb_migrations/` | Staging PocketBase migrations |
| `/opt/pocketbase/hizonelaundry/pb_public/` | Production web build |
| `/opt/pocketbase/hizonelaundry/pb_migrations/` | Production PocketBase migrations |

### Passwordless Sudo

The SSH user needs passwordless sudo for restarting PocketBase services. Add to `/etc/sudoers.d/deploy`:

```
deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart pocketbase_hizonelaundry-staging.service
deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart pocketbase_hizonelaundry.service
```

---

## Build-Time Dart Defines

Injected at compile time via `--dart-define`. Android/iOS also select a `--flavor` (`dev`, `staging`, `prod`).

| Define | Staging Value | Production Value | Purpose |
|--------|--------------|-----------------|---------|
| `ENV` | `staging` | `prod` | Selects environment configuration |
| `API_URL` | `$POCKETBASE_URL_STAGING` | `$POCKETBASE_URL_PROD` | Backend API endpoint |

Android flavor IDs:

| Flavor | Application ID | PocketBase |
|--------|----------------|------------|
| `dev` | `com.hznsystems.hizonelaundry.dev` | `http://127.0.0.1:8090` |
| `staging` | `com.hznsystems.hizonelaundry.staging` | staging URL |
| `prod` | `com.hznsystems.hizonelaundry` | production URL (Play Store) |

---

## Android Signing

The APK and App Bundle (AAB) build steps set these environment variables, which are read by `android/app/build.gradle.kts`:

| Variable | Source | Purpose |
|----------|--------|---------|
| `CI` | Hardcoded `"true"` | Signals CI environment |
| `CM_KEYSTORE_PATH` | Path to decoded `.jks` file | Keystore file location |
| `CM_KEYSTORE_PASSWORD` | `KEYSTORE_PASSWORD` secret | Keystore password |
| `CM_KEY_ALIAS` | `KEY_ALIAS` secret | Key alias |
| `CM_KEY_PASSWORD` | `KEY_PASSWORD` secret | Key password |

**Signing logic in `build.gradle.kts`:**
- If `CI=true` and `CM_KEYSTORE_PATH` is set → uses CI environment variables
- Otherwise → falls back to local `android/key.properties` file

### Generating `KEYSTORE_BASE64`

To encode your keystore for the secret:

```bash
base64 -i your-keystore.jks | pbcopy   # macOS (copies to clipboard)
base64 -w 0 your-keystore.jks          # Linux (outputs to stdout)
```

---

## Version Management

Versions are tracked via an external PocketBase instance (the "Version Manager").

### How It Works

1. A single PocketBase record stores `major`, `minor`, `patch` fields.
2. **Staging builds** fetch the current version, increment patch, and append `-staging`.
3. **Production builds** fetch the current version, increment patch (no suffix).
4. After a production release, the `release-and-sync` job PATCHes the record with the new patch number.

### Version Formats

| Environment | Version Format | Tag Format | Example |
|-------------|---------------|------------|---------|
| Staging | `X.Y.Z-staging` | `staging-X.Y.Z` or `staging-X.Y.Z-build.N` | `1.2.4-staging` / `staging-1.2.4-build.42` |
| Production | `X.Y.Z` | `vX.Y.Z` | `1.2.4` / `v1.2.4` |

---

## Build Artifacts & Caching

### Caching Strategy

| Cache | Key | Scope |
|-------|-----|-------|
| Gradle | Managed by `actions/setup-java` | Shared |
| Pub dependencies | `{os}-pub-{hash(pubspec.lock)}` | Shared |
| Flutter build | `{os}-flutter-build-{staging\|prod}-{hash(lib/**, pubspec.lock)}` | Per environment |

Staging and production have **separate** Flutter build caches to prevent conflicts.

### Artifacts

| Environment | Artifact | Destination |
|-------------|----------|-------------|
| Staging | APK | GitHub Release (prerelease) |
| Production | APK | GitHub Actions artifact → GitHub Release (public) |
| Production | AAB | Google Play Internal testing (published) + GitHub Release |
| Both | Web build | Auto-deployed to server via SSH (rsync) |

---

## Platform Support

| Platform | CI/CD Status | Notes |
|----------|-------------|-------|
| Android (APK) | Fully automated | Signed release builds for both environments |
| Android (Play Store) | Production only | Signed AAB uploaded and rolled out on **Internal testing** |
| Web | Fully automated | WASM for staging, standard for production. Auto-deployed via SSH/rsync to PocketBase `pb_public/`. |
| iOS | Not configured | Would require macOS runner + signing certificates |
| macOS | Not configured | Would require macOS runner |
| Linux | Not configured | Could use standard Ubuntu runner |
| Windows | Automated, opt-in | Unsigned release ZIP, built only when the `build-windows` label is present (see [Windows Build (opt-in)](#windows-build-opt-in)) |

---

## Quick Reference: Staging vs Production

| Aspect | Staging | Production |
|--------|---------|-----------|
| **Trigger** | PR merged to `staging` or manual dispatch | PR merged to `main` only |
| **Manual dispatch** | Yes | No |
| **Approval gate** | None | "Production" environment approval |
| **Version suffix** | `-staging` | None |
| **Release type** | Prerelease | Public release |
| **Web build** | `--wasm`, deployed via SSH | Standard, deployed via SSH |
| **Play Store** | Not uploaded | Signed AAB published to Internal testing |
| **Version Manager** | Not updated | Updated after release |

---

## Google Play Store

Play Console does **not** accept APKs for new uploads. Production deploys therefore build a signed **Android App Bundle** (`.aab`) and upload it with the Play Developer API.

**Package name:** `com.hznsystems.hizonelaundry` (must match `applicationId` in `android/app/build.gradle.kts` and the Play Console app).

The AAB is uploaded to **Internal testing** with `status: completed` (published to testers). Staging deploys do **not** upload to Play. The public production track is not used. The app does not appear in Play Store search; testers install via the Internal testing opt-in link.

Testers already on the Internal testing email list receive the new build automatically after a successful production deploy.

### One-time setup (Play Console + GitHub)

Do these steps once. After that, every merge to `main` publishes a new Internal testing AAB automatically.

#### 1. Create the app in Play Console

1. Open [Google Play Console](https://play.google.com/console) with your developer account.
2. **Create app** → name **Hi-Zone Laundry**, default language, app (not game), free or paid.
3. Complete the required dashboard tasks until the app exists (privacy policy, app access, ads, content rating, target audience, Data safety, store listing). You can finish store listing later, but the **app record must exist** before the API can upload.

#### 2. Enable Play App Signing

On first upload, Play Console will ask you to enroll in **Play App Signing**.

- Use the **same keystore** already stored as `KEYSTORE_BASE64`. That key becomes the **upload key** (and, if this is the first listing, also the signing key you export to Google).
- Do not create a second keystore. Changing keys later is painful.

#### 3. First AAB (manual, once)

The Play Developer API usually cannot create the very first artifact. Upload the first bundle by hand:

1. On a machine with Flutter and the release keystore:  
   `flutter build appbundle --flavor prod --release --dart-define=ENV=prod --dart-define=API_URL=<production PocketBase URL>`
2. Or download `app-prod-release.aab` from a GitHub Release after a production build that got as far as the AAB (if the Play upload step is the only failure).
3. In Play Console: **Testing** → **Internal testing** → **Create new release** → upload the `.aab`.
4. Complete and roll out to Internal testing.

After one successful console upload, later production deploys use the API.

#### 4. Google Cloud service account

1. In Play Console go to **Setup** → **API access** (or **Users and permissions** → **Invite new users** / service accounts, depending on the current Console UI).
2. Link a Google Cloud project if prompted.
3. In [Google Cloud Console](https://console.cloud.google.com/) create (or pick) a project, enable **Google Play Android Developer API**.
4. Create a service account (e.g. `hizone-play-upload`) with no GCP roles required.
5. Create a **JSON key** for that service account. Download it. This file is a secret — never commit it.
6. Back in Play Console, grant that service account access to **Hi-Zone Laundry** with at least **Release apps to testing tracks**.

#### 5. GitHub secret

1. Open the JSON key in a text editor and copy the **entire** file (including `{` and `}`).
2. Repo **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.
3. Name: `PLAYSTORE_SERVICE_ACCOUNT_JSON`
4. Value: the full JSON.
5. Also add it on the **Production** environment if that environment is set to restrict secrets.

Until this secret exists, production still deploys web and GitHub Releases; the Play upload step is skipped.

#### Privacy policy URL (Play Console)

A static privacy policy page ships with every web build at:

| Environment | URL |
|-------------|-----|
| Production | `https://hizonelaundry.hznsystems.com/privacy-policy.html` |
| Staging | `https://staging.hizonelaundry.hznsystems.com/privacy-policy.html` |

Source: [`web/privacy-policy.html`](web/privacy-policy.html) (copied into `build/web/` and deployed to PocketBase `pb_public/`). Use the **production** URL in Play Console → App content → Privacy policy.

Shorter alias: `/privacy-policy/` redirects to `/privacy-policy.html`.

The web build also ships `robots.txt` and `noindex` meta tags on the main app so search engines and bots are asked not to index the staff application. The privacy policy URL stays publicly fetchable for Play Console.

#### 6. After each production deploy

1. Wait for `deploy-production` to finish.
2. Testers already opted in get the new version (`X.Y.Z`, version code = GitHub run number) from Play Store without a new opt-in.
3. New testers still need the Internal testing opt-in URL (email lists cannot be updated via the Play API; add emails in Play Console).

---

## Release notes

Staging and production deploys compile **user-facing release notes** from merged PRs into `staging` using [`.github/scripts/compile_release_notes.py`](.github/scripts/compile_release_notes.py).

| When | PRs included | Used on |
|------|----------------|---------|
| Staging deploy | Merged to `staging` since the previous `staging-*` GitHub Release | Staging GitHub Release body |
| Production deploy | Merged to `staging` since the previous `v*` GitHub Release | Production GitHub Release, Play Internal testing “What’s new”, auto-promote staging→main PR body |

### Writing PR descriptions

Add a **`## Release notes`** section to each staging PR with plain-language bullets for staff and customers. Example:

```markdown
## Release notes
- Orders cannot move to Ready until every service has a machine and a pack count.
- The dashboard highlights orders that still need machines or packs.
- Mag-style full service pricing now supports a minimum charge per order.
```

If `## Release notes` is missing, CI falls back to **`## Summary`** (filtered to drop technical lines) and then the PR title.

Avoid putting QA steps, migrations, or CI details in Release notes — those stay under Test plan / QA Notes.

### Version codes

Play requires each upload to have a **higher `versionCode`** than the last. CI uses `--build-number=${{ github.run_number }}`, so codes increase with every workflow run. Do not upload a local AAB with a lower number than the last Play upload.
