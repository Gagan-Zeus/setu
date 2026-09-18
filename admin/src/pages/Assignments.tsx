import { useMemo, useState } from 'react'
import {
  useAssignments, useCaseloadSize, usePhcs, useReassignAsha, useStaff,
} from '../lib/queries'
import { CanWrite } from '../components/Shell'
import { ErrorNote, Loading, Page } from '../components/ui'
import type { AdminUser, Staff } from '../lib/types'

/// The core screen. Medical officers on the left, ASHA workers on the right,
/// unassigned ASHAs pinned to the top in a warning colour because that is the
/// state the whole portal exists to clear.
export default function Assignments({ me }: { me: AdminUser }) {
  const phcs = usePhcs(), staff = useStaff(), assignments = useAssignments()
  const reassign = useReassignAsha()
  const [phcId, setPhcId] = useState<string>('')
  const [selectedMo, setSelectedMo] = useState<string | null>(null)
  const [picked, setPicked] = useState<Set<string>>(new Set())
  const [confirming, setConfirming] = useState<Staff | null>(null)
  const [error, setError] = useState<string | null>(null)

  const activePhcs = useMemo(
    () => (phcs.data ?? []).filter((p) => p.active), [phcs.data])
  const currentPhc = phcId || activePhcs[0]?.id || ''

  const officers = (staff.data ?? [])
    .filter((s) => s.role === 'doctor' && s.active && s.phc_id === currentPhc)
  const ashas = (staff.data ?? [])
    .filter((s) => s.role === 'asha' && s.active && s.phc_id === currentPhc)

  const byAsha = new Map((assignments.data ?? []).map((a) => [a.asha_id, a]))
  const unassigned = ashas.filter((a) => !byAsha.has(a.id))
  const assigned = ashas.filter((a) => byAsha.has(a.id))

  if (phcs.isLoading || staff.isLoading) return <Loading />

  async function assign(ashaIds: string[], moId: string, reason?: string) {
    setError(null)
    try {
      // One call per ASHA, each atomic in the database. A partial failure
      // leaves the ones that succeeded correctly assigned rather than rolling
      // back work that was right.
      for (const id of ashaIds) {
        await reassign.mutateAsync({ ashaId: id, medicalOfficerId: moId, reason })
      }
      setPicked(new Set())
      setConfirming(null)
    } catch (e) { setError(e instanceof Error ? e.message : String(e)) }
  }

  return (
    <Page
      title="Assignments"
      subtitle="Who each ASHA worker reports to. Every change is kept — reassignment history is clinical audit data."
      actions={
        <select className="input w-64" value={currentPhc} onChange={(e) => setPhcId(e.target.value)}>
          {activePhcs.map((p) => <option key={p.id} value={p.id}>{p.name_en}</option>)}
        </select>
      }
    >
      <ErrorNote error={error} />

      {unassigned.length > 0 && (
        <div className="card border-danger/40 bg-danger-soft p-3 mb-4">
          <span className="font-semibold text-danger">
            {unassigned.length} unassigned ASHA worker{unassigned.length === 1 ? '' : 's'}
          </span>
          <span className="text-danger/80">
            {' '}— a red flag raised in the field has nobody to escalate to.
          </span>
        </div>
      )}

      <div className="grid md:grid-cols-2 gap-4">
        <div className="card">
          <div className="px-3 py-2 border-b border-divider font-semibold bg-paper">
            Medical officers
          </div>
          {officers.length === 0 ? (
            <p className="p-3 text-soft">No medical officer at this PHC yet.</p>
          ) : officers.map((mo) => {
            const count = [...byAsha.values()].filter((a) => a.medical_officer_id === mo.id).length
            const isSel = selectedMo === mo.id
            return (
              <button key={mo.id} onClick={() => setSelectedMo(isSel ? null : mo.id)}
                className={`w-full text-left px-3 py-2 border-b border-divider last:border-0 ${
                  isSel ? 'bg-teal-soft' : 'hover:bg-paper'}`}>
                <div className="flex items-center justify-between">
                  <span className="font-medium">{mo.name}</span>
                  <span className="text-soft tabular-nums">{count} ASHA</span>
                </div>
                <div className="text-soft text-[11px]">{mo.email ?? mo.phone}</div>
              </button>
            )
          })}
          {selectedMo && picked.size > 0 && (
            <CanWrite me={me}>
              <div className="p-3 border-t border-divider bg-paper">
                <button className="btn-primary w-full justify-center"
                  onClick={() => assign([...picked], selectedMo, 'bulk assignment')}>
                  Assign {picked.size} selected ASHA{picked.size === 1 ? '' : 's'} to this officer
                </button>
              </div>
            </CanWrite>
          )}
        </div>

        <div className="card">
          <div className="px-3 py-2 border-b border-divider font-semibold bg-paper">
            ASHA workers
          </div>
          {[...unassigned, ...assigned].length === 0 ? (
            <p className="p-3 text-soft">No ASHA workers at this PHC yet.</p>
          ) : [...unassigned, ...assigned].map((a) => {
            const current = byAsha.get(a.id)
            const mo = officers.find((o) => o.id === current?.medical_officer_id)
            const isUnassigned = !current
            return (
              <div key={a.id}
                className={`px-3 py-2 border-b border-divider last:border-0 flex items-center gap-2 ${
                  isUnassigned ? 'bg-danger-soft' : ''}`}>
                <CanWrite me={me}>
                  <input type="checkbox" checked={picked.has(a.id)}
                    onChange={(e) => {
                      const next = new Set(picked)
                      e.target.checked ? next.add(a.id) : next.delete(a.id)
                      setPicked(next)
                    }} />
                </CanWrite>
                <div className="flex-1 min-w-0">
                  <div className="font-medium truncate">{a.name}</div>
                  <div className="text-[11px] text-soft truncate">
                    {isUnassigned
                      ? <span className="text-danger font-medium">No medical officer</span>
                      : <>Reports to {mo?.name ?? 'someone at another PHC'}</>}
                  </div>
                </div>
                <CanWrite me={me}>
                  <button className="btn-ghost" onClick={() => setConfirming(a)}>Reassign</button>
                </CanWrite>
              </div>
            )
          })}
        </div>
      </div>

      {confirming && (
        <ReassignDialog
          asha={confirming} officers={officers}
          onClose={() => setConfirming(null)}
          onConfirm={(moId, reason) => assign([confirming.id], moId, reason)}
        />
      )}
    </Page>
  )
}

