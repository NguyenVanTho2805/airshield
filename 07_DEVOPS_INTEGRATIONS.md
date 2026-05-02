# 07 — DevOps, Environment & External Integrations

> **Phạm vi**: Docker Compose, environment variables, 5 external API integrations, Alembic migrations, logging/monitoring strategy.
> **Nguồn**: `docker-compose.yml`, `.env.example`, `app/core/config.py`, `requirements.txt`, `main.py`, `app/tasks/aqi_collector.py`, `app/services/chatbot_service.py`, `app/services/device_adapters/tuya_adapter.py`, `app/services/notification_service.py`, `app/services/routing_service.py`, `alembic/`

---

## PHẦN 1: Docker Configuration

### 1.1 Tổng Quan Infrastructure

AirShield chạy theo mô hình **hybrid**: dịch vụ hạ tầng (PostgreSQL, Redis) chạy trong Docker container, trong khi FastAPI backend chạy trực tiếp trên host bằng `uvicorn`. Không có Dockerfile riêng cho backend trong phiên bản hiện tại.

```
┌─────────────────────────────────────────┐
│            Docker Compose               │
│  ┌──────────────┐  ┌──────────────┐     │
│  │  PostgreSQL  │  │    Redis     │     │
│  │ postgis:15-  │  │  7-alpine    │     │
│  │    3.4       │  │              │     │
│  │  :5432       │  │  :6379       │     │
│  └──────┬───────┘  └──────┬───────┘     │
│         │                 │             │
└─────────┼─────────────────┼─────────────┘
          │ localhost        │ localhost
┌─────────▼─────────────────▼─────────────┐
│     FastAPI (uvicorn) — Host Process     │
│     python main:app --reload             │
│     :8000                               │
└─────────────────────────────────────────┘
          ▲
          │ HTTP
┌─────────▼────────────┐
│   Flutter Mobile App │
│   (Android/iOS)      │
└──────────────────────┘
```

### 1.2 Docker Compose Services

**File**: `docker-compose.yml` (version 3.8)

| Service | Image | Container Name | Port | Volume | Healthcheck |
|---------|-------|----------------|------|--------|-------------|
| `postgres` | `postgis/postgis:15-3.4` | `airshield_postgres` | `5432:5432` | `postgres_data:/var/lib/postgresql/data` | `pg_isready -U airshield -d airshield_db` |
| `redis` | `redis:7-alpine` | `airshield_redis` | `6379:6379` | `redis_data:/data` | `redis-cli ping` |

> **Lưu ý**: Image PostgreSQL là `postgis/postgis:15-3.4` (không phải `postgres:15` thuần) để hỗ trợ extension PostGIS cho spatial queries (community reports, station coordinates).

### 1.3 PostgreSQL Service Chi Tiết

```yaml
postgres:
  image: postgis/postgis:15-3.4
  container_name: airshield_postgres
  env_file:
    - .env                              # POSTGRES_PASSWORD lấy từ .env
  environment:
    POSTGRES_USER: airshield
    POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    POSTGRES_DB: airshield_db
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data   # Persistent storage
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U airshield -d airshield_db"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### 1.4 Redis Service Chi Tiết

```yaml
redis:
  image: redis:7-alpine           # Alpine = lightweight image (~30MB)
  container_name: airshield_redis
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
  command: redis-server --appendonly yes   # AOF persistence (survive restarts)
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
```

> **`--appendonly yes`**: Redis ghi mọi lệnh ghi vào file AOF (`appendonly.aof`), đảm bảo dữ liệu cache session chatbot (TTL 24h) không bị mất khi container restart.

### 1.5 Volumes

```yaml
volumes:
  postgres_data:   # Docker managed named volume — data tồn tại qua container lifecycle
  redis_data:      # Docker managed named volume — lưu AOF file
```

### 1.6 Khởi Động Hệ Thống

```bash
# Bước 1: Khởi động hạ tầng
docker-compose up -d

# Bước 2: Apply database migrations
alembic upgrade head

# Bước 3: Khởi động API server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Application Startup Sequence** (trong `main.py` `lifespan()`):
1. `await init_db()` — khởi tạo SQLAlchemy engine, tạo tables nếu thiếu
2. `scheduler.add_job(aqi_collector, IntervalTrigger(minutes=30))` — đăng ký APScheduler job
3. `scheduler.start()` — bắt đầu background scheduler
4. `await _run_aqi_collection()` — chạy ngay lần đầu để seed data

---

## PHẦN 2: Environment Variables

**File cấu hình**: `app/core/config.py` (Pydantic Settings) + `.env.example`

**Cơ chế**: `pydantic_settings.BaseSettings` tự động đọc từ file `.env` và environment variables. `@lru_cache()` đảm bảo Settings chỉ được khởi tạo một lần.

