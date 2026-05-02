"""
AQS Module - Air Quality Service Models.
Tables: stations, air_quality_logs
"""

import enum
from datetime import datetime
from sqlalchemy import String, Float, Boolean, Integer, DateTime, ForeignKey, Index, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional

from .base import Base


class StationSource(enum.Enum):
    """Enum for station data source."""
    IQAIR = "iqair"
    PAMAIR = "pamair"


class Station(Base):
    """
    Air quality monitoring station.
    Can be from IQAir API or PamAir sensors.
    """
    __tablename__ = "stations"
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    source: Mapped[StationSource] = mapped_column(
        Enum(StationSource), 
        nullable=False,
        default=StationSource.IQAIR
    )
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    
    # Relationships
    logs: Mapped[list["AirQualityLog"]] = relationship(
        "AirQualityLog",
        back_populates="station",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self) -> str:
        return f"<Station(id={self.id}, name='{self.name}', source={self.source.value})>"


class AirQualityLog(Base):
    """
    Air quality measurement log entry.
    Stores AQI and related metrics at a point in time.
    """
    __tablename__ = "air_quality_logs"
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    station_id: Mapped[int] = mapped_column(
        ForeignKey("stations.id", ondelete="CASCADE"),
        nullable=False
    )
    aqi: Mapped[int] = mapped_column(Integer, nullable=False)
    pm25: Mapped[float] = mapped_column(Float, nullable=True)
    temperature: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    humidity: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    recorded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.utcnow
    )
    
    # Relationships
    station: Mapped["Station"] = relationship("Station", back_populates="logs")
    
    # Composite index for efficient queries
    __table_args__ = (
        Index("ix_air_quality_logs_station_recorded", "station_id", "recorded_at"),
    )
    
    def __repr__(self) -> str:
        return f"<AirQualityLog(id={self.id}, station_id={self.station_id}, aqi={self.aqi})>"
