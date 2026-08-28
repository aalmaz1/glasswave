import { describe, it, expect } from "vitest";
import { coerceDate, inferCreatedAt, stripHtml, fmtDate, countWords, newNoteId } from "./utils";
import en from "../i18n/lang/en";

describe("stripHtml", () => {
  it("returns empty for empty/falsy input", () => {
    expect(stripHtml("")).toBe("");
    expect(stripHtml(undefined as unknown as string)).toBe("");
  });

  it("strips tags and turns block boundaries into newlines", () => {
    expect(stripHtml("<p>Hello</p><p>World</p>")).toBe("Hello\nWorld");
    expect(stripHtml("<ul><li>a</li><li>b</li></ul>")).toBe("a\nb");
    expect(stripHtml("<div>one</div><br/><div>two</div>")).toBe("one\ntwo");
  });

  it("removes inline tags and collapses repeated newlines", () => {
    expect(stripHtml("<p><b>bold</b> text</p>")).toBe("bold text");
  });
});

describe("coerceDate", () => {
  it("returns null for null/undefined/invalid", () => {
    expect(coerceDate(null)).toBeNull();
    expect(coerceDate(undefined)).toBeNull();
    expect(coerceDate("not-a-date")).toBeNull();
  });

  it("returns the Date itself for Date instances", () => {
    const d = new Date("2026-01-01T00:00:00Z");
    expect(coerceDate(d)).toEqual(d);
  });

  it("handles Firestore Timestamp-like objects", () => {
    const d = new Date("2026-01-01T00:00:00Z");
    expect(coerceDate({ toDate: () => d })).toEqual(d);
  });

  it("parses ISO strings", () => {
    expect(coerceDate("2026-01-01T00:00:00Z")).toEqual(new Date("2026-01-01T00:00:00Z"));
  });
});

describe("inferCreatedAt", () => {
  const updatedAt = new Date("2026-01-01T00:00:00Z");

  it("prefers an explicit raw createdAt", () => {
    const raw = new Date("2025-06-01T00:00:00Z");
    expect(inferCreatedAt(1, updatedAt, raw)).toEqual(raw);
  });

  it("derives from a millisecond id when present", () => {
    const id = new Date("2025-06-01T00:00:00Z").getTime();
    expect(inferCreatedAt(id, updatedAt, null)).toEqual(new Date(id));
  });

  it("falls back to updatedAt for small ids", () => {
    expect(inferCreatedAt(42, updatedAt, null)).toEqual(updatedAt);
  });
});

describe("fmtDate", () => {
  const now = new Date("2026-08-01T12:00:00Z").getTime();

  it("renders just-now / minutes / hours", () => {
    expect(fmtDate(new Date(now - 30_000), "en-US", en, now)).toBe(en.timeJustNow);
    expect(fmtDate(new Date(now - 5 * 60_000), "en-US", en, now)).toBe(en.timeMinAgo(5));
    expect(fmtDate(new Date(now - 3 * 3_600_000), "en-US", en, now)).toBe(en.timeHoursAgo(3));
  });

  it("renders yesterday and days", () => {
    expect(fmtDate(new Date(now - 86_400_000), "en-US", en, now)).toBe(en.timeYesterday);
    expect(fmtDate(new Date(now - 3 * 86_400_000), "en-US", en, now)).toBe(en.timeDaysAgo(3));
  });

  it("falls back to a full date after a week", () => {
    const out = fmtDate(new Date(now - 30 * 86_400_000), "en-US", en, now);
    expect(out).toBeTruthy();
    expect(out).not.toBe(en.timeDaysAgo(30));
  });
});

describe("countWords", () => {
  it("counts whitespace-separated words", () => {
    expect(countWords("one two three")).toBe(3);
    expect(countWords("  spaced   out  ")).toBe(2);
    expect(countWords("")).toBe(0);
  });
});

describe("newNoteId", () => {
  it("returns a positive safe integer", () => {
    const id = newNoteId();
    expect(Number.isInteger(id)).toBe(true);
    expect(id).toBeGreaterThan(0);
    expect(id).toBeLessThanOrEqual(Number.MAX_SAFE_INTEGER);
  });

  it("does not reuse the Date.now() style id", () => {
    const id = newNoteId();
    expect(id).not.toBe(Date.now());
  });
});
