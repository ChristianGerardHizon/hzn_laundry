#!/usr/bin/env python3
"""Seed multi-org demo data on local PocketBase for isolation testing.

Creates / updates:
  - Test login: christiangerardhizon@gmail.com / password101 (Admin)
  - Second org "Sunrise Laundry" (Christian is a member — org switcher appears)
  - Third org "Private Cleaners" (Christian is NOT a member — isolation check)
  - Customers, services, and sales stamped to each org's branch

Usage:
  python server/scripts/seed_multi_org_demo.py
"""

from __future__ import annotations

import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"

TEST_EMAIL = "christiangerardhizon@gmail.com"
TEST_PASSWORD = "password101"
TEST_NAME = "Christian Gerard Hizon"


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


def ensure_membership(
    base: str,
    token: str,
    user_id: str,
    org_id: str,
    role_id: str,
    label: str,
):
    existing = find_first(
        base,
        token,
        "organizationMemberships",
        f"user = '{user_id}' && organization = '{org_id}'",
    )
    body = {
        "user": user_id,
        "organization": org_id,
        "role": role_id,
        "status": "active",
        "joinedAt": datetime.now(timezone.utc)
        .isoformat()
        .replace("+00:00", "Z"),
    }
    if existing:
        status, payload = req(
            base,
            f"/api/collections/organizationMemberships/records/{existing['id']}",
            method="PATCH",
            token=token,
            body=body,
        )
        return must(status, 200, f"update membership {label}", payload)
    status, payload = req(
        base,
        "/api/collections/organizationMemberships/records",
        method="POST",
        token=token,
        body=body,
    )
    return must(status, 200, f"create membership {label}", payload)


def ensure_sale_with_service(
    base: str,
    token: str,
    *,
    receipt: str,
    branch_id: str,
    cashier_id: str,
    customer_id: str,
    customer_name: str,
    service_id: str,
    service_name: str,
    quantity: float,
    unit_price: float,
    order_status: str,
    payment_status: str,
):
    existing = find_first(
        base, token, "sales", f"receiptNumber = '{receipt}'"
    )
    total = quantity * unit_price
    sale_body = {
        "receiptNumber": receipt,
        "branch": branch_id,
        "cashier": cashier_id,
        "customer": customer_id,
        "customerName": customer_name,
        "totalAmount": total,
        "status": "pending",
        "orderStatus": order_status,
        "paymentStatus": payment_status,
        "isPaid": payment_status == "paid",
        "packs": 1,
        "isDeleted": False,
        "notes": "multi-org demo seed",
        "postedDate": datetime.now(timezone.utc)
        .isoformat()
        .replace("+00:00", "Z"),
    }
    if existing:
        sale = existing
        print(f"OK sale exists {receipt}")
    else:
        status, sale = req(
            base,
            "/api/collections/sales/records",
            method="POST",
            token=token,
            body=sale_body,
        )
        must(status, 200, f"create sale {receipt}", sale)

    line = find_first(
        base,
        token,
        "saleServiceItems",
        f"sale = '{sale['id']}' && service = '{service_id}'",
    )
    line_body = {
        "sale": sale["id"],
        "service": service_id,
        "serviceName": service_name,
        "quantity": quantity,
        "unitPrice": unit_price,
        "subtotal": total,
        "status": "pending",
    }
    if line:
        print(f"OK sale line exists for {receipt}")
        return sale
    status, payload = req(
        base,
        "/api/collections/saleServiceItems/records",
        method="POST",
        token=token,
        body=line_body,
    )
    must(status, 200, f"create sale line {receipt}", payload)
    return sale


def upsert_env_keys(pairs: dict[str, str]) -> None:
    lines = ENV_PATH.read_text(encoding="utf-8").splitlines()
    keys = set(pairs)
    seen: set[str] = set()
    out: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped and not stripped.startswith("#") and "=" in stripped:
            key = stripped.split("=", 1)[0].strip()
            if key in keys:
                out.append(f"{key}={pairs[key]}")
                seen.add(key)
                continue
        out.append(line)
    if seen != keys:
        if out and out[-1].strip():
            out.append("")
        out.append("# Local multi-org demo login (seed_multi_org_demo.py)")
        for key, value in pairs.items():
            if key not in seen:
                out.append(f"{key}={value}")
    ENV_PATH.write_text("\n".join(out) + "\n", encoding="utf-8")
    print("OK updated .env TEST_ACCOUNT_* keys")


