"""
CGS Module - Community & Gamification Service Models.
Tables: community_reports
Uses PostGIS for spatial data.
"""

import enum
import uuid
from datetime import datetime
from sqlalchemy import String, Float, DateTime, Enum, Text
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
from geoalchemy2 import Geometry

from .base import Base


class IncidentType(enum.Enum):
    """Types of pollution incidents."""
    BURNING = "burning"
    DUST = "dust"
    SMOKE = "smoke"
    CHEMICAL = "chemical"
    OTHER = "other"


class ReportStatus(enum.Enum):
    """Status of community reports."""
    PENDING = "pending"
    VERIFIED = "verified"
    REJECTED = "rejected"


class CommunityReport(Base):
    """
    Community-submitted pollution incident reports.
    Uses PostGIS Geometry Point for location data.
    """
    __tablename__ = "community_reports"
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        nullable=False,
        index=True
    )
    incident_type: Mapped[IncidentType] = mapped_column(
        Enum(IncidentType),
        nullable=False,
        default=IncidentType.OTHER
    )
    # PostGIS Geometry Point (SRID 4326 = WGS84)
    geom: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326),
        nullable=False,
        comment="Location as PostGIS Point geometry"
    )
    image_url: Mapped[str] = mapped_column(
        Text,
        nullable=True,
        comment="URL to uploaded incident image"
    )
    description: Mapped[str] = mapped_column(
        Text,
        nullable=True,
        comment="User description of the incident"
    )
    status: Mapped[ReportStatus] = mapped_column(
        Enum(ReportStatus),
        nullable=False,
        default=ReportStatus.PENDING
    )
    trust_score: Mapped[float] = mapped_column(
        Float,
        nullable=False,
        default=0.5,
        comment="Credibility score from 0.0 to 1.0"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.utcnow
    )
    
    def __repr__(self) -> str:
        return f"<CommunityReport(id={self.id}, type={self.incident_type.value}, status={self.status.value})>"
