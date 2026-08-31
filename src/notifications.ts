import { getPlatform, isNativeApp } from "./capDetect";

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

export { isNativeApp };

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
function reminderSound(): string {
  return getPlatform() === "ios" ? "glasswave_notification.wav" : "glasswave_notification.mp3";
}
/** Web copy of the same sound, bundled under `public/sounds/`. */
const WEB_SOUND_URL = "/sounds/glasswave-notification.mp3";

/** Status-bar icon: white-on-transparent vector in `res/drawable`. */
const REMINDER_SMALL_ICON = "ic_stat_notify";

type LocalNotificationsPlugin = typeof import("@capacitor/local-notifications").LocalNotifications;

/**
 * Watchdog for every call that crosses the Capacitor bridge.
 *
 * A native bridge call is just a promise the WebView resolves when the Java /
 * Swift side calls back. If the plugin is missing, the activity is being
 * recreated, or the OEM blocks the permission dialog, that callback never
 * arrives and the promise hangs *forever* — no rejection, no timeout. Anything
 * awaiting it (previously: the reminder "Save" button) then freezes silently.
 * A bounded wait turns that into a normal, recoverable failure.
 */
const BRIDGE_TIMEOUT_MS = 8000;

function withTimeout<T>(promise: Promise<T>, fallback: T, label: string, ms = BRIDGE_TIMEOUT_MS) {
  return new Promise<T>((resolve) => {
    let settled = false;
    const timer = setTimeout(() => {
      if (settled) return;
      settled = true;
      console.warn(`[Notifications] ${label} timed out after ${ms}ms — continuing without it.`);
      resolve(fallback);
    }, ms);
    Promise.resolve(promise).then(
      (value) => {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        resolve(value);
      },
      (error) => {
        if (settled) return;
        settled = true;
        clearTimeout(timer);
        console.warn(`[Notifications] ${label} failed`, error);
        resolve(fallback);
      }
    );
  });
}

let pluginPromise: Promise<LocalNotificationsPlugin | null> | null = null;

async function loadLocalNotifications(): Promise<LocalNotificationsPlugin | null> {
  if (!isNativeApp()) return null;
  // The dynamic import can also hang (a chunk request served by a stale
  // service worker that never answers), so it gets the same watchdog.
  // Memoized: the chunk is fetched at most once per session.
  if (!pluginPromise) {
    pluginPromise = withTimeout(
      import("@capacitor/local-notifications").then((mod) => mod.LocalNotifications),
      null,
      "LocalNotifications import"
    ).then((plugin) => {
      if (!plugin) pluginPromise = null; // allow a later retry
      return plugin;
    });
  }
  return pluginPromise;
}

/** Stable 31-bit notification id derived from an arbitrary string key. */
function notifIdForKey(key: string): number {
  let h = 5381;
  for (let i = 0; i < key.length; i++) {
    h = ((h << 5) + h + key.charCodeAt(i)) | 0;
  }
  return Math.abs(h) % 0x7fffffff || 1;
}

function isUsableDate(at: Date): boolean {
  return at instanceof Date && !Number.isNaN(at.getTime());
}

/**
 * Create (or reuse) the reminder notification channel with the GlassWave notification sound.
 * Idempotent and safe to call on every startup and before every schedule; on
 * web this is a no-op. `name` is shown to the user in Android's channel
 * settings, so callers pass the localized "Reminder" label.
 */
