import { useState } from 'react'
import { supabase } from '../lib/supabase'
import { email as emailSchema } from '../lib/schemas'
import { Field } from '../components/ui'

/// Administrators sign in with an emailed code, the same mechanism the three
/// apps use. No password is ever set by anyone but the account holder, so an
/// administrator who creates another administrator never learns their password
/// — there isn't one to learn.
export default function Login() {
  const [step, setStep] = useState<'email' | 'code'>('email')
  const [address, setAddress] = useState('')
  const [code, setCode] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function sendCode(e: React.FormEvent) {
    e.preventDefault()
    const parsed = emailSchema.safeParse(address)
    if (!parsed.success) return setError(parsed.error.issues[0].message)
    setBusy(true); setError(null)
    // shouldCreateUser: false — the admin_users row must already exist. An
    // address nobody invited must not be able to mint itself an account.
    const { error } = await supabase.auth.signInWithOtp({
      email: parsed.data,
      options: { shouldCreateUser: false },
    })
    setBusy(false)
    if (error) return setError(error.message)
    setStep('code')
  }

  async function verify(e: React.FormEvent) {
    e.preventDefault()
    if (code.trim().length !== 6) return setError('Enter all 6 digits')
    setBusy(true); setError(null)
    const { error } = await supabase.auth.verifyOtp({
      email: address.trim().toLowerCase(), token: code.trim(), type: 'email',
    })
    setBusy(false)
    if (error) return setError(error.message)
    window.location.href = '/'
  }

  return (
    <div className="min-h-screen grid place-items-center px-4">
      <div className="card p-6 w-full max-w-sm">
        <div className="mb-5">
          <h1 className="text-lg font-semibold">Setu Admin</h1>
          <p className="text-soft mt-0.5">
            {step === 'email'
              ? 'Sign in with your work email address.'
              : `We sent a 6 digit code to ${address}.`}
          </p>
        </div>

        {error && (
          <div className="card border-danger/40 bg-danger-soft p-2.5 text-danger mb-3">{error}</div>
        )}

        {step === 'email' ? (
          <form onSubmit={sendCode} className="space-y-3">
            <Field label="Email address">
              <input
                className="input" type="email" autoFocus autoComplete="username"
                value={address} onChange={(e) => setAddress(e.target.value)}
                placeholder="name@karnataka.gov.in"
              />
            </Field>
            <button className="btn-primary w-full justify-center" disabled={busy}>
              {busy ? 'Sending…' : 'Send code'}
            </button>
          </form>
        ) : (
          <form onSubmit={verify} className="space-y-3">
            <Field label="6 digit code">
              <input
                className="input font-mono tracking-[0.3em] text-center" autoFocus
                inputMode="numeric" maxLength={6} value={code}
                onChange={(e) => setCode(e.target.value.replace(/\D/g, ''))}
              />
            </Field>
            <button className="btn-primary w-full justify-center" disabled={busy}>
              {busy ? 'Checking…' : 'Verify'}
            </button>
            <button type="button" className="btn-ghost w-full justify-center"
              onClick={() => { setStep('email'); setCode(''); setError(null) }}>
              Use a different address
            </button>
          </form>
        )}
      </div>
    </div>
  )
}
