#!/usr/bin/env python3
"""Seed Sunrise Laundry on production into a full operational store.

Creates / updates (idempotent) under Sunrise Main:
  - Basic organizationSubscription
  - Sunrise-branded services (soft-deletes thin demo Wash / Dry Fold)
  - Retail products + house consumables + recipes
  - Dryer 1 / Dryer 2 (keeps existing washers + storages)
  - POS group "Main Menu" + items
  - Employees (no login users)
  - Active loyalty promo

Does NOT create Manager/Cashier/Attendant users. Christian stays sole Admin.

Usage:
  python server/scripts/seed_sunrise_full_store.py          # dry-run
  python server/scripts/seed_sunrise_full_store.py --apply  # write to prod
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"

SUNRISE_ORG_ID = "02wayjwoy6dz2fn"
SUNRISE_BRANCH_ID = "qsj8yw829tsm6hc"
BASIC_PACKAGE_ID = "zj5qfboi4wp8ws7"
CATEGORY_BASIC_SERVICE = "3p3uqkw8iusjld3"
UNIT_KILOGRAMS = "ulr7qlh8r4qej8u"

DEMO_SERVICE_NAMES = ("Sunrise Wash", "Sunrise Dry Fold")

SERVICES = [
    {
        "name": "Regular Wash",
        "price": 85,
        "weightBased": True,
        "category": CATEGORY_BASIC_SERVICE,
        "quantityUnit": UNIT_KILOGRAMS,
        "showPrompt": True,
        "estimatedDuration": 45,
        "description": "Wash only — per kg",
    },
    {
        "name": "Wash Dry Fold",
        "price": 130,
        "weightBased": True,
        "category": CATEGORY_BASIC_SERVICE,
        "quantityUnit": UNIT_KILOGRAMS,
        "showPrompt": True,
        "estimatedDuration": 90,
        "description": "Wash, dry, and fold — per kg",
    },
    {
        "name": "Full Service",
        "price": 150,
        "weightBased": True,
        "category": CATEGORY_BASIC_SERVICE,
        "quantityUnit": UNIT_KILOGRAMS,
        "showPrompt": True,
        "estimatedDuration": 120,
        "description": "Full laundry service — per kg",
    },
    {
        "name": "Dry Only",
        "price": 25,
        "weightBased": True,
        "category": CATEGORY_BASIC_SERVICE,
        "quantityUnit": UNIT_KILOGRAMS,
        "showPrompt": True,
        "estimatedDuration": 40,
        "description": "Drying only — per kg",
    },
    {
        "name": "Comforter / Bulky",
        "price": 180,
        "weightBased": False,
        "category": CATEGORY_BASIC_SERVICE,
        "quantityUnit": "",
        "showPrompt": False,
        "estimatedDuration": 90,
        "description": "Flat rate for comforter or bulky items",
    },
]

RETAIL_PRODUCTS = [
    {"name": "Powder Scoop", "price": 12, "forSale": True, "isConsumable": False},
    {"name": "Fabcon Scoop", "price": 12, "forSale": True, "isConsumable": False},
    {"name": "Color Safe", "price": 15, "forSale": True, "isConsumable": False},
    {"name": "Baking Soda", "price": 8, "forSale": True, "isConsumable": False},
    {"name": "Extra Soak", "price": 50, "forSale": True, "isConsumable": False},
]

CONSUMABLES = [
    {
        "name": "Detergent",
        "price": 0,
        "forSale": False,
        "isConsumable": True,
        "countsTowardMaterialCost": True,
        "defaultUsage": 30,
        "usageMin": 0,
        "usageMax": 100,
        "usageStep": 5,
        "unitCost": 0.5,
        "recipeDefaultQuantity": 30,
        "prefill": True,
    },
    {
        "name": "Softener",
        "price": 0,
        "forSale": False,
        "isConsumable": True,
        "countsTowardMaterialCost": True,
        "defaultUsage": 20,
        "usageMin": 0,
        "usageMax": 100,
        "usageStep": 5,
        "unitCost": 0.4,
        "recipeDefaultQuantity": 20,
        "prefill": True,
    },
    {
        "name": "Bleach",
        "price": 0,
        "forSale": False,
        "isConsumable": True,
        "countsTowardMaterialCost": True,
        "defaultUsage": 10,
        "usageMin": 0,
        "usageMax": 50,
        "usageStep": 5,
        "unitCost": 0.3,
        "recipeDefaultQuantity": 0,
        "prefill": False,
    },
]

# Recipes attach Detergent + Softener to these service names.
RECIPE_SERVICE_NAMES = ("Full Service", "Wash Dry Fold")

DRYERS = [
    {"name": "Dryer 1", "type": "dryer", "size": "large"},
    {"name": "Dryer 2", "type": "dryer", "size": "large"},
]

EMPLOYEES = [
    {"name": "Rosa", "baseSalary": 450},
    {"name": "Miguel", "baseSalary": 450},
    {"name": "Liza", "baseSalary": 400},
    {"name": "Carlo", "baseSalary": 400},
]

PROMO = {
    "name": "Sunrise Loyal 5",
    "description": "Free 5kg after 5 completed orders",
    "requiredOrders": 5,
    "rewardFreeWeight": 5,
}


def load_env() -> dict[str, str]:
    env: dict[str, str] = {}
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def req(
    base: str,
    path: str,
    method: str = "GET",
    token: str | None = None,
    body: dict | None = None,
):
    data = None if body is None else json.dumps(body).encode()
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(
        base + path, data=data, headers=headers, method=method
    )
    try:
        with urllib.request.urlopen(request) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode()
        try:
            payload = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            payload = {"raw": raw}
        return exc.code, payload


def must(status: int, expected: int | set[int], label: str, payload=None):
    expected_set = {expected} if isinstance(expected, int) else expected
    if status not in expected_set:
        raise SystemExit(f"{label} failed: HTTP {status} {payload}")
    print(f"OK {label}")
    return payload


def find_first(base: str, token: str, collection: str, filter_expr: str):
    params = urllib.parse.urlencode(
        {"page": 1, "perPage": 1, "filter": filter_expr}
    )
    status, payload = req(
        base,
        f"/api/collections/{collection}/records?{params}",
        token=token,
    )
    if status != 200:
        raise SystemExit(f"list {collection} failed: {status} {payload}")
    items = payload.get("items") or []
    return items[0] if items else None


def list_all(
    base: str,
    token: str,
    collection: str,
    filter_expr: str | None = None,
):
    items: list[dict] = []
    page = 1
    while True:
        params: dict = {"page": page, "perPage": 200}
        if filter_expr:
            params["filter"] = filter_expr
        q = urllib.parse.urlencode(params)
        status, payload = req(
            base, f"/api/collections/{collection}/records?{q}", token=token
        )
        if status != 200:
            raise SystemExit(f"list {collection} failed: {status} {payload}")
        items.extend(payload.get("items") or [])
        if page >= (payload.get("totalPages") or 1):
            break
        page += 1
    return items


def upsert(
    base: str,
    token: str,
    collection: str,
    filter_expr: str,
    body: dict,
    label: str,
    *,
    apply: bool,
):
    existing = find_first(base, token, collection, filter_expr)
    if existing:
        if not apply:
            print(f"DRY would update {label} ({existing['id']})")
            return existing
        status, payload = req(
            base,
            f"/api/collections/{collection}/records/{existing['id']}",
            method="PATCH",
            token=token,
            body=body,
        )
        return must(status, 200, f"update {label}", payload)
    if not apply:
        print(f"DRY would create {label}")
        return {"id": f"dry-{label}", **body}
    status, payload = req(
        base,
        f"/api/collections/{collection}/records",
        method="POST",
        token=token,
        body=body,
    )
    return must(status, 200, f"create {label}", payload)


def iso_z(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def print_counts(base: str, token: str, title: str) -> None:
    branch = SUNRISE_BRANCH_ID
    org = SUNRISE_ORG_ID
    bf = f"branch = '{branch}'"
    print(f"\n=== {title} ===")
    for coll, filt in [
        ("organizationSubscriptions", f"organization = '{org}'"),
        ("services", f"{bf} && isDeleted = false"),
        ("products", f"{bf} && isDeleted = false"),
        ("serviceConsumableRecipes", None),
        ("machines", f"{bf} && isDeleted = false"),
        ("storages", f"{bf} && isDeleted = false"),
        ("posGroups", f"{bf} && isDeleted = false"),
        ("employees", f"organization = '{org}' && isDeleted = false"),
        ("promos", f"{bf} && isDeleted = false"),
        (
            "organizationMemberships",
            f"organization = '{org}' && status = 'active'",
        ),
    ]:
        if coll == "serviceConsumableRecipes":
            # Count recipes whose service is on Sunrise branch
            services = list_all(
                base, token, "services", f"{bf} && isDeleted = false"
            )
            ids = {s["id"] for s in services}
            recipes = list_all(base, token, coll)
            n = sum(1 for r in recipes if r.get("service") in ids)
            print(f"  {coll}: {n}")
            continue
        items = list_all(base, token, coll, filt)
        print(f"  {coll}: {len(items)}")
        if coll == "organizationMemberships":
            print(f"    (expect 1 - Christian Admin only)")
        if coll == "machines":
            by_type: dict[str, int] = {}
            for m in items:
                by_type[m.get("type") or "?"] = (
                    by_type.get(m.get("type") or "?", 0) + 1
                )
            print(f"    types: {by_type}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Seed Sunrise Laundry full store on production"
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes to production (default is dry-run)",
    )
    args = parser.parse_args()
    apply: bool = args.apply

    env = load_env()
    base = (env.get("PROD_URL") or "").rstrip("/")
    email = env.get("PROD_EMAIL") or ""
    password = env.get("PROD_PASSWORD") or ""
    if not base or not email or not password:
        raise SystemExit("PROD_URL / PROD_EMAIL / PROD_PASSWORD missing in .env")

    status, auth = req(
        base,
        "/api/collections/_superusers/auth-with-password",
        method="POST",
        body={"identity": email, "password": password},
    )
    must(status, 200, "superuser auth", auth)
    token = auth["token"]

    org = find_first(base, token, "organizations", f"id = '{SUNRISE_ORG_ID}'")
    if not org or org.get("name") != "Sunrise Laundry":
        raise SystemExit(
            f"Expected Sunrise Laundry at {SUNRISE_ORG_ID}, got {org}"
        )
    branch = find_first(
        base, token, "branches", f"id = '{SUNRISE_BRANCH_ID}'"
    )
    if not branch or branch.get("organization") != SUNRISE_ORG_ID:
        raise SystemExit(f"Sunrise Main branch mismatch: {branch}")

    mode = "APPLY" if apply else "DRY-RUN"
    print(f"Mode: {mode} -> {base}")
    print(f"Org: {org['name']} ({org['id']})")
    print(f"Branch: {branch['name']} ({branch['id']})")
    print_counts(base, token, "BEFORE")

    # --- 1. Subscription ---
    now = datetime.now(timezone.utc)
    period_end = now + timedelta(days=30)
    upsert(
        base,
        token,
        "organizationSubscriptions",
        f"organization = '{SUNRISE_ORG_ID}' && isDeleted = false",
        {
            "organization": SUNRISE_ORG_ID,
            "package": BASIC_PACKAGE_ID,
            "packageName": "Basic",
            "price": 2000,
            "intervalCount": 1,
            "intervalUnit": "month",
            "status": "active",
            "periodStart": iso_z(now),
            "periodEnd": iso_z(period_end),
            "isDeleted": False,
        },
        "Sunrise Basic subscription",
        apply=apply,
    )

    # --- 2. Soft-delete demo services ---
    for name in DEMO_SERVICE_NAMES:
        existing = find_first(
            base,
            token,
            "services",
            f"branch = '{SUNRISE_BRANCH_ID}' && name = '{name}'",
        )
        if not existing:
            print(f"SKIP demo service missing: {name}")
            continue
        if existing.get("isDeleted"):
            print(f"OK already deleted {name}")
            continue
        upsert(
            base,
            token,
            "services",
            f"id = '{existing['id']}'",
            {"isDeleted": True},
            f"soft-delete {name}",
            apply=apply,
        )

    # --- 3. Services ---
    service_ids: dict[str, str] = {}
    for spec in SERVICES:
        body = {
            "name": spec["name"],
            "description": spec["description"],
            "branch": SUNRISE_BRANCH_ID,
            "price": spec["price"],
            "weightBased": spec["weightBased"],
            "category": spec["category"] or None,
            "quantityUnit": spec["quantityUnit"] or None,
            "showPrompt": spec["showPrompt"],
            "estimatedDuration": spec["estimatedDuration"],
            "isDeleted": False,
            "isVariablePrice": False,
            "isDefault": False,
            "allowExcess": True,
            "minimumCharge": 0,
        }
        # Clear empty relation strings
        if not body["category"]:
            body.pop("category")
        if not body["quantityUnit"]:
            body.pop("quantityUnit")
        rec = upsert(
            base,
            token,
            "services",
            (
                f"branch = '{SUNRISE_BRANCH_ID}' && name = '{spec['name']}'"
            ),
            body,
            f"service {spec['name']}",
            apply=apply,
        )
        service_ids[spec["name"]] = rec["id"]

    # --- 4. Products ---
    product_ids: dict[str, str] = {}
    for spec in RETAIL_PRODUCTS:
        body = {
            "name": spec["name"],
            "branch": SUNRISE_BRANCH_ID,
            "price": spec["price"],
            "forSale": True,
            "isConsumable": False,
            "isDeleted": False,
            "trackStock": False,
            "requireStock": False,
            "trackByLot": False,
            "quantity": 0,
            "countsTowardMaterialCost": False,
        }
        rec = upsert(
            base,
            token,
            "products",
            (
                f"branch = '{SUNRISE_BRANCH_ID}' && name = '{spec['name']}'"
            ),
            body,
            f"product {spec['name']}",
            apply=apply,
        )
        product_ids[spec["name"]] = rec["id"]

    for spec in CONSUMABLES:
        body = {
            "name": spec["name"],
            "branch": SUNRISE_BRANCH_ID,
            "price": spec["price"],
            "forSale": False,
            "isConsumable": True,
            "isDeleted": False,
            "trackStock": False,
            "requireStock": False,
            "trackByLot": False,
            "quantity": 0,
            "countsTowardMaterialCost": True,
            "defaultUsage": spec["defaultUsage"],
            "usageMin": spec["usageMin"],
            "usageMax": spec["usageMax"],
            "usageStep": spec["usageStep"],
            "unitCost": spec["unitCost"],
            "description": f"Sunrise house chemical — {spec['name']}",
        }
        rec = upsert(
            base,
            token,
            "products",
            (
                f"branch = '{SUNRISE_BRANCH_ID}' && name = '{spec['name']}'"
            ),
            body,
            f"consumable {spec['name']}",
            apply=apply,
        )
        product_ids[spec["name"]] = rec["id"]

    # --- 5. Recipes (Full Service + Wash Dry Fold → Detergent + Softener) ---
    recipe_products = [
        c for c in CONSUMABLES if c["name"] in ("Detergent", "Softener")
    ]
    for svc_name in RECIPE_SERVICE_NAMES:
        sid = service_ids.get(svc_name)
        if not sid or str(sid).startswith("dry-"):
            print(f"SKIP recipes for {svc_name} (no service id yet)")
            continue
        for cspec in recipe_products:
            pid = product_ids.get(cspec["name"])
            if not pid or str(pid).startswith("dry-"):
                print(f"SKIP recipe {svc_name}/{cspec['name']}")
                continue
            upsert(
                base,
                token,
                "serviceConsumableRecipes",
                f"service = '{sid}' && product = '{pid}'",
                {
                    "service": sid,
                    "product": pid,
                    "defaultQuantity": cspec["recipeDefaultQuantity"],
                    "prefill": cspec["prefill"],
                },
                f"recipe {svc_name} -> {cspec['name']}",
                apply=apply,
            )

    # --- 6. Dryers ---
    for dspec in DRYERS:
        upsert(
            base,
            token,
            "machines",
            (
                f"branch = '{SUNRISE_BRANCH_ID}' && name = '{dspec['name']}'"
                f" && isDeleted = false"
            ),
            {
                "name": dspec["name"],
                "branch": SUNRISE_BRANCH_ID,
                "type": dspec["type"],
                "size": dspec["size"],
                "strictSingleUse": False,
                "isDeleted": False,
            },
            f"machine {dspec['name']}",
            apply=apply,
        )

    # --- 7. POS group + items ---
    pos_group = upsert(
        base,
        token,
        "posGroups",
        (
            f"branch = '{SUNRISE_BRANCH_ID}' && name = 'Main Menu'"
            f" && isDeleted = false"
        ),
        {
            "name": "Main Menu",
            "branch": SUNRISE_BRANCH_ID,
            "sortOrder": 0,
            "isDeleted": False,
        },
        "POS group Main Menu",
        apply=apply,
    )
    gid = pos_group["id"]
    sort = 0
    if not str(gid).startswith("dry-"):
        for svc_name in [s["name"] for s in SERVICES]:
            sid = service_ids[svc_name]
            if str(sid).startswith("dry-"):
                continue
            upsert(
                base,
                token,
                "posGroupItems",
                f"group = '{gid}' && service = '{sid}'",
                {
                    "group": gid,
                    "service": sid,
                    "sortOrder": sort,
                },
                f"POS item service {svc_name}",
                apply=apply,
            )
            sort += 1
        for pname in [p["name"] for p in RETAIL_PRODUCTS]:
            pid = product_ids[pname]
            if str(pid).startswith("dry-"):
                continue
            upsert(
                base,
                token,
                "posGroupItems",
                f"group = '{gid}' && product = '{pid}'",
                {
                    "group": gid,
                    "product": pid,
                    "sortOrder": sort,
                },
                f"POS item product {pname}",
                apply=apply,
            )
            sort += 1
    else:
        print("DRY skip POS items (group not created yet)")

    # --- 8. Employees (no users) ---
    for espec in EMPLOYEES:
        upsert(
            base,
            token,
            "employees",
            (
                f"organization = '{SUNRISE_ORG_ID}'"
                f" && name = '{espec['name']}' && isDeleted = false"
            ),
            {
                "name": espec["name"],
                "organization": SUNRISE_ORG_ID,
                "baseSalary": espec["baseSalary"],
                "isDeleted": False,
            },
            f"employee {espec['name']}",
            apply=apply,
        )

    # --- 9. Promo ---
    start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    end = start + timedelta(days=365)
    upsert(
        base,
        token,
        "promos",
        (
            f"branch = '{SUNRISE_BRANCH_ID}' && name = '{PROMO['name']}'"
            f" && isDeleted = false"
        ),
        {
            "name": PROMO["name"],
            "description": PROMO["description"],
            "branch": SUNRISE_BRANCH_ID,
            "requiredOrders": PROMO["requiredOrders"],
            "rewardFreeWeight": PROMO["rewardFreeWeight"],
            "startDate": iso_z(start),
            "endDate": iso_z(end),
            "isActive": True,
            "isDeleted": False,
        },
        f"promo {PROMO['name']}",
        apply=apply,
    )

    if apply:
        print_counts(base, token, "AFTER")
    else:
        print(
            "\nDry-run complete. Re-run with --apply to write to production."
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
