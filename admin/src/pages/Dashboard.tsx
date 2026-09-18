import { Link } from 'react-router-dom'
import {
  useAssignments, useMothers, usePartners, usePhcs, usePhiAccess, useStaff,
} from '../lib/queries'
import { Loading, Page, Stat } from '../components/ui'

export default function Dashboard() {
  const phcs = usePhcs(), staff = useStaff(), mothers = useMothers()
  const assignments = useAssignments(), partners = usePartners(), phi = usePhiAccess(500)

  if (phcs.isLoading || staff.isLoading || mothers.isLoading) return <Loading />

  const doctors = (staff.data ?? []).filter((s) => s.role === 'doctor' && s.active)
  const ashas = (staff.data ?? []).filter((s) => s.role === 'asha' && s.active)
  const assigned = new Set((assignments.data ?? []).map((a) => a.asha_id))
  // The error state the whole screen exists to surface: an ASHA with no
  // medical officer has nobody to escalate a red flag to.
  const orphaned = ashas.filter((a) => !assigned.has(a.id))
  const pending = (partners.data ?? []).filter((p) => p.status === 'pending')

  const dayAgo = Date.now() - 24 * 60 * 60 * 1000
  const recent = (phi.data ?? []).filter((r) => new Date(r.accessed_at).getTime() > dayAgo)
  const failures = recent.filter((r) => r.response_status >= 400)

  return (
    <Page title="Dashboard" subtitle="System health at a glance.">
      {orphaned.length > 0 && (
        <Link to="/assignments"
          className="card border-danger/40 bg-danger-soft p-3 mb-4 block hover:brightness-95">
          <div className="font-semibold text-danger">
            {orphaned.length} ASHA worker{orphaned.length === 1 ? '' : 's'} with no medical officer
          </div>
          <div className="text-danger/80 mt-0.5">
            {orphaned.map((a) => a.name).join(', ')} — a red flag raised in the field has nobody to
            escalate to. Assign them now.
          </div>
        </Link>
      )}

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-5">
        <Stat label="PHCs active" value={(phcs.data ?? []).filter((p) => p.active).length} />
        <Stat label="Medical officers" value={doctors.length} />
        <Stat label="ASHA workers" value={ashas.length} />
        <Stat label="Mothers registered"
          value={(mothers.data ?? []).filter((m) => m.active && !m.is_sandbox).length} />
        <Stat label="Unassigned ASHAs" value={orphaned.length}
          tone={orphaned.length ? 'danger' : 'good'}
          hint={orphaned.length ? 'Needs attention' : 'All assigned'} />
        <Stat label="Pending partner requests" value={pending.length}
          tone={pending.length ? 'warn' : 'normal'} />
        <Stat label="API calls, 24h" value={recent.length} />
        <Stat label="Failed API calls, 24h" value={failures.length}
          tone={failures.length ? 'warn' : 'normal'}
          hint={failures.length ? 'Check the PHI log' : undefined} />
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        <div className="card p-3">
          <div className="font-semibold mb-2">Mothers by risk</div>
          {(['red', 'amber', 'green'] as const).map((level) => {
            const all = (mothers.data ?? []).filter((m) => m.active && !m.is_sandbox)
            const n = all.filter((m) => m.risk_level === level).length
            const pct = all.length ? Math.round((n / all.length) * 100) : 0
            const bar = { red: 'bg-danger', amber: 'bg-warn', green: 'bg-good' }[level]
            return (
              <div key={level} className="flex items-center gap-2 mb-1.5">
                <div className="w-14 text-soft capitalize">{level}</div>
                <div className="flex-1 h-2 bg-paper rounded overflow-hidden">
                  <div className={`h-full ${bar}`} style={{ width: `${pct}%` }} />
                </div>
                <div className="w-10 text-right tabular-nums">{n}</div>
              </div>
            )
          })}
        </div>

        <div className="card p-3">
          <div className="font-semibold mb-2">Pending partner requests</div>
          {pending.length === 0 ? (
            <p className="text-soft">Nothing waiting for review.</p>
          ) : (
            pending.slice(0, 5).map((p) => (
              <Link key={p.id} to="/partners"
                className="flex items-center justify-between py-1 hover:text-teal">
                <span className="truncate">{p.legal_name}</span>
                <span className="text-soft shrink-0 ml-2">
                  {new Date(p.requested_at).toLocaleDateString()}
                </span>
              </Link>
            ))
          )}
        </div>
      </div>
    </Page>
  )
}
