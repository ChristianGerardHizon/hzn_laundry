#!/usr/bin/env bash
# =============================================================================
# Backfill processedDate for existing sales
# =============================================================================
# Run once after deploying the stamp_processed_date hook + processedDate field.
# For each ready/pickedUp sale with no processedDate, finds the earliest
# activityLogs entry where orderStatus changed to ready/pickedUp, and uses
# that log's created date as processedDate.
# Fallback order: activityLog.created → pickedUpAt → updated
#
# Usage:
#   PB_URL=https://hizonelaundry.hznsystems.com \
#   PB_EMAIL=test@test.com \
#   PB_PASSWORD=yourpassword \
#   bash backfill_processed_date.sh
#
# Or set vars inline:
#   export PB_URL=... PB_EMAIL=... PB_PASSWORD=...
#   bash backfill_processed_date.sh
# =============================================================================

set -euo pipefail

PB_URL="${PB_URL:-http://127.0.0.1:8090}"
PB_EMAIL="${PB_EMAIL:-}"
PB_PASSWORD="${PB_PASSWORD:-}"

if [[ -z "$PB_EMAIL" || -z "$PB_PASSWORD" ]]; then
  echo "Error: PB_EMAIL and PB_PASSWORD must be set."
  exit 1
fi

echo "==> Authenticating with $PB_URL ..."
TOKEN=$(curl -sf -X POST "$PB_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$PB_EMAIL\",\"password\":\"$PB_PASSWORD\"}" | jq -r '.token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "Error: Authentication failed."
  exit 1
fi
echo "    Authenticated."

PAGE=1
PER_PAGE=100
TOTAL_PROCESSED=0
TOTAL_SKIPPED=0

while true; do
  echo ""
  echo "==> Fetching page $PAGE of sales (orderStatus=ready/pickedUp, processedDate empty)..."

  RESPONSE=$(curl -sf \
    "$PB_URL/api/collections/sales/records?filter=orderStatus%3D'ready'||orderStatus%3D'pickedUp'&perPage=$PER_PAGE&page=$PAGE&sort=%2Bcreated" \
    -H "Authorization: Bearer $TOKEN")

  ITEMS=$(echo "$RESPONSE" | jq -c '.items[]')
  TOTAL_ITEMS=$(echo "$RESPONSE" | jq '.totalItems')
  TOTAL_PAGES=$(echo "$RESPONSE" | jq '.totalPages')

  if [[ -z "$ITEMS" ]]; then
    echo "    No more items."
    break
  fi

  while IFS= read -r SALE; do
    SALE_ID=$(echo "$SALE" | jq -r '.id')
    RECEIPT=$(echo "$SALE" | jq -r '.receiptNumber')
    ORDER_STATUS=$(echo "$SALE" | jq -r '.orderStatus')
    PICKED_UP_AT=$(echo "$SALE" | jq -r '.pickedUpAt // empty')
    UPDATED=$(echo "$SALE" | jq -r '.updated // empty')
    EXISTING_PROCESSED=$(echo "$SALE" | jq -r '.processedDate // empty')

    if [[ -n "$EXISTING_PROCESSED" ]]; then
      echo "    SKIP $RECEIPT — already has processedDate: $EXISTING_PROCESSED"
      ((TOTAL_SKIPPED++)) || true
      continue
    fi

    # Query activityLogs for earliest orderStatus→ready or pickedUp transition
    ENCODED_FILTER=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"collection='sales'&&recordId='$SALE_ID'&&action='update'\"))" 2>/dev/null || \
      echo "collection%3D'sales'%26%26recordId%3D'$SALE_ID'%26%26action%3D'update'")

    LOG_RESPONSE=$(curl -sf \
      "$PB_URL/api/collections/activityLogs/records?filter=$ENCODED_FILTER&perPage=50&sort=%2Bcreated" \
      -H "Authorization: Bearer $TOKEN" 2>/dev/null || echo '{"items":[]}')

    # Find earliest log entry where orderStatus changed to ready or pickedUp
    PROCESSED_DATE=$(echo "$LOG_RESPONSE" | jq -r '
      .items[]
      | select(.changes != null)
      | select(
          (.changes.orderStatus.new == "ready") or
          (.changes.orderStatus.new == "pickedUp")
        )
      | .created
    ' | head -1)

    if [[ -n "$PROCESSED_DATE" ]]; then
      # Extract date portion only (YYYY-MM-DD)
      DATE_ONLY=$(echo "$PROCESSED_DATE" | cut -c1-10)
      SOURCE="activityLog"
    elif [[ -n "$PICKED_UP_AT" ]]; then
      DATE_ONLY=$(echo "$PICKED_UP_AT" | cut -c1-10)
      SOURCE="pickedUpAt"
    elif [[ -n "$UPDATED" ]]; then
      DATE_ONLY=$(echo "$UPDATED" | cut -c1-10)
      SOURCE="updated(fallback)"
    else
      echo "    SKIP $RECEIPT — no date source found"
      ((TOTAL_SKIPPED++)) || true
      continue
    fi

    # PATCH the sale
    PATCH_RESULT=$(curl -sf -X PATCH \
      "$PB_URL/api/collections/sales/records/$SALE_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"processedDate\":\"${DATE_ONLY} 00:00:00.000Z\"}" 2>/dev/null | jq -r '.processedDate // "error"')

    echo "    SET $RECEIPT ($ORDER_STATUS) → processedDate=$DATE_ONLY [via $SOURCE]"
    ((TOTAL_PROCESSED++)) || true

  done <<< "$ITEMS"

  if [[ "$PAGE" -ge "$TOTAL_PAGES" ]]; then
    break
  fi
  ((PAGE++)) || true
done

echo ""
echo "==> Done. Processed: $TOTAL_PROCESSED, Skipped: $TOTAL_SKIPPED"