export async function ensureReminderChannel(name = "Reminders"): Promise<void> {
  const LocalNotifications = await loadLocalNotifications();
  if (!LocalNotifications) return;
  for (const legacyId of LEGACY_CHANNEL_IDS) {
    await withTimeout(LocalNotifications.deleteChannel({ id: legacyId }), undefined, "deleteChannel");
  }
  await withTimeout(
    LocalNotifications.createChannel({
      id: REMINDER_CHANNEL_ID,
      name,
      description: "GlassWave",
      sound: reminderSound(),
      importance: 4, // HIGH — heads-up so the sound is audible
      visibility: 1, // public
      vibration: true,
    }),
    undefined,
    "createChannel"
  );
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

/** True if notification permission is already granted. Never prompts. */
export async function hasNotificationPermission(): Promise<boolean> {
  const LocalNotifications = await loadLocalNotifications();
  if (LocalNotifications) {
    const current = await withTimeout(
      LocalNotifications.checkPermissions(),
      null,
      "checkPermissions"
    );
    return current?.display === "granted";
  }
  if (typeof window === "undefined" || !("Notification" in window)) return false;
  return Notification.permission === "granted";
}

/**
 * Ask the user for notification permission. Returns true if permission is
 * (or becomes) granted.
 *
 * Never rejects and never hangs: every bridge call is bounded (see
 * `withTimeout`), so a wedged plugin degrades to "not granted" instead of
 * freezing the caller. It must NOT be awaited before the reminder itself is
 * persisted — saving a reminder has to work even when notifications don't.
 *
 * Callers MUST await this before `scheduleReminderNotification`. Firing it
 * in parallel with `schedule()` races two permission flows: Capacitor 8.3+
 * then opens the system "Alarms & reminders" settings screen (the app
 * appears to close) and the POST_NOTIFICATIONS dialog never appears.
 */
export async function ensureNotificationPermission(): Promise<boolean> {
  const LocalNotifications = await loadLocalNotifications();
  if (LocalNotifications) {
    const current = await withTimeout(
      LocalNotifications.checkPermissions(),
      null,
      "checkPermissions"
    );
    if (current?.display === "granted") return true;
    // The system dialog is user-driven, so it gets a longer leash than a
    // plain bridge round-trip — but still a finite one.
    const res = await withTimeout(
      LocalNotifications.requestPermissions(),
      null,
      "requestPermissions",
      60_000
    );
    return res?.display === "granted";
  }
  if (typeof window === "undefined" || !("Notification" in window)) return false;
  if (Notification.permission === "granted") return true;
  if (Notification.permission === "denied") return false;
  const perm = await Notification.requestPermission().catch(
    () => "denied" as NotificationPermission
  );
  return perm === "granted";
}

/**
 * Use exact AlarmManager only when the OS already allows it. Capacitor 8.3
 * defaults `isExactNotification` to true, and on Android 12+ that makes
 * `schedule()` launch `ACTION_REQUEST_SCHEDULE_EXACT_ALARM` — the user
 * leaves the app (or the Intent crashes on OEMs without that settings
 * activity). Inexact + `allowWhileIdle` still fires in Doze, just not to
 * the second, which is fine for a note reminder.
 */
async function canUseExactAlarms(LocalNotifications: LocalNotificationsPlugin): Promise<boolean> {
  const status = await withTimeout(
    LocalNotifications.checkExactNotificationSetting(),
    null,
    "checkExactNotificationSetting"
  );
  return status?.exact_alarm === "granted";
}

/**
 * Schedule a native notification for a reminder at the given time.
 * On web this is a no-op (web reminders are handled by the in-app poller).
 * Re-scheduling the same key replaces the previous notification.
 *
 * Does not prompt for permission — callers that have a user gesture should
 * `await ensureNotificationPermission()` first. Without permission this
 * returns without calling `schedule()`, so Capacitor 8.3 cannot auto-prompt
 * (and open the exact-alarm settings screen) on a silent startup resync.
 */
export async function scheduleReminderNotification(
  key: string,
  title: string,
  body: string,
  at: Date
): Promise<void> {
  if (!isNativeApp()) return;
  if (!isUsableDate(at) || at.getTime() <= Date.now()) return;
  if (!(await hasNotificationPermission())) return;

  const id = notifIdForKey(key);
  const LocalNotifications = await loadLocalNotifications();
  if (!LocalNotifications) return;
  // Make sure the channel (and its custom sound) exists first: on
  // Android 8+ a notification posted to a missing channel never fires.
  await ensureReminderChannel();
  await withTimeout(LocalNotifications.cancel({ notifications: [{ id }] }), undefined, "cancel");
  const exact = await canUseExactAlarms(LocalNotifications);
  await withTimeout(
    LocalNotifications.schedule({
      notifications: [
        {
          id,
          title: title || "GlassWave",
          body,
          schedule: { at, allowWhileIdle: true },
          channelId: REMINDER_CHANNEL_ID,
          sound: reminderSound(),
          smallIcon: REMINDER_SMALL_ICON,
          isExactNotification: exact,
        },
      ],
    }),
    undefined,
    "schedule"
  );
}

/** Cancel a previously scheduled reminder notification (native no-op on web). */
export async function cancelReminderNotification(key: string): Promise<void> {
  const LocalNotifications = await loadLocalNotifications();
  if (!LocalNotifications) return;
  await withTimeout(
    LocalNotifications.cancel({ notifications: [{ id: notifIdForKey(key) }] }),
    undefined,
    "cancel"
  );
}

export type NativeReminder = {
  key: string;
  title: string;
  body: string;
  at: Date;
};

/**
 * Re-arm every future reminder with the OS scheduler. Safe on web (no-op)
 * and on a cold start without notification permission (does not prompt).
 * Used after login / notes load so reminders survive an app update that
 * never got to schedule them.
 */
export async function syncNativeReminders(reminders: NativeReminder[]): Promise<void> {
  if (!isNativeApp()) return;
  const future = reminders.filter((r) => isUsableDate(r.at) && r.at.getTime() > Date.now());
  if (future.length === 0) return;
  if (!(await hasNotificationPermission())) return;
  await Promise.all(future.map((r) => scheduleReminderNotification(r.key, r.title, r.body, r.at)));
}
