import { describe, it, expect } from "vitest";
import {
  OFFICIAL_FIREBASE_CONFIG,
  isCompleteFirebaseConfig,
  resolveFirebaseConfig,
} from "./firebaseConfig";

describe("resolveFirebaseConfig", () => {
  it("uses the official glasswave-4f5da project when env is empty", () => {
    expect(resolveFirebaseConfig({})).toEqual(OFFICIAL_FIREBASE_CONFIG);
    expect(OFFICIAL_FIREBASE_CONFIG.projectId).toBe("glasswave-4f5da");
    expect(OFFICIAL_FIREBASE_CONFIG.authDomain).toBe("glasswave-4f5da.firebaseapp.com");
    expect(OFFICIAL_FIREBASE_CONFIG.appId).toMatch(/^1:62843359036:web:/);
  });

  it("ignores blank env placeholders so a copied .env.example cannot hijack the project", () => {
    expect(
      resolveFirebaseConfig({
        VITE_FIREBASE_API_KEY: "   ",
        VITE_FIREBASE_PROJECT_ID: "",
        VITE_FIREBASE_APP_ID: undefined,
      })
    ).toEqual(OFFICIAL_FIREBASE_CONFIG);
  });

  it("lets a complete env override every field", () => {
    const override = resolveFirebaseConfig({
      VITE_FIREBASE_API_KEY: "test-key",
      VITE_FIREBASE_AUTH_DOMAIN: "other.firebaseapp.com",
      VITE_FIREBASE_PROJECT_ID: "other-project",
      VITE_FIREBASE_STORAGE_BUCKET: "other.appspot.com",
      VITE_FIREBASE_MESSAGING_SENDER_ID: "1",
      VITE_FIREBASE_APP_ID: "1:1:web:abc",
    });
    expect(override).toEqual({
      apiKey: "test-key",
      authDomain: "other.firebaseapp.com",
      projectId: "other-project",
      storageBucket: "other.appspot.com",
      messagingSenderId: "1",
      appId: "1:1:web:abc",
    });
  });

  it("treats the official config as complete", () => {
    expect(isCompleteFirebaseConfig(OFFICIAL_FIREBASE_CONFIG)).toBe(true);
  });
});
