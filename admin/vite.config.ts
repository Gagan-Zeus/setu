import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// The portal is served from the domain root on Vercel or Render, and from
// /setu/ on GitHub Pages. Rather than hardcode either, the base comes from the
// environment and React Router reads it back through import.meta.env.BASE_URL,
// so one build config covers both and neither has a special case.
export default defineConfig({
  base: process.env.VITE_BASE ?? '/',
  plugins: [react()],
  server: { port: 5174 },
  build: { outDir: 'dist', sourcemap: false },
})
