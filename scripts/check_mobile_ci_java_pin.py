#!/usr/bin/env python3
"""Assert Mobile CI build-android pins Java 17 before the release APK build.

Stdlib only. Exits 0 when `.github/workflows/mobile-ci.yml` configures
`actions/setup-java` with java-version 17 in the `build-android` job before
`flutter build apk --release`. Exits 1 otherwise.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

DEFAULT_WORKFLOW = Path(".github/workflows/mobile-ci.yml")
SETUP_JAVA_RE = re.compile(r"actions/setup-java(?:@[\w.]+)?")
JAVA_VERSION_RE = re.compile(r"java-version:\s*['\"]?17['\"]?")
APK_BUILD_RE = re.compile(r"flutter\s+build\s+apk\s+--release")


def job_block(text: str, job_name: str) -> str:
    """Return the indented body of a top-level jobs.<name> block."""
    marker = f"  {job_name}:"
    start = text.find(marker)
    if start < 0:
        raise SystemExit(f"job '{job_name}' not found")
    body_start = start + len(marker)
    next_job = re.search(r"\n  [A-Za-z0-9_-]+:", text[body_start:])
    end = body_start + next_job.start() if next_job else len(text)
    return text[body_start:end]


def check_java_pin(workflow: Path) -> None:
    text = workflow.read_text(encoding="utf-8")
    android = job_block(text, "build-android")

    setup = SETUP_JAVA_RE.search(android)
    if setup is None:
        raise SystemExit(
            f"{workflow}: build-android missing actions/setup-java before release APK build"
        )

    java17 = JAVA_VERSION_RE.search(android)
    if java17 is None:
        raise SystemExit(
            f"{workflow}: build-android missing java-version 17 for setup-java"
        )

    apk = APK_BUILD_RE.search(android)
    if apk is None:
        raise SystemExit(f"{workflow}: build-android missing flutter build apk --release")

    if setup.start() >= apk.start() or java17.start() >= apk.start():
        raise SystemExit(
            f"{workflow}: Java 17 pin must appear before flutter build apk --release"
        )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "workflow",
        nargs="?",
        type=Path,
        default=DEFAULT_WORKFLOW,
        help=f"path to mobile-ci workflow (default: {DEFAULT_WORKFLOW})",
    )
    args = parser.parse_args(argv)
    if not args.workflow.is_file():
        raise SystemExit(f"{args.workflow}: file not found")
    check_java_pin(args.workflow)
    print(f"{args.workflow}: build-android pins Java 17 before release APK build")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
