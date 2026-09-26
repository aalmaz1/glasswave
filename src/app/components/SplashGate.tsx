import { useLayoutEffect } from "react";
import { holdSplash, releaseInitialSplash } from "../../splash";

/**
 * Keeps the full-screen wave splash (see index.html) on screen while mounted.
 * Renders nothing itself. Use `delay` for loads that are usually instant
 * (prefetched lazy chunks), so the waves only appear when it is actually slow.
 */
export function SplashGate({ delay = 0 }: { delay?: number }) {
  // Layout effect: take the hold in the same commit that mounts the gate, so
  // the splash can never fade out for a frame in between.
  useLayoutEffect(() => holdSplash(delay), [delay]);
  return null;
}

/**
 * Rendered next to the app root: once the first React commit is in, the boot
 * splash may go — unless some SplashGate is still holding it. Sits outside the
 * error boundary so a crashed app still reveals its error screen.
 */
export function SplashRelease() {
  useLayoutEffect(() => {
    releaseInitialSplash();
  }, []);
  return null;
}
