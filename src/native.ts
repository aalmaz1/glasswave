import { App as CapApp } from "@capacitor/app";
import { Capacitor, SystemBars, SystemBarsStyle } from "@capacitor/core";

export function isNativeApp() {
  return Capacitor.isNativePlatform();
}

/** Match the dark glass UI: light status/navigation icons, edge-to-edge insets. */
export async function initNativeShell() {
  if (!isNativeApp()) return;

  try {
    await SystemBars.setStyle({ style: SystemBarsStyle.Light });
  } catch (error) {
    console.warn("Could not configure system bars.", error);
  }
}

/**
 * Android hardware/gesture back: close overlays first, then leave the activity.
 * `onCloseOverlay` should return true when it handled the event.
 */
export function listenNativeBackButton(onCloseOverlay: () => boolean) {
  if (!isNativeApp()) return () => {};

  const handle = CapApp.addListener("backButton", () => {
    if (onCloseOverlay()) return;
    CapApp.minimizeApp().catch(() => {});
  });

  return () => {
    void handle.then((listener) => listener.remove());
  };
}
