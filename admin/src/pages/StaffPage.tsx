import { useState } from 'react'
import { usePhcs, useStaff } from '../lib/queries'
import { CanWrite } from '../components/Shell'
import { KmcLookupStep } from '../components/KmcLookup'
import { ErrorNote, Field, Loading, Page, Table } from '../components/ui'
import { staffSchema } from '../lib/schemas'
import type { AdminUser, KmcDoctor } from '../lib/types'

/// Registering staff creates a Supabase auth user AND a staff row, which has to
/// happen together and cannot happen from a browser: it needs the service role
/// key. The form posts to the Node service, which does both and sends the
/// invite through Resend. VITE_ADMIN_API is where that service lives.
const ADMIN_API = import.meta.env.VITE_ADMIN_API ?? ''

export default function StaffPage({ me }: { me: AdminUser }) {
  const staff = useStaff(), phcs = usePhcs()
  const [role, setRole] = useState<'doctor' | 'asha' | null>(null)
  const [kmcDoctor, setKmcDoctor] = useState<KmcDoctor | null>(null)
  const [filter, setFilter] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)

  if (staff.isLoading) return <Loading />

  const rows = (staff.data ?? []).filter((s) => {
    const q = filter.trim().toLowerCase()
    return !q || [s.name, s.email, s.employee_code].some((v) => v?.toLowerCase().includes(q))
  })

  async function register(values: Record<string, unknown>) {
    setError(null); setNotice(null)
    if (!ADMIN_API) {
      setError(
        'VITE_ADMIN_API is not set. Creating a login needs the service role key, which only the ' +
        'Node service holds — it is never shipped to this bundle. Start that service and set the URL.',
      )
      return
    }
    const res = await fetch(`${ADMIN_API}/admin/staff`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(values),
    })
    if (!res.ok) { setError((await res.json().catch(() => ({}))).message ?? `HTTP ${res.status}`); return }
    setNotice('Registered. An invite is on its way; they set their own password.')
    setRole(null); setKmcDoctor(null); staff.refetch()
  }

  return (
    <Page title="Staff" subtitle="Medical officers and ASHA workers."
      actions={
        <>
          <input className="input w-56" placeholder="Search name, email, code"
            value={filter} onChange={(e) => setFilter(e.target.value)} />
          <CanWrite me={me}>
            <button className="btn-ghost" onClick={() => setRole('doctor')}>Register MO</button>
            <button className="btn-primary" onClick={() => setRole('asha')}>Register ASHA</button>
          </CanWrite>
        </>
      }>
      <ErrorNote error={error} />
      {notice && <div className="card border-good/40 bg-good-soft p-3 text-good mb-3">{notice}</div>}

      {role === 'doctor' && !kmcDoctor && (
        <KmcLookupStep onFound={setKmcDoctor} onCancel={() => setRole(null)} />
      )}

      {((role === 'doctor' && kmcDoctor) || role === 'asha') && (
        <StaffForm role={role!} doctor={kmcDoctor}
          phcs={(phcs.data ?? []).filter((p) => p.active)}
          onCancel={() => { setRole(null); setKmcDoctor(null) }}
          onSubmit={register} />
      )}

      <Table head={['Name', 'Role', 'PHC', 'KMC / Employee code', 'Contact', 'Login', 'Status']}
        empty="No staff yet.">
        {rows.map((s) => (
          <tr key={s.id} className={s.active ? '' : 'opacity-50'}>
            <td className="td font-medium">{s.name}</td>
            <td className="td">
              <span className="chip bg-paper text-soft">
                {s.role === 'doctor' ? 'medical officer' : 'ASHA'}
              </span>
            </td>
            <td className="td">
              {(phcs.data ?? []).find((p) => p.id === s.phc_id)?.name_en
                ?? <span className="text-soft">unassigned</span>}
            </td>
            <td className="td font-mono text-[11px]">
              {s.kmc_registration_number && <div>{s.kmc_registration_number}</div>}
              <div className={s.kmc_registration_number ? 'text-soft' : ''}>
                {s.employee_code ?? '—'}
              </div>
            </td>
            <td className="td">
              <div>{s.email ?? '—'}</div>
              <div className="text-[11px] text-soft">{s.phone ?? ''}</div>
            </td>
            <td className="td">
              {s.auth_user_id
                ? <span className="chip bg-good-soft text-good">active</span>
                : <span className="chip bg-warn-soft text-warn">never signed in</span>}
            </td>
            <td className="td">
              <span className={`chip ${s.active ? 'bg-good-soft text-good' : 'bg-paper text-soft'}`}>
                {s.active ? 'active' : 'inactive'}
              </span>
            </td>
          </tr>
        ))}
      </Table>
    </Page>
  )
}

