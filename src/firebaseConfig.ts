/**
 * Official GlassWave Firebase project (`glasswave-4f5da`).
 *
 * Firebase web API keys are public by design — they ship in the client bundle
 * and are restricted by Auth providers, authorized domains, and App Check, not
 * by secrecy. This IS the project's own backend (the same project as
 * `android/app/google-services.json`), not a leftover demo.
 *
 * `VITE_FIREBASE_*` env vars override these defaults so forks/staging can
 * point at another project. A stale or unrelated config is the usual cause of
 * `auth/operation-not-allowed` even when Email/Password is enabled on
 * glasswave-4f5da.
 */
export const OFFICIAL_FIREBASE_CONFIG = {
  apiKey: "AIzaSyCmRLbOBFhshcFmKmmmCCRUsQVwQ2iFCW4",
  authDomain: "glasswave-4f5da.firebaseapp.com",
  projectId: "glasswave-4f5da",
  storageBucket: "glasswave-4f5da.firebasestorage.app",
  messagingSenderId: "62843359036",
  appId: "1:62843359036:web:82aa269d0c9bc0e78d9839",
} as const;

export type FirebaseWebConfig = {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
};

export type FirebaseEnv = Partial<{
  VITE_FIREBASE_API_KEY: string;
  VITE_FIREBASE_AUTH_DOMAIN: string;
  VITE_FIREBASE_PROJECT_ID: string;
  VITE_FIREBASE_STORAGE_BUCKET: string;
  VITE_FIREBASE_MESSAGING_SENDER_ID: string;
  VITE_FIREBASE_APP_ID: string;
}>;

function pick(value: string | undefined, fallback: string): string {
  const trimmed = value?.trim();
  return trimmed ? trimmed : fallback;
}

/** Merge env overrides on top of the official glasswave-4f5da web config. */
export function resolveFirebaseConfig(env: FirebaseEnv = {}): FirebaseWebConfig {
  return {
    apiKey: pick(env.VITE_FIREBASE_API_KEY, OFFICIAL_FIREBASE_CONFIG.apiKey),
    authDomain: pick(env.VITE_FIREBASE_AUTH_DOMAIN, OFFICIAL_FIREBASE_CONFIG.authDomain),
    projectId: pick(env.VITE_FIREBASE_PROJECT_ID, OFFICIAL_FIREBASE_CONFIG.projectId),
    storageBucket: pick(env.VITE_FIREBASE_STORAGE_BUCKET, OFFICIAL_FIREBASE_CONFIG.storageBucket),
    messagingSenderId: pick(
      env.VITE_FIREBASE_MESSAGING_SENDER_ID,
      OFFICIAL_FIREBASE_CONFIG.messagingSenderId
    ),
    appId: pick(env.VITE_FIREBASE_APP_ID, OFFICIAL_FIREBASE_CONFIG.appId),
  };
}

export function isCompleteFirebaseConfig(config: FirebaseWebConfig): boolean {
  return (
    Boolean(config.apiKey) &&
    Boolean(config.authDomain) &&
    Boolean(config.projectId) &&
    Boolean(config.storageBucket) &&
    Boolean(config.messagingSenderId) &&
    Boolean(config.appId)
  );
}
