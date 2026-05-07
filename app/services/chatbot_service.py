"""
Chatbot Service - AI-powered conversational assistant for AirShield.
Uses Google Gemini 2.5 (google-genai SDK) for natural language generation.
"""

import json
import uuid
from datetime import datetime, timezone
from typing import Optional, List, Tuple

import redis.asyncio as aioredis

try:
    from google import genai
    from google.genai import types as genai_types
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

from app.core.config import settings
from app.schemas.chatbot import ChatResponse, ChatAction, ActionType


SYSTEM_PROMPT = """Bạn là **AirShield Assistant** — trợ lý AI chuyên về chất lượng không khí và sức khỏe.

---

## KIẾN THỨC NỀN: Tiêu Chuẩn Chất Lượng Không Khí (IQAir / US EPA)

### Bảng AQI:
| AQI | Phân loại | Ý nghĩa |
|-----|-----------|---------|
| 0–50 | Tốt | An toàn cho mọi người |
| 51–100 | Trung bình | Nhóm nhạy cảm nên hạn chế gắng sức ngoài trời |
| 101–150 | Không tốt cho nhóm nhạy cảm | Người hen, tim mạch, già, trẻ em hạn chế ra ngoài |
| 151–200 | Không lành mạnh | Mọi người nên hạn chế hoạt động ngoài trời, đeo khẩu trang N95 |
| 201–300 | Rất không lành mạnh | Ở trong nhà, đóng cửa sổ, bật máy lọc không khí |
| 301–500 | Nguy hiểm | Khẩn cấp, tránh hoàn toàn hoạt động ngoài trời |

### Ngưỡng các chất ô nhiễm chính:
| Chất | Tốt | Trung bình | USG | Không lành mạnh |
|------|-----|------------|-----|-----------------|
| PM2.5 (µg/m³) | 0–12 | 12.1–35.4 | 35.5–55.4 | 55.5–150.4 |
| PM10 (µg/m³) | 0–54 | 55–154 | 155–254 | 255–354 |
| O3 / ppb (8h) | 0–54 | 55–70 | 71–85 | 86–105 |
| NO2 / ppb (1h) | 0–53 | 54–100 | 101–360 | 361–649 |
| CO / ppm (8h) | 0–4.4 | 4.5–9.4 | 9.5–12.4 | 12.5–15.4 |

### Lời khuyên theo nhóm đối tượng:

**Người bình thường:**
- AQI ≤ 100: Hoạt động ngoài trời bình thường
- AQI 101–150: Hạn chế chạy bộ / tập thể dục cường độ cao ngoài trời
- AQI 151–200: Đeo khẩu trang N95, hạn chế ra ngoài
- AQI 201+: Ở trong nhà, đóng cửa sổ, bật máy lọc HEPA

**Người hen suyễn / COPD:**
- AQI ≤ 50: Mang theo thuốc hít dự phòng
- AQI 51–100: Chuẩn bị thuốc cấp cứu, theo dõi triệu chứng
- AQI 101–150: Không hoạt động ngoài trời, dùng máy lọc không khí trong nhà
- AQI 151+: Ở trong nhà hoàn toàn; nếu khó thở → gọi cấp cứu 115

**Người tim mạch / cao huyết áp:**
- AQI ≤ 100: Theo dõi huyết áp thường xuyên
- AQI 101–150: Tránh gắng sức, không tập ngoài trời
- AQI 151+: Ở trong nhà; PM2.5 cao làm tăng nguy cơ nhồi máu cơ tim

**Phụ nữ mang thai:**
- AQI ≤ 50: An toàn
- AQI 51–100: Hạn chế ra ngoài > 2 giờ liên tiếp
- AQI 101+: Ở nhà; PM2.5 > 35 µg/m³ tăng nguy cơ sinh non và nhẹ cân

**Trẻ em (< 12 tuổi):**
- AQI ≤ 50: Cho phép chơi ngoài trời tự do
- AQI 51–100: Giảm thời gian chơi ngoài
- AQI 101–150: Không cho chơi thể thao ngoài trời
- AQI 151+: Ở trong nhà, tránh vận động mạnh

**Người cao tuổi (> 65 tuổi):**
- AQI ≤ 100: Tập thể dục nhẹ buổi sáng sớm hoặc chiều tối
- AQI 101+: Ở trong nhà, bật điều hòa hoặc máy lọc không khí

### Biện pháp bảo vệ:
- **Khẩu trang**: N95/KN95 lọc được ≥ 95% PM2.5; khẩu trang vải không có tác dụng
- **Máy lọc không khí**: HEPA filter hiệu quả với PM2.5; CADR ≥ 200 cho phòng ≤ 20m²
- **Thông gió**: Đóng cửa khi AQI ngoài > 100; mở cửa sổ khi AQI ngoài thấp hơn trong nhà
- **Thực vật lọc khí**: Cây lưỡi hổ, thường xuân, dây nhện giúp lọc VOC và CO₂ trong nhà

---

## Quy tắc trả lời:
1. Trả lời bằng **tiếng Việt**, ngắn gọn, thân thiện, dễ hiểu
2. Khi có dữ liệu AQI context, sử dụng số liệu thực tế đó để trả lời
3. Luôn đề xuất hành động cụ thể phù hợp với đối tượng người dùng và mức AQI hiện tại
4. Không chẩn đoán bệnh; chỉ đưa lời khuyên phòng ngừa và khuyến nghị gặp bác sĩ khi cần
5. Khi AQI > 150, luôn nhắc: đeo khẩu trang N95 và bật máy lọc không khí HEPA
6. Với câu hỏi điều khiển thiết bị, xác nhận tên thiết bị trước khi thực hiện
"""

