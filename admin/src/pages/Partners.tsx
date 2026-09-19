import { useState } from 'react'
import { useApiKeys, useKmcRecord, usePartners } from '../lib/queries'
import { edgePost } from '../lib/adminApi'
import { supabase } from '../lib/supabase'
import { rejectionSchema } from '../lib/schemas'
import { ErrorNote, Loading, Page, StatusChip, Table } from '../components/ui'
import type { AdminUser, PartnerOrg } from '../lib/types'

/// What the partner-api answers when a key is issued. Deliberately not the
/// key: that travels to the address the council holds and exists in exactly
/// one place. This screen used to expect `body.key` and render it, which is a
/// credential in a browser, in a screenshot, and in whatever the tab restores.
interface IssuedKey {
  issued: boolean
  key_id: string
  key_prefix: string
  key_last_four: string
  emailed_to: string
  email_sent: boolean
}

export default function Partners({ me }: { me: AdminUser }) {
  const partners = usePartners(), apiKeys = useApiKeys()
  const [open, setOpen] = useState<PartnerOrg | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [issued, setIssued] = useState<IssuedKey | null>(null)
  const [busy, setBusy] = useState(false)
  const [copied, setCopied] = useState(false)

  if (partners.isLoading) return <Loading />

  // Approval is a super_admin power — the database refuses it for anyone else,
  // and hiding the buttons only saves a district_admin from finding out that way.
  const canReview = me.role === 'super_admin'

  async function review(org: PartnerOrg, status: 'approved' | 'rejected', reason?: string) {
    setError(null)
    const { error } = await supabase.from('partner_orgs').update({
      status,
      reviewed_at: new Date().toISOString(),
      reviewed_by: me.id,
      rejection_reason: reason ?? null,
    }).eq('id', org.id)
    if (error) return setError(error.message)
    partners.refetch(); setOpen(null)
  }

  /// Confirming live access is its own decision, recorded before any live key
  /// exists. Both the partner-api and a trigger on api_keys refuse a live key
  /// while `live_access_granted_at` is null, and nothing in this portal ever
  /// set it — so the live button could not have worked even once the endpoint
  /// behind it was right.
  async function grantLiveAccess(org: PartnerOrg) {
    const { error } = await supabase.from('partner_orgs').update({
      live_access_granted_at: new Date().toISOString(),
      live_access_granted_by: me.id,
    }).eq('id', org.id)
    if (error) throw new Error(error.message)
    partners.refetch()
  }

  async function issueKey(org: PartnerOrg, environment: 'sandbox' | 'live') {
    setError(null); setIssued(null); setBusy(true)
    try {
      if (environment === 'live' && !org.live_access_granted_at) {
        await grantLiveAccess(org)
      }
      // partner-api verifies this administrator's own JWT and refuses anyone
      // but a super_admin. The key is generated there with a CSPRNG, hashed
      // before storage, and emailed to the address on the register.
      setIssued(await edgePost<IssuedKey>('partner-api', '/admin/issue-key', {
        partner_org_id: org.id,
        environment,
      }))
      setOpen(null)
      apiKeys.refetch()
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setBusy(false)
    }
  }

  const formUrl = `${window.location.origin}/partner-access`

  return (
    <Page title="Partner API access"
      subtitle="Private hospitals and labs that look up a mother by scanning her QR code."
      actions={
        <>
          <a className="btn-ghost" href="/partner-access" target="_blank" rel="noreferrer">
            Open the request form
          </a>
          <button className="btn-primary" onClick={() => {
            navigator.clipboard?.writeText(formUrl)
            setCopied(true)
            window.setTimeout(() => setCopied(false), 2000)
          }}>
            {copied ? 'Link copied' : 'Copy link for a partner'}
          </button>
        </>
      }>
      <ErrorNote error={error} />

      {issued && (
        <div className={`card p-3 mb-4 ${issued.email_sent
          ? 'border-good/40 bg-good-soft' : 'border-warn/40 bg-warn-soft'}`}>
          <div className={`font-semibold mb-1 ${issued.email_sent ? 'text-good' : 'text-warn'}`}>
            {issued.email_sent
              ? `Key issued and emailed to ${issued.emailed_to}`
              : 'Key issued — but the email did not send'}
          </div>
          <div className="font-mono mb-1">
            {issued.key_prefix}…{issued.key_last_four}
          </div>
          <p className={issued.email_sent ? 'text-good/80' : 'text-warn/90'}>
            {issued.email_sent
              ? 'It went to the address the medical council holds, not one typed into the form. ' +
                'Only a SHA-256 hash is stored here — nobody, including us, can read it back.'
              : `The key exists and is live, but ${issued.emailed_to} never received it. Revoke ` +
                'it and issue another once the mailer is working: there is no way to resend ' +
                'this one, because only its hash was kept.'}
          </p>
          <button className="btn-ghost mt-2" onClick={() => setIssued(null)}>Done</button>
        </div>
      )}

      {(partners.data ?? []).length === 0 && (
        <div className="card p-5 mb-4">
          <div className="font-semibold mb-1">No partner requests yet</div>
          <p className="text-soft mb-3 max-w-xl">
            Requests arrive here on their own. A hospital, lab or NGO fills in the public form and
            the submission lands in this queue as <span className="chip bg-warn-soft text-warn">pending</span>
            {' '}for you to approve or reject. There is nothing to create from this side — an
            administrator never applies on a partner's behalf, because the registration number and
            the intended use have to come from them.
          </p>
          <div className="flex items-center gap-2 mb-3">
            <code className="card bg-paper px-2 py-1 font-mono text-[12px]">{formUrl}</code>
            <button className="btn-ghost" onClick={() => {
              navigator.clipboard?.writeText(formUrl)
              setCopied(true)
              window.setTimeout(() => setCopied(false), 2000)
            }}>{copied ? 'Copied' : 'Copy'}</button>
          </div>
          <p className="text-soft">
            Send that to anyone asking for access. It needs no sign-in, and it is the only page on
            this site that does not.
          </p>
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
                {/* Either the contact typed on an older request, or the
                    registration the newer ones carry instead. Never both
                    blank, because the table would then show nothing at all
                    for a row that does have somebody accountable for it. */}
                {p.contact_name || p.contact_email ? (
                  <>
                    <div>{p.contact_name ?? '—'}</div>
                    <div className="text-[11px] text-soft">{p.contact_email ?? ''}</div>
                  </>
                ) : p.kmc_registration_number ? (
                  <>
                    <div className="font-mono text-[11px]">{p.kmc_registration_number}</div>
                    <div className="text-[11px] text-soft">from the KMC register</div>
                  </>
                ) : (
                  <span className="text-soft">—</span>
                )}
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
          org={open} canReview={canReview} busy={busy} onClose={() => setOpen(null)}
          onApprove={() => review(open, 'approved')}
          onReject={(reason) => review(open, 'rejected', reason)}
          onIssue={(env) => issueKey(open, env)}
        />
      )}
    </Page>
  )
}

