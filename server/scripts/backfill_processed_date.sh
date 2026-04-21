#!/usr/bin/env bash
# =============================================================================
# Backfill processedDate for existing sales
# =============================================================================
# Run once after deploying the stamp_processed_date hook + processedDate field.
# For each ready/pickedUp sale with no processedDate, finds the earliest
# activityLogs entry where orderStatus transitioned INTO ready or pickedUp
# from any other status (i.e. was "set outside of processing" — including
# normal processing→ready/pickedUp and skips like pending→ready). The log's
# created timestamp is used as processedDate.
#
# Fallback: if no such activity log exists (e.g. created directly as
# ready/pickedUp, or logs were trimmed), falls back to postedDate/created.
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

DRY_RUN="${DRY_RUN:-0}"
PAGE=1
PER_PAGE=100
TOTAL_PROCESSED=0
TOTAL_SKIPPED=0
TOTAL_FALLBACK=0

if [[ "$DRY_RUN" == "1" ]]; then
  echo "    DRY_RUN=1 — no writes will be made."
fi

# Server-side filter: only sales that are ready/pickedUp AND missing processedDate.
SALES_FILTER="(orderStatus='ready'||orderStatus='pickedUp')&&(processedDate=''||processedDate=null)"
ENCODED_SALES_FILTER=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$SALES_FILTER")

while true; do
  echo ""
  echo "==> Fetching page $PAGE of affected sales..."

  RESPONSE=$(curl -sf \
    "$PB_URL/api/collections/sales/records?filter=$ENCODED_SALES_FILTER&perPage=$PER_PAGE&page=$PAGE&sort=%2Bcreated" \
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
    POSTED_DATE=$(echo "$SALE" | jq -r '.postedDate // empty')
    CREATED_DATE=$(echo "$SALE" | jq -r '.created // empty')

    # Query activityLogs for this sale (filter server-side to the specific record).
    LOG_FILTER="collection='sales'&&recordId='$SALE_ID'&&action='update'"
    ENCODED_LOG_FILTER=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$LOG_FILTER")

    LOG_RESPONSE=$(curl -sf \
      "$PB_URL/api/collections/activityLogs/records?filter=$ENCODED_LOG_FILTER&perPage=200&sort=%2Bcreated" \
      -H "Authorization: Bearer $TOKEN" 2>/dev/null || echo '{"items":[]}')

    # Find the earliest log entry where orderStatus transitioned INTO
    # ready or pickedUp from any other status. This covers:
    #   - normal processing → ready/pickedUp
    #   - skipped processing (e.g. pending → ready/pickedUp)
    # These are exactly the transitions that "set the order outside of
    # processing" — i.e. moved it past the processing stage.
    PROCESSED_TS=$(echo "$LOG_RESPONSE" | jq -r '
      [ .items[]
        | select(.changes != null)
        | select(.changes.orderStatus != null)
        | select(
            ((.changes.orderStatus.new == "ready") or
             (.changes.orderStatus.new == "pickedUp")) and
            (.changes.orderStatus.old != "ready") and
            (.changes.orderStatus.old != "pickedUp")
          )
        | .created
      ] | sort | .[0] // empty
    ')

    if [[ -n "$PROCESSED_TS" ]]; then
      DATE_ONLY=$(echo "$PROCESSED_TS" | cut -c1-10)
      SOURCE="activityLog"
    elif [[ -n "$POSTED_DATE" ]]; then
      DATE_ONLY=$(echo "$POSTED_DATE" | cut -c1-10)
      SOURCE="postedDate(fallback)"
      ((TOTAL_FALLBACK++)) || true
    elif [[ -n "$CREATED_DATE" ]]; then
      DATE_ONLY=$(echo "$CREATED_DATE" | cut -c1-10)
      SOURCE="created(fallback)"
      ((TOTAL_FALLBACK++)) || true
    else
      echo "    SKIP $RECEIPT — no activity log or fallback date"
      ((TOTAL_SKIPPED++)) || true
      continue
    fi

    NEW_PROCESSED="${DATE_ONLY} 00:00:00.000Z"

    if [[ "$DRY_RUN" == "1" ]]; then
      echo "    DRY  $RECEIPT ($ORDER_STATUS) → processedDate=$DATE_ONLY [via $SOURCE]"
    else
      curl -sf -X PATCH \
        "$PB_URL/api/collections/sales/records/$SALE_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"processedDate\":\"$NEW_PROCESSED\"}" > /dev/null
      echo "    SET  $RECEIPT ($ORDER_STATUS) → processedDate=$DATE_ONLY [via $SOURCE]"
    fi
    ((TOTAL_PROCESSED++)) || true

  done <<< "$ITEMS"

  # Do not advance the page: updated records drop out of the filter, so the
  # next page-1 fetch returns the remaining affected sales. In DRY_RUN we
  # do advance, since records aren't updated.
  if [[ "$DRY_RUN" == "1" ]]; then
    if [[ "$PAGE" -ge "$TOTAL_PAGES" ]]; then
      break
    fi
    ((PAGE++)) || true
  fi
done

echo ""
echo "==> Done. Updated: $TOTAL_PROCESSED (fallback: $TOTAL_FALLBACK), Skipped: $TOTAL_SKIPPED"
