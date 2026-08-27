# GlassWave notification sound

One source file drives every platform: **`glasswave_notification.mp3`**.

| Target              | File                                                                | Notes                                                                                             |
| ------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Web / PWA           | `public/sounds/glasswave-notification.mp3`                          | Played in-app by `playReminderSound()`; the browser Notification API cannot carry a custom sound. |
| Android (Capacitor) | `android-capacitor/app/src/main/res/raw/glasswave_notification.mp3` | Set on the `glasswave-reminders-v3` notification channel **and** on each notification.            |
| iOS (Capacitor)     | `ios-capacitor/App/App/glasswave_notification.wav`                  | Already in the Xcode **App** target's _Copy Bundle Resources_, so it ships inside the app bundle. |

`src/notifications.ts` picks the right file at runtime via `Capacitor.getPlatform()`.

## Why iOS needs a WAV

`UNNotificationSound` only plays **Linear PCM, MA4 (IMA4), µ-law or a-law** audio
in a `.wav`, `.aiff` or `.caf` container, and the clip must be shorter than
30 seconds. An MP3 is silently ignored and iOS falls back to the default sound,
so the iOS asset is a 16-bit Linear PCM WAV decoded from the same MP3
(trimmed where the tail becomes inaudible, with a short fade-out).

Regenerate it after replacing the MP3:

```bash
npm run sound:ios
```

(`scripts/mp3-to-ios-sound.mjs` — pure Node, no ffmpeg required.)

## iOS project

The Capacitor iOS platform lives in `ios-capacitor/` — see
[ios-app.md](./ios-app.md). Nothing has to be done by hand for the sound: the
WAV is already registered in `App.xcodeproj` (file reference + Copy Bundle
Resources), and `npm run cap:sync:ios` keeps the project in sync.

## Replacing the sound later

1. Drop the new MP3 at `public/sounds/glasswave-notification.mp3` and copy it to
   `android-capacitor/app/src/main/res/raw/glasswave_notification.mp3`
   (res/raw names must be lowercase letters, digits and underscores only).
2. Run `npm run sound:ios` to refresh the iOS WAV.
3. **Bump `REMINDER_CHANNEL_ID`** in `src/notifications.ts` (e.g. `-v3`) and add
   the old id to `LEGACY_CHANNEL_IDS`. Android stores a channel's sound when the
   channel is created and ignores later changes, so existing installs keep the
   old sound unless the channel id changes.
