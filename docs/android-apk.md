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

## APK size and release hardening

The release build is tuned for a small, fast APK without losing functionality:

- **R8 + resource shrinking** (`minifyEnabled` / `shrinkResources` in
  `android-capacitor/app/build.gradle`) strip dead Java code and unused
  resources. Capacitor's reflection-based plugin bridge is protected by
  `android-capacitor/app/proguard-rules.pro` (keeps for `com.getcapacitor.**`,
  `com.capacitorjs.**`, `@PluginMethod` / `@PermissionCallback`, and
  BroadcastReceivers). The reminder sound and status-bar icon are resolved at
  runtime via `Resources.getIdentifier`, so the shrinker cannot see them —
  both are pinned by `android-capacitor/app/src/main/res/values/keep.xml`.
- **Locale pruning**: `resConfigs "en", "ru", "ko"` matches the app's i18n
  languages; other library translations fall back to default.
- **WebP assets**: splash screens and launcher icons ship as WebP instead of
  PNG (supported natively since our `minSdk 24`), roughly −40 % on those
  assets with no visible quality loss.
- **Web bundle**: the Vite build is already code-split and Firebase, the
  TipTap editor and the settings screen load lazily, so the startup path
  stays small. Everything lands in the APK regardless — the lazy chunks
  primarily make cold start faster.

If the app is ever distributed through Google Play, switch the CI artifact to
an Android App Bundle (`./gradlew bundleRelease`) — Play then serves each
device a smaller, density/locale-specific split APK automatically. Direct APK
distribution (GitHub Releases) keeps using the universal APK above.

> When debugging a release crash, R8 keeps source file names and line numbers
> (`-keepattributes SourceFile,LineNumberTable`), and the deobfuscation
> mapping lives at
> `android-capacitor/app/build/outputs/mapping/release/mapping.txt`.
