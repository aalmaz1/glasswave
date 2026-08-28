/**
 * Warm up a lazily-imported chunk once the browser is idle.
 *
 * Lazy chunks are great for the startup payload but they turn a previously
 * instant interaction into a spinner the first time it happens (opening the
 * editor, opening settings, switching UI language). Prefetching during idle
 * keeps the startup win while making the later interaction resolve from the
 * module cache — i.e. the user is not supposed to notice anything.
 *
 * `requestIdleCallback` is unavailable on older Safari, so fall back to a
 * plain timeout. Failures are swallowed: a missed prefetch only means the
 * chunk loads on demand instead, exactly like before.
 */
export function prefetchOnIdle(load: () => Promise<unknown>): void {
  if (typeof window === "undefined") return;

  const run = () => {
    void load().catch(() => {});
  };

  type IdleWindow = Window & {
    requestIdleCallback?: (cb: () => void, opts?: { timeout: number }) => number;
  };
  const w = window as IdleWindow;

  if (typeof w.requestIdleCallback === "function") {
    w.requestIdleCallback(run, { timeout: 3000 });
  } else {
    window.setTimeout(run, 2000);
  }
}
