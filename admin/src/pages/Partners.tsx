import { useState } from 'react'
import { useApiKeys, usePartners } from '../lib/queries'
import { supabase } from '../lib/supabase'
import { rejectionSchema } from '../lib/schemas'
import { ErrorNote, Loading, Page, StatusChip, Table } from '../components/ui'
import type { AdminUser, PartnerOrg } from '../lib/types'

const ADMIN_API = import.meta.env.VITE_ADMIN_API ?? ''

export default function Partners({ me }: { me: AdminUser }) {
  const partners = usePartners(), apiKeys = useApiKeys()
  const [open, setOpen] = useState<PartnerOrg | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [issued, setIssued] = useState<string | null>(null)

  if (partners.isLoading) return <Loading />

  // Approval is a super_admin power — the database refuses it for anyone else,
  // and hiding the buttons only saves a district_admin from finding out that way.
  const canReview = me.role === 'super_admin'

  async function review(org: PartnerOrg, status: 'approved' | 'rejected', reason?: string) {
    setError(null)
    const { data: session } = await supabase.auth.getUser()
    const { error } = await supabase.from('partner_orgs').update({
      status,
      reviewed_at: new Date().toISOString(),
      reviewed_by: me.id,
      rejection_reason: reason ?? null,
    }).eq('id', org.id)
    if (error) return setError(error.message)
    void session
    partners.refetch(); setOpen(null)
  }

  async function issueKey(org: PartnerOrg, environment: 'sandbox' | 'live') {
    setError(null); setIssued(null)
    if (!ADMIN_API) {
      setError(
        'VITE_ADMIN_API is not set. Keys are generated with a CSPRNG in the Node service and ' +
        'hashed before storage — that never runs in a browser.',
      )
      return
    }
    const res = await fetch(`${ADMIN_API}/admin/partners/${org.id}/keys`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ environment, scopes: ['mother.read_by_qr'] }),
    })
    const body = await res.json().catch(() => ({}))
    if (!res.ok) return setError(body.message ?? `HTTP ${res.status}`)
    // Shown exactly once. Only a SHA-256 hash is stored; there is no way to
    // retrieve it later, by us or by them.
    setIssued(body.key)
    apiKeys.refetch()
  }

  return (
    <Page title="Partner API access"
      subtitle="Private hospitals and labs that look up a mother by scanning her QR code.">
      <ErrorNote error={error} />

      {issued && (
        <div className="card border-good/40 bg-good-soft p-3 mb-4">
          <div className="font-semibold text-good mb-1">
            Copy this key now — it is shown once and never again
          </div>
          <code className="block bg-white border border-divider rounded p-2 font-mono break-all">
            {issued}
          </code>
          <div className="text-good/80 mt-1">
            Only a SHA-256 hash is stored. If they lose it, they rotate — we cannot retrieve it.
          </div>
          <button className="btn-ghost mt-2" onClick={() => setIssued(null)}>Done</button>
        </div>
      )}

      <Table head={['Organisation', 'Type', 'Contact', 'Requested', 'Status', 'Keys', '']}
        empty="No partner requests yet.">
        {(partners.data ?? []).map((p) => {
          const keys = (apiKeys.data ?? []).filter((k) => k.partner_org_id === p.id && !k.revoked_at)
          return (
            <tr key={p.id}>
              <td className="td">
                <div className="font-medium">{p.legal_name}</div>
                <div className="text-[11px] text-soft font-mono">{p.registration_number}</div>
              </td>
              <td className="td">{p.type.replace('_', ' ')}</td>
              <td className="td">
                <div>{p.contact_name}</div>
                <div className="text-[11px] text-soft">{p.contact_email}</div>
              </td>
              <td className="td tabular-nums">{new Date(p.requested_at).toLocaleDateString()}</td>
              <td className="td"><StatusChip status={p.status} /></td>
              <td className="td">
                {keys.length === 0 ? <span className="text-soft">none</span>
                  : keys.map((k) => (
                    <div key={k.id} className="font-mono text-[11px]">
                      {k.key_prefix}… <span className="text-soft">({k.environment})</span>
                    </div>
                  ))}
              </td>
              <td className="td text-right">
                <button className="btn-ghost" onClick={() => setOpen(p)}>Review</button>
              </td>
            </tr>
          )
        })}
      </Table>

      {open && (
        <ReviewDialog
          org={open} canReview={canReview} onClose={() => setOpen(null)}
          onApprove={() => review(open, 'approved')}
          onReject={(reason) => review(open, 'rejected', reason)}
          onIssue={(env) => issueKey(open, env)}
        />
      )}
    </Page>
  )
}

