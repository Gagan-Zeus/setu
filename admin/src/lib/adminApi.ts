import { supabase } from './supabase'

/// The operations that cannot run in a browser.
///
/// Creating a login needs the service-role key, which bypasses RLS and must
/// never be shipped to a client. It runs in the admin-api Edge Function, which
/// verifies the caller's own session before touching anything.
///
/// The URL is derived from the Supabase URL rather than configured separately.
/// A second environment variable is a second thing to get wrong, and it is
/// always the same host.
const BASE = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/admin-api`

export async function adminPost<T>(path: string, body: unknown): Promise<T> {
  const { data } = await supabase.auth.getSession()
  const token = data.session?.access_token
  if (!token) throw new Error('Your session has expired. Sign in again.')

  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      apikey: import.meta.env.VITE_SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(body),
  })

  const payload = await res.json().catch(() => ({}))
  if (!res.ok) {
    // The function returns a sentence meant to be read by the person who hit
    // the problem. Surfacing it beats inventing a generic one.
    throw new Error(payload.message ?? `Registration failed (HTTP ${res.status})`)
  }
  return payload as T
}
