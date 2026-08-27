# Linux desktop app (AppImage)

The desktop app is the **same React build** as the website and the APK —
[Tauri 2](https://v2.tauri.app/) wraps `dist/` in the system webview
(WebKitGTK on Linux), exactly like Capacitor wraps it on Android.

## Layout

```
src-tauri/              Tauri shell (Rust, ~20 lines of glue)
  tauri.conf.json       window, bundle targets (appimage + deb), version
  capabilities/         window permissions (core:default only)
  icons/                generated from public/icons/icon-512.png
.github/workflows/appimage_build.yml
```

The service worker is intentionally **not** registered inside the shell
(`src/pwa.ts` skips it when `__TAURI_INTERNALS__` is present) — the assets
already ship inside the package, a second cache layer would only get stale.

## Build locally

Node 22+, Rust stable, and the Tauri system dependencies:

```bash
sudo apt-get install -y \
  libwebkit2gtk-4.1-dev libayatana-appindicator3-dev \
  librsvg2-dev libxdo-dev patchelf
npm install
npm run desktop:build     # or: npm run desktop:dev for hot reload
```

Output:

```
src-tauri/target/release/bundle/appimage/GlassWave_<version>_amd64.AppImage
src-tauri/target/release/bundle/deb/glasswave_<version>_amd64.deb
```

Regenerate icons after changing the source icon:

```bash
npx tauri icon public/icons/icon-512.png -o src-tauri/icons
```

## CI (`.github/workflows/appimage_build.yml`)

- **On every GitHub Release** (the APK workflow publishes one per push to
  `main`): builds the AppImage + .deb with the release's version and attaches
  them to that same release — one release, APK and AppImage with matching
  versions.
- **Manual dispatch**: optional `version` input, defaults to the latest
  release tag; packages land in the workflow artifacts.
- Runs on `ubuntu-22.04` on purpose — building on the oldest supported base
  keeps the AppImage's glibc requirement low (Debian 12 / Ubuntu 22.04 are
  Tauri's recommended baselines). Building on a newer distro can produce an
  AppImage that fails on older systems with `GLIBC_2.xx not found`.

## Runtime requirements

The AppImage does **not** bundle a browser: it uses the system's
`libwebkit2gtk-4.1` (standard on Ubuntu 22.04+, Debian 12+, Fedora, Mint…).
The reminder sound plays through the system's GStreamer; most desktops have
the needed plugins out of the box. If you need to support bare systems,
`bundle > linux > appimage > bundleMediaFramework` in `tauri.conf.json`
bundles the media framework at the cost of a much larger file.
