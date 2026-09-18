#!/usr/bin/env bash
# The last step: hand OTP email over to the branded send-email function.
#
#   export SUPABASE_ACCESS_TOKEN=sbp_...
#   ./core/enable_email_hook.sh <project-ref> <resend-api-key> <from-address>
#
# e.g. ./core/enable_email_hook.sh abcd1234efgh re_abc123 no-reply@yourdomain.com
#
# Run this only once Resend has a VERIFIED DOMAIN and the from-address is on
# it. Without one, Resend refuses every recipient except the address that owns
# the Resend account, so one login works and the rest fail silently.
#
# Order is deliberate and is the whole reason this is a script. Enabling the
# hook before the function holds its secrets points Auth at a function that
# answers 500, and every sign-in across all three apps fails for as long as
# that window is open. So: secrets first, confirm, then flip the hook.
set -euo pipefail

REF="${1:-}"; RESEND="${2:-}"; FROM="${3:-}"
if [[ -z "$REF" || -z "$RESEND" || -z "$FROM" ]]; then
  echo "usage: $0 <project-ref> <resend-api-key> <from-address>" >&2
  exit 1
fi
: "${SUPABASE_ACCESS_TOKEN:?export SUPABASE_ACCESS_TOKEN=sbp_...}"

[[ "$RESEND" == re_* ]] || { echo "that does not look like a Resend key" >&2; exit 1; }
[[ "$FROM" == *@* ]]    || { echo "from-address must be an email address" >&2; exit 1; }

API="https://api.supabase.com/v1/projects/$REF/config/auth"
auth=(-H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json")

# The shared secret Auth signs each request with and the function verifies.
# Generated here rather than typed, so it is long and never reused.
# Standard base64, padding and all. GoTrue base64-decodes this itself and
# rejects the URL-safe alphabet - swapping +/ for -_ here fails at send time
# with "illegal base64 data", long after this script has reported success.
SECRET="v1,whsec_$(openssl rand -base64 32 | tr -d '\n')"

echo "1/3  function secrets"
npx supabase secrets set --project-ref "$REF" \
  RESEND_API_KEY="$RESEND" \
  SEND_EMAIL_HOOK_SECRET="$SECRET" \
  OTP_FROM_ADDRESS="$FROM" >/dev/null
echo "     RESEND_API_KEY, SEND_EMAIL_HOOK_SECRET, OTP_FROM_ADDRESS set"

echo "2/3  confirming the function stops answering 500"
# It should now reject an unsigned request as 401 rather than 500. 500 means
# it still has no secrets, and flipping the hook would break every sign-in.
for attempt in 1 2 3 4 5 6; do
  code=$(curl -sS -o /dev/null -w '%{http_code}' -X POST \
    "https://$REF.supabase.co/functions/v1/send-email" \
    -H "Content-Type: application/json" -d '{}' || true)
  [[ "$code" == "401" ]] && break
  echo "     still $code, waiting for the secrets to propagate ($attempt/6)"
  sleep 5
done
[[ "$code" == "401" ]] || {
  echo "     function still answering $code - NOT enabling the hook" >&2
  echo "     check: npx supabase functions logs send-email --project-ref $REF" >&2
  exit 1; }
echo "     401 as expected - signature check is live"

echo "3/3  pointing Auth at it"
# One field per call: this API silently discards a whole multi-field patch if
# any single field in it is not settable, and reports success anyway.
set_field() {
  curl -sS -X PATCH "$API" "${auth[@]}" -d "{\"$1\":$2}" \
    | python3 -c "import json,sys;print(f'     $1 = {json.load(sys.stdin).get(\"$1\")!r}')"
}
set_field hook_send_email_uri "\"https://$REF.supabase.co/functions/v1/send-email\""
set_field hook_send_email_secrets "\"$SECRET\""
set_field hook_send_email_enabled true

cat <<NEXT

Done. Sign in on each app and check the logo matches:
  npx supabase functions logs send-email --project-ref $REF

To roll back if mail stops arriving - Supabase's own sender takes over again,
unbranded but working:
  curl -X PATCH "$API" \\
    -H "Authorization: Bearer \$SUPABASE_ACCESS_TOKEN" \\
    -H "Content-Type: application/json" \\
    -d '{"hook_send_email_enabled":false}'
NEXT
