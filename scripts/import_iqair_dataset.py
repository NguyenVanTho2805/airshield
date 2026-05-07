"""
Import Vietnam AQI dataset from https://github.com/nghiahsgs/iqair-dataset
into the local PostgreSQL database.

Usage:
    python scripts/import_iqair_dataset.py                    # import tất cả
    python scripts/import_iqair_dataset.py --city ha-noi      # 1 thành phố
    python scripts/import_iqair_dataset.py --year 2025        # 1 năm
    python scripts/import_iqair_dataset.py --months 3         # 3 tháng gần nhất

Requires: httpx, pandas (already in requirements.txt)
"""

import asyncio
import argparse
import csv
import io
import sys
from datetime import datetime, timezone
from typing import Optional

import httpx
from sqlalchemy import select, text

sys.path.insert(0, ".")
from app.core.database import AsyncSessionLocal
from app.models.aqs import Station, AirQualityLog, StationSource


# ── City metadata ──────────────────────────────────────────────────────────────

CITIES = {
    "ha-noi": {
        "display": "Hà Nội",
        "latitude": 21.0285,
        "longitude": 105.8542,
    },
    "ho-chi-minh-city": {
        "display": "TP. Hồ Chí Minh",
        "latitude": 10.7769,
        "longitude": 106.7009,
    },
    "da-nang": {
        "display": "Đà Nẵng",
        "latitude": 16.0544,
        "longitude": 108.2022,
    },
    "hue": {
        "display": "Huế",
        "latitude": 16.4637,
        "longitude": 107.5909,
    },
    "nha-trang": {
        "display": "Nha Trang",
        "latitude": 12.2388,
        "longitude": 109.1967,
    },
    "can-tho": {
        "display": "Cần Thơ",
        "latitude": 10.0341,
        "longitude": 105.7853,
    },
    "hai-phong": {
        "display": "Hải Phòng",
        "latitude": 20.8449,
        "longitude": 106.6881,
    },
    "vinh": {
        "display": "Vinh",
        "latitude": 18.6696,
        "longitude": 105.6814,
    },
}

MONTH_NAMES = ["jan", "feb", "mar", "apr", "may", "jun",
               "jul", "aug", "sep", "oct", "nov", "dec"]

BASE_RAW_URL = "https://raw.githubusercontent.com/nghiahsgs/iqair-dataset/main/result"


# ── Helpers ────────────────────────────────────────────────────────────────────

def csv_url(city_slug: str, year: int, month_idx: int) -> str:
    """Build raw GitHub URL for a monthly CSV file."""
    return f"{BASE_RAW_URL}/aqi_{city_slug}_{year}_{MONTH_NAMES[month_idx]}.csv"


def parse_timestamp(ts: str) -> Optional[datetime]:
    """Parse various timestamp formats from the dataset."""
    for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%dT%H:%M:%S", "%d/%m/%Y %H:%M"):
        try:
            return datetime.strptime(ts.strip(), fmt).replace(tzinfo=timezone.utc)
        except ValueError:
            continue
    return None


async def get_or_create_station(session, city_slug: str) -> Station:
    """Return existing station or create a new one."""
    meta = CITIES[city_slug]
    result = await session.execute(
        select(Station).where(Station.name == meta["display"])
    )
    station = result.scalar_one_or_none()
    if station:
        return station

    station = Station(
        name=meta["display"],
        source=StationSource.IQAIR,
        latitude=meta["latitude"],
        longitude=meta["longitude"],
        is_active=True,
    )
    session.add(station)
    await session.flush()
    print(f"  [+] Created station: {meta['display']}")
    return station


async def import_csv_content(session, station: Station, content: str) -> int:
    """Parse CSV content and bulk-insert AirQualityLog rows. Returns count inserted."""
    reader = csv.DictReader(io.StringIO(content))
    rows: list[AirQualityLog] = []

    for row in reader:
        ts = parse_timestamp(row.get("timestamp", ""))
        if not ts:
            continue
        try:
            aqi_val = int(float(row.get("aqi", 0) or 0))
        except (ValueError, TypeError):
            continue
        if not (0 <= aqi_val <= 500):
            continue

        humidity_raw = row.get("humidity", "")
        try:
            humidity = float(str(humidity_raw).replace("%", "").strip()) if humidity_raw else None
        except ValueError:
            humidity = None

        rows.append(AirQualityLog(
            station_id=station.id,
            aqi=aqi_val,
            pm25=None,           # dataset does not include PM2.5 breakdown
            temperature=None,
            humidity=humidity,
            recorded_at=ts,
        ))

    if rows:
        session.add_all(rows)
    return len(rows)


# ── Main import logic ──────────────────────────────────────────────────────────

async def import_city(
    city_slug: str,
    years: list[int],
    month_limit: Optional[int] = None,
    skip_existing: bool = True,
) -> None:
    meta = CITIES[city_slug]
    print(f"\n── {meta['display']} ({city_slug}) ──")

    async with httpx.AsyncClient(timeout=30) as http:
        async with AsyncSessionLocal() as session:
            station = await get_or_create_station(session, city_slug)

            if skip_existing:
                result = await session.execute(
                    text("SELECT COUNT(*) FROM air_quality_logs WHERE station_id = :sid"),
                    {"sid": station.id},
                )
                existing = result.scalar()
                if existing:
                    print(f"  Skipping — {existing:,} rows already in DB (use --force to re-import)")
                    return

            total = 0
            files_checked = 0
            now = datetime.now()

            for year in years:
                for month_idx in range(11, -1, -1):  # newest first
                    if year == now.year and month_idx > now.month - 1:
                        continue
                    if month_limit and files_checked >= month_limit:
                        break

                    url = csv_url(city_slug, year, month_idx)
                    try:
                        resp = await http.get(url)
                        if resp.status_code == 404:
                            continue
                        resp.raise_for_status()
                        count = await import_csv_content(session, station, resp.text)
                        print(f"  {year}-{MONTH_NAMES[month_idx]:>3}: {count:>5} rows")
                        total += count
                        files_checked += 1
                    except Exception as e:
                        print(f"  {year}-{MONTH_NAMES[month_idx]:>3}: ERROR — {e}")

            await session.commit()
            print(f"  Total imported: {total:,} rows")


async def main(
    cities: Optional[list[str]] = None,
    years: Optional[list[int]] = None,
    months: Optional[int] = None,
    force: bool = False,
) -> None:
    target_cities = cities or list(CITIES.keys())
    target_years = years or [2025, 2026]

    print("═" * 60)
    print("  AirShield — Import IQAir Vietnam Dataset")
    print(f"  Cities  : {', '.join(target_cities)}")
    print(f"  Years   : {target_years}")
    print(f"  Months  : {'all' if not months else f'last {months}'}")
    print("═" * 60)

    for slug in target_cities:
        if slug not in CITIES:
            print(f"Unknown city slug: {slug} — skipping")
            continue
        await import_city(slug, target_years, month_limit=months, skip_existing=not force)

    print("\nDone.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Import IQAir Vietnam dataset into AirShield DB")
    parser.add_argument("--city", nargs="+", choices=list(CITIES.keys()),
                        help="City slugs to import (default: all)")
    parser.add_argument("--year", nargs="+", type=int,
                        help="Years to import (default: 2025 2026)")
    parser.add_argument("--months", type=int,
                        help="Import only last N months per city")
    parser.add_argument("--force", action="store_true",
                        help="Re-import even if data already exists")
    args = parser.parse_args()

    asyncio.run(main(
        cities=args.city,
        years=args.year,
        months=args.months,
        force=args.force,
    ))
