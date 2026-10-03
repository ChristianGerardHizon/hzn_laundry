#!/usr/bin/env python3
"""Clear all activityLogs records via the PocketBase API.

Use after org/branch scoping ships: historical rows have no tenant fields and
cannot be listed under membership rules. New logs are stamped by hooks.

Dry-run is the default. Pass --apply to delete.

Usage:
  python server/scripts/clear_activity_logs.py --env staging
  python server/scripts/clear_activity_logs.py --env staging --apply
  python server/scripts/clear_activity_logs.py --env prod --apply
  python server/scripts/clear_activity_logs.py --env local --apply
  python server/scripts/clear_activity_logs.py --all --apply
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENV_PATH = ROOT / ".env"

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
        with urllib.request.urlopen(request, timeout=120) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode()
        try:
            payload = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            payload = {"raw": raw}
        raise SystemExit(f"{method} {path} -> {exc.code}: {payload}") from exc


def auth_superuser(base: str, email: str, password: str) -> str:
    for path in (
        "/api/collections/_superusers/auth-with-password",
        "/api/admins/auth-with-password",
    ):
        try:
            _, payload = req(
                base,
                path,
                method="POST",
                body={"identity": email, "password": password},
            )
            token = payload.get("token")
            if token:
                return token
        except SystemExit:
            continue
    raise SystemExit(f"Superuser auth failed for {base}")


def count_logs(base: str, token: str) -> int:
    _, payload = req(
        base,
        "/api/collections/activityLogs/records?perPage=1",
        token=token,
    )
    return int(payload.get("totalItems") or 0)


def delete_all_logs(base: str, token: str) -> int:
    deleted = 0
    while True:
        _, payload = req(
            base,
            "/api/collections/activityLogs/records?perPage=100&fields=id",
            token=token,
        )
        items = payload.get("items") or []
        if not items:
            break
        for item in items:
            record_id = item.get("id")
            if not record_id:
                continue
            req(
                base,
                f"/api/collections/activityLogs/records/{record_id}",
                method="DELETE",
                token=token,
            )
            deleted += 1
        print(f"  deleted {deleted}…", flush=True)
    return deleted


def run_env(env_name: str, apply: bool) -> None:
    env = load_env()
    base, email, password = resolve_env(env_name, env)
    mode = "APPLY" if apply else "DRY-RUN"
    print(f"\n######## {env_name.upper()} ({mode}) -> {base}")
    token = auth_superuser(base, email, password)
    print("OK superuser auth")
    total = count_logs(base, token)
    print(f"activityLogs totalItems={total}")
    if total == 0:
        print("Nothing to clear.")
        return
    if not apply:
        print(f"Would delete {total} activity log(s). Re-run with --apply to write.")
        return
    deleted = delete_all_logs(base, token)
    remaining = count_logs(base, token)
    print(f"Deleted {deleted}. Remaining={remaining}")
    if remaining != 0:
        raise SystemExit(f"{env_name}: clear incomplete ({remaining} left)")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Clear activityLogs (dry-run default; use --apply to delete)."
    )
    parser.add_argument(
        "--env",
        choices=sorted(ENV_CONFIG.keys()),
        help="Target environment",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Run against staging and prod (not local)",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually delete records (default is dry-run)",
    )
    args = parser.parse_args()

    if bool(args.all) == bool(args.env):
        raise SystemExit("Specify exactly one of --env <name> or --all")

    targets = ["staging", "prod"] if args.all else [args.env]
    for name in targets:
        run_env(name, apply=bool(args.apply))


if __name__ == "__main__":
    main()
    sys.exit(0)
