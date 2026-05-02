"""
Chatbot Models - Database models for AI chatbot conversations.
"""

from datetime import datetime
from typing import Optional
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Integer, Enum as SQLEnum
from sqlalchemy.orm import relationship
from enum import Enum

from .base import Base


class MessageRole(str, Enum):
    """Message sender role."""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ChatSession(Base):
    """Chat session model - groups related messages."""
    
    __tablename__ = "chat_sessions"
    
    id = Column(String(36), primary_key=True)  # UUID
    user_id = Column(String(36), nullable=False, index=True)
    title = Column(String(200), nullable=True)  # Auto-generated from first message
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")


class ChatMessage(Base):
    """Individual chat message within a session."""
    
    __tablename__ = "chat_messages"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String(36), ForeignKey("chat_sessions.id"), nullable=False)
    role = Column(SQLEnum(MessageRole), nullable=False)
    content = Column(Text, nullable=False)
    
    # Context data (AQI, location, etc.) when message was sent
    context_data = Column(Text, nullable=True)  # JSON string
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    session = relationship("ChatSession", back_populates="messages")
