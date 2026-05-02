"""
Pydantic schemas for API request/response validation.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, Field
from enum import Enum


# ============ Common ============

class Coordinate(BaseModel):
    """Geographic coordinate."""
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


# ============ AQS Schemas ============

class StationSource(str, Enum):
    IQAIR = "iqair"
    PAMAIR = "pamair"


class AirQualityResponse(BaseModel):
    """Current air quality response."""
    aqi: int
    pm25: Optional[float] = None
    temperature: Optional[float] = None
    humidity: Optional[float] = None
    station_name: str
    recorded_at: datetime
    
    class Config:
        from_attributes = True


class AirQualityHistoryItem(BaseModel):
    """Single history data point."""
    aqi: int
    pm25: Optional[float] = None
    recorded_at: datetime


class AirQualityHistoryResponse(BaseModel):
    """24-hour history response."""
    station_name: str
    data: List[AirQualityHistoryItem]


class AirQualityForecastItem(BaseModel):
    """Single forecast data point."""
    aqi: int
    recorded_at: datetime
    is_forecast: bool = True


class AirQualityForecastResponse(BaseModel):
    """Forecast response."""
    data: List[AirQualityForecastItem]


# ============ Routing Schemas ============

class TravelMode(str, Enum):
    DRIVING = "driving"
    CYCLING = "cycling"
    WALKING = "walking"


class RouteRequest(BaseModel):
    """Route calculation request."""
    start: Coordinate
    end: Coordinate
    mode: TravelMode = TravelMode.DRIVING


class RouteSegmentResponse(BaseModel):
    """Route segment details."""
    distance_km: float
    aqi_factor: float


class RouteResponse(BaseModel):
    """Single route response."""
    route_type: str
    total_distance_km: float
    total_time_minutes: float
    weighted_cost: float
    segments: List[RouteSegmentResponse]


class RoutesResponse(BaseModel):
    """Response with both route options."""
    fastest: RouteResponse
    cleanest: RouteResponse


# ============ Health Profile Schemas ============

class HealthProfileCreate(BaseModel):
    """Create/update health profile."""
    birth_year: Optional[int] = Field(None, ge=1900, le=2025)
    conditions: Optional[List[str]] = Field(default_factory=list)
    sensitivity_level: int = Field(3, ge=1, le=5)


class HealthProfileResponse(BaseModel):
    """Health profile response."""
    user_id: UUID
    birth_year: Optional[int]
    conditions: Optional[List[str]]
    sensitivity_level: int
    
    class Config:
        from_attributes = True


class RiskLevel(str, Enum):
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    VERY_HIGH = "very_high"
    HAZARDOUS = "hazardous"


class RecommendationResponse(BaseModel):
    """Personalized recommendation response."""
    real_aqi: int
    perceived_aqi: float
    risk_level: RiskLevel
    is_high_risk: bool
    recommendations: List[str]
    warning_message: Optional[str] = None


# ============ Community Schemas ============

class IncidentType(str, Enum):
    BURNING = "burning"
    DUST = "dust"
    SMOKE = "smoke"
    CHEMICAL = "chemical"
    OTHER = "other"


class ReportStatus(str, Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    REJECTED = "rejected"


class CommunityReportCreate(BaseModel):
    """Create community report."""
    incident_type: IncidentType
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    image_url: Optional[str] = None
    description: Optional[str] = None


class CommunityReportResponse(BaseModel):
    """Community report response."""
    id: int
    user_id: UUID
    incident_type: IncidentType
    latitude: float
    longitude: float
    image_url: Optional[str]
    description: Optional[str]
    status: ReportStatus
    trust_score: float
    created_at: datetime
    
    class Config:
        from_attributes = True
