#!/usr/bin/env bash
# Deploy all four Edge Functions to a project.
#
#   ./core/deploy_functions.sh <project-ref>
#   ./core/deploy_functions.sh <project-ref> send-email     # just one
#
# Two things make this harder than it should be, and this script exists for
# both.
#
# The functions live in two places. send-email is under thayi/supabase/ because
# that is where `supabase init` was run; ask-setu, speak and transcribe are in
# core/functions/ because they serve all three apps. The CLI only looks in
# <workdir>/supabase/functions, so it can never see all four at once. This
# stages them into one temporary tree and deploys from there - nothing is
# copied into the repo.
#
# And the CLI bundles with Docker unless told otherwise. There is no Docker on
# this machine, so --use-api is not optional here; without it the deploy fails
# with an error about the daemon that reads like a CLI bug.
set -euo pipefail

REF="${1:-}"
if [[ -z "$REF" ]]; then
  echo "usage: $0 <project-ref> [function-name ...]" >&2
  echo "  the ref is the <this-part> in https://<this-part>.supabase.co" >&2
  exit 1
fi
shift || true

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/supabase/functions"
cp -R "$ROOT/thayi/supabase/functions/send-email" "$STAGE/supabase/functions/"
# Enumerated, not listed. A hardcoded list silently omits a function added
# later, and the failure is a deploy that reports success for the ones it knew
# about while the new one is simply absent.
for d in "$ROOT"/core/functions/*/; do
  [ -f "$d/index.ts" ] || continue
  # ${d%/} strips the trailing slash. With it, cp -R copies the directory's
  # CONTENTS into functions/ rather than the directory itself, and the deploy
  # fails looking for an entrypoint that is sitting one level too high.
  cp -R "${d%/}" "$STAGE/supabase/functions/"
done
# A .env copied in by accident would be uploaded with the function.
find "$STAGE/supabase/functions" -name '.env' -delete

# send-email is called by Auth, which signs the body itself - Supabase's own
# JWT gate would reject it before it ever ran. The other three are called by a
# signed-in app and keep the gate.
cat > "$STAGE/supabase/config.toml" <<TOML
project_id = "$REF"

# send-email is called by Auth, which signs the body itself - Supabase's own
# JWT gate would reject it before it ever ran.
[functions.send-email]
verify_jwt = false

# partner-api authenticates callers itself, three different ways depending on
# the route: a partner presents an API key, an administrator presents their
# session JWT. The gateway only understands the second, so it would reject
# every partner request with "Invalid JWT" before the function saw it. The
# function checks all of them, and refuses by default.
[functions.partner-api]
verify_jwt = false
TOML

echo "staged: $(ls "$STAGE/supabase/functions" | tr '\n' ' ')"
echo

npx supabase functions deploy "$@" \
  --project-ref "$REF" \
  --use-api \
  --workdir "$STAGE"

cat <<NEXT

Deployed. Check one is live:
  npx supabase functions logs send-email --project-ref $REF
NEXT
