# Mobile release CI/CD

Every push to `master` runs tests, builds a release APK, uploads it to **production**, and publishes a GitHub Release backup.

## Production URLs (source of truth)

| File | URL |
|------|-----|
| APK | https://miramind.io/downloads/mira-latest.apk |
| Manifest | https://miramind.io/downloads/version.json |

The Flutter app checks `GET https://api.miramind.io/app/version` (API reads `version.json` from miramind.io) and downloads from `miramind.io` when the user taps update.

## CI pipeline

File: `.github/workflows/mobile_release.yml`

1. `flutter analyze` + `flutter test`
2. `flutter build apk --release` with `build-number = github.run_number`
3. **SCP** `mira-latest.apk` + `version.json` → `/var/www/miramind/downloads/` on showroom-germany
4. Verify public manifest via `curl`
5. GitHub Release (backup artifacts)

Deploy script: `scripts/deploy-mobile-apk.sh`

## Required GitHub secrets (`mira-app` repo)

Already configured:

| Secret | Purpose |
|--------|---------|
| `DEPLOY_HOST` | Production server IP |
| `DEPLOY_USER` | SSH user (e.g. `root`) |
| `DEPLOY_PORT` | SSH port (optional, default 22) |
| `DEPLOY_SSH_KEY` | Private key for SCP upload |

Optional Android signing:

| Secret | Purpose |
|--------|---------|
| `ANDROID_KEYSTORE_BASE64` | Release keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |

Without keystore secrets, CI signs with the debug key (internal testing only). **All production APKs must use the same release keystore** or Android will refuse in-place updates (signature mismatch).

Release keystore SHA-1 (must be in Google Cloud → Credentials → Android OAuth client for `com.mira.mira_app`):

```
DA:63:1B:D7:84:1E:A9:81:65:D0:06:34:37:09:3E:FF:97:34:37:C5
```

CI prints this in the **Print release signing SHA-1** step on each build. After changing the keystore, add the new fingerprint in Console and wait ~5 minutes.

| Secret | Value |
|--------|-------|
| `ANDROID_KEY_ALIAS` | `mira` |

### Google Sign-In

| Secret | Purpose |
|--------|---------|
| `GOOGLE_WEB_CLIENT_ID` | Compile-time `serverClientId` (required) |
| `GOOGLE_ANDROID_CLIENT_ID` | Android OAuth client reference |
| `GOOGLE_IOS_CLIENT_ID` | iOS builds |

CI passes these as `--dart-define` on release builds. Copy values from local `dart_defines.json` into GitHub secrets.

Google Cloud Console: Android OAuth client needs package `com.mira.mira_app` + SHA-1 of the APK signing key. If Sign-In fails with `ApiException: 10`, add the CI keystore SHA-1 in Credentials.

## Backend

`GET /app/version` loads `https://miramind.io/downloads/version.json` first (60s cache), then falls back to GitHub Releases if CDN is unavailable.

No extra production `.env` is required when using the default CDN URL.

## Manual upload

```bash
export DEPLOY_HOST=...
export DEPLOY_USER=root
export DEPLOY_SSH_KEY_FILE=~/.ssh/id_rsa
flutter build apk --release --dart-define=API_BASE_URL=https://api.miramind.io
# create version.json with downloadUrl https://miramind.io/downloads/mira-latest.apk
bash scripts/deploy-mobile-apk.sh build/app/outputs/flutter-apk/app-release.apk version.json
```

## Nginx

Served by `scripts/nginx/miramind.io.conf` → `/var/www/miramind/downloads/`.

Refreshed automatically on backend deploy via `install-nginx-miramind.sh`.
