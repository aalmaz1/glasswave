import {
  createUserWithEmailAndPassword,
  deleteUser,
  EmailAuthProvider,
  reauthenticateWithCredential,
  sendEmailVerification,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signOut,
  updateProfile,
} from "firebase/auth";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  where,
  writeBatch,
} from "firebase/firestore";
import type { Translation } from "../../i18n";
import { auth, db, hasFirebaseConfig } from "../../firebase";
import { DEFAULT_THEME, NOTES_COLLECTION, USERS_COLLECTION, type UserProfile } from "../model";
import type { ThemeId } from "../theme";

export async function getUserProfile(uid: string): Promise<UserProfile | null> {
  if (!db) return null;
  const snap = await getDoc(doc(db, USERS_COLLECTION, uid));
  return snap.exists() ? (snap.data() as UserProfile) : null;
}

export async function setUserTheme(uid: string, themeId: ThemeId) {
  if (db) await setDoc(doc(db, USERS_COLLECTION, uid), { themeId }, { merge: true });
}

async function createUserProfile(uid: string, email: string, name: string) {
  if (!db) return;
  await setDoc(doc(db, USERS_COLLECTION, uid), {
    email,
    name,
    themeId: DEFAULT_THEME,
    createdAt: serverTimestamp(),
  });
}

function authError(error: unknown, t: Translation): string {
  const code = (error as { code?: string })?.code;
  switch (code) {
    case "auth/invalid-credential":
    case "auth/wrong-password":
    case "auth/user-not-found":
      return t.authErrBadCreds;
    case "auth/email-already-in-use":
      return t.authErrEmailUsed;
    case "auth/invalid-email":
      return t.authErrInvalidEmail;
    case "auth/weak-password":
      return t.authErrWeakPw;
    case "auth/operation-not-allowed":
    case "auth/admin-restricted-operation":
      return t.authErrNotAllowed;
    case "auth/unauthorized-domain":
      return t.authErrUnauthorizedDomain;
    case "auth/network-request-failed":
      return t.authErrNetwork;
    case "auth/invalid-api-key":
    case "auth/api-key-not-valid.-please-pass-a-valid-api-key.":
    case "auth/app-not-authorized":
    case "auth/configuration-not-found":
      return t.authErrInvalidApiKey;
    case "auth/too-many-requests":
      return t.authErrTooMany;
    default:
      return t.authErrGeneric;
  }
}

export async function registerAccount(
  email: string,
  name: string,
  password: string,
  t: Translation
): Promise<string | null> {
  if (!hasFirebaseConfig || !auth) return t.authErrNotConfigured;
  email = email.trim().toLowerCase();
  if (!email.includes("@")) return t.authErrInvalidEmail;
  if (name.trim().length < 2) return t.authErrNameShort;
  if (password.length < 6) return t.authErrPwShort;
  try {
    const credential = await createUserWithEmailAndPassword(auth, email, password);
    await updateProfile(credential.user, { displayName: name.trim() });
    await createUserProfile(credential.user.uid, email, name.trim());
    void sendEmailVerification(credential.user).catch(() => {});
    return null;
  } catch (error) {
    return authError(error, t);
  }
}

export async function resetAccountPassword(email: string, t: Translation): Promise<string | null> {
  if (!hasFirebaseConfig || !auth) return t.authErrNotConfigured;
  email = email.trim().toLowerCase();
  if (!email.includes("@")) return t.authErrInvalidEmail;
  try {
    await sendPasswordResetEmail(auth, email);
    return null;
  } catch {
    return t.authErrResetGeneric;
  }
}

export async function loginAccount(
  email: string,
  password: string,
  t: Translation
): Promise<string | null> {
  if (!hasFirebaseConfig || !auth) return t.authErrNotConfigured;
  email = email.trim().toLowerCase();
  if (!email || !password) return t.authErrEmailPassRequired;
  try {
    await signInWithEmailAndPassword(auth, email, password);
    return null;
  } catch (error) {
    return authError(error, t);
  }
}

export async function logoutAccount() {
  if (auth) await signOut(auth);
}

export async function deleteCurrentAccount(
  password: string,
  t: Translation
): Promise<string | null> {
  if (!hasFirebaseConfig || !auth || !db) return t.authErrNotAllowed;
  const user = auth.currentUser;
  if (!user?.email) return t.authErrNotAllowed;
  if (!password) return t.authErrPasswordRequired;
  try {
    await reauthenticateWithCredential(user, EmailAuthProvider.credential(user.email, password));
    const notes = await getDocs(
      query(collection(db, NOTES_COLLECTION), where("ownerUid", "==", user.uid))
    );
    for (let start = 0; start < notes.docs.length; start += 450) {
      const batch = writeBatch(db);
      notes.docs.slice(start, start + 450).forEach((note) => batch.delete(note.ref));
      await batch.commit();
    }
    await deleteDoc(doc(db, USERS_COLLECTION, user.uid));
    await deleteUser(user);
    return null;
  } catch (error) {
    switch ((error as { code?: string })?.code) {
      case "auth/invalid-credential":
      case "auth/wrong-password":
        return t.authErrDeleteBadPw;
      case "auth/requires-recent-login":
        return t.authErrReauth;
      case "permission-denied":
      case "firestore/permission-denied":
        return t.authErrDeletePerm;
      default:
        return t.authErrDeleteGeneric;
    }
  }
}
