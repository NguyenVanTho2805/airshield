"""
Air Quality API Router.
Endpoints: /api/v1/air-quality
"""

import json
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional

logger = logging.getLogger(__name__)
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
import redis.asyncio as aioredis

from app.core.config import settings
from app.core.database import get_db
from app.core.redis import get_redis
from app.models.aqs import Station, AirQualityLog
from app.schemas.schemas import (
    AirQualityResponse,
    AirQualityHistoryResponse,
    AirQualityHistoryItem,
    Coordinate,
)

router = APIRouter()



@router.get("/current", response_model=AirQualityResponse)
async def get_current_air_quality(
    latitude: float = Query(..., ge=-90, le=90, description="User latitude"),
    longitude: float = Query(..., ge=-180, le=180, description="User longitude"),
    db: AsyncSession = Depends(get_db),
    redis: aioredis.Redis = Depends(get_redis),
):
    """
    Get current AQI based on user's location.

    Finds the nearest active station and returns latest reading.
    Results are cached in Redis for 5 minutes to reduce DB load.
    """
    # Redis cache key based on rounded coordinates (2dp ≈ 1.1km precision)
    cache_key = f"aqi:current:{latitude:.2f}:{longitude:.2f}"

    # Try cache first
    try:
        cached = await redis.get(cache_key)
        if cached:
            data = json.loads(cached)
            return AirQualityResponse(**data)
    except Exception as e:
        logger.warning("Redis cache read failed: %s", e)

    # Find nearest active station
    stmt = select(Station).where(Station.is_active == True)
    result = await db.execute(stmt)
    stations = result.scalars().all()

    if not stations:
        raise HTTPException(status_code=404, detail="No active stations found")

    def calculate_distance(station: Station) -> float:
        lat_diff = abs(station.latitude - latitude)
        lon_diff = abs(station.longitude - longitude)
        return (lat_diff ** 2 + lon_diff ** 2) ** 0.5

    nearest_station = min(stations, key=calculate_distance)

    # Get latest reading for this station
    stmt = (
        select(AirQualityLog)
        .where(AirQualityLog.station_id == nearest_station.id)
        .order_by(AirQualityLog.recorded_at.desc())
        .limit(1)
    )
    result = await db.execute(stmt)
    latest_log = result.scalar_one_or_none()

    if not latest_log:
        raise HTTPException(
            status_code=404,
            detail=f"No readings available for station: {nearest_station.name}"
        )

    response = AirQualityResponse(
        aqi=latest_log.aqi,
        pm25=latest_log.pm25,
        temperature=latest_log.temperature,
        humidity=latest_log.humidity,
        station_name=nearest_station.name,
        recorded_at=latest_log.recorded_at,
    )

    # Store in Redis cache
    try:
        payload = response.model_dump()
        payload["recorded_at"] = payload["recorded_at"].isoformat() if payload.get("recorded_at") else None
        await redis.setex(cache_key, settings.CACHE_TTL_AQI, json.dumps(payload))
    except Exception as e:
        logger.warning("Redis cache write failed: %s", e)

    return response


@router.get("/history", response_model=AirQualityHistoryResponse)
async def get_air_quality_history(
    latitude: float = Query(..., ge=-90, le=90, description="User latitude"),
    longitude: float = Query(..., ge=-180, le=180, description="User longitude"),
    hours: int = Query(24, ge=1, le=168, description="Hours of history (max 7 days)"),
    db: AsyncSession = Depends(get_db),
):
    """
    Get historical AQI data for charting.
    
    Returns hourly readings for the specified duration.
    """
    # Find nearest station (same logic as current)
    stmt = select(Station).where(Station.is_active == True)
    result = await db.execute(stmt)
    stations = result.scalars().all()
    
    if not stations:
        raise HTTPException(status_code=404, detail="No active stations found")
    
    def calculate_distance(station: Station) -> float:
        lat_diff = abs(station.latitude - latitude)
        lon_diff = abs(station.longitude - longitude)
        return (lat_diff ** 2 + lon_diff ** 2) ** 0.5
    
    nearest_station = min(stations, key=calculate_distance)
    
    # Get history for the time range
    since = datetime.now(timezone.utc) - timedelta(hours=hours)
    stmt = (
        select(AirQualityLog)
        .where(
            and_(
                AirQualityLog.station_id == nearest_station.id,
                AirQualityLog.recorded_at >= since,
            )
        )
        .order_by(AirQualityLog.recorded_at.asc())
    )
    result = await db.execute(stmt)
    logs = result.scalars().all()
    
    history_data = [
        AirQualityHistoryItem(
            aqi=log.aqi,
            pm25=log.pm25,
            recorded_at=log.recorded_at,
        )
        for log in logs
    ]
    
    return AirQualityHistoryResponse(
        station_name=nearest_station.name,
        data=history_data,
    )


@router.get("/forecast", response_model=AirQualityForecastResponse)
async def get_air_quality_forecast(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    db: AsyncSession = Depends(get_db),
    redis: aioredis.Redis = Depends(get_redis),
):
    """
    Get 24-hour AQI forecast using AI (Prophet).
    Cached in Redis for 1 hour to reduce complex training load.
    """
    from app.services.forecast_service import forecast_service
    from app.schemas.schemas import AirQualityForecastResponse, AirQualityForecastItem
    
    cache_key = f"aqi:forecast:{latitude:.2f}:{longitude:.2f}"
    
    # Check cache (1 hour TTL)
    try:
        cached = await redis.get(cache_key)
        if cached:
            data = json.loads(cached)
            return AirQualityForecastResponse(**data)
    except Exception as e:
        logger.warning("Redis cache read failed: %s", e)
        
    forecast_data = await forecast_service.generate_forecast(
        latitude=latitude,
        longitude=longitude,
        db=db,
        hours_ahead=24
    )
    
    if not forecast_data:
        raise HTTPException(
            status_code=404, 
            detail="Not enough data to calculate forecast"
        )
        
    response = AirQualityForecastResponse(
        data=[AirQualityForecastItem(**item) for item in forecast_data]
    )
    
    # Cache to Redis for 1 hour
    try:
        payload = response.model_dump()
        for item in payload['data']:
            if isinstance(item.get('recorded_at'), datetime):
                item['recorded_at'] = item['recorded_at'].isoformat()
        await redis.setex(cache_key, settings.CACHE_TTL_FORECAST, json.dumps(payload))
    except Exception as e:
        logger.warning("Redis cache write failed: %s", e)
        
    return response
