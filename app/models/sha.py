"""
SHA Module - Smart Home Automation Models.
Tables: user_devices, automation_rules
Manages IoT devices (Air Purifiers) and automation rules.
"""

import uuid
from sqlalchemy import String, Integer, Boolean, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from typing import Optional, List

from .base import Base


class UserDevice(Base):
    """
    User's linked IoT devices (Air Purifiers).
    Example device_id: "xiaomi.air.p3"
    """
    __tablename__ = "user_devices"
    
    device_id: Mapped[str] = mapped_column(
        String(100),
        primary_key=True,
        comment="Unique device identifier, e.g., xiaomi.air.p3"
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        nullable=False,
        index=True,
        comment="Owner user ID"
    )
    provider: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        comment="Device provider: xiaomi, samsung, philips, dyson"
    )
    access_token: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="OAuth token for device API"
    )
    device_name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        default="Air Purifier"
    )
    current_filter_life: Mapped[int] = mapped_column(
        Integer,
        nullable=True,
        default=100,
        comment="Filter life percentage (0-100)"
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True
    )
    
    # Relationship: User has many devices
    # automation_rules = relationship("AutomationRule", back_populates="device")
    
    def __repr__(self) -> str:
        return f"<UserDevice(id={self.device_id}, provider={self.provider})>"


class AutomationRule(Base):
    """
    Automation rules for smart home devices.
    Triggers actions based on metrics like outdoor_aqi, indoor_aqi.
    """
    __tablename__ = "automation_rules"
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        nullable=False,
        index=True
    )
    trigger_metric: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        comment="Metric to monitor: outdoor_aqi, indoor_aqi, pm25"
    )
    threshold_value: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="Threshold to trigger action, e.g., 150"
    )
    action_payload: Mapped[dict] = mapped_column(
        JSON,
        nullable=False,
        comment='Action to execute: {"power": "on", "mode": "turbo"}'
    )
    is_enabled: Mapped[bool] = mapped_column(
        Boolean,
        default=True
    )
    
    def __repr__(self) -> str:
        return f"<AutomationRule(id={self.id}, trigger={self.trigger_metric}, threshold={self.threshold_value})>"
