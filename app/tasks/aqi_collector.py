"""
AQI Collector - Background ETL Worker.

Fetches real-time air quality data from IQAir API every 30 minutes,
stores it in the database, and sends FCM push alerts to users whose
AQI threshold has been exceeded.

Usage: Started automatically on app startup via APScheduler.
"""

import logging
from datetime import datetime, timezone
from typing import Optional

import httpx
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.config import settings
from app.models.aqs import Station, AirQualityLog, StationSource
from app.models.user import User
from app.models.dps import HealthProfile

logger = logging.getLogger(__name__)

# Cities/locations to monitor (lat, lon, display name)
MONITORED_LOCATIONS = [
    {"city": "Hanoi", "country": "Vietnam", "lat": 21.0285, "lon": 105.8542, "name": "Hà Nội"},
    {"city": "Ho Chi Minh City", "country": "Vietnam", "lat": 10.8231, "lon": 106.6297, "name": "TP. Hồ Chí Minh"},
    {"city": "Da Nang", "country": "Vietnam", "lat": 16.0544, "lon": 108.2022, "name": "Đà Nẵng"},
    {"city": "Hai Phong", "country": "Vietnam", "lat": 20.8449, "lon": 106.6881, "name": "Hải Phòng"},
    {"city": "Can Tho", "country": "Vietnam", "lat": 10.0452, "lon": 105.7469, "name": "Cần Thơ"},
]

# AQI threshold to trigger push notifications
AQI_ALERT_THRESHOLD = 100  # Moderate → Unhealthy boundary


class IQAirClient:
    """
    Client for IQAir AirVisual API.
    Docs: https://api-docs.iqair.com/
    """

    BASE_URL = settings.IQAIR_BASE_URL
    API_KEY = settings.IQAIR_API_KEY

    async def fetch_city_data(
        self,
        city: str,
        country: str = "Vietnam",
    ) -> Optional[dict]:
        """
        Fetch current air quality for a city.

        Returns dict with AQI, PM2.5, temperature, humidity or None on error.
        """
        params = {
            "city": city,
            "country": country,
            "key": self.API_KEY,
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(f"{self.BASE_URL}/city", params=params)
                resp.raise_for_status()
                data = resp.json()

            if data.get("status") != "success":
                logger.warning(f"IQAir non-success for {city}: {data}")
                return None

            pollution = data["data"]["current"]["pollution"]
            weather = data["data"]["current"]["weather"]

            return {
                "aqi": pollution.get("aqius"),
                "pm25": pollution.get("conc", {}).get("p2"),
                "temperature": weather.get("tp"),
                "humidity": weather.get("hu"),
            }

        except httpx.HTTPStatusError as e:
            logger.error(f"IQAir HTTP error for {city}: {e.response.status_code}")
            return None
        except Exception as e:
            logger.error(f"IQAir fetch error for {city}: {e}")
            return None


async def _send_aqi_alerts(
    db: AsyncSession,
    station: Station,
    aqi: int,
) -> None:
    """
    Send FCM push notifications to users near this station
    whose perceived AQI exceeds the alert threshold.
    """
    try:
        # Import here to avoid circular imports
        from app.services.notification_service import notification_service
        from app.services.personalization_service import PersonalizationService

        # Find all users with FCM tokens and health profiles
        stmt = select(User, HealthProfile).join(
            HealthProfile, HealthProfile.user_id == User.id, isouter=True
        ).where(User.fcm_token.isnot(None))
        result = await db.execute(stmt)
        rows = result.all()

        personalization = PersonalizationService()

        for user, profile in rows:
            # Calculate perceived AQI with health weights
            perceived_aqi = aqi
            if profile:
                perceived_aqi = personalization.calculate_perceived_aqi(
                    real_aqi=aqi,
                    birth_year=profile.birth_year,
                    conditions=profile.conditions,
                    sensitivity_level=profile.sensitivity_level,
                )

            # Only alert if perceived AQI exceeds threshold
            if perceived_aqi > AQI_ALERT_THRESHOLD:
                await notification_service.send_aqi_alert(
                    fcm_token=user.fcm_token,
                    aqi=aqi,
                    station_name=station.name,
                    perceived_aqi=perceived_aqi,
                )
                logger.info(
                    f"FCM alert sent to {user.email}: "
                    f"AQI={aqi} → perceived={perceived_aqi:.0f} at {station.name}"
                )
    except Exception as e:
        logger.error(f"FCM alert error: {e}")


async def collect_aqi_data(db: AsyncSession) -> None:
    """
    Main ETL job: fetch AQI from IQAir and upsert into DB.
    Triggers FCM push alerts when AQI exceeds threshold.

    Called by APScheduler every 30 minutes.
    """
    client = IQAirClient()
    inserted = 0
    failed = 0

    for loc in MONITORED_LOCATIONS:
        # 1. Upsert station
        stmt = select(Station).where(
            Station.name == loc["name"],
            Station.source == StationSource.IQAIR,
        )
        result = await db.execute(stmt)
        station = result.scalar_one_or_none()

        if not station:
            station = Station(
                name=loc["name"],
                source=StationSource.IQAIR,
                latitude=loc["lat"],
                longitude=loc["lon"],
                is_active=True,
            )
            db.add(station)
            await db.flush()
            logger.info(f"Created new station: {loc['name']}")

        # 2. Fetch live AQI data
        data = await client.fetch_city_data(
            city=loc["city"],
            country=loc["country"],
        )

        if not data or data["aqi"] is None:
            logger.warning(f"No AQI data for {loc['name']}, skipping.")
            failed += 1
            continue

        # 3. Store log entry
        log = AirQualityLog(
            station_id=station.id,
            aqi=data["aqi"],
            pm25=data.get("pm25"),
            temperature=data.get("temperature"),
            humidity=data.get("humidity"),
            recorded_at=datetime.now(timezone.utc),
        )
        db.add(log)
        inserted += 1
        logger.info(f"✅ {loc['name']}: AQI={data['aqi']}, PM2.5={data.get('pm25')}")

        # 4. Send FCM alerts if AQI exceeds threshold
        if data["aqi"] > AQI_ALERT_THRESHOLD:
            await _send_aqi_alerts(db, station, data["aqi"])

    await db.commit()
    logger.info(f"AQI collection done: {inserted} inserted, {failed} failed.")
