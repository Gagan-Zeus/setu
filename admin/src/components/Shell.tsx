import { NavLink, Outlet } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import type { AdminUser } from '../lib/types'

const NAV = [
  { to: '/', label: 'Dashboard', end: true },
  { to: '/phcs', label: 'PHCs' },
  { to: '/staff', label: 'Staff' },
  { to: '/assignments', label: 'Assignments' },
  { to: '/mothers', label: 'Mothers' },
  { to: '/partners', label: 'Partner API' },
  { to: '/audit', label: 'Audit' },
]

export default function Shell({ me }: { me: AdminUser }) {
  return (
    <div className="min-h-screen flex">
      <aside className="w-52 shrink-0 border-r border-divider bg-white flex flex-col">
        <div className="px-4 py-4 border-b border-divider">
          <div className="font-semibold text-ink">Setu Admin</div>
          <div className="text-[11px] text-soft mt-0.5">Control plane</div>
        </div>
        <nav className="p-2 flex-1">
          {NAV.map((n) => (
            <NavLink
              key={n.to} to={n.to} end={n.end}
              className={({ isActive }) =>
                `block px-2.5 py-1.5 rounded-md mb-0.5 ${
                  isActive ? 'bg-teal-soft text-teal font-medium' : 'text-ink hover:bg-paper'
                }`
              }
            >
              {n.label}
            </NavLink>
          ))}
        </nav>
        <div className="p-3 border-t border-divider">
          <div className="truncate font-medium">{me.full_name}</div>
          <div className="text-[11px] text-soft mb-2">
            {me.email}
            <span className="chip bg-paper text-soft ml-1">{me.role.replace('_', ' ')}</span>
          </div>
          <button
            className="btn-ghost w-full justify-center"
            onClick={async () => { await supabase.auth.signOut(); window.location.href = '/' }}
          >
            Sign out
          </button>
        </div>
      </aside>
      <main className="flex-1 min-w-0"><Outlet /></main>
    </div>
  )
}

/// Read-only means read-only. A viewer never sees a control that would fail at
/// the database anyway — RLS already refuses their writes, so this only saves
/// them from finding out the hard way.
export function CanWrite({ me, children }: { me: AdminUser; children: React.ReactNode }) {
  if (me.role === 'viewer') return null
  return <>{children}</>
}
