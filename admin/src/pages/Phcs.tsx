import { useState } from 'react'
import { useDistricts, useMothers, usePhcs, useStaff, useUpsert, keys } from '../lib/queries'
import { phcSchema, type PhcInput } from '../lib/schemas'
import { supabase } from '../lib/supabase'
import { CanWrite } from '../components/Shell'
import { ErrorNote, Field, Loading, Page, Table } from '../components/ui'
import type { AdminUser, Phc } from '../lib/types'

export default function Phcs({ me }: { me: AdminUser }) {
  const phcs = usePhcs(), districts = useDistricts(), staff = useStaff(), mothers = useMothers()
  const [editing, setEditing] = useState<Partial<Phc> | null>(null)
  const [addingDistrict, setAddingDistrict] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const upsert = useUpsert<Record<string, unknown>>('health_centres', keys.phcs)

  if (phcs.isLoading) return <Loading />

  async function deactivate(p: Phc) {
    setError(null)
    // The database refuses this while staff are still on the PHC. Surfacing
    // its message verbatim is better than inventing one: it names the count.
    const { error } = await supabase
      .from('health_centres').update({ active: false }).eq('id', p.id)
    if (error) setError(error.message)
    else phcs.refetch()
  }

  return (
    <Page
      title="Primary Health Centres"
      subtitle="Each PHC has a district, a contact, and a staff roster."
      actions={
        <CanWrite me={me}>
          <button className="btn-ghost" onClick={() => setAddingDistrict(true)}>New district</button>
          <button className="btn-primary" disabled={(districts.data ?? []).length === 0}
            title={(districts.data ?? []).length === 0
              ? 'Create a district first — a PHC belongs to one'
              : undefined}
            onClick={() => setEditing({})}>New PHC</button>
        </CanWrite>
      }
    >
      <ErrorNote error={error} />

      {addingDistrict && (
        <NewDistrict
          onCancel={() => setAddingDistrict(false)}
          onDone={() => { setAddingDistrict(false); districts.refetch() }}
        />
      )}

      {editing && (
        <PhcForm
          initial={editing}
          districts={(districts.data ?? []).map((d) => ({ id: d.id, name: d.name }))}
          onCancel={() => setEditing(null)}
          onSave={async (values) => {
            setError(null)
            try {
              await upsert.mutateAsync({ ...(editing.id ? { id: editing.id } : {}), ...values })
              setEditing(null)
            } catch (e) { setError(e instanceof Error ? e.message : String(e)) }
          }}
        />
      )}

      {(districts.data ?? []).length === 0 && (
        <div className="card p-4 mb-4">
          <div className="font-semibold mb-1">Start with a district</div>
          <p className="text-soft max-w-xl">
            Everything hangs off geography: a PHC belongs to a district, staff belong to a PHC, and
            an administrator's scope is a set of districts. Create the district you work in and the
            rest follows.
          </p>
        </div>
      )}

      <Table head={['PHC', 'District', 'Contact', 'Staff', 'Mothers', 'Status', '']}
             empty="No PHCs yet. Create the first one.">
        {(phcs.data ?? []).map((p) => {
          const roster = (staff.data ?? []).filter((s) => s.phc_id === p.id && s.active)
          const caseload = (mothers.data ?? []).filter((m) => m.phc_id === p.id && m.active)
          const district = (districts.data ?? []).find((d) => d.id === p.district_id)
          return (
            <tr key={p.id} className={p.active ? '' : 'opacity-50'}>
              <td className="td">
                <div className="font-medium">{p.name_en}</div>
                {p.name_kn && <div className="text-soft text-[11px]">{p.name_kn}</div>}
              </td>
              <td className="td">{district?.name ?? <span className="text-soft">—</span>}</td>
              <td className="td">
                <div>{p.contact_name ?? <span className="text-soft">—</span>}</div>
                <div className="text-soft text-[11px]">{p.phone}</div>
              </td>
              <td className="td tabular-nums">
                {roster.filter((s) => s.role === 'doctor').length} MO ·{' '}
                {roster.filter((s) => s.role === 'asha').length} ASHA
              </td>
              <td className="td tabular-nums">{caseload.length}</td>
              <td className="td">
                <span className={`chip ${p.active ? 'bg-good-soft text-good' : 'bg-paper text-soft'}`}>
                  {p.active ? 'active' : 'inactive'}
                </span>
              </td>
              <td className="td text-right whitespace-nowrap">
                <CanWrite me={me}>
                  <button className="btn-ghost mr-1" onClick={() => setEditing(p)}>Edit</button>
                  {p.active && (
                    <button className="btn-danger" onClick={() => deactivate(p)}>Deactivate</button>
                  )}
                </CanWrite>
              </td>
            </tr>
          )
        })}
      </Table>
    </Page>
  )
}

