import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  // Relative asset URLs so the same build works on the web and inside Capacitor.
  base: "./",
  plugins: [
    react(),
    tailwindcss(),
    // Progressive Web App: offline shell + installability on Android/desktop
    // (and "Add to Home Screen" on iOS). The service worker is registered from
    // src/main.tsx so it can be skipped inside the Capacitor native shell,
    // which already ships the same assets locally.
    VitePWA({
      registerType: "autoUpdate",
      injectRegister: null,
      // The manifest is generated from here instead of public/, so there is a
      // single source of truth.
      manifest: {
        id: "./",
        name: "GlassWave — Notes",
        short_name: "GlassWave",
        description:
          "Modern cross-platform note-taking app with glassmorphism design. Create, organize, and sync notes across devices.",
        lang: "ru",
        start_url: ".",
        scope: ".",
        display: "standalone",
        orientation: "portrait",
        theme_color: "#0b0b1a",
        background_color: "#130500",
        icons: [
          { src: "icons/icon-192.png", sizes: "192x192", type: "image/png", purpose: "any" },
          { src: "icons/icon-512.png", sizes: "512x512", type: "image/png", purpose: "any" },
          { src: "icons/icon-512.png", sizes: "512x512", type: "image/png", purpose: "maskable" },
        ],
      },
      workbox: {
        // Precache the app shell, the icons and the reminder sound so a cold,
        // offline start still works and reminders still chime.
        globPatterns: ["**/*.{js,css,html,png,svg,ico,webmanifest,mp3}"],
        // Firebase's chunk is large; keep it precached anyway (the app is
        // useless without it) and just raise the size limit.
        maximumFileSizeToCacheInBytes: 3 * 1024 * 1024,
        navigateFallback: "index.html",
        cleanupOutdatedCaches: true,
        clientsClaim: true,
        skipWaiting: true,
        runtimeCaching: [
          {
            // Google Fonts stylesheet — revalidate in the background.
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: "StaleWhileRevalidate",
            options: { cacheName: "google-fonts-stylesheets" },
          },
          {
            // Font files are immutable — cache them for a year.
            urlPattern: /^https:\/\/fonts\.gstatic\.com\/.*/i,
            handler: "CacheFirst",
            options: {
              cacheName: "google-fonts-webfonts",
              expiration: { maxEntries: 20, maxAgeSeconds: 60 * 60 * 24 * 365 },
              cacheableResponse: { statuses: [0, 200] },
            },
          },
        ],
      },
    }),
  ],
  preview: {
    // Same reasoning as `server`: allow proxied preview hosts.
    host: true,
    allowedHosts: true,
  },
  server: {
    // Bind to all interfaces and accept any Host header so the app can be
    // previewed through proxied hosts (e.g. sandboxed/dev previews).
    host: true,
    allowedHosts: true,
  },
  build: {
    chunkSizeWarningLimit: 850,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes("node_modules/")) {
            if (id.includes("firebase/")) return "vendor-firebase";
            if (id.includes("@tiptap/") || id.includes("prosemirror-")) return "vendor-tiptap";
            if (id.includes("node_modules/react-dom/") || id.includes("node_modules/react/")) return "vendor-react";
          }
        },
      },
    },
  },
})
