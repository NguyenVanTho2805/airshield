"""
Seed script to populate the database with initial test data.
Run: python -m app.scripts.seed_data
"""

import asyncio
from datetime import datetime, timedelta
import random

from sqlalchemy import text
from app.core.database import AsyncSessionLocal, engine
from app.models.base import Base
from app.models.aqs import Station, AirQualityLog, StationSource


async def clear_tables():
    """Clear existing data."""
    async with AsyncSessionLocal() as session:
        await session.execute(text("DELETE FROM air_quality_logs"))
        await session.execute(text("DELETE FROM stations"))
        await session.commit()


async def create_tables():
    """Create all tables."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def seed_stations():
    """Create sample stations."""
    stations_data = [
        {"name": "Hanoi - Hoan Kiem", "latitude": 21.0285, "longitude": 105.8542, "source": StationSource.IQAIR},
        {"name": "Hanoi - Cau Giay", "latitude": 21.0356, "longitude": 105.7948, "source": StationSource.IQAIR},
        {"name": "Ho Chi Minh City", "latitude": 10.7769, "longitude": 106.7009, "source": StationSource.IQAIR},
        {"name": "Da Nang", "latitude": 16.0544, "longitude": 108.2022, "source": StationSource.PAMAIR},
    ]
    
    async with AsyncSessionLocal() as session:
        for data in stations_data:
            station = Station(**data, is_active=True)
            session.add(station)
        await session.commit()
        
        # Get created stations
        result = await session.execute(text("SELECT id, name FROM stations"))
        stations = result.fetchall()
        print(f"Created {len(stations)} stations:")
        for s in stations:
            print(f"  - {s[0]}: {s[1]}")
        
        return [s[0] for s in stations]


async def seed_air_quality_logs(station_ids: list[int]):
    """Create sample air quality logs for the past 24 hours."""
    async with AsyncSessionLocal() as session:
        now = datetime.utcnow()
        
        for station_id in station_ids:
            # Create 24 hourly readings
            for hours_ago in range(24):
                recorded_at = now - timedelta(hours=hours_ago)
                
                # Random but realistic AQI values
                base_aqi = random.randint(30, 80)
                aqi = base_aqi + random.randint(-10, 20)
                pm25 = aqi * 0.5 + random.uniform(-5, 5)
                
                log = AirQualityLog(
                    station_id=station_id,
                    aqi=max(0, min(500, aqi)),
                    pm25=max(0, round(pm25, 1)),
                    temperature=random.uniform(22, 32),
                    humidity=random.uniform(60, 85),
                    recorded_at=recorded_at,
                )
                session.add(log)
        
        await session.commit()
        print(f"Created {24 * len(station_ids)} air quality log entries")


async def main():
    """Run seed script."""
    print("🌱 Starting database seed...")
    
    try:
        print("📋 Creating tables...")
        await create_tables()
        
        print("🗑️  Clearing existing data...")
        await clear_tables()
        
        print("🏭 Creating stations...")
        station_ids = await seed_stations()
        
        print("📊 Creating air quality logs...")
        await seed_air_quality_logs(station_ids)
        
        print("✅ Seed completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        raise


if __name__ == "__main__":
    asyncio.run(main())