### 2.1 Bảng Đầy Đủ Tất Cả Biến

| Variable | Required | Default | Type | Description | Ví dụ |
|----------|----------|---------|------|-------------|-------|
| **Application** | | | | | |
| `APP_NAME` | No | `"AirShield"` | str | Tên ứng dụng | `AirShield` |
| `APP_VERSION` | No | `"1.0.0"` | str | Phiên bản | `1.0.0` |
| `DEBUG` | No | `false` | bool | Debug mode / auto-reload | `true` |
| **Database** | | | | | |
| `POSTGRES_PASSWORD` | Yes | — | str | Mật khẩu PostgreSQL (dùng trong docker-compose) | `MyStr0ngP@ss` |
| `DATABASE_URL` | Yes | `postgresql+asyncpg://airshield:airshield_dev@localhost:5432/airshield_db` | str | SQLAlchemy async connection string | `postgresql+asyncpg://airshield:pass@localhost:5432/airshield_db` |
| **Redis** | | | | | |
| `REDIS_URL` | No | `redis://localhost:6379/0` | str | Redis connection string | `redis://localhost:6379/0` |
| **Cache TTL** | | | | | |
| `CACHE_TTL_AQI` | No | `300` | int | TTL cache AQI hiện tại (giây) | `300` (5 phút) |
| `CACHE_TTL_FORECAST` | No | `3600` | int | TTL cache Prophet forecast (giây) | `3600` (1 giờ) |
| `CACHE_TTL_HISTORY` | No | `600` | int | TTL cache lịch sử AQI (giây) | `600` (10 phút) |
| **Authentication** | | | | | |
| `SECRET_KEY` | **Yes** | — | str | JWT signing key (32-byte hex, bắt buộc) | `a3f8...` (64 ký tự hex) |
| `JWT_ALGORITHM` | No | `"HS256"` | str | JWT signing algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | No | `10080` | int | JWT expiry (10080 = 7 ngày) | `10080` |
| **API Versioning** | | | | | |
| `API_V1_PREFIX` | No | `"/api/v1"` | str | URL prefix cho tất cả endpoints | `/api/v1` |
| **CORS** | | | | | |
| `CORS_ORIGINS` | No | `"http://localhost:3000,http://localhost:8080,http://localhost:8000"` | str | Comma-separated allowed origins | `https://airshield.app` |
| **IQAir API** | | | | | |
| `IQAIR_API_KEY` | **Yes** | — | str | API key từ iqair.com (validator kiểm tra bắt buộc) | `abc123...` |
| `IQAIR_BASE_URL` | No | `"https://api.airvisual.com/v2"` | str | Base URL IQAir AirVisual API | `https://api.airvisual.com/v2` |
| **Google Gemini** | | | | | |
| `GEMINI_API_KEY` | No* | `""` | str | API key Gemini AI (chatbot fallback nếu trống) | `AIza...` |
| `LLM_MODEL_NAME` | No | `"gemini-1.5-flash"` | str | Gemini model ID | `gemini-1.5-flash` |
| `LLM_MAX_TOKENS` | No | `1024` | int | Số token tối đa mỗi response | `1024` |
| `LLM_TEMPERATURE` | No | `0.7` | float | Creativity (0=deterministic, 1=creative) | `0.7` |
| **Google Maps** | | | | | |
| `GOOGLE_MAPS_API_KEY` | No | `""` | str | API key Directions API (fallback Haversine nếu trống) | `AIza...` |
| `ROUTING_ALPHA` | No | `0.5` | float | Hệ số cân bằng AQI trong cost function | `0.5` |
| **Tuya IoT** | | | | | |
| `TUYA_CLIENT_ID` | No* | `""` | str | Tuya Cloud project client_id | `abc...` |
| `TUYA_CLIENT_SECRET` | No* | `""` | str | Tuya Cloud project client_secret | `xyz...` |
| **Firebase FCM** | | | | | |
| `FIREBASE_CREDENTIALS_PATH` | No* | `"app/firebase_credentials.json"` | str | Đường dẫn đến service account JSON | `app/firebase_credentials.json` |
| **MQTT (IoT)** | | | | | |
| `MQTT_BROKER_HOST` | No | `"localhost"` | str | MQTT broker hostname | `localhost` |
| `MQTT_BROKER_PORT` | No | `1883` | int | MQTT broker port | `1883` |

> **\* Graceful degradation**: Khi thiếu API key, service tự chuyển sang fallback mode (Gemini → static response, Tuya → simulation, Firebase → log-only) thay vì crash.

### 2.2 Validators Bắt Buộc

`SECRET_KEY` và `IQAIR_API_KEY` có `@field_validator` — nếu trống, app sẽ **từ chối khởi động** với thông báo rõ ràng:

