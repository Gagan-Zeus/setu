import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

/// Null when both are present. Vite inlines these at BUILD time, so a deploy
/// whose environment variables were missing or misnamed produces a bundle with
/// nothing here — and the failure surfaces in the browser, far from the build
/// that caused it.
///
/// This used to `throw` at module load. That is loud in a terminal and silent
/// in production: the throw runs before React mounts, so the page renders
/// white with the reason only in the console. Whoever opens it sees nothing at
/// all. The error is carried instead, and App renders it.
export const configError: string | null =
  !url && !anonKey
    ? 'Neither VITE_SUPABASE_URL nor VITE_SUPABASE_ANON_KEY was set when this was built.'
    : !url
      ? 'VITE_SUPABASE_URL was not set when this was built.'
      : !anonKey
        ? 'VITE_SUPABASE_ANON_KEY was not set when this was built.'
        : null

/// The portal authenticates as the signed-in administrator and nothing else.
/// There is no service-role client in this bundle and there must never be one:
/// the service role bypasses RLS entirely, and anything shipped to a browser is
/// readable by whoever opens it. Key generation, invites and the partner API
/// live in the Node service for exactly that reason.
///
/// The placeholders keep createClient from throwing when the config is missing;
/// nothing reaches it, because App renders the error page instead.
export const supabase = createClient(
  url || 'https://unconfigured.supabase.co',
  anonKey || 'unconfigured',
  { auth: { persistSession: true, autoRefreshToken: true } },
)
