import type { Translation } from "../i18n";

/** Coerce an unknown Firestore value into a Date, or null when invalid. */
export function coerceDate(value: unknown): Date | null {
  if (!value) return null;
  if (typeof (value as { toDate?: unknown }).toDate === "function") {
    return (value as { toDate: () => Date }).toDate();
  }
  if (value instanceof Date) return isNaN(value.getTime()) ? null : value;
  const d = new Date(value as string | number);
  return isNaN(d.getTime()) ? null : d;
}

/** Old notes have no createdAt — fall back to the millisecond id, then updatedAt. */
export function inferCreatedAt(id: number, updatedAt: Date, raw?: unknown): Date {
  return coerceDate(raw) ?? (id > 1e12 ? new Date(id) : updatedAt);
}

/** Strip HTML tags, converting block boundaries to newlines. */
export function stripHtml(html: string): string {
  if (!html) return "";
  return html
    .replace(/<\/p>|<\/h[1-6]>|<\/li>|<\/div>|<br\s*\/?>/gi, "\n")
    .replace(/<[^>]*>/g, "")
    .replace(/\n+/g, "\n")
    .trim();
}

/** Human-friendly relative time, localized. */
export function fmtDate(
  d: Date,
  locale: string,
  t: Translation,
  now: number = Date.now()
): string {
  const secs = Math.floor((now - d.getTime()) / 1000);
  if (secs < 60) return t.timeJustNow;
  const mins = Math.floor(secs / 60);
  if (mins < 60) return t.timeMinAgo(mins);
  const hrs = Math.floor(secs / 3600);
  if (hrs < 24) return t.timeHoursAgo(hrs);
  const days = Math.floor(secs / 86400);
  if (days === 1) return t.timeYesterday;
  if (days < 7) return t.timeDaysAgo(days);
  return d.toLocaleDateString(locale, { day: "numeric", month: "long" });
}

/** Count words in plain text (used by the editor word counter). */
export function countWords(plainText: string): number {
  return plainText.trim().split(/\s+/).filter(Boolean).length;
}

/**
 * Generate a collision-resistant numeric note id.
 *
 * Note ids used to be `Date.now()`, which collided whenever two notes were
 * created in the same millisecond (easy on fast keyboards or across two
 * syncing devices). A 53-bit random integer keeps the `number` type (and the
 * existing Firestore schema) while making collisions practically impossible.
 * Falls back to `Date.now()` only where the Web Crypto API is unavailable.
 */
export function newNoteId(): number {
  if (typeof crypto !== "undefined" && typeof crypto.getRandomValues === "function") {
    const buf = new Uint32Array(2);
    crypto.getRandomValues(buf);
    return buf[0] * 0x200000 + (buf[1] & 0x1fffff);
  }
  return Date.now();
}
