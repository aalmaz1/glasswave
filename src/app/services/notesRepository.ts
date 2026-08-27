import type { Query } from "firebase/firestore";
import { getFirebase, type FirebaseServices } from "../../firebase";
import { NOTES_COLLECTION, type FirestoreNote, type Note } from "../model";
import { coerceDate, inferCreatedAt } from "../utils";

export function noteFromFirestore(data: FirestoreNote & { firestoreId: string }): Note {
  const updatedAt = coerceDate(data.updatedAt) ?? new Date();
  const id = Number(data.id ?? Date.now());
  return {
    firestoreId: data.firestoreId,
    id,
    title: String(data.title ?? ""),
    body: String(data.body ?? ""),
    accentIdx: Number(data.accentIdx ?? 0),
    pinned: Boolean(data.pinned),
    archived: Boolean(data.archived),
    trashed: Boolean(data.trashed),
    updatedAt,
    createdAt: inferCreatedAt(id, updatedAt, data.createdAt),
    reminder: coerceDate(data.reminder),
  };
}

export function buildNotesQuery(
  { db, fs }: FirebaseServices,
  ownerUid: string,
  max: number
): Query<FirestoreNote> {
  // A `where(ownerUid) + orderBy(updatedAt)` query requires a composite
  // Firestore index. Loading the list then fails completely until that index
  // has been created in every Firebase project. Keep this query on Firestore's
  // built-in single-field index and sort the bounded result in the client.
  //
  // Pagination is done by growing the `limit` (Firestore returns docs in stable
  // doc-id order for an unordered query, so a larger limit is a strict superset
  // of a smaller one). This avoids the 500-note ceiling without a composite
  // index and keeps a single live `onSnapshot` subscription.
  return fs.query(
    fs.collection(db, NOTES_COLLECTION).withConverter<FirestoreNote>({
      toFirestore: (data) => data as any,
      fromFirestore: (snap) => snap.data() as FirestoreNote,
    }),
    fs.where("ownerUid", "==", ownerUid),
    fs.limit(max)
  );
}

/**
 * Allocate a document id before the first autosave so every draft write is
 * idempotent. Uses the same 20-character alphabet the Firestore SDK's own
 * auto-ids use, so the ids are indistinguishable — but we do not need the
 * SDK (or its startup cost) just to mint one.
 */
export function createNoteDocumentId(): string {
  const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const bytes = new Uint8Array(20);
  crypto.getRandomValues(bytes);
  let id = "";
  for (let i = 0; i < bytes.length; i++) id += chars[bytes[i] % chars.length];
  return id;
}

export async function writeNoteToFirestore(note: Note, ownerUid: string) {
  const fb = await getFirebase();
  if (!fb) return;
  const firestoreId = note.firestoreId ?? createNoteDocumentId();
  const payload = {
    ownerUid,
    id: note.id,
    title: note.title,
    body: note.body,
    accentIdx: note.accentIdx,
    pinned: note.pinned,
    archived: note.archived,
    trashed: note.trashed,
    updatedAt: fb.fs.serverTimestamp(),
    createdAt: note.createdAt ?? new Date(),
    reminder: note.reminder ? note.reminder : null,
  };
  // setDoc supports both the first draft and all later autosaves. The stable
  // preallocated id prevents a new document being created on every debounce.
  await fb.fs.setDoc(fb.fs.doc(fb.db, NOTES_COLLECTION, firestoreId), payload, { merge: true });
  return firestoreId;
}

export async function deleteNoteFromFirestore(note: Note) {
  if (!note.firestoreId) return;
  const fb = await getFirebase();
  if (!fb) return;
  await fb.fs.deleteDoc(fb.fs.doc(fb.db, NOTES_COLLECTION, note.firestoreId));
}

export async function patchNoteInFirestore(note: Note, patch: Partial<Note>, ownerUid: string) {
  if (!note.firestoreId) return writeNoteToFirestore({ ...note, ...patch }, ownerUid);
  const fb = await getFirebase();
  if (!fb) return;
  const payload: any = { updatedAt: fb.fs.serverTimestamp() };
  if (patch.title !== undefined) payload.title = patch.title;
  if (patch.body !== undefined) payload.body = patch.body;
  if (patch.accentIdx !== undefined) payload.accentIdx = patch.accentIdx;
  if (patch.pinned !== undefined) payload.pinned = patch.pinned;
  if (patch.archived !== undefined) payload.archived = patch.archived;
  if (patch.trashed !== undefined) payload.trashed = patch.trashed;
  if (patch.reminder !== undefined) payload.reminder = patch.reminder ?? null;
  await fb.fs.updateDoc(fb.fs.doc(fb.db, NOTES_COLLECTION, note.firestoreId), payload);
  return note.firestoreId;
}
