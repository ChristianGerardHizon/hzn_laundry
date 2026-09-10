#!/usr/bin/env python3
"""Backfill saleServiceItems.storageName from assigned storage records.

Fills empty snapshot names when storage relation IDs are already set.
Dry-run is the default. Pass --apply to write.

Usage:
  python server/scripts/backfill_sale_service_storage_names.py --env both
  python server/scripts/backfill_sale_service_storage_names.py --env prod --apply
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"

URLS = {
    "staging": "https://staging.hznlaundry.hznsystems.com",
    "prod": "https://hznlaundry.hznsystems.com",
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


def request_json(url: str, token: str | None = None, method: str = "GET", body: dict | None = None):
    data = None if body is None else json.dumps(body).encode()
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())


def auth(url: str, email: str, password: str) -> str:
    payload = request_json(
        f"{url}/api/collections/_superusers/auth-with-password",
        method="POST",
        body={"identity": email, "password": password},
    )
    token = payload.get("token")
    if not token:
        raise SystemExit(f"Auth failed for {url}")
    return token


def storage_label(record: dict) -> str | None:
    storage_ids = record.get("storage") or []
    if isinstance(storage_ids, str):
        storage_ids = [storage_ids] if storage_ids else []
    storage_ids = [sid for sid in storage_ids if sid]
    if not storage_ids:
        return None

    expand = (record.get("expand") or {}).get("storage") or []
    if isinstance(expand, dict):
        expand = [expand]
    names_by_id = {item.get("id"): (item.get("name") or "").strip() for item in expand}
    names = [names_by_id.get(sid, "") for sid in storage_ids]
    names = [name for name in names if name]
    if not names:
        return None
    return ", ".join(names)


def list_items(url: str, token: str):
    page = 1
    per_page = 200
    while True:
        query = urllib.parse.urlencode(
            {
                "page": page,
                "perPage": per_page,
                "expand": "storage",
                "fields": "id,storage,storageName,expand.storage.id,expand.storage.name",
            }
        )
        payload = request_json(
            f"{url}/api/collections/saleServiceItems/records?{query}",
            token=token,
        )
        items = payload.get("items") or []
        if not items:
            break
        yield from items
        if page >= payload.get("totalPages", page):
            break
        page += 1


def run_env(name: str, url: str, email: str, password: str, apply: bool) -> None:
    print(f"\n==> {name} ({url})")
    token = auth(url, email, password)
    print("    Authenticated.")

    scanned = 0
    would_update = 0
    skipped_no_storage = 0
    skipped_already_set = 0
    skipped_unresolved = 0
    updated = 0

    for record in list_items(url, token):
        scanned += 1
        current = (record.get("storageName") or "").strip()
        label = storage_label(record)
        if label is None:
            storage_ids = record.get("storage") or []
            if storage_ids:
                skipped_unresolved += 1
            else:
                skipped_no_storage += 1
            continue
        if current == label:
            skipped_already_set += 1
            continue

        would_update += 1
        action = "APPLY" if apply else "DRY"
        print(f"    {action} {record['id']}: {current!r} -> {label!r}")
        if apply:
            request_json(
                f"{url}/api/collections/saleServiceItems/records/{record['id']}",
                token=token,
                method="PATCH",
                body={"storageName": label},
            )
            updated += 1

    print(
        f"    scanned={scanned} update={would_update if not apply else updated} "
        f"already_set={skipped_already_set} no_storage={skipped_no_storage} "
        f"unresolved={skipped_unresolved}"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--env", choices=("staging", "prod", "both"), default="both")
    parser.add_argument("--apply", action="store_true", help="Write storageName values")
    args = parser.parse_args()

    env = load_env()
    targets = ["staging", "prod"] if args.env == "both" else [args.env]
    if not args.apply:
        print("Dry-run (pass --apply to write).")

    for name in targets:
        email_key = "STAGING_EMAIL" if name == "staging" else "PROD_EMAIL"
        password_key = "STAGING_PASSWORD" if name == "staging" else "PROD_PASSWORD"
        url_key = "STAGING_URL" if name == "staging" else "PROD_URL"
        email = env.get(email_key, "")
        password = env.get(password_key, "")
        url = env.get(url_key, URLS[name]).rstrip("/")
        if not email or not password:
            raise SystemExit(f"Missing {email_key}/{password_key} in .env")
        run_env(name, url, email, password, args.apply)

    return 0


if __name__ == "__main__":
    sys.exit(main())
