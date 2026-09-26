/**
 * Full-screen wave splash.
 *
 * The markup and critical CSS live in index.html, so the waves are on screen
 * from the very first paint — before any JavaScript has been downloaded. This
 * module only decides when the splash goes away (and when it may come back):
 *
 * - the initial splash stays up until `releaseInitialSplash()` is called;
 * - while any `holdSplash()` is active the splash stays (or comes back) up.
 *
 * Every function is a no-op when the element is missing (unit tests, or an
 * index.html without the splash), so callers never need to guard.
 */

const SPLASH_ID = "gw-splash";
const OUT_CLASS = "gw-out";
/** localStorage key read by the inline script in index.html — keep in sync. */
export const SPLASH_THEME_KEY = "glasswave_splash_v1";
/** Slightly longer than the opacity / tide transitions in index.html. */
const FADE_MS = 600;
/** Last-resort cap when the fade is tracked through the Web Animations API. */
const FADE_SAFETY_MS = 4000;

let initialReleased = false;
let holds = 0;
let hideTimer: ReturnType<typeof setTimeout> | undefined;
let fadeToken = 0;

function splashEl(): HTMLElement | null {
  return typeof document === "undefined" ? null : document.getElementById(SPLASH_ID);
}

function isOnScreen(el: HTMLElement): boolean {
  return !el.hidden && !el.classList.contains(OUT_CLASS);
}

function wanted(): boolean {
  return !initialReleased || holds > 0;
}

function clearHideTimer(): void {
  if (hideTimer === undefined) return;
  clearTimeout(hideTimer);
  hideTimer = undefined;
}

function fadeOut(el: HTMLElement): void {
  el.classList.add(OUT_CLASS);
  const token = ++fadeToken;
  const finish = () => {
    if (token !== fadeToken || wanted()) return;
    clearHideTimer();
    // display:none stops the animations, so a hidden splash costs nothing.
    el.hidden = true;
  };

  // The app's first render is heavy and can keep the main thread busy for a
  // while. A plain timer would then hide the splash before a single frame of
  // the fade was shown. A CSS transition only starts once its first frame is
  // actually rendered, so wait for it to finish instead — the fade then always
  // plays in full over the ready app. The timer covers engines without the
  // Web Animations API (and jsdom).
  const fade =
    typeof el.getAnimations === "function"
      ? el.getAnimations().find((a) => (a as CSSTransition).transitionProperty === "opacity")
      : undefined;
  if (fade) fade.finished.then(finish, finish);
  clearHideTimer();
  hideTimer = setTimeout(finish, fade ? FADE_SAFETY_MS : FADE_MS);
}

function sync(): void {
  const el = splashEl();
  if (!el) return;

  if (wanted()) {
    clearHideTimer();
    fadeToken += 1; // a fade still in flight must not hide us any more
    if (el.hidden) {
      el.hidden = false;
      // Flush styles while still transparent so removing the class fades in.
      void getComputedStyle(el).opacity;
    }
    el.classList.remove(OUT_CLASS);
    return;
  }

  if (!el.classList.contains(OUT_CLASS)) fadeOut(el);
}

/**
 * Keep the splash on screen until the returned function is called.
 *
 * With `delayMs > 0` the splash only appears if the hold outlives the delay,
 * so fast loads do not flash it. If the splash is already visible the hold is
 * taken immediately, so it cannot fade out underneath the caller.
 */
export function holdSplash(delayMs = 0): () => void {
  let held = false;
  let released = false;
  let timer: ReturnType<typeof setTimeout> | undefined;

  const acquire = () => {
    timer = undefined;
    held = true;
    holds += 1;
    sync();
  };

  const el = splashEl();
  if (delayMs > 0 && !(el && isOnScreen(el))) timer = setTimeout(acquire, delayMs);
  else acquire();

  return () => {
    if (released) return;
    released = true;
    if (timer !== undefined) clearTimeout(timer);
    if (held) {
      holds -= 1;
      sync();
    }
  };
}

/** The app has rendered its first screen: let the boot splash fade out. */
export function releaseInitialSplash(): void {
  if (initialReleased) return;
  initialReleased = true;
  sync();
}

type SplashTheme = { bg: string; orbs: ReadonlyArray<{ color: string }> };

const RGB_RE = /rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})/;

/**
 * Paint the splash in the given theme and remember it, so the next launch
 * (F5, cold start of the PWA) shows the waves in the user's own colours.
 */
export function rememberSplashTheme(theme: SplashTheme): void {
  const colors = theme.orbs.slice(0, 3).map((orb) => {
    const m = RGB_RE.exec(orb.color);
    return m ? `${m[1]},${m[2]},${m[3]}` : null;
  });
  const [c1, c2, c3] = colors;
  if (!c1 || !c2 || !c3 || !theme.bg.startsWith("linear-gradient(")) return;

  if (typeof document !== "undefined") {
    const root = document.documentElement.style;
    root.setProperty("--gw-bg", theme.bg);
    root.setProperty("--gw-c1", c1);
    root.setProperty("--gw-c2", c2);
    root.setProperty("--gw-c3", c3);
  }
  try {
    localStorage.setItem(SPLASH_THEME_KEY, JSON.stringify({ bg: theme.bg, c1, c2, c3 }));
  } catch {
    // Private mode / quota: the splash just falls back to the default colours.
  }
}

/** Test-only: reset module state between cases. */
export function __resetSplashForTests(): void {
  clearHideTimer();
  fadeToken += 1;
  initialReleased = false;
  holds = 0;
}
