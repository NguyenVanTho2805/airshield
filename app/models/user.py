"""
User Model - Authentication & Authorization.
Table: users
"""

import enum
from datetime import datetime
from typing import Optional
from sqlalchemy import String, Boolean, DateTime, Enum
from sqlalchemy.orm import Mapped, mapped_column
from uuid import UUID, uuid4

from .base import Base


class UserRole(enum.Enum):
    """User role enum."""
    USER = "user"
    ADMIN = "admin"


class User(Base):
    """
    User account for authentication.
    Stores credentials and profile info.
    """
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(
        primary_key=True,
        default=uuid4,
    )
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
    )
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole),
        nullable=False,
        default=UserRole.USER,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    fcm_token: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.utcnow,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email='{self.email}', role={self.role.value})>"