function StaffForm({ role, doctor, phcs, onSubmit, onCancel }: {
  role: 'doctor' | 'asha'
  doctor: KmcDoctor | null
  phcs: { id: string; name_en: string }[]
  onSubmit: (v: Record<string, unknown>) => void
  onCancel: () => void
}) {
  const [errors, setErrors] = useState<Record<string, string>>({})

  function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const raw = Object.fromEntries(new FormData(e.currentTarget).entries())
    const parsed = staffSchema.safeParse({
      ...raw,
      role,
      // The name and the registration come from the register, never from the
      // form: a disabled input submits nothing, and re-typing them would be a
      // way to register someone under a number that is not theirs.
      ...(doctor ? { name: doctor.full_name, kmc_registration_number: doctor.registration_number } : {}),
      villages: [],
    })
    if (!parsed.success) {
      const next: Record<string, string> = {}
      for (const i of parsed.error.issues) next[String(i.path[0])] = i.message
      return setErrors(next)
    }
    setErrors({}); onSubmit(parsed.data)
  }

  return (
    <form onSubmit={submit} className="card p-4 mb-4">
      <div className="font-semibold mb-1">
        Register {role === 'doctor' ? 'a medical officer' : 'an ASHA worker'}
      </div>
      {doctor && (
        <p className="text-soft mb-3">
          From the register: <span className="font-medium text-ink">{doctor.full_name}</span>,{' '}
          {doctor.qualification} · <span className="font-mono">{doctor.registration_number}</span>.
          Add what the council does not know.
        </p>
      )}
      <div className="grid md:grid-cols-3 gap-3">
        <Field label="Full name" error={errors.name}>
          <input name="name" className="input disabled:bg-paper disabled:text-soft"
            autoFocus={!doctor}
            defaultValue={doctor?.full_name ?? ''} disabled={!!doctor}
            title={doctor ? 'From the KMC register — not editable here' : undefined} />
        </Field>
        <Field label="Email" error={errors.email}>
          <input name="email" className="input" autoFocus={!!doctor}
            defaultValue={doctor?.email ?? ''} />
        </Field>
        <Field label="Phone" error={errors.phone}>
          <input name="phone" className="input" defaultValue={doctor?.phone ?? ''} />
        </Field>
        <Field label="Employee code" error={errors.employee_code}>
          <input name="employee_code" className="input" />
        </Field>
        <Field label="PHC" error={errors.phc_id}>
          <select name="phc_id" className="input">
            <option value="">Choose…</option>
            {phcs.map((p) => <option key={p.id} value={p.id}>{p.name_en}</option>)}
          </select>
        </Field>
      </div>
      <p className="text-soft mt-3">
        {role === 'doctor'
          ? 'They receive an invite and set their own password — you never see it.'
          : 'ASHA Setu signs in by email code, so no password is issued. The record only has to exist before she can authenticate.'}
      </p>
      <div className="flex gap-2 mt-3">
        <button className="btn-primary">Register</button>
        <button type="button" className="btn-ghost" onClick={onCancel}>Cancel</button>
      </div>
    </form>
  )
}
