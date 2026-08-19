import { useState, useEffect, useCallback } from "react";

const ALL_THEMES = [
  "sunset", "ice", "mono", "cyber", "aurora", "rose", "cosmos", "forest",
  "obsidian", "graphite", "midnight", "espresso",
] as const;

export type ThemeId = typeof ALL_THEMES[number];

const LS_GUEST_THEME = "glasswave_guest_theme";
const LS_USER_PREFS = (email: string) => `glasswave_prefs_${email.toLowerCase()}`;

export function getRandomTheme(): ThemeId {
  return ALL_THEMES[Math.floor(Math.random() * ALL_THEMES.length)];
}

/**
 * Хук для управления цветовой темой с учётом статуса авторизации.
 */
export function useTheme(
  currentUser: { email: string } | null,
  initialThemeId?: ThemeId
): [ThemeId, (id: ThemeId) => void] {
  const [themeId, setThemeIdRaw] = useState<ThemeId>(() => {
    if (currentUser) {
      try {
        const prefs = JSON.parse(localStorage.getItem(LS_USER_PREFS(currentUser.email)) || "{}");
        if (prefs.themeId && ALL_THEMES.includes(prefs.themeId)) {
          return prefs.themeId as ThemeId;
        }
      } catch { /* ignore */ }
      return initialThemeId ?? "sunset";
    } else {
      try {
        const saved = localStorage.getItem(LS_GUEST_THEME);
        if (saved && (ALL_THEMES as readonly string[]).includes(saved)) {
          return saved as ThemeId;
        }
      } catch { /* ignore */ }
      const random = getRandomTheme();
      localStorage.setItem(LS_GUEST_THEME, random);
      return random;
    }
  });

  useEffect(() => {
    if (currentUser) {
      try {
        const prefs = JSON.parse(localStorage.getItem(LS_USER_PREFS(currentUser.email)) || "{}");
        if (prefs.themeId && ALL_THEMES.includes(prefs.themeId)) {
          setThemeIdRaw(prefs.themeId as ThemeId);
        }
      } catch { /* ignore */ }
    } else {
      try {
        const saved = localStorage.getItem(LS_GUEST_THEME);
        if (saved && (ALL_THEMES as readonly string[]).includes(saved)) {
          setThemeIdRaw(saved as ThemeId);
        } else {
          const random = getRandomTheme();
          localStorage.setItem(LS_GUEST_THEME, random);
          setThemeIdRaw(random);
        }
      } catch {
        const random = getRandomTheme();
        localStorage.setItem(LS_GUEST_THEME, random);
        setThemeIdRaw(random);
      }
    }
  }, [currentUser]);

  const setThemeId = useCallback((id: ThemeId) => {
    setThemeIdRaw(id);
    if (currentUser) {
      try {
        const key = LS_USER_PREFS(currentUser.email);
        const existing = JSON.parse(localStorage.getItem(key) || "{}");
        localStorage.setItem(key, JSON.stringify({ ...existing, themeId: id }));
      } catch { /* ignore */ }
    } else {
      localStorage.setItem(LS_GUEST_THEME, id);
    }
  }, [currentUser]);

  return [themeId, setThemeId];
}
