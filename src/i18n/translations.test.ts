import { describe, it, expect } from "vitest";
import { TRANSLATIONS, type Language } from "./translations";

const LANGS: Language[] = ["ru", "en", "ko"];

describe("TRANSLATIONS", () => {
  it("has all three languages", () => {
    for (const lang of LANGS) {
      expect(TRANSLATIONS[lang]).toBeDefined();
    }
  });

  it("keeps an identical key set across languages", () => {
    const base = Object.keys(TRANSLATIONS.ru).sort();
    for (const lang of LANGS.slice(1)) {
      expect(Object.keys(TRANSLATIONS[lang]).sort()).toEqual(base);
    }
  });

  it("has no empty user-facing strings (except known placeholders)", () => {
    const allowedEmpty = new Set(["editingNote"]);
    for (const lang of LANGS) {
      for (const [key, value] of Object.entries(TRANSLATIONS[lang])) {
        if (allowedEmpty.has(key)) continue;
        expect(typeof value !== "string" || value.length > 0, `${lang}.${key} should not be empty`).toBe(true);
      }
      expect(TRANSLATIONS[lang].editingNote).toBe("");
    }
  });
});

describe("wordsCount pluralization", () => {
  it("Russian: 1 / 2-4 / 5+ / teens", () => {
    expect(TRANSLATIONS.ru.wordsCount(1)).toBe("1 слово");
    expect(TRANSLATIONS.ru.wordsCount(2)).toBe("2 слова");
    expect(TRANSLATIONS.ru.wordsCount(5)).toBe("5 слов");
    expect(TRANSLATIONS.ru.wordsCount(11)).toBe("11 слов");
    expect(TRANSLATIONS.ru.wordsCount(21)).toBe("21 слово");
  });

  it("English: singular vs plural", () => {
    expect(TRANSLATIONS.en.wordsCount(1)).toBe("1 word");
    expect(TRANSLATIONS.en.wordsCount(3)).toBe("3 words");
  });

  it("Korean: no inflection", () => {
    expect(TRANSLATIONS.ko.wordsCount(1)).toBe("1단어");
    expect(TRANSLATIONS.ko.wordsCount(7)).toBe("7단어");
  });
});
