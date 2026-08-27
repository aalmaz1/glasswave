import type { Translation } from "../../i18n";
import { getFirebase, hasFirebaseConfig } from "../../firebase";
import { DEFAULT_THEME, NOTES_COLLECTION, USERS_COLLECTION, type UserProfile } from "../model";
import type { ThemeId } from "../theme";

export async function getUserProfile(uid: string): Promise<UserProfile | null> {
  const fb = await getFirebase();
  if (!fb) return null;
  const snap = await fb.fs.getDoc(fb.fs.doc(fb.db, USERS_COLLECTION, uid));
  return snap.exists() ? (snap.data() as UserProfile) : null;
}

export async function setUserTheme(uid: string, themeId: ThemeId) {
  const fb = await getFirebase();
  if (fb) await fb.fs.setDoc(fb.fs.doc(fb.db, USERS_COLLECTION, uid), { themeId }, { merge: true });
}

async function createUserProfile(uid: string, email: string, name: string) {
  const fb = await getFirebase();
  if (!fb) return;
  await fb.fs.setDoc(fb.fs.doc(fb.db, USERS_COLLECTION, uid), {
    email,
    name,
    themeId: DEFAULT_THEME,
    createdAt: fb.fs.serverTimestamp(),
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
  if (!hasFirebaseConfig) return t.authErrNotConfigured;
  email = email.trim().toLowerCase();
  if (!email.includes("@")) return t.authErrInvalidEmail;
  if (name.trim().length < 2) return t.authErrNameShort;
  if (password.length < 6) return t.authErrPwShort;
  const fb = await getFirebase();
  if (!fb) return t.authErrNotConfigured;
  try {
    const credential = await fb.fauth.createUserWithEmailAndPassword(fb.auth, email, password);
    await fb.fauth.updateProfile(credential.user, { displayName: name.trim() });
    await createUserProfile(credential.user.uid, email, name.trim());
    void fb.fauth.sendEmailVerification(credential.user).catch(() => {});
    return null;
  } catch (error) {
    return authError(error, t);
  }
}

export async function resetAccountPassword(email: string, t: Translation): Promise<string | null> {
  if (!hasFirebaseConfig) return t.authErrNotConfigured;
  email = email.trim().toLowerCase();
  if (!email.includes("@")) return t.authErrInvalidEmail;
  const fb = await getFirebase();
  if (!fb) return t.authErrNotConfigured;
  try {
    await fb.fauth.sendPasswordResetEmail(fb.auth, email);
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
  if (!hasFirebaseConfig) return t.authErrNotConfigured;
  email = email.trim().toLowerCase();
  if (!email || !password) return t.authErrEmailPassRequired;
  const fb = await getFirebase();
  if (!fb) return t.authErrNotConfigured;
  try {
    await fb.fauth.signInWithEmailAndPassword(fb.auth, email, password);
    return null;
  } catch (error) {
    return authError(error, t);
  }
}

export async function logoutAccount() {
  const fb = await getFirebase();
  if (fb) await fb.fauth.signOut(fb.auth);
}

export async function deleteCurrentAccount(
  password: string,
  t: Translation
): Promise<string | null> {
  if (!hasFirebaseConfig) return t.authErrNotAllowed;
  const fb = await getFirebase();
  if (!fb) return t.authErrNotAllowed;
  const { auth, db, fs, fauth } = fb;
  const user = auth.currentUser;
  if (!user?.email) return t.authErrNotAllowed;
  if (!password) return t.authErrPasswordRequired;
  try {
    await fauth.reauthenticateWithCredential(
      user,
      fauth.EmailAuthProvider.credential(user.email, password)
    );
    const notes = await fs.getDocs(
      fs.query(fs.collection(db, NOTES_COLLECTION), fs.where("ownerUid", "==", user.uid))
    );
    for (let start = 0; start < notes.docs.length; start += 450) {
      const batch = fs.writeBatch(db);
      notes.docs.slice(start, start + 450).forEach((note) => batch.delete(note.ref));
      await batch.commit();
    }
    await fs.deleteDoc(fs.doc(db, USERS_COLLECTION, user.uid));
    await fauth.deleteUser(user);
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
