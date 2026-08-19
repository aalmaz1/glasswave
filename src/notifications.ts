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

/** Stable 31-bit notification id derived from an arbitrary string key. */
function notifIdForKey(key: string): number {
  let h = 5381;
  for (let i = 0; i < key.length; i++) {
    h = ((h << 5) + h + key.charCodeAt(i)) | 0;
  }
  return (Math.abs(h) % 0x7fffffff) || 1;
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
  const perm = await Notification.requestPermission().catch(() => "denied" as NotificationPermission);
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
    await LocalNotifications.cancel({ notifications: [{ id }] });
    if (at.getTime() <= Date.now()) return;
    await LocalNotifications.schedule({
      notifications: [
        {
          id,
          title: title || "GlassWave",
          body,
          schedule: { at, allowWhileIdle: true },
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
