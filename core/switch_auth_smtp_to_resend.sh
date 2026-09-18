#!/usr/bin/env bash
# Point Supabase auth email at Resend instead of Gmail.
#
# DO NOT RUN THIS UNTIL A DOMAIN IS VERIFIED IN RESEND.
#
# With no verified domain, Resend only delivers to the address that owns the
# account. Every other recipient is refused outright:
#
#   "You can only send testing emails to your own email address
#    (health.arogyasethu@gmail.com). To send emails to other recipients,
#    please verify a domain"
#
# Auth email is how every one of the eight demo logins receives its OTP, so
# switching before a domain is verified locks seven of them out.
#
# To verify a domain: Resend dashboard -> Domains -> Add Domain, then publish
# the DKIM/SPF records it gives you. Once it reads "verified", set FROM below
# to an address at that domain and run this.
set -euo pipefail

: "${SB_TOKEN:?export SB_TOKEN=<supabase personal access token>}"
: "${RESEND_API_KEY:?export RESEND_API_KEY=<re_...>}"

REF="${SUPABASE_PROJECT_REF:-idngqijhodyahdgodybt}"
FROM="${RESEND_FROM:-noreply@yourdomain.example}"
SENDER_NAME="${RESEND_SENDER_NAME:-Thayi Setu}"

if [[ "$FROM" == *yourdomain.example ]]; then
  echo "Set RESEND_FROM to an address at your verified domain first." >&2
  exit 1
fi

# Resend's SMTP bridge. The username is the literal string "resend"; the
# password is the API key.
curl -sS -X PATCH "https://api.supabase.com/v1/projects/$REF/config/auth" \
  -H "Authorization: Bearer $SB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  "smtp_host": "smtp.resend.com",
  "smtp_port": 465,
  "smtp_user": "resend",
  "smtp_pass": "$RESEND_API_KEY",
  "smtp_admin_email": "$FROM",
  "smtp_sender_name": "$SENDER_NAME"
}
JSON
)" | python3 -c "import json,sys; d=json.load(sys.stdin); print('smtp_host now:', d.get('smtp_host'))"

echo "Send yourself an OTP and confirm it arrives before relying on this."
