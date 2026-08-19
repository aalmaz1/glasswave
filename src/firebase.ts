import { initializeApp } from "firebase/app";
import {
  initializeFirestore,
  persistentLocalCache,
  persistentMultipleTabManager,
} from "firebase/firestore";
import { getAuth } from "firebase/auth";

/**
 * Firestore initialization with persistent local cache.
 *
 * `initializeFirestore()` with `persistentLocalCache()` switches Firestore from
 * in-memory cache to IndexedDB-backed cache. This makes query results survive
 * page reloads and browser restarts, so repeated reads can be served from the
 * local cache instead of triggering paid server reads.
 */

/**
 * Firebase configuration is read exclusively from build-time environment
 * variables (see `.env.example`). No project keys are committed to the repo —
 * if the app ran without a configured project it would silently send traffic to
 * someone else's backend, so we fail fast with a clear message instead.
 */
const REQUIRED_ENV_KEYS = [
  "VITE_FIREBASE_API_KEY",
  "VITE_FIREBASE_AUTH_DOMAIN",
  "VITE_FIREBASE_PROJECT_ID",
  "VITE_FIREBASE_STORAGE_BUCKET",
  "VITE_FIREBASE_MESSAGING_SENDER_ID",
  "VITE_FIREBASE_APP_ID",
] as const;

const missingKeys = REQUIRED_ENV_KEYS.filter((key) => !import.meta.env[key]);
if (missingKeys.length > 0) {
  throw new Error(
    `GlassWave is missing Firebase configuration. ` +
      `Create a \`.env\` file (see \`.env.example\`) with: ${missingKeys.join(", ")}.`
  );
}

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY as string,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN as string,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID as string,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET as string,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID as string,
  appId: import.meta.env.VITE_FIREBASE_APP_ID as string,
};

const app = initializeApp(firebaseConfig);

const db = initializeFirestore(app, {
  localCache: persistentLocalCache({
    tabManager: persistentMultipleTabManager(),
  }),
});

const auth = getAuth(app);

export { app, db, auth };
