import js from "@eslint/js";
import tseslint from "typescript-eslint";
import reactHooks from "eslint-plugin-react-hooks";
import reactRefresh from "eslint-plugin-react-refresh";
import { defineConfig, globalIgnores } from "eslint/config";

/**
 * ESLint flat config.
 *
 * Kept deliberately low-noise: the codebase predates this config, so rules
 * that would flag existing style (e.g. `any`, non-null assertions) are relaxed
 * to warnings or disabled. The goal is to catch real bugs without a
 * whitespace-style churn. Run `npm run lint` in CI.
 */
export default defineConfig([
  globalIgnores(["dist", "node_modules", "coverage", "android-capacitor", "public", "*.config.js"]),

  js.configs.recommended,

  ...tseslint.configs.recommended,

  {
    // Build-time helpers run in Node, not in the browser.
    files: ["scripts/**/*.{js,mjs,cjs}"],
    languageOptions: {
      globals: {
        process: "readonly",
        console: "readonly",
        Buffer: "readonly",
        __dirname: "readonly",
      },
    },
  },

  {
    files: ["**/*.{ts,tsx}"],
    plugins: {
      "react-hooks": reactHooks,
      "react-refresh": reactRefresh,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      "react-refresh/only-export-components": "off",

      // Relaxations for the existing codebase.
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-non-null-assertion": "off",
      "@typescript-eslint/no-empty-object-type": "off",
      "@typescript-eslint/no-unused-vars": [
        "warn",
        { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
      ],
      "@typescript-eslint/ban-ts-comment": "off",
      "no-useless-catch": "off",
      "no-empty": ["warn", { allowEmptyCatch: true }],
    },
  },
]);
