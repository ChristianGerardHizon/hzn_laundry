#!/usr/bin/env python3
"""List users whose email is blank or missing.

Read-only. Never fabricates emails. A human must fill real addresses in the
PocketBase Admin UI before the email-identity cutover migrations run.

Usage:
  python server/scripts/list_users_missing_email.py --env staging
  python server/scripts/list_users_missing_email.py --env prod
  python server/scripts/list_users_missing_email.py --env both
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


def credentials(env: dict[str, str], target: str) -> tuple[str, str, str]:
    prefix = "STAGING" if target == "staging" else "PROD"
    url = env.get(f"{prefix}_URL") or URLS[target]
    email = env.get(f"{prefix}_EMAIL", "")
    password = env.get(f"{prefix}_PASSWORD", "")
    if not email or not password:
        raise SystemExit(f"Missing {prefix}_EMAIL / {prefix}_PASSWORD in .env")
    return url.rstrip("/"), email, password


def list_missing(url: str, token: str) -> list[dict]:
    missing: list[dict] = []
    page = 1
    while True:
        params = urllib.parse.urlencode(
            {
                "page": page,
                "perPage": 200,
                "fields": "id,username,name,email",
                "skipTotal": 1,
            }
        )
        payload = request_json(
            f"{url}/api/collections/users/records?{params}",
            token=token,
        )
        items = payload.get("items") or []
        for record in items:
            email = (record.get("email") or "").strip()
            if not email:
                missing.append(record)
        if len(items) < 200:
            break
        page += 1
    return missing


def run_target(env: dict[str, str], target: str) -> int:
    url, email, password = credentials(env, target)
    token = auth(url, email, password)
    missing = list_missing(url, token)
    print(f"[{target}] {url}")
    if not missing:
        print("  All users have an email.")
        return 0
    print(f"  {len(missing)} user(s) missing email:")
    for record in missing:
        print(
            f"    id={record.get('id')}  username={record.get('username')!r}  "
            f"name={record.get('name')!r}"
        )
    return len(missing)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--env",
        choices=("staging", "prod", "both"),
        default="staging",
    )
    args = parser.parse_args()
    env = load_env()
    targets = ("staging", "prod") if args.env == "both" else (args.env,)
    total = 0
    for target in targets:
        total += run_target(env, target)
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
