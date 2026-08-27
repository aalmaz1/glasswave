import { initializeApp } from "firebase/app";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  initializeFirestore,
  limit,
  onSnapshot,
  persistentLocalCache,
  persistentMultipleTabManager,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from "firebase/firestore";
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  deleteUser,
  EmailAuthProvider,
  getAuth,
  onAuthStateChanged,
  reauthenticateWithCredential,
  sendEmailVerification,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signOut,
  updateProfile,
} from "firebase/auth";
import type { FirebaseServices } from "./firebase";
import type { FirebaseWebConfig } from "./firebaseConfig";

/**
 * Implementation behind the dynamic boundary in ./firebase.ts. Everything
 * here statically imports the Firebase SDK exactly the way the app always did,
 * so the vendor chunk is tree-shaken to the same size as before — it is just
 * no longer part of the startup path. This module must ONLY be imported
 * dynamically, via getFirebase().
 */
export function initFirebase(config: FirebaseWebConfig): FirebaseServices {
  const app = initializeApp(config);
  const db = initializeFirestore(app, {
    localCache: persistentLocalCache({
      tabManager: persistentMultipleTabManager(),
    }),
  });
  const auth = getAuth(app);

  const emulatorUrl = import.meta.env.VITE_FIREBASE_AUTH_EMULATOR?.trim();
  if (emulatorUrl) {
    connectAuthEmulator(auth, emulatorUrl, { disableWarnings: true });
  }

  return {
    app,
    db,
    auth,
    fs: {
      collection,
      deleteDoc,
      doc,
      getDoc,
      getDocs,
      limit,
      onSnapshot,
      query,
      serverTimestamp,
      setDoc,
      updateDoc,
      where,
      writeBatch,
    },
    fauth: {
      createUserWithEmailAndPassword,
      deleteUser,
      EmailAuthProvider,
      onAuthStateChanged,
      reauthenticateWithCredential,
      sendEmailVerification,
      sendPasswordResetEmail,
      signInWithEmailAndPassword,
      signOut,
      updateProfile,
    },
  };
}
