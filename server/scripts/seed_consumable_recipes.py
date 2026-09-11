#!/usr/bin/env python3
"""Seed fake house-chemical products + service consumable recipes on local PB.

Creates / updates:
  - 3 consumable products: Detergent, Fabric Softener, Bleach
  - serviceConsumableRecipes on every non-deleted service
  - featureFlags.consumableUsage=true for orgs that own those services

Usage:
  python server/scripts/seed_consumable_recipes.py
"""

from __future__ import annotations

import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"

CONSUMABLES = [
    {
        "name": "Detergent",
        "defaultUsage": 30,
        "usageStep": 5,
        "unitCost": 0.5,
        "recipeDefaultQuantity": 30,
        "prefill": True,
    },
    {
        "name": "Fabric Softener",
        "defaultUsage": 20,
        "usageStep": 5,
        "unitCost": 0.4,
        "recipeDefaultQuantity": 20,
        "prefill": True,
    },
    {
        "name": "Bleach",
        "defaultUsage": 10,
        "usageStep": 5,
        "unitCost": 0.3,
        "recipeDefaultQuantity": 0,
        "prefill": False,  # must-enter on Create Order
    },
]


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
    expand: str | None = None,
):
    items: list[dict] = []
    page = 1
    while True:
        params: dict[str, str | int] = {"page": page, "perPage": 200}
        if filter_expr:
            params["filter"] = filter_expr
        if expand:
            params["expand"] = expand
        qs = urllib.parse.urlencode(params)
        status, payload = req(
            base,
            f"/api/collections/{collection}/records?{qs}",
            token=token,
        )
        if status != 200:
            raise SystemExit(f"list {collection} failed: {status} {payload}")
        batch = payload.get("items") or []
        items.extend(batch)
        total_pages = int(payload.get("totalPages") or 1)
        if page >= total_pages:
            break
        page += 1
    return items


def upsert_record(
    base: str,
    token: str,
    collection: str,
    filter_expr: str,
    body: dict,
    label: str,
):
    existing = find_first(base, token, collection, filter_expr)
    if existing:
        status, payload = req(
            base,
            f"/api/collections/{collection}/records/{existing['id']}",
            method="PATCH",
            token=token,
            body=body,
        )
        return must(status, 200, f"update {label}", payload)
    status, payload = req(
        base,
        f"/api/collections/{collection}/records",
        method="POST",
        token=token,
        body=body,
    )
    return must(status, 200, f"create {label}", payload)


def assert_local_only(base: str) -> None:
    host = (urlparse(base).hostname or "").lower()
    if host not in {"localhost", "127.0.0.1"}:
        raise SystemExit(
            f"Refusing to run against non-local host '{host}'. "
            "Set LOCAL_API_URL to http://localhost:8088 (or 127.0.0.1)."
        )
    if "hizonelaundry" in base.lower():
        raise SystemExit("Refusing to touch hizonelaundry hosts")


def main() -> int:
    env = load_env()
    base = (env.get("LOCAL_API_URL") or "http://127.0.0.1:8088").rstrip("/")
    assert_local_only(base)

    su_email = env.get("LOCAL_EMAIL", "")
    su_password = env.get("LOCAL_PASSWORD", "")
    if not su_email or not su_password:
        raise SystemExit("LOCAL_EMAIL / LOCAL_PASSWORD missing in .env")

    status, auth = req(
        base,
        "/api/collections/_superusers/auth-with-password",
        method="POST",
        body={"identity": su_email, "password": su_password},
    )
    must(status, 200, "superuser auth", auth)
    token = auth["token"]

    hzn = find_first(base, token, "organizations", "name = 'HZN Laundry'")
    if not hzn:
        hzn = find_first(base, token, "organizations", "isDeleted = false")
    if not hzn:
        raise SystemExit("No organization found — seed orgs first")

    branch = find_first(
        base,
        token,
        "branches",
        f"organization = '{hzn['id']}' && name ~ 'Hi-Zone'",
    )
    if not branch:
        branch = find_first(
            base, token, "branches", f"organization = '{hzn['id']}'"
        )
    if not branch:
        raise SystemExit(f"No branch under org {hzn.get('name')}")

    unit = find_first(base, token, "quantityUnits", "isDeleted = false")
    if not unit:
        unit = find_first(base, token, "quantityUnits", "")

    products: list[dict] = []
    for spec in CONSUMABLES:
        body: dict = {
            "name": spec["name"],
            "description": f"Fake house chemical — {spec['name']}",
            "branch": branch["id"],
            "price": 0,
            "unitCost": spec["unitCost"],
            "forSale": False,
            "trackStock": False,
            "requireStock": False,
            "trackByLot": False,
            "isConsumable": True,
            "countsTowardMaterialCost": True,
            "usageMin": 0,
            "usageStep": spec["usageStep"],
            "defaultUsage": spec["defaultUsage"],
            "isDeleted": False,
        }
        if unit:
            body["quantityUnit"] = unit["id"]
        product = upsert_record(
            base,
            token,
            "products",
            f"name = '{spec['name']}' && isConsumable = true",
            body,
            f"product {spec['name']}",
        )
        products.append({**product, "_recipe": spec})

    services = list_all(
        base,
        token,
        "services",
        filter_expr="isDeleted = false",
        expand="branch",
    )
    if not services:
        raise SystemExit("No non-deleted services found")

    recipe_count = 0
    org_ids: set[str] = set()
    for service in services:
        expand = service.get("expand") or {}
        svc_branch = expand.get("branch") or {}
        org_id = svc_branch.get("organization")
        if org_id:
            org_ids.add(org_id)

        for product in products:
            spec = product["_recipe"]
            upsert_record(
                base,
                token,
                "serviceConsumableRecipes",
                f"service = '{service['id']}' && product = '{product['id']}'",
                {
                    "service": service["id"],
                    "product": product["id"],
                    "defaultQuantity": spec["recipeDefaultQuantity"],
                    "prefill": spec["prefill"],
                },
                f"recipe {service.get('name')} / {product['name']}",
            )
            recipe_count += 1

    # Also enable flag on the default org even if it had no services expanded
    org_ids.add(hzn["id"])

    flag_count = 0
    for org_id in sorted(org_ids):
        upsert_record(
            base,
            token,
            "featureFlags",
            f"organization = '{org_id}' && key = 'consumableUsage'",
            {
                "organization": org_id,
                "key": "consumableUsage",
                "enabled": True,
            },
            f"flag consumableUsage org={org_id}",
        )
        flag_count += 1

    print()
    print("=== Summary ===")
    print(f"Products: {len(products)} ({', '.join(p['name'] for p in products)})")
    print(f"Services covered: {len(services)}")
    print(f"Recipes upserted: {recipe_count}")
    print(f"Orgs with consumableUsage=true: {flag_count}")
    print(f"Product branch: {branch.get('name')} ({branch['id']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