function ReviewDialog({ org, canReview, onApprove, onReject, onIssue, onClose }: {
  org: PartnerOrg; canReview: boolean
  onApprove: () => void; onReject: (reason: string) => void
  onIssue: (env: 'sandbox' | 'live') => void; onClose: () => void
}) {
  const [reason, setReason] = useState('')
  const [reasonError, setReasonError] = useState<string | null>(null)
  const [confirmLive, setConfirmLive] = useState(false)

  return (
    <div className="fixed inset-0 bg-ink/40 grid place-items-center p-4 overflow-y-auto" onClick={onClose}>
      <div className="card p-4 w-full max-w-lg my-8" onClick={(e) => e.stopPropagation()}>
        <h2 className="font-semibold text-base mb-3">{org.legal_name}</h2>
        <dl className="grid grid-cols-3 gap-y-1.5 mb-4">
          {[
            ['Type', org.type.replace('_', ' ')],
            ['Registration', org.registration_number],
            ['Contact', `${org.contact_name} · ${org.contact_email} · ${org.contact_phone}`],
            ['Address', org.address],
            ['Intended use', org.intended_use],
            ['Status', org.status],
          ].map(([k, v]) => (
            <div key={k} className="contents">
              <dt className="text-soft">{k}</dt>
              <dd className="col-span-2">{v}</dd>
            </div>
          ))}
        </dl>

        {!canReview && (
          <p className="card bg-paper p-2.5 text-soft mb-3">
            Only a super admin can approve or reject partner API access.
          </p>
        )}

        {canReview && org.status === 'pending' && (
          <div className="space-y-3">
            <button className="btn-primary w-full justify-center" onClick={onApprove}>
              Approve
            </button>
            <div>
              <label className="label">Or reject, with a reason they can act on</label>
              <input className="input" value={reason}
                onChange={(e) => { setReason(e.target.value); setReasonError(null) }} />
              {reasonError && <p className="text-[11px] text-danger mt-1">{reasonError}</p>}
              <button className="btn-danger w-full justify-center mt-2" onClick={() => {
                const parsed = rejectionSchema.safeParse({ rejection_reason: reason })
                if (!parsed.success) return setReasonError(parsed.error.issues[0].message)
                onReject(reason)
              }}>Reject</button>
            </div>
          </div>
        )}

        {canReview && org.status === 'approved' && (
          <div className="space-y-2">
            <button className="btn-ghost w-full justify-center" onClick={() => onIssue('sandbox')}>
              Issue a sandbox key
            </button>
            <p className="text-soft">
              A sandbox key resolves only the seeded test mothers and can never reach a real record.
            </p>
            {!confirmLive ? (
              <button className="btn-ghost w-full justify-center" onClick={() => setConfirmLive(true)}>
                Issue a live key…
              </button>
            ) : (
              <div className="card border-warn/40 bg-warn-soft p-3">
                <div className="font-semibold text-warn mb-1">
                  A live key reads real patient data
                </div>
                <p className="text-warn/90 mb-2">
                  It resolves real mothers on every scan. Issue it only once you have checked the
                  registration number against the register.
                </p>
                <button className="btn-primary w-full justify-center" onClick={() => onIssue('live')}>
                  I have verified this organisation — issue the live key
                </button>
              </div>
            )}
          </div>
        )}

        <button className="btn-ghost w-full justify-center mt-4" onClick={onClose}>Close</button>
      </div>
    </div>
  )
}
