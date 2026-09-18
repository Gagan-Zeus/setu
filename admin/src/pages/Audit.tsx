import { useState } from 'react'
import { useAudit, usePartners, usePhiAccess } from '../lib/queries'
import { Loading, Page, Table, downloadCsv } from '../components/ui'

/// The screen that makes the system defensible to a health department: every
/// administrative change, and every time a partner read a mother's record.
export default function Audit() {
  const [tab, setTab] = useState<'admin' | 'phi'>('admin')
  const audit = useAudit(500), phi = usePhiAccess(500), partners = usePartners()
  const [from, setFrom] = useState(''), [to, setTo] = useState(''), [q, setQ] = useState('')

  const within = (iso: string) => {
    const t = new Date(iso).getTime()
    if (from && t < new Date(from).getTime()) return false
    if (to && t > new Date(to).getTime() + 86_400_000) return false
    return true
  }

  const adminRows = (audit.data ?? []).filter(
    (r) => within(r.created_at) &&
      (!q || [r.actor_email, r.entity_type, r.entity_id, r.action]
        .some((v) => v?.toLowerCase().includes(q.toLowerCase()))))

  const phiRows = (phi.data ?? []).filter(
    (r) => within(r.accessed_at) &&
      (!q || [r.endpoint, r.qr_token_jti, r.ip_address, String(r.response_status)]
        .some((v) => v?.toLowerCase().includes(q.toLowerCase()))))

  if (audit.isLoading || phi.isLoading) return <Loading />

  const partnerName = (id: string | null) =>
    (partners.data ?? []).find((p) => p.id === id)?.legal_name ?? '—'

  return (
    <Page title="Audit"
      subtitle="Append-only. Neither of these can be edited or deleted by anyone, including us."
      actions={
        <>
          <input type="date" className="input w-36" value={from} onChange={(e) => setFrom(e.target.value)} />
          <input type="date" className="input w-36" value={to} onChange={(e) => setTo(e.target.value)} />
          <input className="input w-48" placeholder="Filter" value={q} onChange={(e) => setQ(e.target.value)} />
          <button className="btn-ghost" onClick={() =>
            tab === 'admin'
              ? downloadCsv('admin-audit.csv', adminRows as unknown as Record<string, unknown>[])
              : downloadCsv('phi-access.csv', phiRows as unknown as Record<string, unknown>[])
          }>Export CSV</button>
        </>
      }>
      <div className="flex gap-1 mb-3">
        {(['admin', 'phi'] as const).map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`btn ${tab === t ? 'bg-teal text-white border-teal' : 'bg-white border-divider'}`}>
            {t === 'admin' ? 'Admin actions' : 'PHI access'}
          </button>
        ))}
      </div>

      {tab === 'admin' ? (
        <Table head={['When', 'Actor', 'Action', 'Entity', 'Changed']} empty="No admin actions recorded.">
          {adminRows.map((r) => {
            const before = (r.before ?? {}) as Record<string, unknown>
            const after = (r.after ?? {}) as Record<string, unknown>
            const changed = Object.keys(after).filter((k) => JSON.stringify(before[k]) !== JSON.stringify(after[k]))
            return (
              <tr key={r.id}>
                <td className="td tabular-nums whitespace-nowrap">
                  {new Date(r.created_at).toLocaleString()}
                </td>
                <td className="td">{r.actor_email ?? <span className="text-soft">system</span>}</td>
                <td className="td"><span className="chip bg-paper text-soft">{r.action}</span></td>
                <td className="td">
                  <div>{r.entity_type}</div>
                  <div className="text-[11px] text-soft font-mono truncate max-w-[16rem]">{r.entity_id}</div>
                </td>
                <td className="td text-[11px] text-soft">
                  {r.action === 'update'
                    ? changed.slice(0, 6).join(', ') || 'no field changed'
                    : r.action === 'insert' ? 'created' : 'removed'}
                </td>
              </tr>
            )
          })}
        </Table>
      ) : (
        <Table head={['When', 'Partner', 'Endpoint', 'Status', 'QR jti', 'IP']}
          empty="No partner lookups yet.">
          {phiRows.map((r) => (
            <tr key={r.id} className={r.response_status >= 400 ? 'bg-danger-soft/40' : ''}>
              <td className="td tabular-nums whitespace-nowrap">
                {new Date(r.accessed_at).toLocaleString()}
              </td>
              <td className="td">{partnerName(r.partner_org_id)}</td>
              <td className="td font-mono text-[11px]">{r.endpoint}</td>
              <td className="td">
                <span className={`chip ${r.response_status < 400
                  ? 'bg-good-soft text-good' : 'bg-danger-soft text-danger'}`}>
                  {r.response_status}
                </span>
                {r.failure_reason && (
                  <span className="text-[11px] text-soft ml-1">{r.failure_reason}</span>
                )}
              </td>
              <td className="td font-mono text-[11px] truncate max-w-[10rem]">{r.qr_token_jti ?? '—'}</td>
              <td className="td font-mono text-[11px]">{r.ip_address ?? '—'}</td>
            </tr>
          ))}
        </Table>
      )}
    </Page>
  )
}
