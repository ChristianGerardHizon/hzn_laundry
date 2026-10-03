#!/usr/bin/env python3
"""Seed Soybean Laundry full store on local, staging, and/or production.

Creates / updates (idempotent):
  - Organization "Soybean Laundry" + Main branch
  - Org logo from server/scripts/assets/soybean_laundry_logo.jpg
  - Admin membership for christiangerardhizon@gmail.com
  - Default featureFlags
  - Super Admin override: consumableUsage enabled
  - Premade package "Basic Package Semi Annually" (₱12,000 / 6 months)
  - Active organizationSubscription
  - Service "Wash and Dry" at ₱22/kg
  - Typical retail products + house consumables + recipes
  - Washer 1–2, Dryer 1–2
  - Front Shelf / Back Shelf storages
  - POS group "Main Menu" + items

Does NOT create employees, promos, or Manager/Cashier login users.
Christian stays sole Admin. Staff invites should use the global Manager role.

Usage:
  python server/scripts/seed_soybean_full_store.py --env local
  python server/scripts/seed_soybean_full_store.py --env staging --apply
  python server/scripts/seed_soybean_full_store.py --all --apply
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"
LOGO_PATH = Path(__file__).resolve().parent / "assets" / "soybean_laundry_logo.jpg"

ORG_NAME = "Soybean Laundry"
ORG_SLUG = "soybean-laundry"
BRANCH_NAME = "Main"
BRANCH_SLUG = "main"
CONTACT = "09170000000"
ADDRESS = "Soybean Laundry, Philippines"
ADMIN_EMAIL = "christiangerardhizon@gmail.com"

PACKAGE_NAME = "Basic Package Semi Annually"
PACKAGE_PRICE = 12000
PACKAGE_INTERVAL_COUNT = 6
PACKAGE_INTERVAL_UNIT = "month"
PACKAGE_PERIOD_DAYS = 183

SERVICE_NAME = "Wash and Dry"
SERVICE_PRICE = 22

DEFAULT_FEATURE_FLAGS = [
    {
        "key": "emailUpdatesEnabled",
        "enabled": True,
        "description": "Send order history link emails to customers",
    },
    {
        "key": "requireMachine",
        "enabled": False,
        "description": "Block moving to Processing if no machine is assigned",
    },
    {
        "key": "requirePack",
        "enabled": False,
        "description": "Block moving to Ready if no packs are set on the order",
    },
    {
        "key": "requireStorage",
        "enabled": False,
        "description": "Block moving to Ready if no storage location is assigned",
    },
]

RETAIL_PRODUCTS = [
    {"name": "Powder Scoop", "price": 12},
    {"name": "Fabcon Scoop", "price": 12},
    {"name": "Color Safe", "price": 15},
    {"name": "Baking Soda", "price": 8},
    {"name": "Extra Soak", "price": 50},
]

CONSUMABLES = [
    {
        "name": "Detergent",
        "price": 0,
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
        "defaultUsage": 10,
        "usageMin": 0,
        "usageMax": 50,
        "usageStep": 5,
        "unitCost": 0.3,
        "recipeDefaultQuantity": 0,
        "prefill": False,
    },
]

MACHINES = [
    {"name": "Washer 1", "type": "washer", "size": "large"},
    {"name": "Washer 2", "type": "washer", "size": "large"},
    {"name": "Dryer 1", "type": "dryer", "size": "large"},
    {"name": "Dryer 2", "type": "dryer", "size": "large"},
]

STORAGES = ["Front Shelf", "Back Shelf"]

ENV_CONFIG = {
    "local": {
        "url_keys": ("LOCAL_API_URL",),
        "default_url": "http://127.0.0.1:8088",
        "email_keys": ("LOCAL_EMAIL", "PB_PROD_EMAIL", "PB_EMAIL"),
        "password_keys": ("LOCAL_PASSWORD", "PB_PROD_PASSWORD", "PB_PASSWORD"),
    },
    "staging": {
        "url_keys": ("STAGING_URL",),
        "default_url": "https://staging.hznlaundry.hznsystems.com",
        "email_keys": ("STAGING_EMAIL", "PB_STAGING_EMAIL"),
        "password_keys": ("STAGING_PASSWORD", "PB_STAGING_PASSWORD"),
    },
    "prod": {
        "url_keys": ("PROD_URL",),
        "default_url": "https://hznlaundry.hznsystems.com",
        "email_keys": ("PROD_EMAIL", "PB_PROD_EMAIL"),
        "password_keys": ("PROD_PASSWORD", "PB_PROD_PASSWORD"),
    },
}


def load_env() -> dict[str, str]:
    env: dict[str, str] = {}
    if not ENV_PATH.exists():
        return env
    text = ENV_PATH.read_text(encoding="utf-8-sig")
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def first_env(env: dict[str, str], keys: tuple[str, ...]) -> str:
    for key in keys:
        value = (env.get(key) or "").strip()
        if value:
            return value
    return ""


def resolve_env(env_name: str, env: dict[str, str]) -> tuple[str, str, str]:
    cfg = ENV_CONFIG[env_name]
    base = first_env(env, cfg["url_keys"]) or cfg["default_url"]
    base = base.rstrip("/")
    email = first_env(env, cfg["email_keys"])
    password = first_env(env, cfg["password_keys"])
    if not email or not password:
        raise SystemExit(
            f"Missing superuser credentials for {env_name}. "
            f"Set one of {cfg['email_keys']} / {cfg['password_keys']} in .env"
        )
    # Safety: never point at Hi-Zone hosts
    if "hizonelaundry" in base.lower():
        raise SystemExit(f"Refusing Hi-Zone host: {base}")
    return base, email, password


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
        return {"id": f"dry-{re.sub(r'[^a-zA-Z0-9]+', '-', label)}", **body}
    status, payload = req(
        base,
        f"/api/collections/{collection}/records",
        method="POST",
        token=token,
        body=body,
    )
    return must(status, 200, f"create {label}", payload)


def upload_logo(
    base: str,
    token: str,
    org_id: str,
    logo_path: Path,
    *,
    apply: bool,
) -> None:
    if not logo_path.is_file():
        raise SystemExit(f"Logo file missing: {logo_path}")
    if str(org_id).startswith("dry-"):
        print(f"DRY would upload logo from {logo_path.name}")
        return
    if not apply:
        print(f"DRY would upload logo from {logo_path.name} -> org {org_id}")
        return

    boundary = "----SoybeanLogoBoundary7MA4YWxkTrZu0gW"
    file_bytes = logo_path.read_bytes()
    filename = logo_path.name
    body = b"".join(
        [
            f"--{boundary}\r\n".encode(),
            (
                f'Content-Disposition: form-data; name="logo"; '
                f'filename="{filename}"\r\n'
            ).encode(),
            b"Content-Type: image/jpeg\r\n\r\n",
            file_bytes,
            b"\r\n",
            f"--{boundary}--\r\n".encode(),
        ]
    )
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": f"multipart/form-data; boundary={boundary}",
    }
    request = urllib.request.Request(
        f"{base}/api/collections/organizations/records/{org_id}",
        data=body,
        headers=headers,
        method="PATCH",
    )
    try:
        with urllib.request.urlopen(request) as resp:
            raw = resp.read().decode()
            payload = json.loads(raw) if raw else {}
            logo_name = payload.get("logo") or ""
            if not logo_name:
                raise SystemExit(f"upload logo failed: empty logo field {payload}")
            print(f"OK upload logo ({logo_name})")
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode()
        raise SystemExit(f"upload logo failed: HTTP {exc.code} {raw}") from exc


def iso_z(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def resolve_kg_unit(base: str, token: str) -> str:
    unit = find_first(
        base,
        token,
        "quantityUnits",
        "name ~ 'Kilogram' && isDeleted = false",
    )
    if not unit:
        unit = find_first(
            base, token, "quantityUnits", "name ~ 'kg' && isDeleted = false"
        )
    if not unit:
        raise SystemExit("quantityUnits: no Kilograms/kg unit found")
    print(f"OK quantity unit {unit.get('name')} ({unit['id']})")
    return unit["id"]


def resolve_service_category(base: str, token: str) -> str | None:
    category = find_first(
        base,
        token,
        "serviceCategories",
        "name ~ 'Basic' && isDeleted = false",
    )
    if not category:
        category = find_first(
            base, token, "serviceCategories", "isDeleted = false"
        )
    if not category:
        print("WARN no serviceCategories found — service will omit category")
        return None
    print(f"OK service category {category.get('name')} ({category['id']})")
    return category["id"]


def resolve_basic_package_template(base: str, token: str) -> dict:
    basic = find_first(
        base,
        token,
        "subscriptionPackages",
        "name = 'Basic' && isPremade = true && isDeleted = false",
    )
    if not basic:
        basic = find_first(
            base,
            token,
            "subscriptionPackages",
            "name ~ 'Basic' && isPremade = true && isDeleted = false",
        )
    if basic:
        print(f"OK Basic package template ({basic['id']})")
        return basic
    print("WARN Basic package not found — using empty features / null limits")
    return {}


def print_counts(base: str, token: str, org_id: str, branch_id: str, title: str):
    bf = f"branch = '{branch_id}'"
    print(f"\n=== {title} ===")
    for coll, filt in [
        ("organizationSubscriptions", f"organization = '{org_id}'"),
        ("featureFlags", f"organization = '{org_id}'"),
        ("services", f"{bf} && isDeleted = false"),
        ("products", f"{bf} && isDeleted = false"),
        ("machines", f"{bf} && isDeleted = false"),
        ("storages", f"{bf} && isDeleted = false"),
        ("posGroups", f"{bf} && isDeleted = false"),
        (
            "organizationMemberships",
            f"organization = '{org_id}' && status = 'active'",
        ),
        ("employees", f"organization = '{org_id}' && isDeleted = false"),
        ("promos", f"{bf} && isDeleted = false"),
    ]:
        items = list_all(base, token, coll, filt)
        print(f"  {coll}: {len(items)}")


def seed_env(env_name: str, env: dict[str, str], *, apply: bool) -> None:
    base, email, password = resolve_env(env_name, env)
    mode = "APPLY" if apply else "DRY-RUN"
    print(f"\n######## {env_name.upper()} ({mode}) -> {base}")

    status, auth = req(
        base,
        "/api/collections/_superusers/auth-with-password",
        method="POST",
        body={"identity": email, "password": password},
    )
    must(status, 200, f"{env_name} superuser auth", auth)
    token = auth["token"]

    admin_role = find_first(
        base, token, "userRoles", "name = 'Admin' && isSystem = true"
    )
    if not admin_role:
        raise SystemExit(f"{env_name}: Admin system role not found")

    christian = find_first(base, token, "users", f"email = '{ADMIN_EMAIL}'")
    if not christian:
        raise SystemExit(
            f"{env_name}: user {ADMIN_EMAIL} not found — create/login that "
            "account before seeding Soybean"
        )
    print(f"OK admin user {ADMIN_EMAIL} ({christian['id']})")

    now = datetime.now(timezone.utc)
    org = upsert(
        base,
        token,
        "organizations",
        f"name = '{ORG_NAME}' && isDeleted = false",
        {
            "name": ORG_NAME,
            "slug": ORG_SLUG,
            "contactNumber": CONTACT,
            "address": ADDRESS,
            "isDeleted": False,
            "onboardingCompletedAt": iso_z(now),
        },
        f"org {ORG_NAME}",
        apply=apply,
    )
    org_id = org["id"]
    upload_logo(base, token, org_id, LOGO_PATH, apply=apply)

    branch = upsert(
        base,
        token,
        "branches",
        f"organization = '{org_id}' && name = '{BRANCH_NAME}'",
        {
            "name": BRANCH_NAME,
            "slug": BRANCH_SLUG,
            "address": ADDRESS,
            "contactNumber": CONTACT,
            "organization": org_id,
            "operatingHours": "",
            "cutOffTime": "",
            "isDeleted": False,
        },
        f"branch {BRANCH_NAME}",
        apply=apply,
    )
    branch_id = branch["id"]

    if apply:
        print_counts(base, token, org_id, branch_id, f"{env_name} BEFORE")

    upsert(
        base,
        token,
        "organizationMemberships",
        f"user = '{christian['id']}' && organization = '{org_id}'",
        {
            "user": christian["id"],
            "organization": org_id,
            "role": admin_role["id"],
            "status": "active",
            "joinedAt": iso_z(now),
        },
        f"membership {ADMIN_EMAIL} Admin",
        apply=apply,
    )

    for flag in DEFAULT_FEATURE_FLAGS:
        upsert(
            base,
            token,
            "featureFlags",
            f"organization = '{org_id}' && key = '{flag['key']}'",
            {
                "organization": org_id,
                "key": flag["key"],
                "enabled": flag["enabled"],
                "description": flag["description"],
            },
            f"featureFlag {flag['key']}",
            apply=apply,
        )

    # Basic package includes products but not consumableUsage; force it on.
    upsert(
        base,
        token,
        "organizationFeatureOverrides",
        f"organization = '{org_id}' && featureKey = 'consumableUsage'",
        {
            "organization": org_id,
            "featureKey": "consumableUsage",
            "enabled": True,
            "note": "Enable consumable usage for Soybean Laundry",
        },
        "feature override consumableUsage",
        apply=apply,
    )

    basic_template = resolve_basic_package_template(base, token)
    package_body = {
        "name": PACKAGE_NAME,
        "description": "Basic features billed semi-annually (₱2,000/month × 6)",
        "price": PACKAGE_PRICE,
        "intervalCount": PACKAGE_INTERVAL_COUNT,
        "intervalUnit": PACKAGE_INTERVAL_UNIT,
        "isPremade": True,
        "isActive": True,
        "isDeleted": False,
        "features": basic_template.get("features") or [],
        "maxBranches": basic_template.get("maxBranches"),
        "maxEmployees": basic_template.get("maxEmployees"),
    }
    # Clear null limits so PB doesn't reject; omit keys when None
    if package_body["maxBranches"] is None:
        package_body.pop("maxBranches")
    if package_body["maxEmployees"] is None:
        package_body.pop("maxEmployees")

    package = upsert(
        base,
        token,
        "subscriptionPackages",
        f"name = '{PACKAGE_NAME}' && isDeleted = false",
        package_body,
        f"package {PACKAGE_NAME}",
        apply=apply,
    )

    period_end = now + timedelta(days=PACKAGE_PERIOD_DAYS)
    upsert(
        base,
        token,
        "organizationSubscriptions",
        f"organization = '{org_id}' && isDeleted = false",
        {
            "organization": org_id,
            "package": package["id"],
            "packageName": PACKAGE_NAME,
            "price": PACKAGE_PRICE,
            "intervalCount": PACKAGE_INTERVAL_COUNT,
            "intervalUnit": PACKAGE_INTERVAL_UNIT,
            "status": "active",
            "periodStart": iso_z(now),
            "periodEnd": iso_z(period_end),
            "isDeleted": False,
        },
        "organizationSubscription",
        apply=apply,
    )

    kg_id = resolve_kg_unit(base, token)
    category_id = resolve_service_category(base, token)

    service_body = {
        "name": SERVICE_NAME,
        "description": "Wash and dry — per kg",
        "branch": branch_id,
        "price": SERVICE_PRICE,
        "weightBased": True,
        "quantityUnit": kg_id,
        "showPrompt": True,
        "estimatedDuration": 90,
        "isDeleted": False,
        "isVariablePrice": False,
        "isDefault": False,
        "allowExcess": True,
        "minimumCharge": 0,
    }
    if category_id:
        service_body["category"] = category_id

    service = upsert(
        base,
        token,
        "services",
        f"branch = '{branch_id}' && name = '{SERVICE_NAME}'",
        service_body,
        f"service {SERVICE_NAME}",
        apply=apply,
    )
    service_id = service["id"]

    product_ids: dict[str, str] = {}
    for spec in RETAIL_PRODUCTS:
        rec = upsert(
            base,
            token,
            "products",
            f"branch = '{branch_id}' && name = '{spec['name']}'",
            {
                "name": spec["name"],
                "branch": branch_id,
                "price": spec["price"],
                "forSale": True,
                "isConsumable": False,
                "isDeleted": False,
                "trackStock": False,
                "requireStock": False,
                "trackByLot": False,
                "quantity": 0,
                "countsTowardMaterialCost": False,
            },
            f"product {spec['name']}",
            apply=apply,
        )
        product_ids[spec["name"]] = rec["id"]

    for spec in CONSUMABLES:
        rec = upsert(
            base,
            token,
            "products",
            f"branch = '{branch_id}' && name = '{spec['name']}'",
            {
                "name": spec["name"],
                "branch": branch_id,
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
                "description": f"Soybean house chemical — {spec['name']}",
            },
            f"consumable {spec['name']}",
            apply=apply,
        )
        product_ids[spec["name"]] = rec["id"]

    if not str(service_id).startswith("dry-"):
        for cspec in CONSUMABLES:
            if cspec["name"] not in ("Detergent", "Softener"):
                continue
            pid = product_ids[cspec["name"]]
            if str(pid).startswith("dry-"):
                continue
            upsert(
                base,
                token,
                "serviceConsumableRecipes",
                f"service = '{service_id}' && product = '{pid}'",
                {
                    "service": service_id,
                    "product": pid,
                    "defaultQuantity": cspec["recipeDefaultQuantity"],
                    "prefill": cspec["prefill"],
                },
                f"recipe {SERVICE_NAME} -> {cspec['name']}",
                apply=apply,
            )

    for mspec in MACHINES:
        upsert(
            base,
            token,
            "machines",
            (
                f"branch = '{branch_id}' && name = '{mspec['name']}'"
                f" && isDeleted = false"
            ),
            {
                "name": mspec["name"],
                "branch": branch_id,
                "type": mspec["type"],
                "size": mspec["size"],
                "strictSingleUse": False,
                "isDeleted": False,
            },
            f"machine {mspec['name']}",
            apply=apply,
        )

    for sname in STORAGES:
        upsert(
            base,
            token,
            "storages",
            f"branch = '{branch_id}' && name = '{sname}' && isDeleted = false",
            {
                "name": sname,
                "branch": branch_id,
                "isAvailable": True,
                "isDeleted": False,
            },
            f"storage {sname}",
            apply=apply,
        )

    pos_group = upsert(
        base,
        token,
        "posGroups",
        f"branch = '{branch_id}' && name = 'Main Menu' && isDeleted = false",
        {
            "name": "Main Menu",
            "branch": branch_id,
            "sortOrder": 0,
            "isDeleted": False,
        },
        "POS group Main Menu",
        apply=apply,
    )
    gid = pos_group["id"]
    sort = 0
    if not str(gid).startswith("dry-"):
        if not str(service_id).startswith("dry-"):
            upsert(
                base,
                token,
                "posGroupItems",
                f"group = '{gid}' && service = '{service_id}'",
                {
                    "group": gid,
                    "service": service_id,
                    "sortOrder": sort,
                },
                f"POS item service {SERVICE_NAME}",
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

    if apply:
        print_counts(base, token, org_id, branch_id, f"{env_name} AFTER")
    else:
        print(f"\nDry-run complete for {env_name}. Re-run with --apply to write.")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Seed Soybean Laundry full store (local/staging/prod)"
    )
    parser.add_argument(
        "--env",
        choices=("local", "staging", "prod"),
        help="Target environment",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Run against local, staging, and prod in sequence",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write changes (default is dry-run)",
    )
    args = parser.parse_args()

    if bool(args.all) == bool(args.env):
        raise SystemExit("Specify exactly one of --env <name> or --all")

    targets = ["local", "staging", "prod"] if args.all else [args.env]
    env = load_env()

    for name in targets:
        seed_env(name, env, apply=args.apply)

    return 0


if __name__ == "__main__":
    sys.exit(main())