```python
@field_validator('SECRET_KEY')
@classmethod
def secret_key_required(cls, v: str) -> str:
    if not v:
        raise ValueError(
            "SECRET_KEY is required. Generate a secure key with:\n"
            "  python -c \"import secrets; print(secrets.token_hex(32))\"\n"
            "Then set SECRET_KEY=<result> in your .env file."
        )
    return v
```

---

## PHẦN 3: External API Integrations

### 3.1 IQAir AirVisual API

**Mục đích**: Lấy dữ liệu AQI thời gian thực từ 5 thành phố Việt Nam, chạy mỗi 30 phút qua APScheduler.

| Thông số | Giá trị |
|---------|---------|
| Base URL | `https://api.airvisual.com/v2` |
| Authentication | API key trong query parameter `?key=<IQAIR_API_KEY>` |
| Endpoint sử dụng | `GET /v2/city` |
| Rate limit | 10,000 calls/tháng (Free tier) |
| Timeout | 10 giây |
| HTTP client | `httpx.AsyncClient` (async) |

**5 thành phố được giám sát:**

| Thành phố | Latitude | Longitude | IQAir Name |
|-----------|----------|-----------|------------|
| Hà Nội | 21.0285 | 105.8542 | `Hanoi` |
| TP. Hồ Chí Minh | 10.8231 | 106.6297 | `Ho Chi Minh City` |
| Đà Nẵng | 16.0544 | 108.2022 | `Da Nang` |
| Hải Phòng | 20.8449 | 106.6881 | `Hai Phong` |
| Cần Thơ | 10.0452 | 105.7469 | `Can Tho` |

**Request format:**
```http
GET https://api.airvisual.com/v2/city?city=Hanoi&country=Vietnam&key={IQAIR_API_KEY}
```

**Response format:**
```json
{
  "status": "success",
  "data": {
    "current": {
      "pollution": {
        "aqius": 42,          // AQI US standard (0-500)
        "conc": { "p2": 10.5 } // PM2.5 concentration (µg/m³)
      },
      "weather": {
        "tp": 28,   // Temperature (°C)
        "hu": 75    // Humidity (%)
      }
    }
  }
}
```

**Code snippet — `IQAirClient.fetch_city_data()`:**

```python
# app/tasks/aqi_collector.py

class IQAirClient:
    BASE_URL = settings.IQAIR_BASE_URL     # "https://api.airvisual.com/v2"
    API_KEY  = settings.IQAIR_API_KEY

    async def fetch_city_data(self, city: str, country: str = "Vietnam") -> Optional[dict]:
        params = {"city": city, "country": country, "key": self.API_KEY}

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(f"{self.BASE_URL}/city", params=params)
                resp.raise_for_status()
                data = resp.json()

            if data.get("status") != "success":
                logger.warning(f"IQAir non-success for {city}: {data}")
                return None

            pollution = data["data"]["current"]["pollution"]
            weather   = data["data"]["current"]["weather"]

            return {
                "aqi":         pollution.get("aqius"),
                "pm25":        pollution.get("conc", {}).get("p2"),
                "temperature": weather.get("tp"),
                "humidity":    weather.get("hu"),
            }

        except httpx.HTTPStatusError as e:
            logger.error(f"IQAir HTTP error for {city}: {e.response.status_code}")
            return None
        except Exception as e:
            logger.error(f"IQAir fetch error for {city}: {e}")
            return None
```

**Error handling:**

| Lỗi | Xử lý |
|-----|-------|
| HTTP error (4xx/5xx) | Log error, return `None`, skip city |
| Connection timeout (>10s) | `httpx.TimeoutException` → return `None` |
| `status != "success"` | Log warning, return `None` |
| Exception chung | Log error, return `None`, không retry |

---

### 3.2 Google Gemini API

**Mục đích**: AI chatbot hỗ trợ tư vấn chất lượng không khí bằng tiếng Việt.

| Thông số | Giá trị |
|---------|---------|
| SDK | `google-generativeai>=0.3.0` |
| Model | `gemini-1.5-flash` (configurable qua `LLM_MODEL_NAME`) |
| Authentication | API key qua `genai.configure(api_key=...)` |
| Max output tokens | `1024` (configurable) |
| Temperature | `0.7` (configurable) |
| Session storage | Redis (TTL 24h, key `chat_session:{uuid}`) |
| Fallback | Static rule-based responses khi `GEMINI_API_KEY` trống |

**Initialization:**
```python
# app/services/chatbot_service.py

import google.generativeai as genai

genai.configure(api_key=settings.GEMINI_API_KEY)
model = genai.GenerativeModel(
    model_name=settings.LLM_MODEL_NAME,  # "gemini-1.5-flash"
    generation_config={
        "temperature":        settings.LLM_TEMPERATURE,   # 0.7
        "max_output_tokens":  settings.LLM_MAX_TOKENS,    # 1024
    }
)
```

