# GlassWave Android APK (Capacitor)

The APK is the **React + Vite app**, packaged with Capacitor 8.

Flutter’s native project stays in `glasswave_flutter_ver/android/`. Capacitor lives in `android-capacitor/`.

## Automatic GitHub Releases

`.github/workflows/apk_build.yml` builds and publishes a new APK automatically after every push to `main` (normally after a pull request is merged).

Each workflow run:

1. Builds the web application and syncs it with Capacitor.
2. Builds an installable release APK.
3. Assigns an increasing version based on the GitHub Actions run number, for example `1.0.12`.
4. Creates the tag and GitHub Release `v1.0.12`.
5. Attaches `GlassWave-1.0.12.apk` to the Release.

The workflow can also be started from **GitHub → Actions → Build and release Android APK → Run workflow**. A manually started run creates a Release in the same way.

GitHub Actions receives only the built-in `GITHUB_TOKEN`; no personal token or extra repository secret is required. The workflow declares `contents: write` so it can create tags and Releases.

> Changes pushed only to a feature branch do not publish a production Release. Merge them into `main` first.

## Build locally

Requirements: Node.js 22+, JDK 21, Android SDK (compileSdk 36).

```bash
npm install
npm run android:apk
```

Installable file:

```
android-capacitor/app/build/outputs/apk/release/app-release.apk
```

Local builds use version `1.0.0` and version code `1`. You can override them when needed:

```bash
VERSION_NAME=1.2.0 VERSION_CODE=120 npm run android:apk
```

Sync the web build without compiling Gradle:

```bash
npm run cap:sync
npx cap open android
```
