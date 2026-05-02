#!/usr/bin/env python3
"""
check_env.py — Validate .env configuration for AirShield backend.
Usage: python scripts/check_env.py
"""

import os
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
ENV_FILE = ROOT / ".env"

REQUIRED = {
    "SECRET_KEY": "JWT secret — generate: python -c \"import secrets; print(secrets.token_hex(32))\"",
    "IQAIR_API_KEY": "IQAir API key — https://www.iqair.com/air-pollution-data-api",
    "GEMINI_API_KEY": "Google Gemini key — https://aistudio.google.com/app/apikey",
    "DATABASE_URL": "PostgreSQL connection string",
}

OPTIONAL = {
    "GOOGLE_MAPS_API_KEY": "Google Maps Directions API — https://console.cloud.google.com/",
    "TUYA_CLIENT_ID": "Tuya IoT Client ID — https://iot.tuya.com/",
    "TUYA_CLIENT_SECRET": "Tuya IoT Client Secret",
    "FIREBASE_CREDENTIALS_PATH": "Firebase service account JSON path",
}

PLACEHOLDER_PREFIXES = ("REPLACE_WITH_", "your_", "change-this")


def load_env(path: Path) -> dict[str, str]:
    env: dict[str, str] = {}
    if not path.exists():
        return env
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        env[key.strip()] = value.strip()
    return env


def is_placeholder(value: str) -> bool:
    return any(value.startswith(p) for p in PLACEHOLDER_PREFIXES) or not value


def check(env: dict[str, str]) -> bool:
    ok = True

    print("\n=== AirShield Environment Check ===\n")

    print("REQUIRED keys:")
    for key, hint in REQUIRED.items():
        value = env.get(key, "")
        if not value or is_placeholder(value):
            print(f"  ✗ {key} — MISSING")
            print(f"    → {hint}")
            ok = False
        else:
            masked = value[:4] + "****" if len(value) > 4 else "****"
            print(f"  ✓ {key} = {masked}")

    print("\nOPTIONAL keys:")
    for key, hint in OPTIONAL.items():
        value = env.get(key, "")
        if not value or is_placeholder(value):
            print(f"  - {key} — not set ({hint})")
        else:
            masked = value[:4] + "****" if len(value) > 4 else "****"
            print(f"  ✓ {key} = {masked}")

    print()
    if ok:
        print("All required keys are set. You're good to go!")
    else:
        print("Some required keys are missing. Copy .env.example to .env and fill them in.")
    print()
    return ok


def main() -> None:
    if not ENV_FILE.exists():
        print(f"Error: {ENV_FILE} not found.")
        print("Run: cp .env.example .env  and fill in the values.")
        sys.exit(1)

    env = load_env(ENV_FILE)
    success = check(env)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
