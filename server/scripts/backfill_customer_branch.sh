#!/usr/bin/env bash
# =============================================================================
# Backfill customers.branch from each customer's most recent sale
# =============================================================================
# Local helper for the PocketBase at http://127.0.0.1:8090.
# Does not target staging or production.
#
# Assigns unassigned customers to a branch:
#   1. Branch of their most recent sale (sort -created)
#   2. Otherwise the first non-deleted branch (sort +created)
#
# Customers that already have a branch are skipped (idempotent).
# Dry-run is the DEFAULT. No writes happen until you pass --apply.
#
# Usage:
#   PB_EMAIL=... PB_PASSWORD=... bash server/scripts/backfill_customer_branch.sh
#   bash server/scripts/backfill_customer_branch.sh --apply
# =============================================================================

set -euo pipefail

PB_URL="${PB_URL:-http://127.0.0.1:8090}"
PB_EMAIL="${PB_EMAIL:-}"
PB_PASSWORD="${PB_PASSWORD:-}"
DRY_RUN="${DRY_RUN:-1}"

usage() {
  cat <<'EOF'
Backfill customers.branch from most recent sale (fallback: first branch).

Dry-run is the default. Pass --apply to write.

Usage:
  PB_EMAIL=... PB_PASSWORD=... bash server/scripts/backfill_customer_branch.sh
  PB_EMAIL=... PB_PASSWORD=... bash server/scripts/backfill_customer_branch.sh --apply

Runs against local PocketBase (http://127.0.0.1:8090) only.

Options:
  --dry-run   Preview assignments without writing (default)
  --apply     Write branch values to unassigned customers
  -h, --help  Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --apply) DRY_RUN=0 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$PB_EMAIL" || -z "$PB_PASSWORD" ]]; then
  echo "Error: PB_EMAIL and PB_PASSWORD must be set."
  exit 1
fi

case "$PB_URL" in
  http://127.0.0.1:*|http://localhost:*|http://127.0.0.1|http://localhost)
    ;;
  *)
    echo "Error: this script is local-only. PB_URL must be http://127.0.0.1:8090 (got $PB_URL)."
    exit 1
    ;;
esac

encode() {
  python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$1"
}

branch_name() {
  local id="$1"
  echo "$BRANCHES_JSON" | jq -r --arg id "$id" \
    '.items[] | select(.id == $id) | .name' | head -n 1
}

echo "==> Authenticating with $PB_URL ..."
TOKEN=$(curl -sf -X POST "$PB_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$PB_EMAIL\",\"password\":\"$PB_PASSWORD\"}" | jq -r '.token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "Error: Authentication failed."
  exit 1
fi
echo "    Authenticated."

if [[ "$DRY_RUN" == "1" ]]; then
  echo "    MODE=dry-run — no writes will be made. Pass --apply to write."
else
  echo "    MODE=apply — unassigned customers will be updated."
fi

echo ""
echo "==> Loading branches..."
BRANCHES_JSON=$(curl -sf \
  "$PB_URL/api/collections/branches/records?perPage=200&sort=%2Bcreated&filter=$(encode 'isDeleted = false')" \
  -H "Authorization: Bearer $TOKEN")

FALLBACK_ID=$(echo "$BRANCHES_JSON" | jq -r '.items[0].id // empty')
FALLBACK_NAME=$(echo "$BRANCHES_JSON" | jq -r '.items[0].name // empty')
BRANCH_COUNT=$(echo "$BRANCHES_JSON" | jq '.items | length')

if [[ -z "$FALLBACK_ID" ]]; then
  echo "Error: No active branches found."
  exit 1
fi

echo "    $BRANCH_COUNT active branch(es). Fallback: $FALLBACK_NAME ($FALLBACK_ID)"

PAGE=1
PER_PAGE=100
TOTAL_ASSIGN=0
TOTAL_SKIP_HAS_BRANCH=0
TOTAL_FROM_SALE=0
TOTAL_FROM_FALLBACK=0

while true; do
  echo ""
  echo "==> Fetching customers page $PAGE..."

  RESPONSE=$(curl -sf \
    "$PB_URL/api/collections/customers/records?perPage=$PER_PAGE&page=$PAGE&sort=id" \
    -H "Authorization: Bearer $TOKEN")

  TOTAL_PAGES=$(echo "$RESPONSE" | jq '.totalPages')
  ITEM_COUNT=$(echo "$RESPONSE" | jq '.items | length')

  if [[ "$ITEM_COUNT" -eq 0 ]]; then
    echo "    No more items."
    break
  fi

  while IFS= read -r CUSTOMER; do
    CID=$(echo "$CUSTOMER" | jq -r '.id')
    CNAME=$(echo "$CUSTOMER" | jq -r '.name')
    CURRENT=$(echo "$CUSTOMER" | jq -r '.branch // empty')

    if [[ -n "$CURRENT" ]]; then
      echo "    SKIP  $CNAME ($CID) — already branch=$(branch_name "$CURRENT") ($CURRENT)"
      TOTAL_SKIP_HAS_BRANCH=$((TOTAL_SKIP_HAS_BRANCH + 1))
      continue
    fi

    SALE_FILTER=$(encode "customer = \"$CID\"")
    SALE_JSON=$(curl -sf \
      "$PB_URL/api/collections/sales/records?perPage=1&sort=-created&filter=$SALE_FILTER" \
      -H "Authorization: Bearer $TOKEN")

    SALE_BRANCH=$(echo "$SALE_JSON" | jq -r '.items[0].branch // empty')
    SALE_RECEIPT=$(echo "$SALE_JSON" | jq -r '.items[0].receiptNumber // empty')

    if [[ -n "$SALE_BRANCH" ]]; then
      TARGET="$SALE_BRANCH"
      SOURCE="sale:$SALE_RECEIPT"
      TOTAL_FROM_SALE=$((TOTAL_FROM_SALE + 1))
    else
      TARGET="$FALLBACK_ID"
      SOURCE="fallback:$FALLBACK_NAME"
      TOTAL_FROM_FALLBACK=$((TOTAL_FROM_FALLBACK + 1))
    fi

    TARGET_LABEL="$(branch_name "$TARGET") ($TARGET)"

    if [[ "$DRY_RUN" == "1" ]]; then
      echo "    DRY   $CNAME ($CID) → $TARGET_LABEL [$SOURCE]"
    else
      curl -sf -X PATCH \
        "$PB_URL/api/collections/customers/records/$CID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"branch\":\"$TARGET\"}" > /dev/null
      echo "    SET   $CNAME ($CID) → $TARGET_LABEL [$SOURCE]"
    fi
    TOTAL_ASSIGN=$((TOTAL_ASSIGN + 1))
  done < <(echo "$RESPONSE" | jq -c '.items[]')

  if [[ "$PAGE" -ge "$TOTAL_PAGES" ]]; then
    break
  fi
  ((PAGE++)) || true
done

echo ""
if [[ "$DRY_RUN" == "1" ]]; then
  echo "==> Dry run complete."
  echo "    Would assign: $TOTAL_ASSIGN  (from sale: $TOTAL_FROM_SALE, fallback: $TOTAL_FROM_FALLBACK)"
  echo "    Already had branch: $TOTAL_SKIP_HAS_BRANCH"
  echo "    Re-run with --apply to write."
else
  echo "==> Done."
  echo "    Assigned: $TOTAL_ASSIGN  (from sale: $TOTAL_FROM_SALE, fallback: $TOTAL_FROM_FALLBACK)"
  echo "    Already had branch: $TOTAL_SKIP_HAS_BRANCH"
fi
