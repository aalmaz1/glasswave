/**
 * Platform detection WITHOUT importing `@capacitor/core`.
 *
 * This mirrors the upstream implementation in
 * `node_modules/@capacitor/core/dist/index.js` statement for statement:
 *
 *   getPlatformId(win) = win.androidBridge              -> "android"
 *                      : win.webkit.messageHandlers.bridge -> "ios"
 *                      : "web"
 *   isNativePlatform() = getPlatform() !== "web"
 *
 * The important detail is that upstream reads the native bridges, NOT the
 * `window.Capacitor` facade. Reading the same bridges here means web and
 * native visitors get exactly the same answer as before — the SDK is simply
 * no longer on the startup path. On the web the bridges are absent, so we
 * never pay for the ~3.4 kB gzip of Capacitor that used to ship eagerly to
 * every visitor just to answer "are we native?" (usually: no).
 *
 * The actual Capacitor plugins are imported dynamically at their call sites,
 * inside the `isNativeApp()` guard, so nothing changes observably.
 */

type NativeBridges = {
  androidBridge?: unknown;
  webkit?: { messageHandlers?: { bridge?: unknown } };
  CapacitorCustomPlatform?: { name: string } | null;
};

function getPlatformId(win: Window): string {
  const w = win as unknown as NativeBridges;
  if (w?.androidBridge) return "android";
  else if (w?.webkit?.messageHandlers?.bridge) return "ios";
  else return "web";
}

/** "android" | "ios" | "web" (or a custom platform name), safe on plain web. */
export function getPlatform(): string {
  try {
    const custom = (window as unknown as NativeBridges)?.CapacitorCustomPlatform ?? null;
    return custom !== null ? custom.name : getPlatformId(window);
  } catch {
    return "web";
  }
}

/** True only inside the Capacitor native shell (APK / iOS app). */
export function isNativeApp(): boolean {
  try {
    return getPlatform() !== "web";
  } catch {
    return false;
  }
}
