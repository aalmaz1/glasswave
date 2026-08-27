import type { FirebaseApp } from "firebase/app";
import type { Auth } from "firebase/auth";
import type { Firestore } from "firebase/firestore";
import { isCompleteFirebaseConfig, resolveFirebaseConfig } from "./firebaseConfig";

/**
 * Firebase configuration.
 *
 * Defaults to the official `glasswave-4f5da` web app (Email/Password is the
 * sign-in method this client uses). `VITE_FIREBASE_*` overrides are applied
 * when set — pointing them at another project is the usual reason a working
 * Email/Password toggle still yields `auth/operation-not-allowed`.
 *
 * The Auth emulator is NEVER attached unless `VITE_FIREBASE_AUTH_EMULATOR`
 * is an explicit URL. A leftover emulator hook talks to a local project
 * where Email/Password is typically disabled.
 */

const firebaseConfig = resolveFirebaseConfig({
  VITE_FIREBASE_API_KEY: import.meta.env.VITE_FIREBASE_API_KEY,
  VITE_FIREBASE_AUTH_DOMAIN: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  VITE_FIREBASE_PROJECT_ID: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  VITE_FIREBASE_STORAGE_BUCKET: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  VITE_FIREBASE_MESSAGING_SENDER_ID: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  VITE_FIREBASE_APP_ID: import.meta.env.VITE_FIREBASE_APP_ID,
});

/**
 * Synchronous check so the UI can render the "not configured" states without
 * loading the Firebase SDK at all.
 */
export const hasFirebaseConfig = isCompleteFirebaseConfig(firebaseConfig);

type FirestoreModule = typeof import("firebase/firestore");
type AuthModule = typeof import("firebase/auth");

/**
 * Loaded Firebase handles, plus the SDK functions the app uses (re-exported
 * from ./firebase.impl as a plain object so callers never statically import
 * the SDK — a static import would drag ~790 KB of vendor code back into the
 * startup chunk). `./firebase.impl` uses plain static named imports, which
 * keeps Rollup's tree-shaking intact; only this file is the dynamic boundary.
 */
export interface FirebaseServices {
  app: FirebaseApp;
  db: Firestore;
  auth: Auth;
  fs: Pick<
    FirestoreModule,
    | "collection"
    | "deleteDoc"
    | "doc"
    | "getDoc"
    | "getDocs"
    | "limit"
    | "onSnapshot"
    | "query"
    | "serverTimestamp"
    | "setDoc"
    | "updateDoc"
    | "where"
    | "writeBatch"
  >;
  fauth: Pick<
    AuthModule,
    | "createUserWithEmailAndPassword"
    | "deleteUser"
    | "EmailAuthProvider"
    | "onAuthStateChanged"
    | "reauthenticateWithCredential"
    | "sendEmailVerification"
    | "sendPasswordResetEmail"
    | "signInWithEmailAndPassword"
    | "signOut"
    | "updateProfile"
  >;
}

let cached: Promise<FirebaseServices | null> | null = null;

/**
 * Load and initialize Firebase on first use.
 *
 * The SDK is intentionally behind a dynamic boundary: guests live entirely in
 * localStorage and never need sign-in or sync, so they should not download,
 * parse, and evaluate the Firebase chunks at startup. Signed-in flows call
 * this before touching Auth or Firestore; concurrent callers share one
 * initialization promise. A failed load resets the cache so the next call
 * retries instead of latching onto a rejected promise.
 */
export function getFirebase(): Promise<FirebaseServices | null> {
  if (!hasFirebaseConfig) return Promise.resolve(null);
  if (!cached) {
    cached = import("./firebase.impl")
      .then((impl) => impl.initFirebase(firebaseConfig))
      .catch((error) => {
        cached = null;
        throw error;
      });
  }
  return cached;
}
