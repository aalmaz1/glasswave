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
})