**System Prompt** (tiêm vào lần nhắn đầu tiên trong session):
```
Bạn là AirShield Assistant - trợ lý AI thông minh chuyên về chất lượng không khí và sức khỏe.

Khả năng: Giải thích AQI/PM2.5/PM10, tư vấn sức khỏe, hướng dẫn thiết bị lọc khí, Smart Home.
Quy tắc: Trả lời tiếng Việt, ngắn gọn. Đề xuất hành động khi AQI > 100.
```

**Request format với multi-turn history:**
```python
# app/services/chatbot_service.py — hàm chat()

async def chat(self, message: str, redis, session_id=None, aqi_data=None, ...):
    # Lấy hoặc tạo session từ Redis
    session_id, session = await self._get_or_create_session(redis, session_id)
    history = session["messages"]

    # Build chat history cho Gemini
    chat_history = [
        {"role": msg["role"], "parts": [msg["content"]]}
        for msg in history[:-1]   # Tất cả trừ message hiện tại
    ]

    chat = model.start_chat(history=chat_history)

    # Inject context (AQI data + user profile) vào prompt
    prompt = message
    if aqi_data:
        prompt = f"**Dữ liệu AQI hiện tại:**\n{json.dumps(aqi_data)}\n\n**Câu hỏi:** {message}"

    # System prompt chỉ inject ở message đầu tiên
    if len(history) == 1:
        prompt = f"{SYSTEM_PROMPT}\n\n{prompt}"

    response = chat.send_message(prompt)
    return response.text
```

**Action Detection** (keyword-based, sau khi nhận response):

| Từ khóa trong user message | Action trả về |
|---------------------------|---------------|
| "bật", "tắt", "máy lọc", "điều hòa" | `CONTROL_DEVICE` → `open_device_control` |
| "aqi", "pm2.5", "ô nhiễm" | `SHOW_AQI` → `refresh_aqi` |
| "bản đồ", "map", "vị trí" | `SHOW_MAP` → `open_map` |

---

### 3.3 Tuya IoT Platform

**Mục đích**: Điều khiển thiết bị smart home (máy lọc không khí, quạt, điều hòa) qua Tuya Cloud API.

| Thông số | Giá trị |
|---------|---------|
| Base URL | `https://openapi.tuyaus.com` (US data center) |
| Authentication | HMAC-SHA256 OAuth 2.0 (2-bước) |
| HTTP client | `httpx.AsyncClient` (async) |
| Token caching | In-memory, tự refresh trước 60 giây hết hạn |
| Fallback | Simulation mode khi thiếu credentials |

**HMAC-SHA256 Signing Algorithm:**

```python
# app/services/device_adapters/tuya_adapter.py

def _sign(self, method: str, path: str, body: str = "", access_token: str = "") -> dict:
    ts = str(int(time.time() * 1000))  # Millisecond timestamp

    # Chuỗi ký: client_id + access_token + timestamp + METHOD + body_hash + path
    sign_str = (self.client_id + (access_token or "") + ts
                + method.upper() + "\n" + "" + "\n" + "" + "\n" + path)

    if body:
        body_hash = hashlib.sha256(body.encode()).hexdigest()
        sign_str = sign_str.replace("\n" + path, "\n" + body_hash + "\n" + path)

    signature = hmac.new(
        self.client_secret.encode(),
        sign_str.encode(),
        hashlib.sha256
    ).hexdigest().upper()

    return {
        "client_id":    self.client_id,
        "access_token": access_token or "",
        "sign":         signature,
        "sign_method":  "HMAC-SHA256",
        "t":            ts,
    }
```

**Luồng xác thực 2 bước:**

```
Bước 1: Lấy Platform Access Token
  GET /v1.0/token?grant_type=1
  Headers: { client_id, sign (không có access_token), sign_method, t }
  Response: { "result": { "access_token": "...", "expire_time": 7200 } }

Bước 2: Gửi Device Command
  POST /v1.0/iot-03/devices/{device_id}/commands
  Headers: { client_id, access_token, sign (có access_token), sign_method, t }
  Body: { "commands": [{ "code": "switch_1", "value": true }] }
```

**DP (Data Point) Mapping:**

| Generic Command | Tuya DP Code | Value Type | Ví dụ |
|-----------------|-------------|------------|-------|
| `power` | `switch_1` | Boolean | `true` / `false` |
| `set_mode` | `mode` | String | `"auto"`, `"sleep"`, `"turbo"` |
| `set_speed` | `fan_speed_enum` | String | `"low"`, `"medium"`, `"high"` |
| `set_fan_speed` | `fan_speed_percent` | Integer | `0`–`100` |

