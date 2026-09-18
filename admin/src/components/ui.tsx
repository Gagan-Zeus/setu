import type { ReactNode } from 'react'

export function Page({ title, subtitle, actions, children }: {
  title: string; subtitle?: string; actions?: ReactNode; children: ReactNode
}) {
  return (
    <div className="px-6 py-5">
      <div className="flex items-start justify-between gap-4 mb-4">
        <div>
          <h1 className="text-lg font-semibold text-ink">{title}</h1>
          {subtitle && <p className="text-soft mt-0.5">{subtitle}</p>}
        </div>
        {actions && <div className="flex items-center gap-2 shrink-0">{actions}</div>}
      </div>
      {children}
    </div>
  )
}

export function Table({ head, children, empty }: {
  head: string[]; children: ReactNode; empty?: string
}) {
  const rows = Array.isArray(children) ? children.flat() : [children]
  const isEmpty = rows.filter(Boolean).length === 0
  return (
    <div className="card overflow-x-auto">
      <table className="w-full border-collapse">
        <thead className="bg-paper">
          <tr>{head.map((h) => <th key={h} className="th">{h}</th>)}</tr>
        </thead>
        <tbody>
          {isEmpty ? (
            <tr><td className="td text-soft" colSpan={head.length}>{empty ?? 'Nothing here yet.'}</td></tr>
          ) : children}
        </tbody>
      </table>
    </div>
  )
}

export function Stat({ label, value, tone = 'normal', hint }: {
  label: string; value: number | string; tone?: 'normal' | 'danger' | 'warn' | 'good'; hint?: string
}) {
  const tones = {
    normal: 'border-divider',
    danger: 'border-danger/40 bg-danger-soft',
    warn: 'border-warn/40 bg-warn-soft',
    good: 'border-good/40 bg-good-soft',
  }
  return (
    <div className={`card p-3 ${tones[tone]}`}>
      <div className="text-[11px] uppercase tracking-wide text-soft font-semibold">{label}</div>
      <div className="text-2xl font-semibold mt-1 tabular-nums">{value}</div>
      {hint && <div className="text-[11px] text-soft mt-0.5">{hint}</div>}
    </div>
  )
}

export function Risk({ level }: { level: string }) {
  const map: Record<string, string> = {
    red: 'bg-danger-soft text-danger',
    amber: 'bg-warn-soft text-warn',
    green: 'bg-good-soft text-good',
  }
  return <span className={`chip ${map[level] ?? 'bg-paper text-soft'}`}>{level}</span>
}

export function StatusChip({ status }: { status: string }) {
  const map: Record<string, string> = {
    pending: 'bg-warn-soft text-warn',
    approved: 'bg-good-soft text-good',
    rejected: 'bg-danger-soft text-danger',
    suspended: 'bg-danger-soft text-danger',
  }
  return <span className={`chip ${map[status] ?? 'bg-paper text-soft'}`}>{status}</span>
}

export function Field({ label, error, children }: {
  label: string; error?: string; children: ReactNode
}) {
  return (
    <div>
      <label className="label">{label}</label>
      {children}
      {error && <p className="text-[11px] text-danger mt-1">{error}</p>}
    </div>
  )
}

export function Loading() {
  return <div className="p-6 text-soft">Loading…</div>
}

export function ErrorNote({ error }: { error: unknown }) {
  if (!error) return null
  const message = error instanceof Error ? error.message : String(error)
  return (
    <div className="card border-danger/40 bg-danger-soft p-3 text-danger mb-3">{message}</div>
  )
}

/// CSV export for the audit screens. Quoting is the whole job: a rejection
/// reason with a comma in it must not become two columns.
export function toCsv(rows: Record<string, unknown>[]): string {
  if (rows.length === 0) return ''
  const cols = Object.keys(rows[0])
  const cell = (v: unknown) => {
    const s = v === null || v === undefined ? '' : typeof v === 'object' ? JSON.stringify(v) : String(v)
    return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
  }
  return [cols.join(','), ...rows.map((r) => cols.map((c) => cell(r[c])).join(','))].join('\n')
}

export function downloadCsv(name: string, rows: Record<string, unknown>[]) {
  const blob = new Blob([toCsv(rows)], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = name
  a.click()
  URL.revokeObjectURL(url)
}
