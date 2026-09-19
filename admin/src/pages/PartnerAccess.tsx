import { useState } from 'react'
import { supabase } from '../lib/supabase'
import { useKmcVerifyPublic, type KmcPublicCheck } from '../lib/queries'
import { kmcNumber, partnerRequestSchema } from '../lib/schemas'
import { Field } from '../components/ui'

/// The only unauthenticated page.
///
/// It opens with the KMC registration of the doctor making the request, because
/// a hospital is not a person and cannot be struck off. A named, registered
/// professional stands behind every application — someone the council can
/// identify, whose standing can be checked now and again later.
///
/// Verifying first also removes three fields. The contact's name, email and
/// phone are on the register; asking someone to retype them is how the two end
/// up disagreeing, and the key is later emailed to the address the council
/// holds rather than one typed into this form.
///
/// RLS lets anon INSERT a pending row and nothing else — this form cannot read
/// back what it wrote, so it is not a way to enumerate who else has applied.
export default function PartnerAccess() {
  const [doctor, setDoctor] = useState<KmcPublicCheck | null>(null)
  const [sent, setSent] = useState(false)

  if (sent) return <Submitted doctor={doctor} />

  return (
    <div className="min-h-screen py-10 px-4">
      <div className="max-w-2xl mx-auto">
        <div className="card p-6">
          <h1 className="text-lg font-semibold">Request Setu API access</h1>
          <p className="text-soft mt-0.5">
            For hospitals, labs and NGOs that need to look up a mother's antenatal summary when she
            presents her Thayi Setu QR code. Access is read-only and limited to that one lookup.
          </p>

          {!doctor
            ? <VerifyStep onVerified={setDoctor} />
            : <OrgStep doctor={doctor} onBack={() => setDoctor(null)} onSent={() => setSent(true)} />}
        </div>
      </div>
    </div>
  )
}

function VerifyStep({ onVerified }: { onVerified: (d: KmcPublicCheck) => void }) {
  const [value, setValue] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<KmcPublicCheck | null>(null)
  const verify = useKmcVerifyPublic()

  async function submit(e: React.FormEvent) {
    e.preventDefault()
    setError(null); setResult(null)
    const parsed = kmcNumber.safeParse(value)
    if (!parsed.success) return setError(parsed.error.issues[0].message)
    try {
      const r = await verify.mutateAsync(parsed.data)
      setResult(r)
      if (r.valid) onVerified(r)
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err))
    }
  }

  return (
    <div className="border-t border-divider mt-5 pt-5">
      <div className="font-semibold mb-1">Step 1 — the doctor making this request</div>
      <p className="text-soft mb-4">
        A registered medical practitioner has to stand behind the request. Enter their KMC
        registration number; their name and contact details come from the council, so you do not
        have to type them.
      </p>

      <form onSubmit={submit} className="flex items-end gap-2">
        <div className="w-72">
          <Field label="KMC registration number" error={error ?? undefined}>
            <input className="input font-mono" autoFocus placeholder="KMC-DEMO-88207"
              value={value} onChange={(e) => { setValue(e.target.value); setResult(null) }} />
          </Field>
        </div>
        <button className="btn-primary" disabled={verify.isPending}>
          {verify.isPending ? 'Checking…' : 'Verify'}
        </button>
      </form>

      {result && !result.valid && (
        <div className="card border-danger/40 bg-danger-soft p-3 mt-3 text-danger">
          <div className="font-semibold">
            {result.reason === 'not_in_registry'
              ? 'Not on the register'
              : `This registration is ${result.status}`}
          </div>
          <p className="text-danger/90 mt-0.5">
            {result.reason === 'not_in_registry'
              ? 'No registration matches that number. Check it against the certificate.'
              : 'A registration that is not in good standing does not authorise practice, so it ' +
                'cannot support a request for access to patient records.'}
          </p>
        </div>
      )}
    </div>
  )
}

function OrgStep({ doctor, onBack, onSent }: {
  doctor: KmcPublicCheck; onBack: () => void; onSent: () => void
}) {
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const raw = Object.fromEntries(new FormData(e.currentTarget).entries())
    const parsed = partnerRequestSchema.safeParse({
      ...raw,
      // From the verified record, never from a field — a form value here would
      // let someone attach a registration that is not the one they proved.
      kmc_registration_number: doctor.registration_number,
    })
    if (!parsed.success) {
      const next: Record<string, string> = {}
      for (const i of parsed.error.issues) next[String(i.path[0])] = i.message
      return setErrors(next)
    }

    setErrors({}); setBusy(true); setError(null)
    const { error } = await supabase.from('partner_orgs').insert({
      ...parsed.data,
      // What the register said at the moment of the request. The register is
      // live and a doctor may lapse later; this records what was true when
      // access was asked for, which is the question an audit asks.
      kmc_verified_at: new Date().toISOString(),
      kmc_status_at_request: doctor.status,
      contact_name: doctor.full_name,
      contact_email: doctor.email,
      contact_phone: doctor.phone,
      status: 'pending',
    })
    setBusy(false)
    if (error) return setError(error.message)
    onSent()
  }

  return (
    <form onSubmit={submit} className="border-t border-divider mt-5 pt-5">
      <div className="card bg-good-soft border-good/40 p-3 mb-4">
        <div className="flex items-start justify-between gap-3">
          <div>
            <div className="font-semibold text-good">{doctor.full_name}</div>
            <div className="text-good/90">{doctor.qualification}</div>
            <div className="text-good/80 text-[11px] mt-1 font-mono">
              {doctor.registration_number} · {doctor.state_medical_council} · {doctor.status}
            </div>
          </div>
          <button type="button" className="btn-ghost shrink-0" onClick={onBack}>Change</button>
        </div>
        <p className="text-good/90 mt-2">
          The API key will be emailed to the address the council holds for this registration.
        </p>
        {doctor.is_demo && (
          <p className="text-warn mt-2">
            Demo registry — Karnataka publishes no lookup API, so this was checked against a local
            stand-in and verifies nothing.
          </p>
        )}
      </div>

      <div className="font-semibold mb-3">Step 2 — the organisation</div>
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
        <Field label="Facility address" error={errors.address}>
          <input name="address" className="input" />
        </Field>
        <div className="md:col-span-2">
          <Field label="What will you use it for?" error={errors.intended_use}>
            <textarea name="intended_use" className="input h-20 py-1.5"
              placeholder="e.g. so the duty obstetrician can see her risk flags and recent vitals before examining a mother who arrives in labour" />
          </Field>
        </div>
      </div>

      {error && <div className="card border-danger/40 bg-danger-soft p-3 text-danger mt-4">{error}</div>}

      <button className="btn-primary mt-4" disabled={busy}>
        {busy ? 'Sending…' : 'Submit request'}
      </button>
    </form>
  )
}

function Submitted({ doctor }: { doctor: KmcPublicCheck | null }) {
  return (
    <div className="min-h-screen grid place-items-center p-4">
      <div className="card p-6 max-w-md">
        <h1 className="text-lg font-semibold mb-1">Request received</h1>
        <p className="text-soft">
          We will review it and reply to{' '}
          <span className="font-medium text-ink">{doctor?.email ?? 'the registered address'}</span>,
          the address the medical council holds for {doctor?.full_name ?? 'that registration'}.
        </p>
        <p className="text-soft mt-3">
          If approved you will receive a sandbox key first, which resolves only seeded test records,
          and a live key after a second check. The key arrives by email and is shown once — we store
          only a hash of it.
        </p>
      </div>
    </div>
  )
}