function ReassignDialog({ asha, officers, onConfirm, onClose }: {
  asha: Staff
  officers: Staff[]
  onConfirm: (moId: string, reason: string) => void
  onClose: () => void
}) {
  const [moId, setMoId] = useState('')
  const [reason, setReason] = useState('')
  // The number that has to be named before anyone clicks through.
  const caseload = useCaseloadSize(asha.id)

  return (
    <div className="fixed inset-0 bg-ink/40 grid place-items-center p-4" onClick={onClose}>
      <div className="card p-4 w-full max-w-md" onClick={(e) => e.stopPropagation()}>
        <h2 className="font-semibold mb-1">Reassign {asha.name}</h2>
        <p className="text-soft mb-3">
          {caseload.isLoading
            ? 'Counting her caseload…'
            : <><span className="font-semibold text-ink">{caseload.data ?? 0} mother
              {caseload.data === 1 ? '' : 's'}</span> move with her. The previous assignment is
              kept, not overwritten.</>}
        </p>
        <label className="label">New medical officer</label>
        <select className="input mb-3" value={moId} onChange={(e) => setMoId(e.target.value)}>
          <option value="">Choose…</option>
          {officers.map((o) => <option key={o.id} value={o.id}>{o.name}</option>)}
        </select>
        <label className="label">Reason (kept in the audit trail)</label>
        <input className="input mb-4" value={reason} onChange={(e) => setReason(e.target.value)}
          placeholder="e.g. sub-centre boundary changed" />
        <div className="flex gap-2">
          <button className="btn-primary" disabled={!moId}
            onClick={() => onConfirm(moId, reason)}>Confirm reassignment</button>
          <button className="btn-ghost" onClick={onClose}>Cancel</button>
        </div>
      </div>
    </div>
  )
}
