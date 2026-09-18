import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!url || !anonKey) {
  throw new Error(
    'VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY must be set. Copy .env.example to .env.local.',
  )
}

/// The portal authenticates as the signed-in administrator and nothing else.
/// There is no service-role client in this bundle and there must never be one:
/// the service role bypasses RLS entirely, and anything shipped to a browser is
/// readable by whoever opens it. Key generation, invites and the partner API
/// live in the Node service for exactly this reason.
export const supabase = createClient(url, anonKey, {
  auth: { persistSession: true, autoRefreshToken: true },
})
