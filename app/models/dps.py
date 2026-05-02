"""
DPS Module - Deep Personalization Service Models.
Tables: health_profiles, advice_rules
"""

import uuid
from sqlalchemy import String, Integer, Text, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID

from .base import Base


class HealthProfile(Base):
    """
    User health profile for personalized recommendations.
    Stores health conditions and sensitivity level.
    """
    __tablename__ = "health_profiles"
    
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )
    birth_year: Mapped[int] = mapped_column(Integer, nullable=True)
    conditions: Mapped[list[str]] = mapped_column(
        ARRAY(String(100)),
        nullable=True,
        default=list,
        comment="Health conditions: asthma, sinus, heart_disease, etc."
    )
    sensitivity_level: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=3,
        comment="Sensitivity level from 1 (low) to 5 (high)"
    )
    
    def __repr__(self) -> str:
        return f"<HealthProfile(user_id={self.user_id}, sensitivity={self.sensitivity_level})>"


class AdviceRule(Base):
    """
    Rules for generating personalized advice based on AQI thresholds.
    """
    __tablename__ = "advice_rules"
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    min_aqi_threshold: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="Minimum AQI value to trigger this rule"
    )
    condition_tag: Mapped[str] = mapped_column(
        String(100),
        nullable=True,
        comment="Health condition to match (null = all users)"
    )
    message_template: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        comment="Message template with {placeholders}"
    )
    action_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="info",
        comment="Action type: info, warning, alert, emergency"
    )
    
    def __repr__(self) -> str:
        return f"<AdviceRule(id={self.id}, threshold={self.min_aqi_threshold}, action={self.action_type})>"