**Code snippet — gửi command:**
```python
async def send_command(self, device_id: str, access_token: str, command: str, value: Any) -> dict:
    token = await self._get_access_token()   # Lấy/refresh platform token

    if not token:
        # Simulation mode — trả về success giả khi thiếu credentials
        return {"success": True, "message": f"[Simulated] Command '{command}={value}' logged"}

    dp_key = dp_map.get(command, command)    # Map generic → Tuya DP
    path   = f"/v1.0/iot-03/devices/{device_id}/commands"
    body   = json.dumps({"commands": [{"code": dp_key, "value": value}]})
    headers = self._sign("POST", path, body, token)
    headers["Content-Type"] = "application/json"

    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.post(f"{TUYA_BASE_URL}{path}", headers=headers, content=body)
        resp.raise_for_status()
        data = resp.json()

    return {"success": data.get("success"), "message": "Command sent via Tuya Cloud"}
```

**Token caching:**
```python
# Token được cache in-memory, refresh trước 60s hết hạn
self._token_expires = time.time() + expire_time - 60  # Buffer 60 giây

async def _get_access_token(self) -> Optional[str]:
    if self._access_token and time.time() < self._token_expires:
        return self._access_token   # Cache hit
    # ... fetch new token
```

---

### 3.4 Firebase Cloud Messaging (FCM)

**Mục đích**: Gửi push notification đến thiết bị mobile khi AQI vượt ngưỡng.

| Thông số | Giá trị |
|---------|---------|
| SDK | `firebase-admin>=6.4.0` |
| Authentication | Service account JSON file (`firebase_credentials.json`) |
| Initialization | Singleton — `firebase_admin.initialize_app()` chỉ gọi một lần |
| Trigger | AQI > 100 (ngưỡng `AQI_ALERT_THRESHOLD`) |
| Fallback | Log-only khi `FIREBASE_CREDENTIALS_PATH` trống |

**Notification Payload Structure:**

```python
# app/services/notification_service.py

message = messaging.Message(
    notification=messaging.Notification(
        title="🔴 Không Khí Không Lành Mạnh",
        body=f"AQI {aqi} tại {station_name}! Tránh hoạt động ngoài trời."
    ),
    data={                          # Extra data payload (string values only)
        "type":          "aqi_alert",
        "aqi":           str(aqi),
        "station":       station_name,
        "perceived_aqi": str(round(perceived_aqi)),  # Cá nhân hóa
    },
    token=fcm_token,               # Từ users.fcm_token trong DB
    android=messaging.AndroidConfig(priority="high"),          # Ưu tiên cao
    apns=messaging.APNSConfig(
        payload=messaging.APNSPayload(
            aps=messaging.Aps(sound="default")                 # iOS sound
        )
    ),
)
messaging.send(message)
```

**AQI-based notification severity levels:**

| AQI Range | Title | Nội dung | Emoji |
|-----------|-------|----------|-------|
| 51–100 | Chất Lượng Không Khí Trung Bình | Nhóm nhạy cảm cần chú ý | ⚠️ |
| 101–150 | Không Khí Kém | Hạn chế ra ngoài, đeo khẩu trang | 🟠 |
| 151–200 | Không Khí Không Lành Mạnh | Tránh hoạt động ngoài trời | 🔴 |
| 201+ | Nguy Hiểm | Ở trong nhà, đóng cửa sổ ngay! | ☠️ |

**Trigger flow trong ETL pipeline:**

```python
# app/tasks/aqi_collector.py — collect_aqi_data()

for loc in MONITORED_LOCATIONS:
    data = await client.fetch_city_data(loc["city"])

    if data["aqi"] > AQI_ALERT_THRESHOLD:   # AQI > 100
        await _send_aqi_alerts(db, station, data["aqi"])

async def _send_aqi_alerts(db, station, aqi):
    # Lấy tất cả users có FCM token
    users = await db.execute(
        select(User, HealthProfile)
        .join(HealthProfile, isouter=True)
        .where(User.fcm_token.isnot(None))
    )
    for user, profile in users:
        # Tính perceived AQI (có tính trọng số sức khỏe)
        perceived_aqi = personalization.calculate_perceived_aqi(real_aqi=aqi, ...)

        if perceived_aqi > AQI_ALERT_THRESHOLD:
            await notification_service.send_aqi_alert(user.fcm_token, aqi, station.name, perceived_aqi)
```

---

### 3.5 Google Maps Directions API

**Mục đích**: Lấy tuyến đường thực tế từ Google Maps cho routing engine. **Optional** — fallback Haversine khi không có API key.

