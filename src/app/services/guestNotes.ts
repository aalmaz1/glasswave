import { doc, writeBatch } from "firebase/firestore";
import { db } from "../../firebase";
import { LS_GUEST_DIRTY, LS_GUEST_NOTES, NOTES_COLLECTION, type Note } from "../model";
import { inferCreatedAt } from "../utils";

/* ════════════════════════════════════════════════════════════════════
   GUEST LOCAL NOTES (localStorage persistence)
   ════════════════════════════════════════════════════════════════════ */
export function loadGuestNotes(): Note[] | null {
  try {
    const raw = localStorage.getItem(LS_GUEST_NOTES);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as any[];
    return parsed.map((n) => {
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
  } catch {
    return null;
  }
}

export function saveGuestNotes(notes: Note[]) {
  try {
    localStorage.setItem(LS_GUEST_NOTES, JSON.stringify(notes));
  } catch {}
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
  if (!db || !isGuestNotesDirty()) return;
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
      const batch = writeBatch(db!);
      notes.slice(start, start + 450).forEach((n) => {
        // A deterministic id makes retries after a partially successful
        // migration overwrite the same document instead of duplicating notes.
        batch.set(doc(db!, NOTES_COLLECTION, `guest_${uid}_${n.id}`), {
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

/* ════════════════════════════════════════════════════════════════════
   SEED
   ════════════════════════════════════════════════════════════════════ */
const SEED: Note[] = [
  {
    id: 1,
    title: "Product Roadmap Q3",
    body: "<p>Launch mobile redesign by August 15. Milestones: design handoff Jul 20, beta Aug 1, soft launch Aug 10. Coordinate with Elena on onboarding flow.</p>",
    updatedAt: new Date("2026-07-11T14:30:00"),
    createdAt: new Date("2026-07-01T10:00:00"),
    accentIdx: 0,
    pinned: true,
    archived: false,
    trashed: false,
    reminder: null,
  },
  {
    id: 2,
    title: "Design Sprint Notes",
    body: "<p>Decided on glassmorphism for v2. Action items: component library, Figma tokens, user testing schedule.</p>",
    updatedAt: new Date("2026-07-10T09:15:00"),
    createdAt: new Date("2026-07-03T11:00:00"),
    accentIdx: 1,
    pinned: false,
    archived: false,
    trashed: false,
    reminder: null,
  },
  {
    id: 3,
    title: "Reading List",
    body: "<ul><li>Thinking in Systems — Meadows</li><li>A Pattern Language — Alexander</li><li>Working in Public — Nadia Eghbal</li><li>Finite and Infinite Games — Carse</li></ul>",
    updatedAt: new Date("2026-07-09T18:00:00"),
    createdAt: new Date("2026-07-02T16:00:00"),
    accentIdx: 2,
    pinned: true,
    archived: false,
    trashed: false,
    reminder: null,
  },
  {
    id: 4,
    title: "API Integration",
    body: "<p>Auth: /v2/auth/token. Rate limit 1000 req/min. Headers: X-API-Key, Content-Type. Exponential backoff from 500ms.</p>",
    updatedAt: new Date("2026-07-08T11:45:00"),
    createdAt: new Date("2026-07-04T09:00:00"),
    accentIdx: 3,
    pinned: false,
    archived: false,
    trashed: false,
    reminder: null,
  },
];

export function getFallbackNotes(): Note[] {
  return SEED.map((n) => ({ ...n }));
}
