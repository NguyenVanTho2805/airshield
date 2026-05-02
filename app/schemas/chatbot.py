"""
Chatbot Schemas - Pydantic models for API request/response.
"""

from datetime import datetime
from typing import Optional, List, Any, Dict
from pydantic import BaseModel, Field
from enum import Enum


class MessageRoleSchema(str, Enum):
    """Message sender role."""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ChatRequest(BaseModel):
    """Chat request payload."""
    
    message: str = Field(..., min_length=1, max_length=2000, description="User message")
    session_id: Optional[str] = Field(None, description="Session ID for conversation continuity")
    
    # Optional context
    latitude: Optional[float] = Field(None, ge=-90, le=90, description="User latitude")
    longitude: Optional[float] = Field(None, ge=-180, le=180, description="User longitude")
    include_aqi_context: bool = Field(True, description="Include current AQI in context")
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Chất lượng không khí hôm nay thế nào?",
                "session_id": "abc-123",
                "latitude": 21.0285,
                "longitude": 105.8542
            }
        }


class ActionType(str, Enum):
    """Types of actions the chatbot can trigger."""
    NONE = "none"
    SHOW_AQI = "show_aqi"
    SHOW_MAP = "show_map"
    CONTROL_DEVICE = "control_device"
    NAVIGATE_TO = "navigate_to"


class ChatAction(BaseModel):
    """Action suggested by chatbot."""
    
    action_type: ActionType = ActionType.NONE
    payload: Optional[Dict[str, Any]] = None


class ChatResponse(BaseModel):
    """Chat response payload."""
    
    session_id: str = Field(..., description="Session ID for this conversation")
    message: str = Field(..., description="AI response message")
    
    # Optional action to trigger in app
    action: Optional[ChatAction] = None
    
    # Metadata
    sources: Optional[List[str]] = Field(None, description="Data sources used")
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        json_schema_extra = {
            "example": {
                "session_id": "abc-123",
                "message": "Chất lượng không khí hiện tại ở Hà Nội là Tốt (AQI: 45). Bạn có thể yên tâm hoạt động ngoài trời.",
                "action": {"action_type": "show_aqi", "payload": {"aqi": 45}},
                "sources": ["IQAir API"],
                "timestamp": "2026-02-05T23:45:00Z"
            }
        }


class ChatMessageSchema(BaseModel):
    """Single message in conversation history."""
    
    role: MessageRoleSchema
    content: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class ChatSessionSchema(BaseModel):
    """Chat session with messages."""
    
    id: str
    user_id: str
    title: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    messages: List[ChatMessageSchema] = []
    
    class Config:
        from_attributes = True


class ChatSessionListItem(BaseModel):
    """Chat session for list display."""
    
    id: str
    title: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    message_count: int = 0
    
    class Config:
        from_attributes = True
