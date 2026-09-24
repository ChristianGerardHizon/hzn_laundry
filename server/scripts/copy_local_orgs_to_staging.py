#!/usr/bin/env python3
"""Copy real orgs, users, roles, and services from local PocketBase to staging.

Copies only:
  - HZN Laundry, Sunrise Laundry, Private Cleaners (+ branches)
  - userRoles (upsert by id)
  - users with non-empty email (Christian remapped to existing staging id)
  - organizationMemberships for copyable users
  - serviceCategories, quantityUnits, services for those branches

Dry-run is the default. Pass --apply to write.

Usage:
  python server/scripts/copy_local_orgs_to_staging.py
  python server/scripts/copy_local_orgs_to_staging.py --apply
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"

ORG_IDS = frozenset(
    {
        "1fvr8oh16mx2mcq",  # HZN Laundry
        "02wayjwoy6dz2fn",  # Sunrise Laundry
        "wkhkjwh9m0kmggv",  # Private Cleaners
    }
)

CHRISTIAN_EMAIL = "christiangerardhizon@gmail.com"
CHRISTIAN_LOCAL_ID = "g6ha82mm76qa203"

STRIP_KEYS = frozenset(
    {
        "collectionId",
        "collectionName",
        "expand",
        "created",
        "updated",
        "avatar",
        "tokenKey",
        "password",
        "passwordConfirm",
        "emailVisibility",
    }
)


def load_env() -> dict[str, str]:
    env: dict[str, str] = {}
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def request_json(
    url: str,
    token: str | None = None,
    method: str = "GET",
    body: dict | None = None,
):
    data = None if body is None else json.dumps(body).encode()
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode()
        try:
            payload = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            payload = {"raw": raw}
        return exc.code, payload


def auth(url: str, email: str, password: str) -> str:
    status, payload = request_json(
        f"{url}/api/collections/_superusers/auth-with-password",
        method="POST",
        body={"identity": email, "password": password},
    )
    token = payload.get("token") if status == 200 else None
    if not token:
        raise SystemExit(f"Auth failed for {url}: HTTP {status} {payload}")
    return token


def list_all(url: str, token: str, collection: str) -> list[dict]:
    items: list[dict] = []
    page = 1
    while True:
        params = urllib.parse.urlencode({"page": page, "perPage": 200})
        status, payload = request_json(
            f"{url}/api/collections/{collection}/records?{params}",
            token=token,
        )
        if status != 200:
            raise SystemExit(f"list {collection} failed: HTTP {status} {payload}")
        batch = payload.get("items") or []
        items.extend(batch)
        if page >= payload.get("totalPages", page) or not batch:
            break
        page += 1
    return items


def get_record(url: str, token: str, collection: str, record_id: str) -> dict | None:
    status, payload = request_json(
        f"{url}/api/collections/{collection}/records/{record_id}",
        token=token,
    )
    if status == 404:
        return None
    if status != 200:
        raise SystemExit(
            f"get {collection}/{record_id} failed: HTTP {status} {payload}"
        )
    return payload


def find_by_filter(
    url: str, token: str, collection: str, filter_expr: str
) -> dict | None:
    params = urllib.parse.urlencode(
        {"page": 1, "perPage": 1, "filter": filter_expr}
    )
    status, payload = request_json(
        f"{url}/api/collections/{collection}/records?{params}",
        token=token,
    )
    if status != 200:
        raise SystemExit(f"filter {collection} failed: HTTP {status} {payload}")
    items = payload.get("items") or []
    return items[0] if items else None


def clean_body(record: dict, *, keep_id: bool = True) -> dict:
    body: dict = {}
    for key, value in record.items():
        if key in STRIP_KEYS:
            continue
        if key == "id" and not keep_id:
            continue
        if value == "" and key in {
            "invitedBy",
            "role",
            "branch",
            "category",
            "quantityUnit",
            "user",
            "avatar",
        }:
            continue
        body[key] = value
    return body


class Counters:
    def __init__(self) -> None:
        self.created = 0
        self.updated = 0
        self.skipped = 0
        self.would_create = 0
        self.would_update = 0

    def summary(self, apply: bool) -> str:
        if apply:
            return (
                f"created={self.created} updated={self.updated} "
                f"skipped={self.skipped}"
            )
        return (
            f"would_create={self.would_create} would_update={self.would_update} "
            f"skipped={self.skipped}"
        )


def upsert_by_id(
    dest_url: str,
    token: str,
    collection: str,
    record_id: str,
    body: dict,
    apply: bool,
    counters: Counters,
    label: str,
) -> None:
    existing = get_record(dest_url, token, collection, record_id)
    payload = dict(body)
    if existing is None:
        payload["id"] = record_id
        if not apply:
            counters.would_create += 1
            print(f"  [dry] CREATE {collection}/{record_id} {label}")
            return
        status, resp = request_json(
            f"{dest_url}/api/collections/{collection}/records",
            token=token,
            method="POST",
            body=payload,
        )
        if status != 200:
            raise SystemExit(
                f"create {collection}/{record_id} failed: HTTP {status} {resp}"
            )
        counters.created += 1
        print(f"  CREATE {collection}/{record_id} {label}")
        return

    payload.pop("id", None)
    if not apply:
        counters.would_update += 1
        print(f"  [dry] UPDATE {collection}/{record_id} {label}")
        return
    status, resp = request_json(
        f"{dest_url}/api/collections/{collection}/records/{record_id}",
        token=token,
        method="PATCH",
        body=payload,
    )
    if status != 200:
        raise SystemExit(
            f"update {collection}/{record_id} failed: HTTP {status} {resp}"
        )
    counters.updated += 1
    print(f"  UPDATE {collection}/{record_id} {label}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write to staging (default is dry-run)",
    )
    args = parser.parse_args()
    apply = args.apply

    env = load_env()
    local_url = (env.get("LOCAL_API_URL") or "http://127.0.0.1:8088").rstrip("/")
    local_email = env.get("LOCAL_EMAIL", "")
    local_password = env.get("LOCAL_PASSWORD", "")
    staging_url = (
        env.get("STAGING_URL") or "https://staging.hznlaundry.hznsystems.com"
    ).rstrip("/")
    staging_email = env.get("STAGING_EMAIL", "")
    staging_password = env.get("STAGING_PASSWORD", "")
    test_password = env.get("TEST_ACCOUNT_PASSWORD", "")

    if not local_email or not local_password:
        raise SystemExit("Missing LOCAL_EMAIL / LOCAL_PASSWORD in .env")
    if not staging_email or not staging_password:
        raise SystemExit("Missing STAGING_EMAIL / STAGING_PASSWORD in .env")
    if apply and not test_password:
        raise SystemExit(
            "Missing TEST_ACCOUNT_PASSWORD in .env (needed for new auth users)"
        )

    mode = "APPLY" if apply else "DRY-RUN"
    print(f"==> {mode}: {local_url} -> {staging_url}")

    local_token = auth(local_url, local_email, local_password)
    staging_token = auth(staging_url, staging_email, staging_password)
    print("Authenticated to local and staging.")

    print("\n[userRoles]")
    role_counters = Counters()
    for role in list_all(local_url, local_token, "userRoles"):
        body = clean_body(role)
        body.pop("user", None)
        upsert_by_id(
            staging_url,
            staging_token,
            "userRoles",
            role["id"],
            body,
            apply,
            role_counters,
            role.get("name", ""),
        )
    print(f"  {role_counters.summary(apply)}")

    print("\n[organizations]")
    org_counters = Counters()
    local_orgs = [
        o
        for o in list_all(local_url, local_token, "organizations")
        if o["id"] in ORG_IDS
    ]
    for org in local_orgs:
        body = clean_body(org)
        upsert_by_id(
            staging_url,
            staging_token,
            "organizations",
            org["id"],
            body,
            apply,
            org_counters,
            org.get("name", ""),
        )
    print(f"  {org_counters.summary(apply)}")

    print("\n[branches]")
    branch_counters = Counters()
    local_branches = [
        b
        for b in list_all(local_url, local_token, "branches")
        if b.get("organization") in ORG_IDS
    ]
    branch_ids = {b["id"] for b in local_branches}
    for branch in local_branches:
        body = clean_body(branch)
        upsert_by_id(
            staging_url,
            staging_token,
            "branches",
            branch["id"],
            body,
            apply,
            branch_counters,
            branch.get("name", ""),
        )
    print(f"  {branch_counters.summary(apply)}")

    for collection in ("quantityUnits", "serviceCategories"):
        print(f"\n[{collection}]")
        counters = Counters()
        for record in list_all(local_url, local_token, collection):
            body = clean_body(record)
            upsert_by_id(
                staging_url,
                staging_token,
                collection,
                record["id"],
                body,
                apply,
                counters,
                record.get("name", ""),
            )
        print(f"  {counters.summary(apply)}")

    print("\n[users]")
    user_counters = Counters()
    user_id_map: dict[str, str] = {}

    staging_christian = find_by_filter(
        staging_url,
        staging_token,
        "users",
        f"email = '{CHRISTIAN_EMAIL}'",
    )
    if not staging_christian:
        raise SystemExit(
            f"Staging is missing {CHRISTIAN_EMAIL}; cannot remap Christian user"
        )
    staging_christian_id = staging_christian["id"]
    user_id_map[CHRISTIAN_LOCAL_ID] = staging_christian_id
    print(
        f"  remap {CHRISTIAN_EMAIL}: {CHRISTIAN_LOCAL_ID} -> {staging_christian_id}"
    )

    for user in list_all(local_url, local_token, "users"):
        email = (user.get("email") or "").strip()
        if not email:
            user_counters.skipped += 1
            print(f"  SKIP blank email id={user['id']} name={user.get('name')!r}")
            continue

        body = clean_body(user, keep_id=True)
        branch = body.get("branch")
        if branch and branch not in branch_ids:
            body.pop("branch", None)

        if email.lower() == CHRISTIAN_EMAIL.lower():
            body.pop("id", None)
            body.pop("email", None)
            if not apply:
                user_counters.would_update += 1
                print(f"  [dry] UPDATE users/{staging_christian_id} {email}")
            else:
                status, resp = request_json(
                    f"{staging_url}/api/collections/users/records/{staging_christian_id}",
                    token=staging_token,
                    method="PATCH",
                    body=body,
                )
                if status != 200:
                    raise SystemExit(
                        f"update Christian failed: HTTP {status} {resp}"
                    )
                user_counters.updated += 1
                print(f"  UPDATE users/{staging_christian_id} {email}")
            continue

        dest_id = user["id"]
        user_id_map[dest_id] = dest_id
        existing = get_record(staging_url, staging_token, "users", dest_id)
        if existing is None:
            by_email = find_by_filter(
                staging_url,
                staging_token,
                "users",
                f"email = '{email}'",
            )
            if by_email:
                user_id_map[dest_id] = by_email["id"]
                body.pop("id", None)
                body.pop("email", None)
                if not apply:
                    user_counters.would_update += 1
                    print(
                        f"  [dry] UPDATE users/{by_email['id']} {email} "
                        f"(email match remap)"
                    )
                else:
                    status, resp = request_json(
                        f"{staging_url}/api/collections/users/records/{by_email['id']}",
                        token=staging_token,
                        method="PATCH",
                        body=body,
                    )
                    if status != 200:
                        raise SystemExit(
                            f"update user {email} failed: HTTP {status} {resp}"
                        )
                    user_counters.updated += 1
                    print(f"  UPDATE users/{by_email['id']} {email}")
                continue

            create_body = dict(body)
            create_body["id"] = dest_id
            create_body["password"] = test_password if apply else "REDACTED"
            create_body["passwordConfirm"] = create_body["password"]
            create_body["email"] = email
            if not apply:
                user_counters.would_create += 1
                print(f"  [dry] CREATE users/{dest_id} {email}")
            else:
                status, resp = request_json(
                    f"{staging_url}/api/collections/users/records",
                    token=staging_token,
                    method="POST",
                    body=create_body,
                )
                if status != 200:
                    raise SystemExit(
                        f"create user {email} failed: HTTP {status} {resp}"
                    )
                user_counters.created += 1
                print(f"  CREATE users/{dest_id} {email}")
        else:
            body.pop("id", None)
            if not apply:
                user_counters.would_update += 1
                print(f"  [dry] UPDATE users/{dest_id} {email}")
            else:
                status, resp = request_json(
                    f"{staging_url}/api/collections/users/records/{dest_id}",
                    token=staging_token,
                    method="PATCH",
                    body=body,
                )
                if status != 200:
                    raise SystemExit(
                        f"update user {email} failed: HTTP {status} {resp}"
                    )
                user_counters.updated += 1
                print(f"  UPDATE users/{dest_id} {email}")

    print(f"  {user_counters.summary(apply)}")

    print("\n[organizationMemberships]")
    mem_counters = Counters()
    for mem in list_all(local_url, local_token, "organizationMemberships"):
        if mem.get("organization") not in ORG_IDS:
            continue
        local_user = mem.get("user") or ""
        if local_user not in user_id_map:
            mem_counters.skipped += 1
            print(
                f"  SKIP membership {mem['id']} "
                f"(user {local_user} not copyable)"
            )
            continue
        body = clean_body(mem)
        body["user"] = user_id_map[local_user]
        invited = body.get("invitedBy")
        if invited:
            if invited in user_id_map:
                body["invitedBy"] = user_id_map[invited]
            else:
                body.pop("invitedBy", None)

        existing_pair = find_by_filter(
            staging_url,
            staging_token,
            "organizationMemberships",
            f"user = '{body['user']}' && organization = '{body['organization']}'",
        )
        if existing_pair:
            patch = dict(body)
            patch.pop("id", None)
            if not apply:
                mem_counters.would_update += 1
                print(
                    f"  [dry] UPDATE organizationMemberships/{existing_pair['id']}"
                )
            else:
                status, resp = request_json(
                    f"{staging_url}/api/collections/organizationMemberships/records/{existing_pair['id']}",
                    token=staging_token,
                    method="PATCH",
                    body=patch,
                )
                if status != 200:
                    raise SystemExit(
                        f"update membership failed: HTTP {status} {resp}"
                    )
                mem_counters.updated += 1
                print(f"  UPDATE organizationMemberships/{existing_pair['id']}")
            continue

        upsert_by_id(
            staging_url,
            staging_token,
            "organizationMemberships",
            mem["id"],
            body,
            apply,
            mem_counters,
            f"user={body['user']} org={body['organization']}",
        )
    print(f"  {mem_counters.summary(apply)}")

    print("\n[services]")
    service_counters = Counters()
    for service in list_all(local_url, local_token, "services"):
        if service.get("branch") not in branch_ids:
            service_counters.skipped += 1
            continue
        body = clean_body(service)
        upsert_by_id(
            staging_url,
            staging_token,
            "services",
            service["id"],
            body,
            apply,
            service_counters,
            service.get("name", ""),
        )
    print(f"  {service_counters.summary(apply)}")

    print(f"\nDone ({mode}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
