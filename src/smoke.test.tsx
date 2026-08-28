// @vitest-environment jsdom
import { describe, it, expect, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { LanguageProvider, detectLanguage, loadTranslation } from "./i18n";
import en from "./i18n/lang/en";
import ru from "./i18n/lang/ru";
import App from "./app/App";

/**
 * Temporary smoke test: proves the lazy-loading refactor still boots the app
 * end to end (language resolves, App mounts, guest dashboard renders).
 */
describe("smoke", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("detects the language from localStorage", () => {
    localStorage.setItem("preferred-lang", "ko");
    expect(detectLanguage()).toBe("ko");
  });

  it("boots the app with a resolved translation", async () => {
    const lang = detectLanguage();
    const initialT = await loadTranslation(lang);
    const expected = lang === "ru" ? ru : en;
    expect(initialT.searchPlaceholder).toBe(expected.searchPlaceholder);

    render(
      <LanguageProvider initialLanguage={lang} initialT={initialT}>
        <App />
      </LanguageProvider>
    );

    expect(await screen.findByPlaceholderText(initialT.searchPlaceholder)).toBeTruthy();
  });
});
