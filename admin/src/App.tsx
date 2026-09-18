import { useEffect, useState } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { supabase } from './lib/supabase'
import { useMe } from './lib/queries'
import Shell from './components/Shell'
import { Loading } from './components/ui'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import Phcs from './pages/Phcs'
import StaffPage from './pages/StaffPage'
import Assignments from './pages/Assignments'
import Mothers from './pages/Mothers'
import Partners from './pages/Partners'
import Audit from './pages/Audit'
import PartnerAccess from './pages/PartnerAccess'

const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: 1, refetchOnWindowFocus: false } },
})

function Authed() {
  const [checked, setChecked] = useState(false)
  const [signedIn, setSignedIn] = useState(false)
  const me = useMe()

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSignedIn(!!data.session); setChecked(true)
    })
    const { data: sub } = supabase.auth.onAuthStateChange((_e, session) => {
      setSignedIn(!!session)
    })
    return () => sub.subscription.unsubscribe()
  }, [])

  if (!checked || me.isLoading) return <Loading />
  if (!signedIn) return <Login />

  // Signed in to Supabase but with no admin_users row. This is the case where
  // an ASHA or a doctor tries the portal with their clinical login: they
  // authenticate fine and have no business here, and saying so plainly beats
  // an empty dashboard that looks broken.
  if (!me.data) {
    return (
      <div className="min-h-screen grid place-items-center p-4">
        <div className="card p-6 max-w-md">
          <h1 className="text-lg font-semibold mb-1">This account is not an administrator</h1>
          <p className="text-soft mb-4">
            Signing in worked, but there is no admin record for this address. Clinical staff use
            the ASHA and Care apps; the portal is a separate account.
          </p>
          <button className="btn-ghost" onClick={async () => {
            await supabase.auth.signOut(); window.location.reload()
          }}>Sign out</button>
        </div>
      </div>
    )
  }

  const me_ = me.data
  return (
    <Routes>
      <Route element={<Shell me={me_} />}>
        <Route index element={<Dashboard />} />
        <Route path="phcs" element={<Phcs me={me_} />} />
        <Route path="staff" element={<StaffPage me={me_} />} />
        <Route path="assignments" element={<Assignments me={me_} />} />
        <Route path="mothers" element={<Mothers me={me_} />} />
        <Route path="partners" element={<Partners me={me_} />} />
        <Route path="audit" element={<Audit />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      {/* Matches vite's `base`, so the same bundle works at / and at /setu/. */}
      <BrowserRouter basename={import.meta.env.BASE_URL}>
        <Routes>
          {/* The one unauthenticated route. */}
          <Route path="/partner-access" element={<PartnerAccess />} />
          <Route path="/*" element={<Authed />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  )
}