| Thông số | Giá trị |
|---------|---------|
| Endpoint | `https://maps.googleapis.com/maps/api/directions/json` |
| Authentication | API key trong query parameter `?key=<GOOGLE_MAPS_API_KEY>` |
| Timeout | 10 giây |
| Fallback | Haversine × 1.3 (fastest) hoặc × 1.6 (cleanest) khi không có key |

**Request parameters:**

| Parameter | Value | Mô tả |
|-----------|-------|-------|
| `origin` | `"lat,lon"` | Tọa độ điểm xuất phát |
| `destination` | `"lat,lon"` | Tọa độ điểm đến |
| `mode` | `"driving"` / `"cycling"` / `"walking"` | Phương tiện |
| `key` | `GOOGLE_MAPS_API_KEY` | API key |
| `departure_time` | `"now"` | Tính toán theo traffic thực tế |
| `avoid` | `"highways"` | Chỉ dùng cho cleanest route |

**Code snippet:**

```python
# app/services/routing_service.py

async def _fetch_google_maps_route(
    self, origin: Coordinate, destination: Coordinate, mode: str, avoid: Optional[str] = None
) -> Optional[dict]:
    if not settings.GOOGLE_MAPS_API_KEY:
        return None   # Trigger Haversine fallback

    params = {
        "origin":         f"{origin.latitude},{origin.longitude}",
        "destination":    f"{destination.latitude},{destination.longitude}",
        "mode":           mode,
        "key":            settings.GOOGLE_MAPS_API_KEY,
        "departure_time": "now",
    }
    if avoid:
        params["avoid"] = avoid   # "highways" cho cleanest route

    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(
            "https://maps.googleapis.com/maps/api/directions/json",
            params=params,
        )
        data = resp.json()

    if data.get("status") != "OK" or not data.get("routes"):
        return None

    leg = data["routes"][0]["legs"][0]
    return {
        "distance_km":       leg["distance"]["value"] / 1000,
        "duration_minutes":  leg["duration"]["value"] / 60,
    }
```

**Fastest vs Cleanest Route (2 API calls):**

| Route Type | `avoid` param | AQI Factor | Distance multiplier (fallback) |
|------------|---------------|------------|-------------------------------|
| Fastest | _(none)_ | 0.5 | × 1.3 |
| Cleanest | `"highways"` | 0.15 | × 1.6 |

---

## PHẦN 4: Database Migrations (Alembic)

### 4.1 Cấu Trúc Alembic

```
airshield/
├── alembic.ini                         # Alembic config (sqlalchemy.url từ env)
└── alembic/
    ├── env.py                          # Migration runner (async-aware)
    ├── script.py.mako                  # Template cho migration files mới
    └── versions/
        └── 2026_01_22_0032-7c56532ac126_initial_migration_v2.py
```

### 4.2 Tích Hợp Async

`alembic/env.py` sử dụng `async_engine_from_config` với `NullPool` để tương thích với SQLAlchemy async:

```python
# alembic/env.py

import asyncio, sys
from sqlalchemy.ext.asyncio import async_engine_from_config
from sqlalchemy import pool

# Windows fix: SelectorEventLoop thay vì ProactorEventLoop
if sys.platform == 'win32':
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# Đọc DATABASE_URL từ Settings
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)
target_metadata = Base.metadata

# Bộ lọc: bỏ qua bảng hệ thống PostGIS (spatial_ref_sys, geometry_columns,...)
def include_object(object, name, type_, reflected, compare_to):
    if type_ == "table" and reflected and name not in target_metadata.tables:
        return False
    return True
```

### 4.3 Danh Sách Migrations

| Revision ID | Ngày tạo | Mô tả | Down revision |
|-------------|----------|-------|--------------|
| `7c56532ac126` | 2026-01-22 00:32 | Initial migration v2 (toàn bộ schema) | `None` (base) |

> Có 1 file `__pycache__` với revision `7d20221ff7d7` nhưng không có file Python tương ứng — đây là migration thử nghiệm ban đầu, không sử dụng.

### 4.4 Tables Được Tạo (Upgrade)

Migration `7c56532ac126` tạo 7 tables theo thứ tự (leaf tables trước, parent tables sau):

```sql
-- Thứ tự tạo bảng (không có FK constraint chưa tạo)

1. advice_rules         -- Quy tắc tư vấn sức khỏe theo AQI
2. automation_rules     -- Smart Home automation triggers
3. community_reports    -- Báo cáo cộng đồng (PostGIS Point geometry)
4. health_profiles      -- Hồ sơ sức khỏe người dùng (PK = user_id)
5. stations             -- Trạm đo AQI (IQAir/PamAir sources)
6. user_devices         -- Thiết bị IoT của người dùng
7. air_quality_logs     -- Lịch sử dữ liệu AQI (FK → stations)
```

