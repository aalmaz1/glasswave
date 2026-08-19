import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  // Relative asset URLs so the same build works on the web and inside Capacitor.
  base: "./",
  plugins: [
    react(),
    tailwindcss(),
  ],
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
