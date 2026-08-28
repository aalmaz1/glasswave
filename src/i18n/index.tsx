import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { LANGUAGES, LOADERS, type Language, type Translation } from "./translations";
import { prefetchOnIdle } from "../prefetch";

export { LANGUAGE_OPTIONS, themeNameByLang } from "./translations";
export type { Language, Translation } from "./translations";

/**
 * Resolved translations, so switching to an already-seen language never waits
 * on a network round trip.
 */
const cache = new Map<Language, Translation>();

export function detectLanguage(): Language {
  if (typeof window === "undefined") return "ru";
  const saved = window.localStorage.getItem("preferred-lang");
  if (saved === "en" || saved === "ko" || saved === "ru") return saved;
  const nav = (navigator.language || "ru").toLowerCase();
  if (nav.startsWith("ko")) return "ko";
  if (nav.startsWith("en")) return "en";
  return "ru";
}

export async function loadTranslation(lang: Language): Promise<Translation> {
  const hit = cache.get(lang);
  if (hit) return hit;
  const mod = await LOADERS[lang]();
  cache.set(lang, mod.default);
  return mod.default;
}

/**
 * Warm the remaining languages once the browser is idle.
 *
 * The strings are no longer part of the startup bundle, so without this the
 * first switch to another language would leave the UI on the old strings for
 * one round trip. Prefetching during idle keeps the switch instant — the user
 * should not be able to tell that translations are now loaded on demand.
 */
export function prefetchTranslations(current: Language): void {
  const rest = LANGUAGES.filter((l) => l !== current);
  prefetchOnIdle(() => Promise.all(rest.map(loadTranslation)));
}

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: Translation;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({
  initialLanguage,
  initialT,
  children,
}: {
  initialLanguage: Language;
  initialT: Translation;
  children: ReactNode;
}) {
  const [language, setLanguageState] = useState<Language>(initialLanguage);
  const [t, setT] = useState<Translation>(initialT);

  useEffect(() => {
    cache.set(initialLanguage, initialT);
  }, [initialLanguage, initialT]);

  useEffect(() => {
    window.localStorage.setItem("preferred-lang", language);
    document.documentElement.lang = language;
  }, [language]);

  useEffect(() => {
    const cached = cache.get(language);
    if (cached) {
      setT(cached);
      return;
    }
    let cancelled = false;
    void loadTranslation(language).then((next) => {
      if (!cancelled) setT(next);
    });
    return () => {
      cancelled = true;
    };
  }, [language]);

  useEffect(() => {
    prefetchTranslations(initialLanguage);
  }, [initialLanguage]);

  return (
    <LanguageContext.Provider value={{ language, setLanguage: setLanguageState, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useTranslation() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useTranslation must be used within a LanguageProvider");
  }
  return context;
}