> **Lưu ý**: Bảng `users` được tạo riêng (không nằm trong migration file này — có thể qua `init_db()` SQLAlchemy metadata).

### 4.5 Indexes Quan Trọng

| Index | Table | Columns | Type | Mục đích |
|-------|-------|---------|------|----------|
| `ix_air_quality_logs_station_recorded` | `air_quality_logs` | `(station_id, recorded_at)` | B-tree composite | Query lịch sử AQI theo trạm + thời gian |
| `idx_community_reports_geom` | `community_reports` | `geom` | **GiST** | Spatial queries (PostGIS `ST_DWithin`) |
| `ix_automation_rules_user_id` | `automation_rules` | `user_id` | B-tree | Lấy automation rules theo user |
| `ix_community_reports_user_id` | `community_reports` | `user_id` | B-tree | Lọc reports theo user |
| `ix_user_devices_user_id` | `user_devices` | `user_id` | B-tree | Lấy devices theo user |

### 4.6 PostGIS Column

```python
# community_reports.geom — điểm quan trọng cho spatial functionality
sa.Column('geom',
    geoalchemy2.types.Geometry(
        geometry_type='POINT',
        srid=4326,          # WGS84 (latitude/longitude chuẩn GPS)
        dimension=2,
    ),
    nullable=False,
    comment='Location as PostGIS Point geometry'
)

# Index GiST cho spatial query
op.create_index('idx_community_reports_geom', 'community_reports', ['geom'],
    postgresql_using='gist')   # GiST index = bắt buộc cho PostGIS
```

### 4.7 Các Lệnh Migration

```bash
# Apply tất cả migrations lên latest
alembic upgrade head

# Rollback tất cả về base (xóa toàn bộ schema)
alembic downgrade base

# Reset DB hoàn toàn
alembic downgrade base && alembic upgrade head

# Tạo migration mới từ model changes
alembic revision --autogenerate -m "add_column_X_to_table_Y"

# Xem lịch sử migrations
alembic history --verbose

# Xem revision hiện tại của DB
alembic current
```

---

## PHẦN 5: Monitoring & Logging

### 5.1 Logging Strategy

AirShield sử dụng Python standard logging (`logging` module) với module-level loggers:

```python
import logging
logger = logging.getLogger(__name__)
# → logger name = module path, e.g., "app.tasks.aqi_collector"
```

**Log messages theo mức độ:**

| Level | Khi nào dùng | Ví dụ |
|-------|-------------|-------|
| `DEBUG` | Chi tiết kỹ thuật (routing fallback) | `"GOOGLE_MAPS_API_KEY not set, using approximation."` |
| `INFO` | Events bình thường | `"✅ Hà Nội: AQI=42, PM2.5=10.5"`, `"FCM alert sent to user@..."` |
| `WARNING` | Dữ liệu không hoàn chỉnh, config thiếu | `"IQAir non-success for Da Nang"`, `"Tuya credentials not configured"` |
| `ERROR` | Lỗi có thể recover | `"Tuya token fetch failed: ..."`, `"FCM send failed: ..."` |

**Key log messages:**

```
# ETL Pipeline (mỗi 30 phút)
INFO  ✅ Hà Nội: AQI=42, PM2.5=10.5
INFO  ✅ TP. Hồ Chí Minh: AQI=89, PM2.5=35.2
INFO  FCM alert sent to user@example.com: AQI=120 → perceived=195.0 at Hà Nội
INFO  AQI collection done: 5 inserted, 0 failed.

# Firebase Init
INFO  ✅ Firebase Admin SDK initialized

# Routing
INFO  Routes: fastest=8.4km, cleanest=10.8km (straight=6.5km, via=GoogleMaps)
```

### 5.2 APScheduler Monitoring

```python
# main.py — startup configuration
scheduler.add_job(
    _run_aqi_collection,
    trigger=IntervalTrigger(minutes=30),
    id="aqi_collector",
    replace_existing=True,
    misfire_grace_time=60,   # Nếu lỡ giờ < 60s thì vẫn chạy
)
```

**Đặc điểm:**
- `AsyncIOScheduler` — chạy trong event loop của FastAPI, không block
- `misfire_grace_time=60` — nếu job bị bỏ lỡ (server restart, etc.) dưới 60 giây, sẽ chạy bù
- Không có retry logic — nếu 1 city fetch fail, skip và tiếp tục các city khác

### 5.3 Health Check Endpoints

```
GET /           → {"status": "healthy", "name": "AirShield", "version": "1.0.0"}
GET /health     → {"status": "healthy|degraded", "database": "connected", "redis": "connected"}
```

`/health` thực sự probe cả PostgreSQL (`SELECT 1`) và Redis (`PING`) để xác nhận connectivity.

### 5.4 Sentry (Mobile Only)

