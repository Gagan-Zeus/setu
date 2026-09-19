import { useState } from 'react'
import { useKmcLookup } from '../lib/queries'
import { kmcNumber } from '../lib/schemas'
import type { KmcDoctor, KmcLookup as Result } from '../lib/types'
import { Field } from './ui'

/// Registering a medical officer starts with the council, not with a form.
///
/// The administrator confirms a record rather than composing one: they type the
/// number on the certificate, and everything the register knows is filled in.
/// Only what the council does not know — which PHC, the employee code, the
/// address to invite them at — is left to type.
export function KmcLookupStep({ onFound, onCancel }: {
  onFound: (doctor: KmcDoctor) => void
  onCancel: () => void
}) {
  const [value, setValue] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<Result | null>(null)
  const lookup = useKmcLookup()

  async function search(e: React.FormEvent) {
    e.preventDefault()
    setError(null); setResult(null)
    const parsed = kmcNumber.safeParse(value)
    if (!parsed.success) return setError(parsed.error.issues[0].message)
    try {
      setResult(await lookup.mutateAsync(parsed.data))
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err))
    }
  }

  const d = result?.doctor

  return (
    <div className="card p-4 mb-4">
      <div className="font-semibold mb-1">Register a medical officer</div>
      <p className="text-soft mb-3 max-w-2xl">
        Start with the KMC registration number on their certificate. The council is the authority
        on who is a doctor, so the details come from the register rather than being typed.
      </p>

      <form onSubmit={search} className="flex items-end gap-2 mb-1">
        <div className="w-72">
          <Field label="KMC registration number" error={error ?? undefined}>
            <input className="input font-mono" autoFocus placeholder="KMC-DEMO-64821"
              value={value} onChange={(e) => { setValue(e.target.value); setResult(null) }} />
          </Field>
        </div>
        <button className="btn-primary" disabled={lookup.isPending}>
          {lookup.isPending ? 'Looking up…' : 'Look up'}
        </button>
        <button type="button" className="btn-ghost" onClick={onCancel}>Cancel</button>
      </form>

      {result && !result.found && (
        <div className="card border-danger/40 bg-danger-soft p-3 mt-3 text-danger">
          <div className="font-semibold">Not in the register</div>
          <p className="text-danger/90 mt-0.5">
            No registration matches that number. Check it against the certificate — a doctor who is
            not on the register cannot be registered here.
          </p>
        </div>
      )}

      {d && (
        <div className="mt-3">
          {result?.is_demo && (
            <div className="card border-warn/40 bg-warn-soft p-2.5 mb-3 text-warn">
              <span className="font-semibold">Demo registry.</span> Karnataka publishes no API for
              registration lookup, so this answer comes from a local stand-in, not from the council.
              It verifies nothing.
            </div>
          )}

          <div className="card p-3 mb-3">
            <div className="flex items-start justify-between gap-3 mb-2">
              <div>
                <div className="font-semibold text-base">{d.full_name}</div>
                <div className="text-soft">{d.qualification}</div>
              </div>
              <StatusChip status={d.status} />
            </div>
            <dl className="grid grid-cols-2 md:grid-cols-3 gap-y-1.5 gap-x-4">
              <Row k="Registration number" v={d.registration_number} mono />
              <Row k="Father's name" v={d.father_name} />
              <Row k="Date of birth" v={d.date_of_birth} />
              <Row k="Gender" v={d.gender} />
              <Row k="University" v={d.university} />
              <Row k="Year of passing" v={d.year_of_passing?.toString() ?? null} />
              <Row k="Registered on" v={d.registration_date} />
              <Row k="Council" v={d.state_medical_council} />
              <Row k="Renewal due" v={d.renewal_due} />
              <Row k="Address" v={d.address} wide />
            </dl>
          </div>

          {result?.already_registered ? (
            <div className="card border-warn/40 bg-warn-soft p-3 text-warn">
              <div className="font-semibold">Already registered</div>
              <p className="text-warn/90 mt-0.5">
                This registration is already attached to{' '}
                <span className="font-semibold">{result.existing_staff?.name}</span>
                {result.existing_staff?.email ? ` (${result.existing_staff.email})` : ''}. One
                doctor holds one registration, so there is nothing to add — find them on the Staff
                screen instead.
              </p>
            </div>
          ) : !result?.in_good_standing ? (
            <div className="card border-danger/40 bg-danger-soft p-3 text-danger">
              <div className="font-semibold">
                This registration is {d.status}
              </div>
              <p className="text-danger/90 mt-0.5">
                {d.status === 'expired'
                  ? 'The registration lapsed and has not been renewed, so it does not authorise practice today.'
                  : 'The council has suspended this registration.'}{' '}
                They cannot be registered as a medical officer until it is in good standing again.
              </p>
            </div>
          ) : (
            <button className="btn-primary" onClick={() => onFound(d)}>
              Continue with {d.full_name}
            </button>
          )}
        </div>
      )}
    </div>
  )
}

function Row({ k, v, mono, wide }: {
  k: string; v: string | null | undefined; mono?: boolean; wide?: boolean
}) {
  return (
    <div className={wide ? 'col-span-2 md:col-span-3' : ''}>
      <dt className="text-[11px] uppercase tracking-wide text-soft font-semibold">{k}</dt>
      <dd className={mono ? 'font-mono' : ''}>{v || <span className="text-soft">—</span>}</dd>
    </div>
  )
}

function StatusChip({ status }: { status: string }) {
  const map: Record<string, string> = {
    active: 'bg-good-soft text-good',
    renewed: 'bg-good-soft text-good',
    expired: 'bg-danger-soft text-danger',
    suspended: 'bg-danger-soft text-danger',
  }
  return <span className={`chip ${map[status] ?? 'bg-paper text-soft'}`}>{status}</span>
}
