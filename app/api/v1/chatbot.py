"""
Chatbot API Endpoints - AI conversational interface for AirShield.
"""

from typing import Optional, List
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from datetime import datetime, timedelta, timezone

import redis.asyncio as aioredis

from app.core.database import get_db
from app.core.redis import get_redis
from app.core.auth import get_current_active_user
from app.models.user import User
from app.models.aqs import Station, AirQualityLog
from app.schemas.chatbot import (
    ChatRequest,
    ChatResponse,
    ChatSessionSchema,
    ChatSessionListItem
)
from app.services.chatbot_service import chatbot_service


router = APIRouter()


async def _get_real_aqi_context(
    latitude: float,
    longitude: float,
    db: AsyncSession,
) -> Optional[dict]:
    """
    Fetch real AQI from nearest station in DB.
    Replaces the old mock data (aqi: 65).
    """
    stmt = select(Station).where(Station.is_active == True)
    result = await db.execute(stmt)
    stations = result.scalars().all()

    if not stations:
        return None

    def distance(s: Station) -> float:
        return ((s.latitude - latitude) ** 2 + (s.longitude - longitude) ** 2) ** 0.5

    nearest = min(stations, key=distance)

    # Get latest reading (within last 2 hours)
    since = datetime.now(timezone.utc) - timedelta(hours=2)
    stmt = (
        select(AirQualityLog)
        .where(
            and_(
                AirQualityLog.station_id == nearest.id,
                AirQualityLog.recorded_at >= since,
            )
        )
        .order_by(AirQualityLog.recorded_at.desc())
        .limit(1)
    )
    result = await db.execute(stmt)
    log = result.scalar_one_or_none()

    if not log:
        return None

    # AQI level label
    aqi = log.aqi
    if aqi <= 50:
        status = "Tốt"
    elif aqi <= 100:
        status = "Trung bình"
    elif aqi <= 150:
        status = "Không tốt cho nhóm nhạy cảm"
    elif aqi <= 200:
        status = "Không lành mạnh"
    elif aqi <= 300:
        status = "Rất không lành mạnh"
    else:
        status = "Nguy hiểm"

    return {
        "station": nearest.name,
        "aqi": aqi,
        "pm25": log.pm25,
        "temperature": log.temperature,
        "humidity": log.humidity,
        "status": status,
        "recorded_at": log.recorded_at.isoformat(),
    }


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
    redis: aioredis.Redis = Depends(get_redis),
) -> ChatResponse:
    """
    Send a message to the AI chatbot and get a response.

    The chatbot can:
    - Answer questions about air quality (AQI, PM2.5, etc.)
    - Provide health recommendations based on AQI levels
    - Help control smart home devices
    - Give personalized advice based on user health profile

    **Session Management:**
    - If `session_id` is provided, continues the existing conversation
    - If `session_id` is null/omitted, creates a new session

    **Context:**
    - Optionally provide latitude/longitude for location-aware responses
    - Set `include_aqi_context=true` to include current AQI data from DB
    """
    # Fetch real AQI from DB (replaces hardcoded mock)
    aqi_data = None
    if request.include_aqi_context and request.latitude and request.longitude:
        aqi_data = await _get_real_aqi_context(
            latitude=request.latitude,
            longitude=request.longitude,
            db=db,
        )

    response = await chatbot_service.chat(
        message=request.message,
        redis=redis,
        session_id=request.session_id,
        aqi_data=aqi_data,
        user_id=str(current_user.id),
    )

    return response


@router.get("/sessions", response_model=List[ChatSessionListItem])
async def list_sessions(
    current_user: User = Depends(get_current_active_user),
    redis: aioredis.Redis = Depends(get_redis),
) -> List[ChatSessionListItem]:
    """
    List all chat sessions for the current user.
    """
    sessions = await chatbot_service.list_sessions(redis=redis, user_id=str(current_user.id))
    return [
        ChatSessionListItem(
            id=s["id"],
            title=s.get("title"),
            message_count=s.get("message_count", 0),
            created_at=s.get("created_at", "2026-01-01T00:00:00Z"),
            updated_at=s.get("updated_at", "2026-01-01T00:00:00Z")
        )
        for s in sessions
    ]


@router.get("/sessions/{session_id}")
async def get_session(
    session_id: str,
    current_user: User = Depends(get_current_active_user),
    redis: aioredis.Redis = Depends(get_redis),
):
    """
    Get chat history for a specific session.
    """
    history = await chatbot_service.get_session_history(redis=redis, session_id=session_id)

    if not history:
        raise HTTPException(
            status_code=404,
            detail=f"Session '{session_id}' not found"
        )

    return {
        "session_id": session_id,
        "messages": history,
        "message_count": len(history)
    }


@router.delete("/sessions/{session_id}")
async def delete_session(
    session_id: str,
    current_user: User = Depends(get_current_active_user),
    redis: aioredis.Redis = Depends(get_redis),
):
    """
    Delete a chat session and all its messages.
    """
    success = await chatbot_service.delete_session(redis=redis, session_id=session_id)

    if not success:
        raise HTTPException(
            status_code=404,
            detail=f"Session '{session_id}' not found"
        )

    return {"message": f"Session '{session_id}' deleted successfully"}
