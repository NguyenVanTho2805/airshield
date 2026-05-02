"""
Health Profile API Router.
Endpoints: /api/v1/user/health
"""

from fastapi import APIRouter, Depends, HTTPException, Header
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.database import get_db
from app.core.auth import get_current_active_user
from app.models.user import User
from app.models.dps import HealthProfile
from app.models.aqs import Station, AirQualityLog
from app.schemas.schemas import (
    HealthProfileCreate,
    HealthProfileResponse,
    RecommendationResponse,
    RiskLevel as SchemaRiskLevel,
)
from app.services.personalization_service import PersonalizationService

router = APIRouter()


@router.post("/profile", response_model=HealthProfileResponse)
async def update_health_profile(
    profile_data: HealthProfileCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create or update health profile for the current authenticated user.

    Stores health conditions and sensitivity preferences for personalization.
    """
    stmt = select(HealthProfile).where(HealthProfile.user_id == current_user.id)
    result = await db.execute(stmt)
    existing_profile = result.scalar_one_or_none()

    if existing_profile:
        existing_profile.birth_year = profile_data.birth_year
        existing_profile.conditions = profile_data.conditions
        existing_profile.sensitivity_level = profile_data.sensitivity_level
        profile = existing_profile
    else:
        profile = HealthProfile(
            user_id=current_user.id,
            birth_year=profile_data.birth_year,
            conditions=profile_data.conditions,
            sensitivity_level=profile_data.sensitivity_level,
        )
        db.add(profile)

    await db.commit()
    await db.refresh(profile)

    return HealthProfileResponse(
        user_id=profile.user_id,
        birth_year=profile.birth_year,
        conditions=profile.conditions,
        sensitivity_level=profile.sensitivity_level,
    )


@router.get("/recommendation", response_model=RecommendationResponse)
async def get_personalized_recommendation(
    latitude: float,
    longitude: float,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
    accept_language: Optional[str] = Header(default="vi", alias="Accept-Language"),
):
    """
    Get personalized health recommendation based on current AQI and user profile.

    Set `Accept-Language: vi` for Vietnamese (default) or `Accept-Language: en` for English.
    """
    # Get user health profile
    stmt = select(HealthProfile).where(HealthProfile.user_id == current_user.id)
    result = await db.execute(stmt)
    profile = result.scalar_one_or_none()

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Health profile not found. Please set up your profile first via POST /user/health/profile"
        )

    # Get nearest active station
    stmt = select(Station).where(Station.is_active == True)
    result = await db.execute(stmt)
    stations = result.scalars().all()

    if not stations:
        raise HTTPException(status_code=404, detail="No active air quality stations found")

    def calculate_distance(station: Station) -> float:
        lat_diff = abs(station.latitude - latitude)
        lon_diff = abs(station.longitude - longitude)
        return (lat_diff ** 2 + lon_diff ** 2) ** 0.5

    nearest_station = min(stations, key=calculate_distance)

    # Get latest reading
    stmt = (
        select(AirQualityLog)
        .where(AirQualityLog.station_id == nearest_station.id)
        .order_by(AirQualityLog.recorded_at.desc())
        .limit(1)
    )
    result = await db.execute(stmt)
    latest_log = result.scalar_one_or_none()

    if not latest_log:
        raise HTTPException(status_code=404, detail="No AQI data available for your location")

    # Determine language (Accept-Language: vi or en)
    lang = "vi" if "vi" in (accept_language or "") else "en"

    # Generate personalized advice
    personalization = PersonalizationService()
    advice = personalization.get_personalized_advice(
        real_aqi=latest_log.aqi,
        birth_year=profile.birth_year,
        conditions=profile.conditions,
        sensitivity_level=profile.sensitivity_level,
        lang=lang,
    )

    return RecommendationResponse(
        real_aqi=latest_log.aqi,
        perceived_aqi=advice.perceived_aqi,
        risk_level=SchemaRiskLevel(advice.risk_level.value),
        is_high_risk=advice.is_high_risk,
        recommendations=advice.recommendations,
        warning_message=advice.warning_message,
    )
