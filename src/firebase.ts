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
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY ?? "AIzaSyCmRLbOBFhshcFmKmmmCCRUsQVwQ2iFCW4",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN ?? "glasswave-4f5da.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID ?? "glasswave-4f5da",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET ?? "glasswave-4f5da.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID ?? "62843359036",
  appId: import.meta.env.VITE_FIREBASE_APP_ID ?? "1:62843359036:web:82aa269d0c9bc0e78d9839",
};

const app = initializeApp(firebaseConfig);

const db = initializeFirestore(app, {
  localCache: persistentLocalCache({
    tabManager: persistentMultipleTabManager(),
  }),
});

const auth = getAuth(app);

export { app, db, auth };
