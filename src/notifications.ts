import { Capacitor } from "@capacitor/core";
import { LocalNotifications } from "@capacitor/local-notifications";

/**
 * Notification helper that works in both environments:
 *  - Capacitor native shell (APK): real Android notifications via
 *    @capacitor/local-notifications. This also triggers the Android 13+
 *    POST_NOTIFICATIONS runtime permission dialog.
 *  - Plain browser: falls back to the Web Notification API.
 *
 * The Web Notification API does NOT work inside an Android WebView, which is
 * why the previous `Notification.requestPermission()` call was a silent no-op.
 */

export const isNativeApp = (): boolean => {
  try {
    return Capacitor.isNativePlatform();
  } catch {
    return false;
  }
};

/** Current Capacitor platform ("android" | "ios" | "web"), safe on plain web. */
function getPlatform(): string {
  try {
    return Capacitor.getPlatform();
  } catch {
    return "web";
  }
}

/**
 * Android notification channel for reminders. On Android 8+ the channel (not
 * the individual notification) owns the sound, so we create a dedicated channel
 * configured with the GlassWave notification sound and route every reminder through it.
 */
// NOTE: Android caches a channel's sound at creation time and ignores later
// changes, so the id is versioned — bump it whenever the sound file changes.
const REMINDER_CHANNEL_ID = "glasswave-reminders-v3";
/** Previous channel ids, deleted on startup so stale sounds cannot linger. */
const LEGACY_CHANNEL_IDS = ["glasswave-reminders", "glasswave-reminders-v2"];
/**
 * Native sound asset, per platform:
 *  - Android: `android-capacitor/app/src/main/res/raw/glasswave_notification.mp3`
 *  - iOS: `glasswave_notification.wav` in the app bundle (see
 *    `resources/ios/`). iOS only plays Linear PCM / MA4 / µ-law / a-law in a
 *    `.wav`, `.aiff` or `.caf` container — an MP3 is ignored and the system
 *    default sound is used instead, hence the decoded WAV copy.
 */
const REMINDER_SOUND =
  getPlatform() === "ios" ? "glasswave_notification.wav" : "glasswave_notification.mp3";
/** Web copy of the same sound, bundled under `public/sounds/`. */
const WEB_SOUND_URL = "/sounds/glasswave-notification.mp3";

/** Stable 31-bit notification id derived from an arbitrary string key. */
function notifIdForKey(key: string): number {
  let h = 5381;
  for (let i = 0; i < key.length; i++) {
    h = ((h << 5) + h + key.charCodeAt(i)) | 0;
  }
  return Math.abs(h) % 0x7fffffff || 1;
}

/**
 * Create (or reuse) the reminder notification channel with the GlassWave notification sound.
 * Idempotent and safe to call on every startup and before every schedule; on
 * web this is a no-op. `name` is shown to the user in Android's channel
 * settings, so callers pass the localized "Reminder" label.
 */
export async function ensureReminderChannel(name = "Reminders"): Promise<void> {
  if (!isNativeApp()) return;
  try {
    for (const legacyId of LEGACY_CHANNEL_IDS) {
      await LocalNotifications.deleteChannel({ id: legacyId }).catch(() => {});
    }
    await LocalNotifications.createChannel({
      id: REMINDER_CHANNEL_ID,
      name,
      description: "GlassWave",
      sound: REMINDER_SOUND,
      importance: 4, // HIGH — heads-up so the sound is audible
      visibility: 1, // public
      vibration: true,
    });
  } catch (error) {
    console.warn("[Notifications] Could not create reminder channel.", error);
  }
}

/**
 * Best-effort in-app playback of the notification sound for web reminders. The browser
 * Notification API cannot play a custom sound, so when the app is open we play
 * it ourselves alongside the (optional) browser notification.
 */
export function playReminderSound(): void {
  try {
    const audio = new Audio(WEB_SOUND_URL);
    audio.volume = 0.9;
    void audio.play().catch(() => {});
  } catch {
    /* autoplay blocked or audio unsupported — nothing else to do */
  }
}

/**
 * Ask the user for notification permission. Returns true if permission is
 * (or becomes) granted. Safe to call on every reminder save — on native it
 * resolves instantly when already granted/denied, on web the same.
 */
export async function ensureNotificationPermission(): Promise<boolean> {
  if (isNativeApp()) {
    try {
      const current = await LocalNotifications.checkPermissions();
      if (current.display === "granted") return true;
      const res = await LocalNotifications.requestPermissions();
      return res.display === "granted";
    } catch {
      return false;
    }
  }
  if (!("Notification" in window)) return false;
  if (Notification.permission === "granted") return true;
  if (Notification.permission === "denied") return false;
  const perm = await Notification.requestPermission().catch(
    () => "denied" as NotificationPermission
  );
  return perm === "granted";
}

/**
 * Schedule a native notification for a reminder at the given time.
 * On web this is a no-op (web reminders are handled by the in-app poller).
 * Re-scheduling the same key replaces the previous notification.
 */
export async function scheduleReminderNotification(
  key: string,
  title: string,
  body: string,
  at: Date
): Promise<void> {
  if (!isNativeApp()) return;
  const id = notifIdForKey(key);
  try {
    // Make sure the channel (and its custom sound) exists first: on
    // Android 8+ a notification posted to a missing channel never fires.
    await ensureReminderChannel();
    await LocalNotifications.cancel({ notifications: [{ id }] });
    if (at.getTime() <= Date.now()) return;
    await LocalNotifications.schedule({
      notifications: [
        {
          id,
          title: title || "GlassWave",
          body,
          schedule: { at, allowWhileIdle: true },
          channelId: REMINDER_CHANNEL_ID,
          sound: REMINDER_SOUND,
          smallIcon: "ic_launcher",
        },
      ],
    });
  } catch (e) {
    console.warn("[Notifications] schedule failed", e);
  }
}

/** Cancel a previously scheduled reminder notification (native no-op on web). */
export async function cancelReminderNotification(key: string): Promise<void> {
  if (!isNativeApp()) return;
  try {
    await LocalNotifications.cancel({ notifications: [{ id: notifIdForKey(key) }] });
  } catch (e) {
    console.warn("[Notifications] cancel failed", e);
  }
}
