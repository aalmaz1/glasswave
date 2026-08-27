# GlassWave iOS app (Capacitor)

The iOS app is the **React + Vite app** packaged with Capacitor 8, exactly like
the Android APK.

- Capacitor's Xcode project: **`ios-capacitor/`** (configured via `ios.path` in
  `capacitor.config.ts`). Flutter's own native project stays in `glasswave_flutter_ver/ios/`.
- Capacitor 8 uses **Swift Package Manager**, so there is no CocoaPods /
  `pod install` step.

```bash
npm run cap:sync:ios                      # build the web app + copy it into ios-capacitor
open ios-capacitor/App/App.xcworkspace    # macOS + Xcode, to run / archive
```

Bundle id `com.glasswave.app`, display name `GlassWave`, deployment target
iOS 15.

## Branding

The icon and launch screen come from the app artwork `assets/icon.png` — the
same image the Android launcher icons use — not from the Capacitor placeholder
logo. They are committed, so nothing has to be regenerated for a normal build.

After changing `assets/icon.png`:

```bash
npm i -D sharp && node scripts/generate-ios-assets.mjs
```

That writes:

| Asset         | File                                                                            |
| ------------- | ------------------------------------------------------------------------------- |
| App icon      | `.../Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png` (1024×1024, opaque) |
| Launch screen | `.../Assets.xcassets/Splash.imageset/splash-2732x2732*.png` (icon on dark navy) |

`sharp` is intentionally **not** a permanent dependency: these assets change
about never, and it would slow every CI install down.

## Notification sound

See [notification-sound.md](./notification-sound.md). Short version: iOS cannot
play the MP3, so `glasswave_notification.wav` is bundled with the app target and
`src/notifications.ts` selects it when `Capacitor.getPlatform() === "ios"`.

## Not covered yet

There is no CI workflow for iOS (unlike `.github/workflows/apk_build.yml` for
Android) — building and signing an `.ipa` needs a macOS runner plus an Apple
Developer account, certificates and a provisioning profile.
