import { useState } from 'react'
import { supabase } from '../lib/supabase'
import { partnerRequestSchema } from '../lib/schemas'
import { Field } from '../components/ui'

/// The only unauthenticated page. RLS lets anon INSERT a partner_orgs row with
/// status 'pending' and nothing else — it cannot read back what it wrote, so
/// this form is not a way to enumerate who else has applied.
export default function PartnerAccess() {
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [sent, setSent] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const raw = Object.fromEntries(new FormData(e.currentTarget).entries())
    if (raw.district_id === '') delete raw.district_id
    const parsed = partnerRequestSchema.safeParse(raw)
    if (!parsed.success) {
      const next: Record<string, string> = {}
      for (const i of parsed.error.issues) next[String(i.path[0])] = i.message
      return setErrors(next)
    }
    setErrors({}); setBusy(true); setError(null)
    const { error } = await supabase.from('partner_orgs').insert({ ...parsed.data, status: 'pending' })
    setBusy(false)
    if (error) return setError(error.message)
    setSent(true)
  }

  if (sent) {
    return (
      <div className="min-h-screen grid place-items-center p-4">
        <div className="card p-6 max-w-md">
          <h1 className="text-lg font-semibold mb-1">Request received</h1>
          <p className="text-soft">
            We will review it and email {"the address you gave"}. If approved you will get a sandbox
            key first, against seeded test records, and a live key only after a second check.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen py-10 px-4">
      <form onSubmit={submit} className="card p-6 max-w-2xl mx-auto">
        <h1 className="text-lg font-semibold">Request Setu API access</h1>
        <p className="text-soft mt-0.5 mb-5">
          For hospitals, labs and NGOs that need to look up a mother's antenatal summary when she
          presents her Thayi Setu QR code. Access is read-only and limited to that one lookup.
        </p>

        {error && <div className="card border-danger/40 bg-danger-soft p-3 text-danger mb-4">{error}</div>}

        <div className="grid md:grid-cols-2 gap-3">
          <Field label="Legal name" error={errors.legal_name}>
            <input name="legal_name" className="input" autoFocus />
          </Field>
          <Field label="Organisation type" error={errors.type}>
            <select name="type" className="input" defaultValue="private_hospital">
              <option value="private_hospital">Private hospital</option>
              <option value="lab">Laboratory</option>
              <option value="ngo">NGO</option>
            </select>
          </Field>
          <Field label="Registration number" error={errors.registration_number}>
            <input name="registration_number" className="input" />
          </Field>
          <Field label="Contact person" error={errors.contact_name}>
            <input name="contact_name" className="input" />
          </Field>
          <Field label="Contact email" error={errors.contact_email}>
            <input name="contact_email" type="email" className="input" />
          </Field>
          <Field label="Contact phone" error={errors.contact_phone}>
            <input name="contact_phone" className="input" />
          </Field>
          <div className="md:col-span-2">
            <Field label="Address" error={errors.address}>
              <input name="address" className="input" />
            </Field>
          </div>
          <div className="md:col-span-2">
            <Field label="What will you use it for?" error={errors.intended_use}>
              <textarea name="intended_use" className="input h-20 py-1.5" />
            </Field>
          </div>
        </div>

        <button className="btn-primary mt-4" disabled={busy}>
          {busy ? 'Sending…' : 'Submit request'}
        </button>
      </form>
    </div>
  )
}