_SESSION_KEY_PREFIX = "chat_session:"
_SESSION_TTL = 86400  # 24 hours


class ChatbotService:
    """AI Chatbot Service using Google Gemini 2.5 (google-genai SDK)."""

    def __init__(self) -> None:
        self._client: Optional["genai.Client"] = None

        if GEMINI_AVAILABLE and settings.GEMINI_API_KEY:
            self._client = genai.Client(api_key=settings.GEMINI_API_KEY)

    # ── Session helpers ────────────────────────────────────────────────────────

    async def _get_or_create_session(
        self,
        redis: aioredis.Redis,
        session_id: Optional[str],
        user_id: str = "",
    ) -> Tuple[str, dict]:
        if session_id:
            raw = await redis.get(f"{_SESSION_KEY_PREFIX}{session_id}")
            if raw:
                return session_id, json.loads(raw)

        sid = session_id or str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()
        session = {"user_id": user_id, "messages": [], "created_at": now, "updated_at": now}
        await redis.setex(f"{_SESSION_KEY_PREFIX}{sid}", _SESSION_TTL, json.dumps(session))
        return sid, session

    async def _save_session(self, redis: aioredis.Redis, sid: str, session: dict) -> None:
        session["updated_at"] = datetime.now(timezone.utc).isoformat()
        await redis.setex(f"{_SESSION_KEY_PREFIX}{sid}", _SESSION_TTL, json.dumps(session))

    # ── Context builder ────────────────────────────────────────────────────────

    def _build_context(
        self,
        aqi_data: Optional[dict] = None,
        user_profile: Optional[dict] = None,
    ) -> str:
        parts: list[str] = []
        if aqi_data:
            parts.append(f"**Dữ liệu AQI hiện tại:**\n{json.dumps(aqi_data, ensure_ascii=False, indent=2)}")
        if user_profile:
            parts.append(f"**Hồ sơ sức khỏe người dùng:**\n{json.dumps(user_profile, ensure_ascii=False, indent=2)}")
        return "\n\n".join(parts)

    # ── Action detector ────────────────────────────────────────────────────────

    def _detect_action(self, message: str) -> ChatAction:
        msg = message.lower()
        if any(k in msg for k in ["bật", "tắt", "mở", "đóng", "điều khiển", "máy lọc", "purifier", "quạt", "điều hòa"]):
            return ChatAction(action_type=ActionType.CONTROL_DEVICE, payload={"suggested_action": "open_device_control"})
        if any(k in msg for k in ["aqi", "chất lượng không khí", "ô nhiễm", "pm2.5", "pm25"]):
            return ChatAction(action_type=ActionType.SHOW_AQI, payload={"suggested_action": "refresh_aqi"})
        if any(k in msg for k in ["bản đồ", "map", "vị trí", "location", "khu vực"]):
            return ChatAction(action_type=ActionType.SHOW_MAP, payload={"suggested_action": "open_map"})
        return ChatAction(action_type=ActionType.NONE)

    # ── Main chat method ───────────────────────────────────────────────────────

    async def chat(
        self,
        message: str,
        redis: aioredis.Redis,
        session_id: Optional[str] = None,
        aqi_data: Optional[dict] = None,
        user_profile: Optional[dict] = None,
        user_id: str = "",
    ) -> ChatResponse:
        sid, session = await self._get_or_create_session(redis, session_id, user_id)
        history: list[dict] = session["messages"]

        context = self._build_context(aqi_data, user_profile)
        prompt = f"{context}\n\n**Câu hỏi:** {message}" if context else message

        history.append({"role": "user", "content": message})

        try:
            if self._client:
                # Build Gemini history (all messages except the latest user turn)
                gemini_history = [
                    genai_types.Content(
                        role="model" if m["role"] == "assistant" else "user",
                        parts=[genai_types.Part(text=m["content"])],
                    )
                    for m in history[:-1]
                ]

                chat_session = self._client.aio.chats.create(
                    model=settings.LLM_MODEL_NAME,
                    config=genai_types.GenerateContentConfig(
                        system_instruction=SYSTEM_PROMPT,
                        temperature=settings.LLM_TEMPERATURE,
                        max_output_tokens=settings.LLM_MAX_TOKENS,
                    ),
                    history=gemini_history,
                )
                response = await chat_session.send_message(prompt)
                ai_response = response.text

            else:
                ai_response = self._fallback_response(message, aqi_data)

        except Exception as e:
            ai_response = (
                f"Xin lỗi, tôi gặp lỗi khi xử lý câu hỏi. Vui lòng thử lại. "
                f"(Lỗi: {str(e)[:120]})"
            )

        history.append({"role": "assistant", "content": ai_response})
        await self._save_session(redis, sid, session)

        action = self._detect_action(message)
        return ChatResponse(
            session_id=sid,
            message=ai_response,
            action=action if action.action_type != ActionType.NONE else None,
            sources=["AirShield Database", "IQAir API"] if aqi_data else None,
            timestamp=datetime.now(timezone.utc),
        )

    # ── Fallback (no API key) ──────────────────────────────────────────────────

    def _fallback_response(self, message: str, aqi_data: Optional[dict] = None) -> str:
        msg = message.lower()
        if any(k in msg for k in ["aqi", "chất lượng", "ô nhiễm", "pm2.5"]):
            if aqi_data:
                aqi = int(aqi_data.get("aqi") or 0)
                label = (
                    "Tốt — an toàn cho mọi người." if aqi <= 50
                    else "Trung bình — nhóm nhạy cảm nên hạn chế gắng sức." if aqi <= 100
                    else "Không tốt cho nhóm nhạy cảm — hạn chế ra ngoài." if aqi <= 150
                    else "Không lành mạnh — đeo khẩu trang N95, hạn chế ra ngoài." if aqi <= 200
                    else "Rất không lành mạnh — ở trong nhà, bật máy lọc không khí."
                )
                return f"Chất lượng không khí hiện tại: **AQI {aqi}** — {label}"
            return "Để xem chất lượng không khí, vui lòng bật định vị hoặc chọn vị trí trên bản đồ."

        if any(k in msg for k in ["xin chào", "hello", "hi", "chào"]):
            return (
                "Xin chào! Tôi là AirShield Assistant. Tôi có thể giúp bạn:\n"
                "• Kiểm tra & giải thích chỉ số AQI, PM2.5, PM10\n"
                "• Tư vấn sức khỏe theo mức ô nhiễm và tình trạng sức khỏe\n"
                "• Hướng dẫn sử dụng máy lọc không khí\n"
                "• Điều khiển thiết bị Smart Home\n\nBạn cần giúp gì?"
            )
        return (
            "Tôi là AirShield Assistant. Hãy hỏi tôi về chất lượng không khí, "
            "lời khuyên sức khỏe, hoặc điều khiển thiết bị smart home nhé!"
        )

    # ── Session management ─────────────────────────────────────────────────────

    async def get_session_history(self, redis: aioredis.Redis, session_id: str) -> List[dict]:
        raw = await redis.get(f"{_SESSION_KEY_PREFIX}{session_id}")
        return json.loads(raw).get("messages", []) if raw else []

    async def delete_session(self, redis: aioredis.Redis, session_id: str) -> bool:
        return bool(await redis.delete(f"{_SESSION_KEY_PREFIX}{session_id}"))

    async def list_sessions(self, redis: aioredis.Redis, user_id: str = "") -> List[dict]:
        sessions = []
        async for key in redis.scan_iter(f"{_SESSION_KEY_PREFIX}*"):
            raw = await redis.get(key)
            if not raw:
                continue
            data = json.loads(raw)
            if user_id and data.get("user_id") != user_id:
                continue
            sid = key.removeprefix(_SESSION_KEY_PREFIX) if isinstance(key, str) else key.decode().removeprefix(_SESSION_KEY_PREFIX)
            messages = data.get("messages", [])
            sessions.append({
                "id": sid,
                "message_count": len(messages),
                "title": messages[0]["content"][:50] + "..." if messages else None,
                "created_at": data.get("created_at", "2026-01-01T00:00:00Z"),
                "updated_at": data.get("updated_at", "2026-01-01T00:00:00Z"),
            })
        return sessions


chatbot_service = ChatbotService()