function PhcForm({ initial, districts, onSave, onCancel }: {
  initial: Partial<Phc>
  districts: { id: string; name: string }[]
  onSave: (v: PhcInput) => void
  onCancel: () => void
}) {
  const [errors, setErrors] = useState<Record<string, string>>({})

  function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const form = new FormData(e.currentTarget)
    const raw = Object.fromEntries(form.entries())
    // Blank optional numbers must not reach Zod as empty strings.
    for (const k of ['latitude', 'longitude']) if (raw[k] === '') delete raw[k]
    const parsed = phcSchema.safeParse(raw)
    if (!parsed.success) {
      const next: Record<string, string> = {}
      for (const i of parsed.error.issues) next[String(i.path[0])] = i.message
      return setErrors(next)
    }
    setErrors({})
    onSave(parsed.data)
  }

  return (
    <form onSubmit={submit} className="card p-4 mb-4 grid md:grid-cols-3 gap-3">
      <Field label="Name (English)" error={errors.name_en}>
        <input name="name_en" className="input" defaultValue={initial.name_en ?? ''} autoFocus />
      </Field>
      <Field label="Name (Kannada)" error={errors.name_kn}>
        <input name="name_kn" className="input" defaultValue={initial.name_kn ?? ''} />
      </Field>
      <Field label="District" error={errors.district_id}>
        <select name="district_id" className="input" defaultValue={initial.district_id ?? ''}>
          <option value="">Choose…</option>
          {districts.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}
        </select>
      </Field>
      <Field label="Phone" error={errors.phone}>
        <input name="phone" className="input" defaultValue={initial.phone ?? ''} />
      </Field>
      <Field label="Contact name" error={errors.contact_name}>
        <input name="contact_name" className="input" defaultValue={initial.contact_name ?? ''} />
      </Field>
      <Field label="Address" error={errors.address}>
        <input name="address" className="input" defaultValue={initial.address ?? ''} />
      </Field>
      <Field label="Latitude" error={errors.latitude}>
        <input name="latitude" className="input" inputMode="decimal"
          placeholder="13.2137" defaultValue={initial.latitude ?? ''} />
      </Field>
      <Field label="Longitude" error={errors.longitude}>
        <input name="longitude" className="input" inputMode="decimal"
          placeholder="75.9946" defaultValue={initial.longitude ?? ''} />
      </Field>
      <p className="text-soft md:col-span-3">
        The coordinate is how a pregnant woman is shown the ASHA worker nearest
        to her: every worker posted here inherits it until she pins her own
        sub-centre. Left blank, her workers have no location at all and she
        cannot be told which of them is closest. Copy it from Google Maps \u2014
        right-click the PHC and the first entry is the pair.
      </p>
      <div className="md:col-span-3 flex gap-2">
        <button className="btn-primary">{initial.id ? 'Save changes' : 'Create PHC'}</button>
        <button type="button" className="btn-ghost" onClick={onCancel}>Cancel</button>
      </div>
    </form>
  )
}

/// Districts had no form at all, so an empty system could never make its first
/// PHC — the dropdown was permanently blank and district_id is required.
function NewDistrict({ onDone, onCancel }: { onDone: () => void; onCancel: () => void }) {
  const [name, setName] = useState('')
  const [nameKn, setNameKn] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(e: React.FormEvent) {
    e.preventDefault()
    if (name.trim().length < 3) return setError('Enter the district name')
    setBusy(true); setError(null)
    const { error } = await supabase.from('districts').insert({
      name: name.trim(),
      name_kn: nameKn.trim() || null,
      state: 'Karnataka',
    })
    setBusy(false)
    if (error) return setError(error.message)
    onDone()
  }

  return (
    <form onSubmit={submit} className="card p-4 mb-4 grid md:grid-cols-3 gap-3 items-end">
      <Field label="District" error={error ?? undefined}>
        <input className="input" autoFocus value={name}
          onChange={(e) => setName(e.target.value)} placeholder="Hassan" />
      </Field>
      <Field label="Name in Kannada">
        <input className="input" value={nameKn}
          onChange={(e) => setNameKn(e.target.value)} placeholder="ಹಾಸನ" />
      </Field>
      <div className="flex gap-2">
        <button className="btn-primary" disabled={busy}>
          {busy ? 'Creating…' : 'Create district'}
        </button>
        <button type="button" className="btn-ghost" onClick={onCancel}>Cancel</button>
      </div>
    </form>
  )
}
