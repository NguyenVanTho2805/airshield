"""
Chatbot Service - AI-powered conversational assistant for AirShield.
Uses Google Gemini for natural language understanding and generation.
"""

import json
import uuid
from datetime import datetime, timezone
from typing import Optional, List, Tuple

import redis.asyncio as aioredis

try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

from app.core.config import settings
from app.schemas.chatbot import ChatResponse, ChatAction, ActionType


# System prompt for the AirShield chatbot
SYSTEM_PROMPT = """Bạn là **AirShield Assistant** - trợ lý AI thông minh chuyên về chất lượng không khí và sức khỏe.

## Khả năng của bạn:
1. **Chất lượng không khí**: Giải thích AQI, PM2.5, PM10, O3, NO2, SO2, CO và ảnh hưởng sức khỏe
2. **Tư vấn sức khỏe**: Đưa ra lời khuyên dựa trên mức AQI và tình trạng sức khỏe người dùng
3. **Thiết bị lọc khí**: Hướng dẫn sử dụng máy lọc không khí, thay filter
4. **Smart Home**: Điều khiển thiết bị (bật/tắt máy lọc không khí, quạt, điều hòa)

## Quy tắc:
- Trả lời bằng tiếng Việt, ngắn gọn, thân thiện
- Nếu được hỏi về AQI cụ thể, sử dụng context data được cung cấp
- Với câu hỏi về thiết bị, hỏi lại nếu không rõ thiết bị nào
- Luôn đề xuất hành động cụ thể khi AQI > 100

## Phân loại AQI:
- 0–50: Tốt (Good) - An toàn cho mọi người
- 51–100: Trung bình (Moderate) - Nhóm nhạy cảm nên hạn chế
- 101–150: Không tốt cho nhóm nhạy cảm
- 151–200: Không lành mạnh (Unhealthy)
- 201–300: Rất không lành mạnh (Very Unhealthy)
- 301+: Nguy hiểm (Hazardous)
"""

_SESSION_KEY_PREFIX = "chat_session:"
_SESSION_TTL = 86400  # 24 hours


