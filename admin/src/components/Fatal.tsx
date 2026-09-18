import { Component, type ErrorInfo, type ReactNode } from 'react'

/// A white screen is the least useful failure a deployed app can have: it says
/// nothing to the person looking at it and nothing to whoever has to fix it.
/// Anything that escapes a render lands here and becomes a page that names it.
export class ErrorBoundary extends Component<{ children: ReactNode }, { error: Error | null }> {
  state = { error: null as Error | null }

  static getDerivedStateFromError(error: Error) {
    return { error }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('Setu Admin crashed:', error, info.componentStack)
  }

  render() {
    if (!this.state.error) return this.props.children
    return (
      <Fatal title="Something went wrong">
        <p className="mb-3">{this.state.error.message}</p>
        <p className="text-soft">
          The full stack is in the browser console. Reloading may clear it; if it does not, this is
          a bug worth reporting with what you were doing at the time.
        </p>
      </Fatal>
    )
  }
}

export function Fatal({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="min-h-screen grid place-items-center p-4">
      <div className="card p-6 max-w-lg">
        <h1 className="text-lg font-semibold mb-2">{title}</h1>
        <div>{children}</div>
      </div>
    </div>
  )
}

/// Shown when the build had no Supabase configuration. It names the variable,
/// says where to set it and why it cannot be fixed at runtime, because the
/// person seeing this is usually the person who has to go and set it.
export function ConfigError({ reason }: { reason: string }) {
  return (
    <Fatal title="This build has no Supabase configuration">
      <p className="mb-3">{reason}</p>
      <p className="mb-3 text-soft">
        Vite compiles these into the bundle when it builds, so this cannot be corrected by
        reloading — the values have to be set and the project redeployed.
      </p>
      <div className="card bg-paper p-3 font-mono text-[12px] mb-3">
        VITE_SUPABASE_URL=https://&lt;ref&gt;.supabase.co<br />
        VITE_SUPABASE_ANON_KEY=sb_publishable_…
      </div>
      <p className="text-soft">
        On Vercel: Settings → Environment Variables. Both need the readable visibility rather than
        secret — a <code className="font-mono">VITE_</code> prefix means the value ships inside the
        bundle, so it cannot be a secret, and the publishable key is designed to. Tick Production
        and Preview, then redeploy.
      </p>
    </Fatal>
  )
}
