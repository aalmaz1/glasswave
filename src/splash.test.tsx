// @vitest-environment jsdom
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { cleanup, render, screen, waitFor } from "@testing-library/react";
import indexHtml from "../index.html?raw";
import { LanguageProvider, loadTranslation } from "./i18n";
import en from "./i18n/lang/en";
import ko from "./i18n/lang/ko";
import ru from "./i18n/lang/ru";
import App from "./app/App";
import { SplashRelease } from "./app/components/SplashGate";
import { THEMES } from "./app/theme";
import {
  SPLASH_THEME_KEY,
  __resetSplashForTests,
  holdSplash,
  releaseInitialSplash,
  rememberSplashTheme,
} from "./splash";

// Use the real markup and inline scripts from index.html, so the tests break
// if the page and src/splash.ts ever drift apart.
const page = new DOMParser().parseFromString(indexHtml, "text/html");
const splashMarkup = page.getElementById("gw-splash")?.outerHTML ?? "";
const inlineScripts = Array.from(
  page.querySelectorAll("script:not([src])"),
  (s) => s.textContent ?? ""
);
const themeScript = inlineScripts.find((code) => code.includes(SPLASH_THEME_KEY)) ?? "";
const labelScript = inlineScripts.find((code) => code.includes("preferred-lang")) ?? "";
const runInline = (code: string) => new Function(code)();

const splash = () => document.getElementById("gw-splash") as HTMLElement;
const isShown = () => !splash().hidden && !splash().classList.contains("gw-out");

beforeEach(() => {
  __resetSplashForTests();
  localStorage.clear();
  document.documentElement.removeAttribute("style");
  document.body.innerHTML = splashMarkup;
});

describe("index.html splash markup", () => {
  it("is present, visible by default and carries its own inline scripts", () => {
    expect(splashMarkup).toContain('role="status"');
    expect(themeScript).not.toBe("");
    expect(labelScript).not.toBe("");
    expect(isShown()).toBe(true);
  });
});

describe("splash controller", () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it("stays up until the app releases it, then fades out and hides", () => {
    vi.advanceTimersByTime(5000);
    expect(isShown()).toBe(true);

    releaseInitialSplash();
    expect(splash().classList.contains("gw-out")).toBe(true);
    expect(splash().hidden).toBe(false); // still fading
    vi.advanceTimersByTime(1000);
    expect(splash().hidden).toBe(true);
  });

  it("waits for the fade to be played on screen before hiding", async () => {
    // Real browsers: the fade is tracked through the Web Animations API, so a
    // main thread busy with the app's first render cannot swallow it.
    let endFade = () => {};
    const finished = new Promise<void>((resolve) => (endFade = resolve));
    const transition = { transitionProperty: "opacity", finished } as unknown as Animation;
    splash().getAnimations = () => [transition];

    releaseInitialSplash();
    vi.advanceTimersByTime(1000); // a plain timer would have hidden it by now
    expect(splash().hidden).toBe(false);

    endFade();
    await finished;
    await Promise.resolve();
    expect(splash().hidden).toBe(true);
  });

  it("still hides if the tracked fade never reports back", () => {
    const transition = {
      transitionProperty: "opacity",
      finished: new Promise(() => {}),
    } as unknown as Animation;
    splash().getAnimations = () => [transition];

    releaseInitialSplash();
    vi.advanceTimersByTime(3000);
    expect(splash().hidden).toBe(false);
    vi.advanceTimersByTime(2000);
    expect(splash().hidden).toBe(true);
  });

  it("keeps the splash while a hold outlives the initial release", () => {
    const release = holdSplash();
    releaseInitialSplash();
    vi.advanceTimersByTime(1000);
    expect(isShown()).toBe(true);

    release();
    vi.advanceTimersByTime(1000);
    expect(splash().hidden).toBe(true);
  });

  it("shows a delayed hold only when the load is slow", () => {
    releaseInitialSplash();
    vi.advanceTimersByTime(1000);

    const fast = holdSplash(200);
    vi.advanceTimersByTime(150);
    fast();
    vi.advanceTimersByTime(1000);
    expect(splash().hidden).toBe(true);

    const slow = holdSplash(200);
    vi.advanceTimersByTime(250);
    expect(isShown()).toBe(true);
    slow();
    vi.advanceTimersByTime(1000);
    expect(splash().hidden).toBe(true);
  });

  it("brings the splash back when a hold arrives during the fade-out", () => {
    releaseInitialSplash();
    vi.advanceTimersByTime(200);
    const release = holdSplash();
    vi.advanceTimersByTime(1000);
    expect(isShown()).toBe(true);
    release();
  });

  it("ignores repeated calls of the same release function", () => {
    const a = holdSplash();
    const b = holdSplash();
    releaseInitialSplash();
    a();
    a();
    vi.advanceTimersByTime(1000);
    expect(isShown()).toBe(true);

    b();
    vi.advanceTimersByTime(1000);
    expect(splash().hidden).toBe(true);
  });

  it("is a no-op without the splash element", () => {
    document.body.innerHTML = "";
    expect(() => {
      const release = holdSplash(100);
      releaseInitialSplash();
      release();
      vi.runAllTimers();
    }).not.toThrow();
  });
});

describe("splash theme", () => {
  it.each(THEMES)("remembers $id so index.html can paint it on the next launch", (theme) => {
    rememberSplashTheme(theme);
    document.documentElement.removeAttribute("style"); // simulate a reload

    runInline(themeScript);

    const style = document.documentElement.style;
    expect(style.getPropertyValue("--gw-bg")).toBe(theme.bg);
    theme.orbs.slice(0, 3).forEach((orb, i) => {
      const [r, g, b] = orb.color.match(/\d+/g) ?? [];
      expect(style.getPropertyValue(`--gw-c${i + 1}`)).toBe(`${r},${g},${b}`);
    });
  });

  it("ignores tampered or broken storage", () => {
    localStorage.setItem(
      SPLASH_THEME_KEY,
      JSON.stringify({ bg: "red;}</style><script>alert(1)</script>", c1: "1,2,3;x", c2: 5 })
    );
    runInline(themeScript);
    expect(document.documentElement.getAttribute("style")).toBeNull();

    localStorage.setItem(SPLASH_THEME_KEY, "{not json");
    expect(() => runInline(themeScript)).not.toThrow();
  });
});

describe("splash label", () => {
  it.each([
    ["ru", ru.loading],
    ["en", en.loading],
    ["ko", ko.loading],
  ])("announces loading in %s like the app does", (lang, text) => {
    localStorage.setItem("preferred-lang", lang);
    runInline(labelScript);
    expect(splash().querySelector(".gw-sr")?.textContent).toBe(text);
  });
});

describe("splash with the app", () => {
  afterEach(() => {
    cleanup();
  });

  it("covers the boot and fades out once the dashboard is ready", async () => {
    const t = await loadTranslation("en");
    render(
      <LanguageProvider initialLanguage="en" initialT={t}>
        <App />
        <SplashRelease />
      </LanguageProvider>
    );

    // No "Loading..." text screen any more — the waves cover the boot while
    // the Firebase session is being restored.
    expect(screen.queryByText(en.loading)).toBeNull();
    expect(screen.queryByPlaceholderText(t.searchPlaceholder)).toBeNull();
    expect(isShown()).toBe(true);

    expect(await screen.findByPlaceholderText(t.searchPlaceholder)).toBeTruthy();
    await waitFor(() => expect(splash().hidden).toBe(true));
    expect(localStorage.getItem(SPLASH_THEME_KEY)).toContain("linear-gradient(");
  });
});
