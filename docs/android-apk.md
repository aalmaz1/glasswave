# GlassWave Android APK (Capacitor)

The APK is the **React + Vite app**, packaged with Capacitor 8.

Flutter’s native project stays in `android/`. Capacitor lives in `android-capacitor/`.

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

Sync the web build without compiling Gradle:

```bash
npm run cap:sync
npx cap open android
```

## Optional GitHub Action

Copy `.github/workflows/android-apk.yml` from the snippet below if your token can write workflow files:

```yaml
name: Build Capacitor APK
on:
  workflow_dispatch:
jobs:
  apk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21
      - uses: android-actions/setup-android@v3
      - run: npm ci
      - run: npm run cap:sync
      - working-directory: android-capacitor
        run: ./gradlew assembleRelease --no-daemon
      - uses: actions/upload-artifact@v4
        with:
          name: GlassWave
          path: android-capacitor/app/build/outputs/apk/release/*.apk
```
