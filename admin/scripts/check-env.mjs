/// Fails the build when the Supabase configuration is missing.
///
/// Vite inlines VITE_ variables at build time, so without them the build
/// happily succeeds and ships a bundle that cannot talk to anything. The
/// failure then surfaces in a browser, minutes later and a long way from the
/// build that caused it. Better to stop here, where the reason lands in the
/// deploy log next to the commit that produced it.
import { loadEnv } from 'vite'

// Vite reads .env.local itself and never exports it to the shell, so checking
// process.env alone would fail every local build that is perfectly configured.
// loadEnv resolves the same files, in the same order, that the build will use.
const env = { ...loadEnv('production', process.cwd(), 'VITE_'), ...process.env }

const REQUIRED = ['VITE_SUPABASE_URL', 'VITE_SUPABASE_ANON_KEY']
const missing = REQUIRED.filter((k) => !env[k])

if (missing.length > 0) {
  console.error('\n  Build stopped: missing ' + missing.join(' and ') + '\n')
  if (process.env.VERCEL) {
    console.error(
      `  This is a Vercel build (env: ${process.env.VERCEL_ENV ?? 'unknown'}).\n` +
      '  Settings -> Environment Variables. Check all four:\n' +
      '    1. the names match exactly, including the VITE_ prefix\n' +
      `    2. they are ticked for this environment — this build is "${process.env.VERCEL_ENV ?? '?'}"\n` +
      '    3. visibility is the readable option, not secret\n' +
      '    4. you redeployed AFTER saving them; saving alone rebuilds nothing\n',
    )
  } else {
    console.error('  Copy .env.example to .env.local and fill it in.\n')
  }
  process.exit(1)
}

console.log(
  '  env ok: ' +
  env.VITE_SUPABASE_URL.replace(/https:\/\/([a-z0-9]+)\..*/, '$1') +
  ' (' + (process.env.VERCEL_ENV ?? 'local') + ')',
)
