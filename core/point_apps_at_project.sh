#!/usr/bin/env bash
# Point all three apps at a Supabase project.
#
#   ./core/point_apps_at_project.sh https://abcd1234.supabase.co sb_publishable_xxx
#
# Writes .env at the repo root, which is gitignored and which all three apps
# read at build time:
#
#   cd thayi && flutter run --dart-define-from-file=../.env
#
# One file rather than three env.dart edits, so two apps cannot end up on one
# project while the third is still on another - which fails looking like an RLS
# bug rather than a config mistake.
#
# The publishable (anon) key is meant to ship inside the client; RLS is what
# protects the data. The service-role key must never be passed here.
set -euo pipefail

URL="${1:-}"
KEY="${2:-}"

if [[ -z "$URL" || -z "$KEY" ]]; then
  echo "usage: $0 <supabase-url> <publishable-anon-key>" >&2
  echo "  e.g. $0 https://abcd1234.supabase.co sb_publishable_xxxxxxxx" >&2
  exit 1
fi

[[ "$URL" =~ ^https://[a-z0-9-]+\.supabase\.co/?$ ]] || {
  echo "that does not look like a project URL: $URL" >&2; exit 1; }
URL="${URL%/}"

case "$KEY" in
  sb_secret_*|service_role*|*.*.*)
    echo "REFUSING: that looks like a secret or JWT key." >&2
    echo "Use the publishable / anon key - it is the one safe to ship." >&2
    exit 1 ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

# Keep whatever else is in there (USE_SUPABASE, anything added later) and
# replace only the two keys, so re-pointing never silently drops a setting.
KEEP=""
if [[ -f "$ENV_FILE" ]]; then
  KEEP="$(grep -vE '^(SUPABASE_URL|SUPABASE_ANON_KEY)=' "$ENV_FILE" || true)"
  cp "$ENV_FILE" "$ENV_FILE.bak"
  echo "previous .env kept as .env.bak"
fi

{
  echo "SUPABASE_URL=$URL"
  echo "SUPABASE_ANON_KEY=$KEY"
  [[ -n "$KEEP" ]] && echo "$KEEP"
} > "$ENV_FILE"

# A .env that git can see is the whole problem this was meant to avoid.
if ! git -C "$ROOT" check-ignore -q .env 2>/dev/null; then
  echo "WARNING: .env is NOT gitignored - add it before committing." >&2
fi

echo
echo "$ENV_FILE"
sed 's/^/    /' "$ENV_FILE"
cat <<'NEXT'

Build any of the three with it:
  cd thayi && flutter run --dart-define-from-file=../.env
NEXT
