import {
  collection,
  deleteDoc,
  doc,
  limit,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  type Query,
} from "firebase/firestore";
import { db } from "../../firebase";
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

export function buildNotesQuery(ownerUid: string, max: number): Query<FirestoreNote> | null {
  if (!db) return null;
  // A `where(ownerUid) + orderBy(updatedAt)` query requires a composite
  // Firestore index. Loading the list then fails completely until that index
  // has been created in every Firebase project. Keep this query on Firestore's
  // built-in single-field index and sort the bounded result in the client.
  //
  // Pagination is done by growing the `limit` (Firestore returns docs in stable
  // doc-id order for an unordered query, so a larger limit is a strict superset
  // of a smaller one). This avoids the 500-note ceiling without a composite
  // index and keeps a single live `onSnapshot` subscription.
  return query(
    collection(db, NOTES_COLLECTION).withConverter<FirestoreNote>({
      toFirestore: (data) => data as any,
      fromFirestore: (snap) => snap.data() as FirestoreNote,
    }),
    where("ownerUid", "==", ownerUid),
    limit(max)
  );
}

/** Allocate a document id before the first autosave so every draft write is idempotent. */
export function createNoteDocumentId(): string | undefined {
  return db ? doc(collection(db, NOTES_COLLECTION)).id : undefined;
}

export async function writeNoteToFirestore(note: Note, ownerUid: string) {
  if (!db) return;
  const firestoreId = note.firestoreId ?? createNoteDocumentId();
  if (!firestoreId) return;
  const payload = {
    ownerUid,
    id: note.id,
    title: note.title,
    body: note.body,
    accentIdx: note.accentIdx,
    pinned: note.pinned,
    archived: note.archived,
    trashed: note.trashed,
    updatedAt: serverTimestamp(),
    createdAt: note.createdAt ?? new Date(),
    reminder: note.reminder ? note.reminder : null,
  };
  // setDoc supports both the first draft and all later autosaves. The stable
  // preallocated id prevents a new document being created on every debounce.
  await setDoc(doc(db, NOTES_COLLECTION, firestoreId), payload, { merge: true });
  return firestoreId;
}

export async function deleteNoteFromFirestore(note: Note) {
  if (!db || !note.firestoreId) return;
  await deleteDoc(doc(db, NOTES_COLLECTION, note.firestoreId));
}

export async function patchNoteInFirestore(note: Note, patch: Partial<Note>, ownerUid: string) {
  if (!db) return;
  if (!note.firestoreId) return writeNoteToFirestore({ ...note, ...patch }, ownerUid);
  const payload: any = { updatedAt: serverTimestamp() };
  if (patch.title !== undefined) payload.title = patch.title;
  if (patch.body !== undefined) payload.body = patch.body;
  if (patch.accentIdx !== undefined) payload.accentIdx = patch.accentIdx;
  if (patch.pinned !== undefined) payload.pinned = patch.pinned;
  if (patch.archived !== undefined) payload.archived = patch.archived;
  if (patch.trashed !== undefined) payload.trashed = patch.trashed;
  if (patch.reminder !== undefined) payload.reminder = patch.reminder ?? null;
  await updateDoc(doc(db, NOTES_COLLECTION, note.firestoreId), payload);
  return note.firestoreId;
}
