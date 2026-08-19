import { initializeApp } from "firebase/app";
import {
  initializeFirestore,
  persistentLocalCache,
  persistentMultipleTabManager,
  type Firestore,
} from "firebase/firestore";
import { connectAuthEmulator, getAuth, type Auth } from "firebase/auth";
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

export const hasFirebaseConfig = isCompleteFirebaseConfig(firebaseConfig);

let app: ReturnType<typeof initializeApp> | null = null;
let db: Firestore | null = null;
let auth: Auth | null = null;

if (hasFirebaseConfig) {
  app = initializeApp(firebaseConfig);
  db = initializeFirestore(app, {
    localCache: persistentLocalCache({
      tabManager: persistentMultipleTabManager(),
    }),
  });
  auth = getAuth(app);

  const emulatorUrl = import.meta.env.VITE_FIREBASE_AUTH_EMULATOR?.trim();
  if (emulatorUrl) {
    connectAuthEmulator(auth, emulatorUrl, { disableWarnings: true });
  }
}

export { app, db, auth };
