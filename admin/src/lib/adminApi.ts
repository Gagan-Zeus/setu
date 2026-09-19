import { supabase } from './supabase'

/// The operations that cannot run in a browser.
///
/// Creating a login and minting a partner API key both need the service-role
/// key, which bypasses RLS and must never be shipped to a client. They run in
/// Edge Functions that verify the caller's own session before touching
/// anything: `admin-api` for staff, `partner-api` for keys.
///
/// The host is derived from the Supabase URL rather than configured
/// separately. A second environment variable is a second thing to get wrong,
/// and it is always the same host — which is exactly how the key-issuing
/// screen ended up pointing at a `VITE_ADMIN_API` service that was never
/// built, and reporting its own misconfiguration as the reason no key could
/// be issued.
const FUNCTIONS = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1`

/// POST to `path` on the named Edge Function, as the signed-in administrator.
export async function edgePost<T>(
  fn: 'admin-api' | 'partner-api',
  path: string,
  body: unknown,
): Promise<T> {
  const { data } = await supabase.auth.getSession()
  const token = data.session?.access_token
  if (!token) throw new Error('Your session has expired. Sign in again.')

  const res = await fetch(`${FUNCTIONS}/${fn}${path}`, {
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
    // The functions return a sentence meant to be read by the person who hit
    // the problem. Surfacing it beats inventing a generic one.
    throw new Error(payload.message ?? `Request failed (HTTP ${res.status})`)
  }
  return payload as T
}

export const adminPost = <T>(path: string, body: unknown) =>
  edgePost<T>('admin-api', path, body)