def main() -> int:
    env = load_env()
    base = (env.get("LOCAL_API_URL") or "http://127.0.0.1:8090").rstrip("/")
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

    admin_role = find_first(
        base, token, "userRoles", "name = 'Admin' && isSystem = true"
    )
    cashier_role = find_first(base, token, "userRoles", "name = 'Cashier'")
    if not admin_role or not cashier_role:
        raise SystemExit("Admin/Cashier roles not found")

    # Prefer updating the existing Christian Admin user when present.
    christian = find_first(base, token, "users", "name = 'Christian'")
    if not christian:
        christian = find_first(
            base, token, "users", f"email = '{TEST_EMAIL}'"
        )

    hzn = find_first(base, token, "organizations", "name = 'HZN Laundry'")
    if not hzn:
        raise SystemExit("Default org 'HZN Laundry' missing — run org migrations first")

    hzn_branch = find_first(
        base,
        token,
        "branches",
        f"organization = '{hzn['id']}' && name ~ 'Hi-Zone'",
    )
    if not hzn_branch:
        hzn_branch = find_first(
            base, token, "branches", f"organization = '{hzn['id']}'"
        )
    if not hzn_branch:
        raise SystemExit("No branch found under HZN Laundry")

    user_body = {
        "email": TEST_EMAIL,
        "emailVisibility": True,
        "verified": True,
        "name": TEST_NAME,
        "role": admin_role["id"],
        "branch": hzn_branch["id"],
        "password": TEST_PASSWORD,
        "passwordConfirm": TEST_PASSWORD,
    }
    if christian:
        # Password fields on PATCH reset the password.
        status, christian = req(
            base,
            f"/api/collections/users/records/{christian['id']}",
            method="PATCH",
            token=token,
            body=user_body,
        )
        must(status, 200, f"update test user {TEST_EMAIL}", christian)
    else:
        status, christian = req(
            base,
            "/api/collections/users/records",
            method="POST",
            token=token,
            body=user_body,
        )
        must(status, 200, f"create test user {TEST_EMAIL}", christian)

    ensure_membership(
        base,
        token,
        christian["id"],
        hzn["id"],
        admin_role["id"],
        "Christian -> HZN Laundry",
    )

    sunrise = upsert_record(
        base,
        token,
        "organizations",
        "name = 'Sunrise Laundry'",
        {
            "name": "Sunrise Laundry",
            "contactNumber": "09171234567",
            "address": "123 Sunrise Ave, QC",
            "isDeleted": False,
            "onboardingCompletedAt": datetime.now(timezone.utc)
            .isoformat()
            .replace("+00:00", "Z"),
        },
        "org Sunrise Laundry",
    )
    sunrise_branch = upsert_record(
        base,
        token,
        "branches",
        f"organization = '{sunrise['id']}' && name = 'Sunrise Main'",
        {
            "name": "Sunrise Main",
            "address": "123 Sunrise Ave, QC",
            "contactNumber": "09171234567",
            "organization": sunrise["id"],
            "incentiveAmount": 5,
            "incentivePerServiceItems": 200,
        },
        "branch Sunrise Main",
    )
    ensure_membership(
        base,
        token,
        christian["id"],
        sunrise["id"],
        admin_role["id"],
        "Christian -> Sunrise Laundry",
    )

    private = upsert_record(
        base,
        token,
        "organizations",
        "name = 'Private Cleaners'",
        {
            "name": "Private Cleaners",
            "contactNumber": "09179876543",
            "address": "99 Hidden St, Manila",
            "isDeleted": False,
            "onboardingCompletedAt": datetime.now(timezone.utc)
            .isoformat()
            .replace("+00:00", "Z"),
        },
        "org Private Cleaners",
    )
    private_branch = upsert_record(
        base,
        token,
        "branches",
        f"organization = '{private['id']}' && name = 'Private HQ'",
        {
            "name": "Private HQ",
            "address": "99 Hidden St, Manila",
            "contactNumber": "09179876543",
            "organization": private["id"],
            "incentiveAmount": 5,
            "incentivePerServiceItems": 200,
        },
        "branch Private HQ",
    )

    private_cashier = upsert_record(
        base,
        token,
        "users",
        "email = 'private.cashier@demo.local'",
        {
            "email": "private.cashier@demo.local",
            "emailVisibility": True,
            "verified": True,
            "name": "Private Cashier",
            "role": cashier_role["id"],
            "branch": private_branch["id"],
            "password": TEST_PASSWORD,
            "passwordConfirm": TEST_PASSWORD,
        },
        "user private.cashier@demo.local",
    )
    ensure_membership(
        base,
        token,
        private_cashier["id"],
        private["id"],
        cashier_role["id"],
        "Private Cashier -> Private Cleaners",
    )

    # Customers (members)
    hzn_member = upsert_record(
        base,
        token,
        "customers",
        f"branch = '{hzn_branch['id']}' && name = 'HZN Member Ana'",
        {
            "name": "HZN Member Ana",
            "phone": "09171110001",
            "address": "Ana St, HZN",
            "email": "ana.hzn@example.com",
            "branch": hzn_branch["id"],
            "notes": "demo member — HZN Laundry",
        },
        "customer HZN Member Ana",
    )
    sunrise_member_a = upsert_record(
        base,
        token,
        "customers",
        f"branch = '{sunrise_branch['id']}' && name = 'Sunrise Member Ben'",
        {
            "name": "Sunrise Member Ben",
            "phone": "09172220002",
            "address": "Ben St, Sunrise",
            "email": "ben.sunrise@example.com",
            "branch": sunrise_branch["id"],
            "notes": "demo member — Sunrise Laundry",
        },
        "customer Sunrise Member Ben",
    )
    sunrise_member_b = upsert_record(
        base,
        token,
        "customers",
        f"branch = '{sunrise_branch['id']}' && name = 'Sunrise Member Cara'",
        {
            "name": "Sunrise Member Cara",
            "phone": "09173330003",
            "address": "Cara St, Sunrise",
            "email": "cara.sunrise@example.com",
            "branch": sunrise_branch["id"],
            "notes": "demo member — Sunrise Laundry",
        },
        "customer Sunrise Member Cara",
    )
    private_member = upsert_record(
        base,
        token,
        "customers",
        f"branch = '{private_branch['id']}' && name = 'Private Member Dee'",
        {
            "name": "Private Member Dee",
            "phone": "09174440004",
            "address": "Dee St, Private",
            "email": "dee.private@example.com",
            "branch": private_branch["id"],
            "notes": "demo member — Private Cleaners (should be invisible to Christian)",
        },
        "customer Private Member Dee",
    )

    # Services
    hzn_service = upsert_record(
        base,
        token,
        "services",
        f"branch = '{hzn_branch['id']}' && name = 'HZN Demo Wash'",
        {
            "name": "HZN Demo Wash",
            "description": "Demo wash service for HZN Laundry",
            "branch": hzn_branch["id"],
            "price": 150,
            "isVariablePrice": False,
            "weightBased": False,
            "isDeleted": False,
            "isDefault": False,
        },
        "service HZN Demo Wash",
    )
    sunrise_wash = upsert_record(
        base,
        token,
        "services",
        f"branch = '{sunrise_branch['id']}' && name = 'Sunrise Wash'",
        {
            "name": "Sunrise Wash",
            "description": "Wash service — Sunrise only",
            "branch": sunrise_branch["id"],
            "price": 180,
            "isVariablePrice": False,
            "weightBased": False,
            "isDeleted": False,
            "isDefault": True,
        },
        "service Sunrise Wash",
    )
    sunrise_dry = upsert_record(
        base,
        token,
        "services",
        f"branch = '{sunrise_branch['id']}' && name = 'Sunrise Dry Fold'",
        {
            "name": "Sunrise Dry Fold",
            "description": "Dry + fold — Sunrise only",
            "branch": sunrise_branch["id"],
            "price": 120,
            "isVariablePrice": False,
            "weightBased": False,
            "isDeleted": False,
            "isDefault": False,
        },
        "service Sunrise Dry Fold",
    )
    private_service = upsert_record(
        base,
        token,
        "services",
        f"branch = '{private_branch['id']}' && name = 'Private Secret Wash'",
        {
            "name": "Private Secret Wash",
            "description": "Should NOT be visible to Christian",
            "branch": private_branch["id"],
            "price": 999,
            "isVariablePrice": False,
            "weightBased": False,
            "isDeleted": False,
            "isDefault": True,
        },
        "service Private Secret Wash",
    )

    # Orders
    ensure_sale_with_service(
        base,
        token,
        receipt="DEMO-HZN-001",
        branch_id=hzn_branch["id"],
        cashier_id=christian["id"],
        customer_id=hzn_member["id"],
        customer_name=hzn_member["name"],
        service_id=hzn_service["id"],
        service_name=hzn_service["name"],
        quantity=1,
        unit_price=150,
        order_status="processing",
        payment_status="unpaid",
    )
    ensure_sale_with_service(
        base,
        token,
        receipt="DEMO-SUN-001",
        branch_id=sunrise_branch["id"],
        cashier_id=christian["id"],
        customer_id=sunrise_member_a["id"],
        customer_name=sunrise_member_a["name"],
        service_id=sunrise_wash["id"],
        service_name=sunrise_wash["name"],
        quantity=2,
        unit_price=180,
        order_status="pending",
        payment_status="unpaid",
    )
    ensure_sale_with_service(
        base,
        token,
        receipt="DEMO-SUN-002",
        branch_id=sunrise_branch["id"],
        cashier_id=christian["id"],
        customer_id=sunrise_member_b["id"],
        customer_name=sunrise_member_b["name"],
        service_id=sunrise_dry["id"],
        service_name=sunrise_dry["name"],
        quantity=1,
        unit_price=120,
        order_status="ready",
        payment_status="paid",
    )
    ensure_sale_with_service(
        base,
        token,
        receipt="DEMO-PRIV-001",
        branch_id=private_branch["id"],
        cashier_id=private_cashier["id"],
        customer_id=private_member["id"],
        customer_name=private_member["name"],
        service_id=private_service["id"],
        service_name=private_service["name"],
        quantity=1,
        unit_price=999,
        order_status="pending",
        payment_status="unpaid",
    )

    # Verify login works
    status, login = req(
        base,
        "/api/collections/users/auth-with-password",
        method="POST",
        body={"identity": TEST_EMAIL, "password": TEST_PASSWORD},
    )
    must(status, 200, f"login as {TEST_EMAIL}", login)

    user_token = login["token"]
    status, visible_orgs = req(
        base,
        "/api/collections/organizations/records?perPage=50",
        token=user_token,
    )
    names = sorted(o.get("name") for o in (visible_orgs.get("items") or []))
    print("visible orgs for Christian:", names)
    if "Private Cleaners" in names:
        raise SystemExit("isolation failed: Private Cleaners visible to Christian")
    if "Sunrise Laundry" not in names or "HZN Laundry" not in names:
        raise SystemExit(f"expected HZN + Sunrise for Christian, got {names}")

    status, private_services = req(
        base,
        "/api/collections/services/records?filter="
        + urllib.parse.quote(f"name = 'Private Secret Wash'"),
        token=user_token,
    )
    if status == 200 and (private_services.get("items") or []):
        raise SystemExit("isolation failed: Private Secret Wash visible to Christian")
    print("OK Private Secret Wash hidden from Christian")

    upsert_env_keys(
        {
            "TEST_ACCOUNT_EMAIL": TEST_EMAIL,
            "TEST_ACCOUNT_PASSWORD": TEST_PASSWORD,
        }
    )

    print(
        "\nReady. Login with:\n"
        f"  email: {TEST_EMAIL}\n"
        f"  password: {TEST_PASSWORD}\n"
        "Orgs: HZN Laundry + Sunrise Laundry (switcher visible).\n"
        "Private Cleaners is seeded but NOT visible to this account.\n"
        "Extra isolation login: private.cashier@demo.local / password101"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
