import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { TRANSLATIONS, type Language, type Translation } from "./translations";

export {
  TRANSLATIONS,
  themeNameByLang,
  LANGUAGE_OPTIONS,
} from "./translations";
export type { Language, Translation } from "./translations";

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: Translation;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<Language>(() => {
    if (typeof window === "undefined") return "ru";
    const saved = window.localStorage.getItem("preferred-lang");
    if (saved === "en" || saved === "ko" || saved === "ru") return saved;
    const nav = (navigator.language || "ru").toLowerCase();
    if (nav.startsWith("ko")) return "ko";
    if (nav.startsWith("en")) return "en";
    return "ru";
  });

  useEffect(() => {
    window.localStorage.setItem("preferred-lang", language);
    document.documentElement.lang = language;
  }, [language]);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
  };

  const t = TRANSLATIONS[language];

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
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