function ReviewDialog({ org, canReview, busy, onApprove, onReject, onIssue, onClose }: {
  org: PartnerOrg; canReview: boolean; busy: boolean
  onApprove: () => void; onReject: (reason: string) => void
  onIssue: (env: 'sandbox' | 'live') => void; onClose: () => void
}) {
  const [reason, setReason] = useState('')
  const [reasonError, setReasonError] = useState<string | null>(null)
  const [confirmLive, setConfirmLive] = useState(false)
  // Who is actually accountable for this request. Since 0009 that is a KMC
  // registration rather than three text fields, and reading the register is
  // the only way to put a name to it.
  const kmc = useKmcRecord(org.kmc_registration_number)
  const doctor = kmc.data?.doctor

  const contact = org.contact_name || org.contact_email || org.contact_phone
    ? [org.contact_name, org.contact_email, org.contact_phone].filter(Boolean).join(' · ')
    : null

  return (
    <div className="fixed inset-0 bg-ink/40 grid place-items-center p-4 overflow-y-auto" onClick={onClose}>
      <div className="card p-4 w-full max-w-lg my-8" onClick={(e) => e.stopPropagation()}>
        <h2 className="font-semibold text-base mb-3">{org.legal_name}</h2>
        <dl className="grid grid-cols-3 gap-y-1.5 mb-4">
          {[
            ['Type', org.type.replace('_', ' ')],
            ['Registration', org.registration_number],
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

        {/* The doctor behind the request, read from the register rather than
            from the form. Three nulls joined with a middle dot is what this
            showed before, on every request made since the form started asking
            for a KMC number instead of a name, an email and a phone. */}
        <div className="card bg-paper p-3 mb-4">
          <div className="text-[11px] uppercase tracking-wide text-soft font-semibold mb-1">
            Accountable doctor
          </div>
          {org.kmc_registration_number ? (
            kmc.isLoading ? (
              <div className="text-soft">Reading the register…</div>
            ) : doctor ? (
              <>
                <div className="font-semibold">{doctor.full_name}</div>
                <div className="text-soft">{doctor.qualification}</div>
                <div className="font-mono text-[11px] mt-1">{doctor.registration_number}</div>
                <div className="text-[11px] text-soft">
                  {doctor.email ?? 'no address on the register'}
                  {doctor.phone ? ` · ${doctor.phone}` : ''}
                </div>
                {/* What the register says NOW, beside what it said then. A
                    doctor may have lapsed since the request was made, and
                    issuing a key is the moment that matters. */}
                {kmc.data?.in_good_standing === false && (
                  <div className="text-danger mt-1.5">
                    This registration is {doctor.status} today. The key issue will be refused
                    until it is in good standing again.
                  </div>
                )}
                {org.kmc_status_at_request &&
                  org.kmc_status_at_request !== doctor.status && (
                    <div className="text-warn mt-1">
                      It was “{org.kmc_status_at_request}” when the request was made.
                    </div>
                  )}
              </>
            ) : (
              <div className="text-danger">
                {org.kmc_registration_number} is not in the register.
              </div>
            )
          ) : contact ? (
            <div>{contact}</div>
          ) : (
            <div className="text-soft">
              No contact and no registration — this request predates both.
            </div>
          )}
        </div>

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
            <button className="btn-ghost w-full justify-center" disabled={busy}
              onClick={() => onIssue('sandbox')}>
              {busy ? 'Issuing…' : 'Issue a sandbox key'}
            </button>
            <p className="text-soft">
              A sandbox key resolves only the seeded test mothers and can never reach a real record.
            </p>
            {!confirmLive ? (
              <button className="btn-ghost w-full justify-center" disabled={busy}
                onClick={() => setConfirmLive(true)}>
                Issue a live key…
              </button>
            ) : (
              <div className="card border-warn/40 bg-warn-soft p-3">
                <div className="font-semibold text-warn mb-1">
                  A live key reads real patient data
                </div>
                <p className="text-warn/90 mb-2">
                  It resolves real mothers on every scan. Issue it only once you have checked the
                  registration number against the register. The key is emailed to the address the
                  council holds — it is never shown here, and cannot be recovered afterwards.
                </p>
                <button className="btn-primary w-full justify-center" disabled={busy}
                  onClick={() => onIssue('live')}>
                  {busy ? 'Issuing…' : 'I have verified this organisation — issue the live key'}
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
