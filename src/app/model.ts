import type { ThemeId } from "./theme";

/** Domain model used by guest storage, Firestore and presentation layers. */
export type Note = {
  firestoreId?: string;
  id: number;
  title: string;
  body: string;
  updatedAt: Date;
  createdAt: Date;
  accentIdx: number;
  pinned: boolean;
  archived: boolean;
  trashed: boolean;
  reminder: Date | null;
};

/** Serialized shape stored in the private Firestore notes collection. */
export type FirestoreNote = {
  ownerUid: string;
  id: number;
  title: string;
  body: string;
  accentIdx: number;
  pinned: boolean;
  archived: boolean;
  trashed: boolean;
  updatedAt: unknown;
  createdAt?: unknown;
  reminder: unknown;
};

export type Screen = "dashboard" | "settings";
export type Tab = "all" | "archive" | "trash";
export type SortOrder = "default" | "created" | "updated";
export type AuthUser = { uid: string; email: string; name: string };
export type UserProfile = { name: string; themeId?: ThemeId };

export const USERS_COLLECTION = "users";
export const NOTES_COLLECTION = "notes";
export const NOTES_PAGE_SIZE = 100;
export const DEFAULT_THEME: ThemeId = "sunset";
export const LS_GUEST_NOTES = "glasswave_guest_notes_v1";
export const LS_GUEST_DIRTY = "glasswave_guest_notes_dirty";
