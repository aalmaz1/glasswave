import { useState, useEffect, useCallback } from "react";

/**
 * Список доступных тем для случайного выбора (8 основных цветовых тем).
 * Исключаем "obsidian", "graphite", "midnight", "espresso" — это дополнительные тёмные темы.
 */
const RANDOM_THEME_CANDIDATES = [
  "sunset",   // Тёплый закат 🌅
  "ice",      // Ледяная свежесть 🧊
  "mono",     // Монохром 🪨
  "cyber",    // Кибер-закат 🌺
  "aurora",   // Северное сияние 🌌
  "rose",     // Полночная роза 🥀
  "cosmos",   // Глубокий космос 🔭
  "forest",   // Тёмный лес 🌲
] as const;

export type ThemeId = 
  | "sunset" | "ice" | "mono" | "cyber" | "aurora" | "rose" | "cosmos" | "forest"
  | "obsidian" | "graphite" | "midnight" | "espresso";

const LS_GUEST_THEME = "noova_guest_theme";

/**
 * Выбирает случайную тему из набора кандидатов.
 */
export function getRandomTheme(): ThemeId {
  const index = Math.floor(Math.random() * RANDOM_THEME_CANDIDATES.length);
  return RANDOM_THEME_CANDIDATES[index] as ThemeId;
}

/**
 * Хук для управления цветовой темой с учётом статуса авторизации.
 * 
 * Логика:
 * - Если пользователь НЕ залогинен: при первом посещении выбирается случайная тема,
 *   которая сохраняется в localStorage. При обновлении страницы тема не меняется.
 * - Если пользователь залогинен: используется его предпочтительная тема из localStorage
 *   (или "sunset" по умолчанию, если предпочтения нет).
 * - При выходе из системы (логауте) тема сбрасывается на сохранённую гостевую тему.
 * - При входе тема переключается на предпочтения пользователя.
 * 
 * @param currentUser - текущий авторизованный пользователь (null если не залогинен)
 * @param initialThemeId - начальная тема (для совместимости с существующим кодом)
 */
export function useTheme(
  currentUser: { email: string } | null,
  initialThemeId?: ThemeId
): [ThemeId, (id: ThemeId) => void] {
  const [themeId, setThemeIdRaw] = useState<ThemeId>(() => {
    // Инициализация темы при первом рендере
    if (currentUser) {
      // Залогинен: пробуем загрузить предпочтения пользователя
      try {
        const prefs = JSON.parse(localStorage.getItem(`noova_prefs_${currentUser.email}`) || "{}");
        if (prefs.themeId) {
          return prefs.themeId as ThemeId;
        }
      } catch {
        // Игнорируем ошибки парсинга
      }
      return initialThemeId ?? "sunset";
    } else {
      // Не залогинен: пробуем загрузить сохранённую гостевую тему
      try {
        const savedGuestTheme = localStorage.getItem(LS_GUEST_THEME);
        if (savedGuestTheme && RANDOM_THEME_CANDIDATES.includes(savedGuestTheme as any)) {
          return savedGuestTheme as ThemeId;
        }
      } catch {
        // Игнорируем ошибки
      }
      // Первая загрузка для гостя — выбираем случайную тему
      const randomTheme = getRandomTheme();
      localStorage.setItem(LS_GUEST_THEME, randomTheme);
      return randomTheme;
    }
  });

  // Эффект для синхронизации темы при изменении статуса авторизации
  useEffect(() => {
    if (currentUser) {
      // Пользователь залогинился — загружаем его предпочтения
      try {
        const prefs = JSON.parse(localStorage.getItem(`noova_prefs_${currentUser.email}`) || "{}");
        if (prefs.themeId) {
          setThemeIdRaw(prefs.themeId as ThemeId);
        }
        // Если у пользователя нет предпочтений — оставляем текущую (гостевую) тему
      } catch {
        // Игнорируем ошибки
      }
    } else {
      // Пользователь вышел — загружаем гостевую тему или создаём новую
      try {
        const savedGuestTheme = localStorage.getItem(LS_GUEST_THEME);
        if (savedGuestTheme && RANDOM_THEME_CANDIDATES.includes(savedGuestTheme as any)) {
          setThemeIdRaw(savedGuestTheme as ThemeId);
        } else {
          const randomTheme = getRandomTheme();
          localStorage.setItem(LS_GUEST_THEME, randomTheme);
          setThemeIdRaw(randomTheme);
        }
      } catch {
        const randomTheme = getRandomTheme();
        localStorage.setItem(LS_GUEST_THEME, randomTheme);
        setThemeIdRaw(randomTheme);
      }
    }
  }, [currentUser]);

  /**
   * Устанавливает тему с учётом статуса авторизации.
   * - Для залогиненных: сохраняет в localStorage пользователя
   * - Для незалогиненных: сохраняет в гостевой localStorage
   */
  const setThemeId = useCallback((id: ThemeId) => {
    setThemeIdRaw(id);
    if (currentUser) {
      // Сохраняем предпочтение пользователя
      try {
        const existingPrefs = JSON.parse(localStorage.getItem(`noova_prefs_${currentUser.email}`) || "{}");
        localStorage.setItem(`noova_prefs_${currentUser.email}`, JSON.stringify({ ...existingPrefs, themeId: id }));
      } catch {
        // Игнорируем ошибки сохранения
      }
    } else {
      // Сохраняем гостевую тему
      localStorage.setItem(LS_GUEST_THEME, id);
    }
  }, [currentUser]);

  return [themeId, setThemeId];
}
