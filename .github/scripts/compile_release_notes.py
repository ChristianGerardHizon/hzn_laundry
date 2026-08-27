#!/usr/bin/env python3
"""Compile user-facing release notes from merged staging PRs."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

CURSOR_SUMMARY = re.compile(
    r"<!--\s*CURSOR_SUMMARY\s*-->.*?<!--\s*/CURSOR_SUMMARY\s*-->",
    re.DOTALL | re.IGNORECASE,
)
SECTION_HEADING = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)
CONVENTIONAL_PREFIX = re.compile(
    r"^(feat|fix|ci|chore|docs|refactor|perf|style|test)(\([^)]+\))?:\s*",
    re.IGNORECASE,
)

TECHNICAL_KEYWORDS = (
    "pocketbase",
    "riverpod",
    "migration",
    "grepai",
    "github actions",
    "workflow",
    "artifact",
    "build.gradle",
    "service account",
    "keystore",
    "rsync",
    "ssh",
    "dart-define",
    "app bundle",
    "aab",
    "apk",
    "ci:",
    "bugbot",
)

SKIP_SECTIONS = {
    "test plan",
    "qa notes",
    "regression risks",
    "cursor summary",
}


def run_gh(*args: str) -> str:
    result = subprocess.run(
        ["gh", *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        check=True,
    )
    return result.stdout.strip()


def load_json_gh(*args: str):
    return json.loads(run_gh(*args))


def parse_github_time(value: str) -> datetime:
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def get_latest_release_tag(repo: str, prefix: str, *, prerelease: bool | None) -> str | None:
    releases = load_json_gh(
        "release",
        "list",
        "--repo",
        repo,
        "--json",
        "tagName,publishedAt,isPrerelease",
        "--limit",
        "100",
    )
    matching = [
        release
        for release in releases
        if release["tagName"].startswith(prefix)
        and (prerelease is None or release["isPrerelease"] == prerelease)
    ]
    if not matching:
        return None
    matching.sort(key=lambda item: parse_github_time(item["publishedAt"]), reverse=True)
    return matching[0]["tagName"]


def get_release_published_at(repo: str, tag: str) -> datetime | None:
    try:
        release = load_json_gh(
            "api",
            f"repos/{repo}/releases/tags/{tag}",
        )
    except subprocess.CalledProcessError:
        return None
    published = release.get("published_at")
    if not published:
        return None
    return parse_github_time(published)


def list_merged_staging_prs(repo: str) -> list[dict]:
    return load_json_gh(
        "pr",
        "list",
        "--repo",
        repo,
        "--base",
        "staging",
        "--state",
        "merged",
        "--json",
        "number,title,body,mergedAt",
        "--limit",
        "100",
    )


def extract_section(body: str, section_name: str) -> str | None:
    for match in SECTION_HEADING.finditer(body):
        heading = match.group(1).strip().lower()
        if heading != section_name.lower():
            continue
        start = match.end()
        end = len(body)
        for next_match in SECTION_HEADING.finditer(body, start):
            end = next_match.start()
            break
        return body[start:end].strip()
    return None


def strip_markdown(text: str) -> str:
    text = CURSOR_SUMMARY.sub("", text)
    text = re.sub(r"- \[ \]\s*", "- ", text)
    text = re.sub(r"- \[[xX]\]\s*", "- ", text)
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"\1", text)
    text = re.sub(r"\r\n", "\n", text)
    return text.strip()


def is_technical_line(line: str) -> bool:
    lowered = line.lower()
    if lowered.startswith("reviewed by") or lowered.startswith("<sup>"):
        return True
    return any(keyword in lowered for keyword in TECHNICAL_KEYWORDS)


def normalize_bullet_lines(text: str) -> list[str]:
    lines: list[str] = []
    for raw_line in text.split("\n"):
        line = raw_line.strip()
        if not line or line.startswith("<!--"):
            continue
        if is_technical_line(line):
            continue
        if line.startswith("- "):
            line = line[2:].strip()
        elif line.startswith("* "):
            line = line[2:].strip()
        if not line:
            continue
        if not line[0].isupper():
            line = line[0].upper() + line[1:]
        lines.append(line)
    return lines


def title_to_bullet(title: str) -> str:
    cleaned = CONVENTIONAL_PREFIX.sub("", title).strip()
    if not cleaned:
        cleaned = title.strip()
    if cleaned:
        cleaned = cleaned[0].upper() + cleaned[1:]
    return cleaned


def extract_pr_notes(body: str, title: str) -> list[str]:
    body = strip_markdown(body or "")

    for preferred in ("release notes", "summary"):
        section = extract_section(body, preferred)
        if section:
            bullets = normalize_bullet_lines(section)
            if bullets:
                return bullets

    fallback = title_to_bullet(title)
    return [fallback] if fallback else []


def dedupe_preserve_order(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        key = item.casefold()
        if key in seen:
            continue
        seen.add(key)
        result.append(item)
    return result


def compile_notes(repo: str, mode: str) -> tuple[str, str, list[dict]]:
    if mode == "staging":
        since_tag = get_latest_release_tag(repo, "staging-", prerelease=True)
    else:
        since_tag = get_latest_release_tag(repo, "v", prerelease=False)

    since_time = get_release_published_at(repo, since_tag) if since_tag else None
    prs = list_merged_staging_prs(repo)

    if since_time is not None:
        prs = [
            pr
            for pr in prs
            if parse_github_time(pr["mergedAt"]) > since_time
        ]

    prs.sort(key=lambda pr: parse_github_time(pr["mergedAt"]))

    bullets: list[str] = []
    for pr in prs:
        bullets.extend(extract_pr_notes(pr.get("body") or "", pr["title"]))

    bullets = dedupe_preserve_order(bullets)

    if not bullets:
        bullets = ["General improvements and bug fixes."]

    markdown_lines = ["## What's new", ""]
    markdown_lines.extend(f"- {bullet}" for bullet in bullets)
    markdown = "\n".join(markdown_lines).strip() + "\n"

    play_lines = [f"• {bullet}" for bullet in bullets]
    play_text = "\n".join(play_lines)
    if len(play_text) > 500:
        play_text = play_text[:497].rstrip() + "..."

    return markdown, play_text, prs


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument(
        "--mode",
        choices=("staging", "production"),
        required=True,
    )
    parser.add_argument("--output-markdown", required=True)
    parser.add_argument("--output-play", required=True)
    args = parser.parse_args()

    markdown, play_text, prs = compile_notes(args.repo, args.mode)

    markdown_path = Path(args.output_markdown)
    play_path = Path(args.output_play)
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    play_path.parent.mkdir(parents=True, exist_ok=True)

    markdown_path.write_text(markdown, encoding="utf-8")
    play_path.write_text(play_text, encoding="utf-8")

    summary_path = markdown_path.with_name("release-notes-summary.json")
    summary_path.write_text(
        json.dumps(
            {
                "mode": args.mode,
                "pr_count": len(prs),
                "pr_numbers": [pr["number"] for pr in prs],
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    print(f"Compiled release notes from {len(prs)} merged PR(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
