/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_SUPABASE_URL: string
  readonly VITE_SUPABASE_ANON_KEY: string
  /// Where the Node service lives. Absent in a static-only deploy, in which
  /// case the screens that need it say so rather than failing silently.
  readonly VITE_ADMIN_API?: string
}
interface ImportMeta { readonly env: ImportMetaEnv }
