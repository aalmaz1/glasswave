import { isNativeApp } from "./capDetect";

export { isNativeApp };

/** Match the dark glass UI: light status/navigation icons, edge-to-edge insets. */
export async function initNativeShell() {
  if (!isNativeApp()) return;

  try {
    // Loaded on demand: on the web this module is never needed, so it must not
    // sit in the startup bundle. Inside the native shell the chunk is already
    // on the device, so this resolves without a network round trip.
    const { SystemBars, SystemBarsStyle } = await import("@capacitor/core");
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

  let removed = false;
  const handle = import("@capacitor/app").then(async ({ App }) => {
    // The listener is async now; make sure we do not subscribe after the
    // component that asked for it has already unmounted.
    if (removed) return null;
    return App.addListener("backButton", () => {
      if (onCloseOverlay()) return;
      App.minimizeApp().catch(() => {});
    });
  });

  return () => {
    removed = true;
    void handle.then((listener) => listener?.remove());
  };
}
