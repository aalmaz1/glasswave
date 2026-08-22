import { Capacitor } from "@capacitor/core";

/**
 * Service worker registration for the PWA.
 *
 * Only meaningful on the web: inside the Capacitor native shell the same assets
 * are already on the device, and a service worker would only add a second,
 * competing cache layer — so registration is skipped there.
 *
 * `registerType: "autoUpdate"` (see vite.config.ts) means a new build takes over
 * as soon as it is downloaded; we just reload once the new worker is in control
 * so the user is never left on a half-updated app.
 */
export function registerServiceWorker(): void {
  if (!import.meta.env.PROD) return;

  try {
    if (Capacitor.isNativePlatform()) return;
  } catch {
    /* not running under Capacitor — continue */
  }

  if (!("serviceWorker" in navigator)) return;

  void import("virtual:pwa-register")
    .then(({ registerSW }) => {
      registerSW({
        immediate: true,
        onRegisteredSW(url) {
          console.info("[PWA] Service worker ready:", url);
        },
        onRegisterError(error) {
          console.warn("[PWA] Service worker registration failed.", error);
        },
      });
    })
    .catch((error) => {
      console.warn("[PWA] Could not load the service worker registration.", error);
    });
}