class ChatbotService:
    """
    AI Chatbot Service for AirShield.
    Provides conversational interface for air quality queries and device control.
    """

    def __init__(self):
        """Initialize the chatbot service."""
        self.model = None

        if GEMINI_AVAILABLE and settings.GEMINI_API_KEY:
            genai.configure(api_key=settings.GEMINI_API_KEY)
            self.model = genai.GenerativeModel(
                model_name=settings.LLM_MODEL_NAME,
                generation_config={
                    "temperature": settings.LLM_TEMPERATURE,
                    "max_output_tokens": settings.LLM_MAX_TOKENS,
                }
            )

    async def _get_or_create_session(
        self,
        redis: aioredis.Redis,
        session_id: Optional[str],
        user_id: str = "",
    ) -> Tuple[str, dict]:
        """Get existing session from Redis or create a new one."""
        if session_id:
            raw = await redis.get(f"{_SESSION_KEY_PREFIX}{session_id}")
            if raw:
                return session_id, json.loads(raw)

        new_id = session_id or str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()
        session = {
            "user_id": user_id,
            "messages": [],
            "created_at": now,
            "updated_at": now,
        }
        await redis.setex(f"{_SESSION_KEY_PREFIX}{new_id}", _SESSION_TTL, json.dumps(session))
        return new_id, session

    async def _save_session(
        self,
        redis: aioredis.Redis,
        session_id: str,
        session: dict,
    ) -> None:
        """Persist session data back to Redis, refreshing TTL."""
        session["updated_at"] = datetime.now(timezone.utc).isoformat()
        await redis.setex(f"{_SESSION_KEY_PREFIX}{session_id}", _SESSION_TTL, json.dumps(session))

    def _build_context(
        self,
        aqi_data: Optional[dict] = None,
        user_profile: Optional[dict] = None
    ) -> str:
        """Build context string for the AI."""
        context_parts = []

        if aqi_data:
            context_parts.append(f"**Dữ liệu AQI hiện tại:**\n{json.dumps(aqi_data, ensure_ascii=False)}")

        if user_profile:
            context_parts.append(f"**Hồ sơ sức khỏe người dùng:**\n{json.dumps(user_profile, ensure_ascii=False)}")

        if not context_parts:
            return ""

        return "\n\n".join(context_parts)

    def _detect_action(self, message: str, response: str) -> ChatAction:
        """Detect if an action should be triggered based on conversation."""
        message_lower = message.lower()

        # Device control keywords
        device_keywords = ["bật", "tắt", "mở", "đóng", "điều khiển", "máy lọc", "purifier", "quạt", "điều hòa"]
        if any(kw in message_lower for kw in device_keywords):
            return ChatAction(
                action_type=ActionType.CONTROL_DEVICE,
                payload={"suggested_action": "open_device_control"}
            )

        # AQI display keywords
        aqi_keywords = ["aqi", "chất lượng không khí", "ô nhiễm", "pm2.5", "pm25"]
        if any(kw in message_lower for kw in aqi_keywords):
            return ChatAction(
                action_type=ActionType.SHOW_AQI,
                payload={"suggested_action": "refresh_aqi"}
            )

        # Map keywords
        map_keywords = ["bản đồ", "map", "vị trí", "location", "khu vực"]
        if any(kw in message_lower for kw in map_keywords):
            return ChatAction(
                action_type=ActionType.SHOW_MAP,
                payload={"suggested_action": "open_map"}
            )

        return ChatAction(action_type=ActionType.NONE)

    async def chat(
        self,
        message: str,
        redis: aioredis.Redis,
        session_id: Optional[str] = None,
        aqi_data: Optional[dict] = None,
        user_profile: Optional[dict] = None,
        user_id: str = "",
    ) -> ChatResponse:
        """
        Process a chat message and return AI response.

        Args:
            message: User's message
            redis: Redis client for session persistence
            session_id: Optional session ID for conversation continuity
            aqi_data: Current AQI data for context
            user_profile: User's health profile for personalization

        Returns:
            ChatResponse with AI message and optional actions
        """
        session_id, session = await self._get_or_create_session(redis, session_id, user_id)
        history = session["messages"]

        # Build context
        context = self._build_context(aqi_data, user_profile)

        # Add user message to history
        history.append({"role": "user", "content": message})

        try:
            if self.model:
                # Build conversation for Gemini
                chat_history = []
                for msg in history[:-1]:  # Exclude current message
                    chat_history.append({
                        "role": msg["role"],
                        "parts": [msg["content"]]
                    })

                # Create chat with history
                chat = self.model.start_chat(history=chat_history)

                # Build prompt with context
                prompt = message
                if context:
                    prompt = f"{context}\n\n**Câu hỏi:** {message}"

                # Add system prompt for first message
                if len(history) == 1:
                    prompt = f"{SYSTEM_PROMPT}\n\n{prompt}"

                # Generate response
                response = chat.send_message(prompt)
                ai_response = response.text
            else:
                # Fallback response when Gemini is not configured
                ai_response = self._get_fallback_response(message, aqi_data)

        except Exception as e:
            ai_response = f"Xin lỗi, tôi gặp lỗi khi xử lý câu hỏi. Vui lòng thử lại. (Error: {str(e)[:100]})"

        # Add AI response to history
        history.append({"role": "assistant", "content": ai_response})

        # Persist updated session
        await self._save_session(redis, session_id, session)

        # Detect action
        action = self._detect_action(message, ai_response)

        return ChatResponse(
            session_id=session_id,
            message=ai_response,
            action=action if action.action_type != ActionType.NONE else None,
            sources=["AirShield Database", "IQAir API"] if aqi_data else None,
            timestamp=datetime.now(timezone.utc)
        )

    def _get_fallback_response(self, message: str, aqi_data: Optional[dict] = None) -> str:
        """Generate fallback response when LLM is not available."""
        message_lower = message.lower()

        # AQI queries
        if any(kw in message_lower for kw in ["aqi", "chất lượng", "ô nhiễm", "pm2.5"]):
            if aqi_data:
                aqi = aqi_data.get("aqi", "N/A")
                return f"Chất lượng không khí hiện tại có AQI là **{aqi}**. " \
                       f"{'Chất lượng tốt, bạn có thể hoạt động ngoài trời.' if int(aqi or 0) <= 50 else 'Bạn nên hạn chế hoạt động ngoài trời.'}"
            return "Để xem chất lượng không khí, vui lòng bật định vị hoặc chọn vị trí trên bản đồ."

        # Greetings
        if any(kw in message_lower for kw in ["xin chào", "hello", "hi", "chào"]):
            return "Xin chào! Tôi là AirShield Assistant. Tôi có thể giúp bạn:\n" \
                   "• Kiểm tra chất lượng không khí\n" \
                   "• Tư vấn sức khỏe theo AQI\n" \
                   "• Điều khiển thiết bị lọc không khí\n\n" \
                   "Bạn cần giúp gì?"

        # Default
        return "Tôi là AirShield Assistant. Tôi có thể giúp bạn về chất lượng không khí, " \
               "tư vấn sức khỏe và điều khiển thiết bị smart home. Bạn muốn hỏi gì?"

    async def get_session_history(self, redis: aioredis.Redis, session_id: str) -> List[dict]:
        """Get message history for a session."""
        raw = await redis.get(f"{_SESSION_KEY_PREFIX}{session_id}")
        if not raw:
            return []
        return json.loads(raw).get("messages", [])

    async def delete_session(self, redis: aioredis.Redis, session_id: str) -> bool:
        """Delete a chat session."""
        deleted = await redis.delete(f"{_SESSION_KEY_PREFIX}{session_id}")
        return bool(deleted)

    async def list_sessions(self, redis: aioredis.Redis, user_id: str = "") -> List[dict]:
        """List chat sessions, optionally filtered by user_id."""
        sessions = []
        async for key in redis.scan_iter(f"{_SESSION_KEY_PREFIX}*"):
            raw = await redis.get(key)
            if not raw:
                continue
            data = json.loads(raw)
            if user_id and data.get("user_id") != user_id:
                continue
            sid = key.removeprefix(_SESSION_KEY_PREFIX)
            messages = data.get("messages", [])
            sessions.append({
                "id": sid,
                "message_count": len(messages),
                "title": messages[0]["content"][:50] + "..." if messages else None,
                "created_at": data.get("created_at", "2026-01-01T00:00:00Z"),
                "updated_at": data.get("updated_at", "2026-01-01T00:00:00Z"),
            })
        return sessions


# Singleton instance
chatbot_service = ChatbotService()
