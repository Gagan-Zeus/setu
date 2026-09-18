import { useState } from 'react'
import { useMothers, usePhcs, useSetMotherActive } from '../lib/queries'
import { CanWrite } from '../components/Shell'
import { ErrorNote, Loading, Page, Risk, Table } from '../components/ui'
import type { AdminUser } from '../lib/types'

export default function Mothers({ me }: { me: AdminUser }) {
  const mothers = useMothers(), phcs = usePhcs()
  const setActive = useSetMotherActive()
  const [q, setQ] = useState(''), [phc, setPhc] = useState(''), [risk, setRisk] = useState('')
  const [error, setError] = useState<string | null>(null)

  if (mothers.isLoading) return <Loading />

  const rows = (mothers.data ?? []).filter((m) => {
    const t = q.trim().toLowerCase()
    return (!t || [m.name_en, m.thayi_card_number, m.village_en].some((v) => v?.toLowerCase().includes(t)))
      && (!phc || m.phc_id === phc)
      && (!risk || m.risk_level === risk)
  })

  return (
    <Page title="Mothers"
      subtitle="Read, search and reassign. Clinical fields are written by the people who observed them and cannot be edited here."
      actions={
        <>
          <input className="input w-56" placeholder="Name, card number, village"
            value={q} onChange={(e) => setQ(e.target.value)} />
          <select className="input w-48" value={phc} onChange={(e) => setPhc(e.target.value)}>
            <option value="">All PHCs</option>
            {(phcs.data ?? []).map((p) => <option key={p.id} value={p.id}>{p.name_en}</option>)}
          </select>
          <select className="input w-32" value={risk} onChange={(e) => setRisk(e.target.value)}>
            <option value="">All risk</option>
            <option value="red">Red</option><option value="amber">Amber</option>
            <option value="green">Green</option>
          </select>
        </>
      }>
      <ErrorNote error={error} />
      <p className="text-soft mb-2 tabular-nums">{rows.length} of {(mothers.data ?? []).length}</p>

      <Table head={['Name', 'Card', 'Village', 'Sub-centre', 'Risk', 'Last visit', '']}
        empty="No mothers match those filters.">
        {rows.slice(0, 300).map((m) => (
          <tr key={m.id} className={m.active ? '' : 'opacity-50'}>
            <td className="td">
              <span className="font-medium">{m.name_en}</span>
              {m.is_sandbox && <span className="chip bg-warn-soft text-warn ml-1.5">sandbox</span>}
            </td>
            <td className="td font-mono text-[11px]">{m.thayi_card_number}</td>
            <td className="td">{m.village_en ?? '—'}</td>
            <td className="td">{m.sub_centre ?? '—'}</td>
            <td className="td"><Risk level={m.risk_level} /></td>
            <td className="td tabular-nums">{m.last_visit_date ?? '—'}</td>
            <td className="td text-right">
              <CanWrite me={me}>
                <button className="btn-ghost" onClick={async () => {
                  setError(null)
                  try { await setActive.mutateAsync({ motherId: m.id, active: !m.active }) }
                  catch (e) { setError(e instanceof Error ? e.message : String(e)) }
                }}>
                  {m.active ? 'Deactivate' : 'Reactivate'}
                </button>
              </CanWrite>
            </td>
          </tr>
        ))}
      </Table>
      {rows.length > 300 && (
        <p className="text-soft mt-2">
          Showing the first 300 of {rows.length}. Narrow the filters rather than scrolling.
        </p>
      )}
    </Page>
  )
}
