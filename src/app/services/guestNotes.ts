import { getFirebase } from "../../firebase";
import type { Translation } from "../../i18n";
import { LS_GUEST_DIRTY, LS_GUEST_NOTES, NOTES_COLLECTION, type Note } from "../model";
import { inferCreatedAt } from "../utils";

/* ════════════════════════════════════════════════════════════════════
   GUEST LOCAL NOTES (localStorage persistence)
   ════════════════════════════════════════════════════════════════════ */

/**
 * Signature of the bundled demo notes that older GlassWave builds wrote into
 * guest storage. They used to flash on the dashboard before the user's real
 * notes loaded. We no longer ship demo content at all, so any copy of these
 * notes already sitting in localStorage is stale and should be discarded.
 */
const LEGACY_DEMO_NOTES: ReadonlyArray<readonly [id: number, title: string]> = [
  [1, "Product Roadmap Q3"],
  [2, "Design Sprint Notes"],
  [3, "Reading List"],
  [4, "API Integration"],
];

/** True when every stored note is one of the legacy demo notes (never edited). */
function isLegacyDemoNotes(notes: { id: number; title: string }[]): boolean {
  if (notes.length === 0) return false;
  return notes.every((n) =>
    LEGACY_DEMO_NOTES.some(([id, title]) => id === n.id && title === n.title)
  );
}

export function loadGuestNotes(): Note[] | null {
  try {
    const raw = localStorage.getItem(LS_GUEST_NOTES);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as any[];
    const notes = parsed.map((n) => {
      const updatedAt = new Date(n.updatedAt);
      const id = Number(n.id ?? Date.now());
      return {
        ...n,
        id,
        updatedAt,
        createdAt: inferCreatedAt(id, updatedAt, n.createdAt),
        reminder: n.reminder ? new Date(n.reminder) : null,
      };
    });
    // Drop demo notes a previous version may have persisted, so they can never
    // flash ahead of the user's own notes again.
    if (isLegacyDemoNotes(notes)) {
      try {
        localStorage.removeItem(LS_GUEST_NOTES);
      } catch {}
      return null;
    }
    return notes;
  } catch {
    return null;
  }
}

export function saveGuestNotes(notes: Note[]) {
  try {
    localStorage.setItem(LS_GUEST_NOTES, JSON.stringify(notes));
  } catch {}
}

/**
 * Welcome/demo notes use reserved negative ids, so they can never collide with
 * a real note (real ids come from `newNoteId()`, which is always positive).
 */
export function isWelcomeNoteId(id: number): boolean {
  return id < 0;
}

/**
 * Build the welcome notes shown to a brand-new guest (no notes of their own).
 * The content is a short tour of GlassWave drawn from the README, localized via
 * the current translation. These notes are ephemeral — they are never persisted
 * and disappear the moment the guest creates or edits their first note.
 */
export function buildWelcomeNotes(t: Translation): Note[] {
  const now = Date.now();
  const make = (slot: number, title: string, body: string, pinned = false): Note => ({
    id: -slot,
    title,
    body,
    updatedAt: new Date(now - slot * 60_000),
    createdAt: new Date(now - slot * 60_000 - 60_000),
    accentIdx: (slot - 1) % 4,
    pinned,
    archived: false,
    trashed: false,
    reminder: null,
  });
  return [
    make(1, t.welcomeNote1Title, t.welcomeNote1Body, true),
    make(2, t.welcomeNote2Title, t.welcomeNote2Body),
    make(3, t.welcomeNote3Title, t.welcomeNote3Body),
    make(4, t.welcomeNote4Title, t.welcomeNote4Body),
  ];
}

/** Marks that the user actually edited guest notes (vs untouched seed content). */
export function markGuestNotesDirty() {
  try {
    localStorage.setItem(LS_GUEST_DIRTY, "1");
  } catch {}
}

function isGuestNotesDirty(): boolean {
  try {
    return localStorage.getItem(LS_GUEST_DIRTY) === "1";
  } catch {
    return false;
  }
}

/**
 * Move guest notes into the user's Firestore account on first sign-in.
 * Runs only when the guest actually created/edited notes (dirty flag), so
 * fresh accounts are not polluted with the bundled demo seed.
 * On failure the local copy is kept, so the migration retries at next login.
 */
export async function migrateGuestNotesToFirestore(uid: string): Promise<void> {
  if (!isGuestNotesDirty()) return;
  const fb = await getFirebase();
  if (!fb) return;
  const { db, fs } = fb;
  const notes = loadGuestNotes();
  if (!notes || notes.length === 0) {
    try {
      localStorage.removeItem(LS_GUEST_DIRTY);
    } catch {}
    return;
  }
  try {
    // Firestore batches are capped at 500 operations — stay below the limit.
    for (let start = 0; start < notes.length; start += 450) {
      const batch = fs.writeBatch(db);
      notes.slice(start, start + 450).forEach((n) => {
        // A deterministic id makes retries after a partially successful
        // migration overwrite the same document instead of duplicating notes.
        batch.set(fs.doc(db, NOTES_COLLECTION, `guest_${uid}_${n.id}`), {
          ownerUid: uid,
          id: n.id,
          title: n.title,
          body: n.body,
          accentIdx: n.accentIdx,
          pinned: n.pinned,
          archived: n.archived,
          trashed: n.trashed,
          updatedAt: n.updatedAt,
          createdAt: n.createdAt ?? inferCreatedAt(n.id, n.updatedAt),
          reminder: n.reminder,
        });
      });
      await batch.commit();
    }
    try {
      localStorage.removeItem(LS_GUEST_NOTES);
      localStorage.removeItem(LS_GUEST_DIRTY);
    } catch {}
    console.info(`[GlassWave] Migrated ${notes.length} guest notes to the account.`);
  } catch (error) {
    console.warn("Could not migrate guest notes. Will retry at next sign-in.", error);
  }
}
