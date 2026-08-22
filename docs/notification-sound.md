# GlassWave notification sound

One source file drives every platform: **`glasswave_notification.mp3`**.

| Target              | File                                                                | Notes                                                                                             |
| ------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Web / PWA           | `public/sounds/glasswave-notification.mp3`                          | Played in-app by `playReminderSound()`; the browser Notification API cannot carry a custom sound. |
| Android (Capacitor) | `android-capacitor/app/src/main/res/raw/glasswave_notification.mp3` | Set on the `glasswave-reminders-v2` notification channel **and** on each notification.            |
| iOS (Capacitor)     | `resources/ios/glasswave_notification.wav`                          | Must be copied into the Xcode app bundle — see below.                                             |

## Why iOS needs a WAV

`UNNotificationSound` only plays **Linear PCM, MA4 (IMA4), µ-law or a-law** audio
in a `.wav`, `.aiff` or `.caf` container, and the clip must be shorter than
30 seconds. An MP3 is silently ignored and iOS falls back to the default sound,
so the iOS asset is a 16-bit Linear PCM WAV decoded from the same MP3
(trimmed at the point where the tail becomes inaudible, with a short fade-out).

Regenerate it after replacing the MP3:

```bash
npm run sound:ios
```

(`scripts/mp3-to-ios-sound.mjs` — pure Node, no ffmpeg required.)

## Adding the sound to the iOS app

The Capacitor iOS platform is not checked in yet. After `npx cap add ios`:

1. Copy the asset into the app target folder:
   ```bash
   cp resources/ios/glasswave_notification.wav ios/App/App/
   ```
2. In Xcode, drag the file into the **App** target (_Copy items if needed_,
   target membership **App**) so it lands in _Build Phases → Copy Bundle Resources_.
3. Nothing else is needed in code: `src/notifications.ts` already passes
   `sound: "glasswave_notification.wav"` when `Capacitor.getPlatform() === "ios"`.

## Replacing the sound later

1. Drop the new MP3 at `public/sounds/glasswave-notification.mp3` and copy it to
   `android-capacitor/app/src/main/res/raw/glasswave_notification.mp3`
   (res/raw names must be lowercase letters, digits and underscores only).
2. Run `npm run sound:ios` to refresh the iOS WAV.
3. **Bump `REMINDER_CHANNEL_ID`** in `src/notifications.ts` (e.g. `-v3`) and add
   the old id to `LEGACY_CHANNEL_IDS`. Android stores a channel's sound when the
   channel is created and ignores later changes, so existing installs keep the
   old sound unless the channel id changes.
