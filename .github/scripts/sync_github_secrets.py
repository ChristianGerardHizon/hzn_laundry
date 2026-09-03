#!/usr/bin/env python3
"""Push local Android signing, Play, and PocketBase secrets to GitHub Actions.

Reads gitignored files under android/keystore/ and .env, then runs
`gh secret set` at repo level and on the Production environment.

Never prints secret values. Requires an authenticated GitHub CLI (`gh`).

Usage:
    python .github/scripts/sync_github_secrets.py
    python .github/scripts/sync_github_secrets.py --dry-run
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
KEYSTORE_DIR = REPO_ROOT / "android" / "keystore"
SECRETS_TXT = KEYSTORE_DIR / "github-secrets.txt"
KEYSTORE_JKS = KEYSTORE_DIR / "upload-keystore.jks"
PLAY_JSON = KEYSTORE_DIR / "hznsystems-d413e58b8c31.json"
ENV_FILE = REPO_ROOT / ".env"
PRODUCTION_ENV = "Production"

KEYSTORE_KEYS = (
    "KEYSTORE_BASE64",
    "KEYSTORE_PASSWORD",
    "KEY_ALIAS",
    "KEY_PASSWORD",
)


class SyncError(Exception):
    pass


def parse_kv_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key:
            values[key] = value
    return values


def require_file(path: Path, hint: str) -> None:
    if not path.is_file():
        raise SyncError(f"Missing {hint}: {path}")


def ensure_gh() -> None:
    if shutil.which("gh") is None:
        raise SyncError("GitHub CLI (`gh`) is not on PATH. Install it and run `gh auth login`.")
    result = subprocess.run(
        ["gh", "auth", "status"],
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if result.returncode != 0:
        raise SyncError("GitHub CLI is not authenticated. Run `gh auth login`.")


def repo_slug() -> str:
    result = subprocess.run(
        ["gh", "repo", "view", "--json", "nameWithOwner"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=REPO_ROOT,
    )
    if result.returncode != 0:
        raise SyncError(result.stderr.strip() or "Failed to resolve GitHub repository via `gh`.")
    try:
        slug = json.loads(result.stdout).get("nameWithOwner", "").strip()
    except json.JSONDecodeError as exc:
        raise SyncError("Failed to parse `gh repo view` output.") from exc
    if not slug:
        raise SyncError("Failed to resolve GitHub repository via `gh`.")
    return slug


def ensure_environment(slug: str, name: str) -> None:
    result = subprocess.run(
        ["gh", "api", "--method", "PUT", f"repos/{slug}/environments/{name}"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=REPO_ROOT,
    )
    if result.returncode != 0:
        raise SyncError(
            f"Failed to create or update GitHub environment {name}: "
            f"{result.stderr.strip() or 'unknown error'}"
        )


def set_secret(name: str, value: str, *, env: str | None = None) -> None:
    cmd = ["gh", "secret", "set", name]
    if env:
        cmd.extend(["--env", env])
    result = subprocess.run(
        cmd,
        input=value,
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=REPO_ROOT,
    )
    if result.returncode != 0:
        dest = f"environment {env}" if env else "repository"
        raise SyncError(f"Failed to set {name} on {dest}: {result.stderr.strip() or 'unknown error'}")


def load_keystore_secrets() -> dict[str, str]:
    require_file(SECRETS_TXT, "keystore secrets file")
    values = parse_kv_file(SECRETS_TXT)
    missing = [key for key in KEYSTORE_KEYS if not values.get(key)]
    if missing:
        raise SyncError(f"{SECRETS_TXT.name} is missing: {', '.join(missing)}")

    if KEYSTORE_JKS.is_file():
        encoded = base64.b64encode(KEYSTORE_JKS.read_bytes()).decode("ascii")
        if encoded != values["KEYSTORE_BASE64"]:
            rewrite_keystore_base64(encoded)
            print(f"Re-encoded KEYSTORE_BASE64 from {KEYSTORE_JKS.name}")
        values["KEYSTORE_BASE64"] = encoded

    return {key: values[key] for key in KEYSTORE_KEYS}


def rewrite_keystore_base64(encoded: str) -> None:
    lines = SECRETS_TXT.read_text(encoding="utf-8").splitlines(keepends=True)
    replaced = False
    new_lines: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("KEYSTORE_BASE64="):
            newline = "\n" if line.endswith("\n") else ""
            new_lines.append(f"KEYSTORE_BASE64={encoded}{newline}")
            replaced = True
        else:
            new_lines.append(line)
    if not replaced:
        new_lines.append(f"KEYSTORE_BASE64={encoded}\n")
    SECRETS_TXT.write_text("".join(new_lines), encoding="utf-8")


def load_play_json() -> str:
    require_file(PLAY_JSON, "Play service-account JSON")
    try:
        data = json.loads(PLAY_JSON.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SyncError(f"{PLAY_JSON.name} is not valid JSON: {exc}") from exc
    if not isinstance(data, dict) or data.get("type") != "service_account":
        raise SyncError(f"{PLAY_JSON.name} is not a Google service-account JSON file.")
    if not data.get("client_email"):
        raise SyncError(f"{PLAY_JSON.name} is missing client_email.")
    return json.dumps(data, separators=(",", ":"))


def load_pocketbase_urls() -> dict[str, str]:
    require_file(ENV_FILE, ".env file")
    env = parse_kv_file(ENV_FILE)
    staging = env.get("STAGING_URL", "").rstrip("/")
    prod = env.get("PROD_URL", "").rstrip("/")
    missing = []
    if not staging:
        missing.append("STAGING_URL")
    if not prod:
        missing.append("PROD_URL")
    if missing:
        raise SyncError(f".env is missing: {', '.join(missing)}")
    return {
        "POCKETBASE_URL_STAGING": staging,
        "POCKETBASE_URL_PROD": prod,
    }


def optional_secrets(args: argparse.Namespace) -> dict[str, str]:
    extras: dict[str, str] = {}
    if args.ssh_host:
        extras["SSH_HOST"] = args.ssh_host
    if args.ssh_user:
        extras["SSH_USER"] = args.ssh_user
    if args.ssh_key:
        path = Path(args.ssh_key).expanduser()
        require_file(path, "SSH private key")
        extras["SSH_PRIVATE_KEY"] = path.read_text(encoding="utf-8")
    if args.version_manager_url:
        extras["VERSION_MANAGER_URL"] = args.version_manager_url
    if args.version_collection_id:
        extras["VERSION_COLLECTION_ID"] = args.version_collection_id
    if args.pb_token:
        extras["PB_TOKEN"] = args.pb_token
    if args.pb_token_file:
        path = Path(args.pb_token_file).expanduser()
        require_file(path, "PB_TOKEN file")
        extras["PB_TOKEN"] = path.read_text(encoding="utf-8").strip()
    return extras


def collect_secrets(args: argparse.Namespace) -> dict[str, str]:
    secrets = load_keystore_secrets()
    secrets["PLAYSTORE_SERVICE_ACCOUNT_JSON"] = load_play_json()
    secrets.update(load_pocketbase_urls())
    secrets.update(optional_secrets(args))
    return secrets


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sync local Play/signing secrets to GitHub Actions.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List secret names that would be set; do not call `gh secret set`.",
    )
    parser.add_argument("--ssh-host", help="Also set SSH_HOST")
    parser.add_argument("--ssh-user", help="Also set SSH_USER")
    parser.add_argument("--ssh-key", help="Path to SSH private key; also sets SSH_PRIVATE_KEY")
    parser.add_argument("--version-manager-url", help="Also set VERSION_MANAGER_URL")
    parser.add_argument("--version-collection-id", help="Also set VERSION_COLLECTION_ID")
    parser.add_argument("--pb-token", help="Also set PB_TOKEN")
    parser.add_argument("--pb-token-file", help="Read PB_TOKEN from this file")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        os.chdir(REPO_ROOT)
        secrets = collect_secrets(args)
        names = list(secrets)
        destinations = ["repository", f"environment {PRODUCTION_ENV}"]

        print("Secrets to update:")
        for name in names:
            print(f"  - {name}")
        print("Destinations:")
        for dest in destinations:
            print(f"  - {dest}")

        if args.dry_run:
            print("Dry run - no secrets were written.")
            return 0

        ensure_gh()
        slug = repo_slug()
        print(f"Repository: {slug}")

        for name, value in secrets.items():
            set_secret(name, value)
            print(f"Set {name} (repository)")

        try:
            ensure_environment(slug, PRODUCTION_ENV)
            for name, value in secrets.items():
                set_secret(name, value, env=PRODUCTION_ENV)
                print(f"Set {name} (environment {PRODUCTION_ENV})")
        except SyncError as exc:
            print(
                f"warning: repository secrets were set, but environment "
                f"{PRODUCTION_ENV} could not be updated ({exc}). "
                f"Create Settings -> Environments -> {PRODUCTION_ENV} if it is "
                "missing, then re-run this script. Repo secrets still work "
                "unless that environment is set to restrict secrets.",
                file=sys.stderr,
            )

        print("Done.")
        return 0
    except SyncError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
