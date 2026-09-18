#!/usr/bin/env bash
# Publish the OTP email logos to a public Supabase storage bucket.
#
#   export SUPABASE_SERVICE_ROLE_KEY=eyJ...      # Settings -> API -> service_role
#   ./core/upload_email_logos.sh
#
# Run once to create the bucket, then again whenever build_email_logos.py has
# regenerated brand/email/.
#
# The logos have to be fetchable over plain HTTPS with no auth: a mail client
# opening the image is not signed in to anything, and a signed URL would expire
# long before the email stops being opened. So the bucket is public, and it
# holds nothing but three logos.
#
# The bucket name matters - the function's default BRAND_ASSET_BASE points at
# `brand`, and each object is named for its Brand.key.
set -euo pipefail

: "${SUPABASE_SERVICE_ROLE_KEY:?export SUPABASE_SERVICE_ROLE_KEY=<service_role key>}"

REF="${SUPABASE_PROJECT_REF:-idngqijhodyahdgodybt}"
URL="${SUPABASE_URL:-https://$REF.supabase.co}"
BUCKET="${BRAND_BUCKET:-brand}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../brand/email" && pwd)"

auth=(-H "apikey: $SUPABASE_SERVICE_ROLE_KEY"
      -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY")

# Idempotent: a second run gets "Bucket already exists", which is not an error
# here. Cache hard - these change once a year at most, and every open of every
# OTP email fetches one.
echo "bucket $BUCKET"
curl -sS -X POST "$URL/storage/v1/bucket" "${auth[@]}" \
  -H "Content-Type: application/json" \
  -d "{\"id\":\"$BUCKET\",\"name\":\"$BUCKET\",\"public\":true,
       \"allowed_mime_types\":[\"image/png\"],\"file_size_limit\":1048576}" \
  | sed 's/^/  /'
echo

for key in thayi asha care; do
  file="$DIR/$key.png"
  [[ -f "$file" ]] || { echo "missing $file - run build_email_logos.py" >&2; exit 1; }
  # x-upsert so re-running replaces rather than failing on the second run.
  curl -sS -X POST "$URL/storage/v1/object/$BUCKET/$key.png" "${auth[@]}" \
    -H "Content-Type: image/png" \
    -H "x-upsert: true" \
    -H "Cache-Control: public, max-age=31536000, immutable" \
    --data-binary "@$file" | sed 's/^/  /'
  echo "  -> $URL/storage/v1/object/public/$BUCKET/$key.png"
done

echo
echo "Check one loads signed out, in a private window:"
echo "  $URL/storage/v1/object/public/$BUCKET/thayi.png"