Sentry error tracking chỉ được tích hợp ở **Flutter mobile app** (không có trong backend):

```dart
// airshield_mobile/lib/main.dart

const sentryDsn = String.fromEnvironment('SENTRY_DSN');
if (sentryDsn.isNotEmpty) {
  await SentryFlutter.init((options) {
    options.dsn = sentryDsn;
  });
}

// Kích hoạt khi build:
// flutter run --dart-define=SENTRY_DSN=https://...@sentry.io/...
```

### 5.5 Graceful Degradation Summary

| Service | Khi không có credentials | Behavior |
|---------|--------------------------|---------|
| Gemini AI | `GEMINI_API_KEY=""` | Trả về rule-based fallback response bằng tiếng Việt |
| Tuya IoT | `TUYA_CLIENT_ID=""` | Log simulation message, trả `success: true` |
| Firebase FCM | `FIREBASE_CREDENTIALS_PATH=""` | Log notification thay vì gửi thật |
| Google Maps | `GOOGLE_MAPS_API_KEY=""` | Dùng Haversine × 1.3 / × 1.6 |
| Redis | Connection failed | AQI endpoint tiếp tục từ DB, bỏ qua cache |

---

## PHẦN 6: Python Dependencies Summary

**File**: `requirements.txt`

| Package | Version | Mục đích |
|---------|---------|---------|
| `fastapi` | ≥0.109.0 | Web framework (async) |
| `uvicorn[standard]` | ≥0.27.0 | ASGI server |
| `sqlalchemy[asyncio]` | ≥2.0.25 | ORM (async) |
| `asyncpg` | ≥0.29.0 | PostgreSQL async driver |
| `alembic` | ≥1.13.0 | Database migrations |
| `geoalchemy2` | ≥0.14.0 | PostGIS types cho SQLAlchemy |
| `pydantic` | ≥2.5.0 | Data validation (v2) |
| `pydantic-settings` | ≥2.1.0 | Settings từ env vars |
| `redis` | ≥5.0.0 | Redis client (async) |
| `aiomqtt` | ≥2.0.0 | MQTT async client (IoT) |
| `google-generativeai` | ≥0.3.0 | Google Gemini SDK |
| `prophet` | ≥1.1.5 | Time-series forecasting |
| `pandas` | ≥2.1.0 | Data manipulation (Prophet input) |
| `python-jose[cryptography]` | ≥3.3.0 | JWT encode/decode |
| `passlib[bcrypt]` | ≥1.7.4 | Password hashing (bcrypt) |
| `apscheduler` | ≥3.10.0 | Background job scheduler |
| `httpx` | ≥0.27.0 | Async HTTP client (IQAir, Maps) |
| `firebase-admin` | ≥6.4.0 | Firebase FCM push notifications |
| `python-multipart` | ≥0.0.6 | Form data parsing (OAuth2 login) |

---

## PHẦN 7: Tóm Tắt Architecture Diagram

```
                    ┌─────────────────────────────────┐
                    │       External Services          │
                    │                                  │
                    │  ┌──────────┐  ┌──────────────┐  │
                    │  │  IQAir   │  │   Google     │  │
                    │  │ AirVisual│  │   Gemini     │  │
                    │  │ /v2/city │  │1.5-flash     │  │
                    │  └────┬─────┘  └──────┬───────┘  │
                    │       │               │           │
                    │  ┌────┴─────┐  ┌──────┴───────┐  │
                    │  │  Tuya    │  │  Firebase    │  │
                    │  │ Cloud US │  │    FCM       │  │
                    │  │HMAC-SHA  │  │ Push Notify  │  │
                    │  └────┬─────┘  └──────┬───────┘  │
                    │       │               │           │
                    │  ┌────┴──────────────┴───────┐   │
                    │  │   Google Maps Directions  │   │
                    │  │    /maps/api/directions   │   │
                    │  └───────────────────────────┘   │
                    └──────────────┬──────────────────┘
                                   │
                    ┌──────────────▼──────────────────┐
                    │       FastAPI Backend            │
                    │                                  │
                    │  APScheduler (30min interval)    │
                    │  → IQAirClient → DB → FCM alerts│
                    │                                  │
                    │  Logging: Python standard logger │
                    │  Health: GET /health             │
                    └──────┬──────────────────────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
   ┌──────────▼────────┐    ┌───────────▼──────────┐
   │    PostgreSQL 15  │    │      Redis 7          │
   │    + PostGIS 3.4  │    │    (redis:7-alpine)   │
   │  (postgis:15-3.4) │    │  --appendonly yes     │
   │  7 tables         │    │  TTL: 5min/1hr/24hr  │
   │  GiST spatial idx │    └──────────────────────┘
   └───────────────────┘
```
