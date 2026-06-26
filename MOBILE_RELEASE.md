# Mobile release CI/CD

Every push to `master` runs tests, builds a release APK, bumps the **build number** from `github.run_number`, and publishes a [GitHub Release](https://github.com/ehsan-soleimanian/mira-app/releases) with:

- `app-release.apk`
- `version.json` (used by the API and in-app update checker)

The Flutter app calls `GET https://api.miramind.io/app/version` on startup (release builds only) and shows an update dialog when a newer build is available.

## GitHub Actions workflow

File: `.github/workflows/mobile_release.yml`

| Job | Purpose |
|-----|---------|
| `test` | `flutter analyze` + `flutter test` |
| `release` | build APK + publish GitHub Release |

Versioning:

- **version name** — from `pubspec.yaml` (e.g. `1.1.0`)
- **build number** — `github.run_number` (monotonic per workflow run)

## Required GitHub secrets (Android signing)

For production-signed APKs, add these repository secrets:

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `.jks` / `.keystore` file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |

Without these secrets, CI still builds an APK signed with the **debug** keystore (fine for internal testing only).

Generate base64 keystore:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.keystore")) | Set-Clipboard
```

## Optional: public APK download URL

If the GitHub repo is **private**, release asset URLs are not usable for end users. Set:

| Secret | Example |
|--------|---------|
| `MOBILE_APK_DOWNLOAD_URL` | `https://miramind.io/downloads/mira-latest.apk` |

Then upload the APK from CI to that host (custom deploy step) or manually after each release.

## Backend: `/app/version`

The API proxies the latest GitHub Release (cached 5 minutes).

Production `.env` on the server:

```env
APP_RELEASE_GITHUB_REPO=ehsan-soleimanian/mira-app
APP_RELEASE_GITHUB_TOKEN=ghp_...   # required for private repos
APP_RELEASE_CACHE_SECONDS=300
```

`APP_RELEASE_GITHUB_TOKEN` needs `contents:read` on the app repo.

## In-app update behaviour

- Runs on app start in **release** mode only
- Compares installed `buildNumber` with API `buildNumber`
- **Optional** update: user can tap «بعداً» / «Later» (dismissed until next build)
- **Forced** update when installed build `< minBuildNumber` (set in `version.json`)

## Manual release

Actions → **Mobile Release** → **Run workflow**

## Local release build

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.miramind.io
```
