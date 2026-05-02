# 04 — Business Logic & Services

> **AirShield Backend** — Phân tích chi tiết thuật toán và business logic
> Source: `app/services/`, `app/tasks/`

---

## MỤC LỤC

1. [Forecast Service — Dự Báo AQI bằng Prophet AI](#1-forecast-service)
2. [Personalization Service — Cá Nhân Hóa AQI](#2-personalization-service)
3. [Routing Service — Tìm Tuyến Đường Sạch](#3-routing-service)
4. [Chatbot Service — AI Hội Thoại với Gemini](#4-chatbot-service)
5. [Device Control — Tuya IoT Adapter](#5-device-control--tuya-iot-adapter)
6. [Background Tasks — AQI Collector](#6-background-tasks--aqi-collector)
7. [Notification Service — FCM Push Alerts](#7-notification-service)
8. [Sơ Đồ Quan Hệ Giữa Các Service](#8-sơ-đồ-quan-hệ-giữa-các-service)

---

## 1. Forecast Service

> **File**: `app/services/forecast_service.py`
> **Thư viện**: `prophet` (Facebook/Meta), `pandas`
> **Cache**: Redis 1 giờ

### 1.1 Tổng Quan

ForecastService dự báo AQI trong **24 giờ tới** bằng mô hình time-series **Prophet**. Mô hình được huấn luyện **on-the-fly** (theo yêu cầu) từ 7 ngày dữ liệu lịch sử trong PostgreSQL — không lưu model đã train.

```
Input:  lat, lon, hours_ahead=24
          │
          ▼
        Tìm trạm gần nhất (Euclidean)
          │
          ▼
        Lấy 7 ngày lịch sử từ DB (≥10 records)
          │
          ▼
        Huấn luyện Prophet Model
          │
          ▼
Output: 24 giá trị AQI dự báo (1/giờ)
```

### 1.2 Input — Nguồn Dữ Liệu

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| `latitude`, `longitude` | `float` | Vị trí người dùng → xác định trạm gần nhất |
| Dữ liệu lịch sử | `AirQualityLog[]` | 7 ngày gần nhất, từ trạm gần nhất |
| `hours_ahead` | `int` | Số giờ cần dự báo (mặc định 24) |

**Điều kiện dữ liệu:**
- Tối thiểu **10 bản ghi** để train model
- Nếu thiếu → kích hoạt **fallback mock** (xem §1.5)

### 1.3 Hyperparameters Prophet

```python
m = Prophet(
    yearly_seasonality  = False,   # Tắt — chỉ có dữ liệu 7 ngày, không đủ 1 năm
    weekly_seasonality  = True,    # Bật — AQI có chu kỳ tuần (cuối tuần khác ngày thường)
    daily_seasonality   = True,    # Bật — AQI có chu kỳ ngày (giờ cao điểm vs ban đêm)
    changepoint_prior_scale = 0.05 # Nhỏ → ít linh hoạt, tránh overfit với 7 ngày data
)
```

**Giải thích từng tham số:**

| Tham số | Giá trị | Lý do |
|---------|---------|-------|
| `yearly_seasonality` | `False` | Chỉ có 7 ngày data, không đủ để học chu kỳ năm |
| `weekly_seasonality` | `True` | AQI thứ 2-6 cao hơn cuối tuần (giao thông, công xưởng) |
| `daily_seasonality` | `True` | AQI 7–9h và 17–19h cao hơn (giờ cao điểm xe cộ) |
| `changepoint_prior_scale` | `0.05` | Giảm tính linh hoạt để tránh overfit, ưu tiên tốc độ |

### 1.4 Quy Trình Huấn Luyện (Training Pipeline)

```python
# Bước 1: Chuẩn bị DataFrame theo chuẩn Prophet
# Prophet yêu cầu đúng 2 cột: 'ds' (datetime) và 'y' (giá trị)
df = pd.DataFrame([
    {
        "ds": log.recorded_at.replace(tzinfo=None),  # Bỏ timezone — Prophet yêu cầu naive datetime
        "y": log.aqi
    }
    for log in logs
])

# Bước 2: Khởi tạo và train model
m = Prophet(
    yearly_seasonality=False,
    weekly_seasonality=True,
    daily_seasonality=True,
    changepoint_prior_scale=0.05
)
m.fit(df)  # Training — mất ~1-3 giây với 336 data points (7 ngày × 48 readings/ngày)

# Bước 3: Tạo khung thời gian tương lai
future = m.make_future_dataframe(periods=hours_ahead, freq='h')
# → DataFrame với tất cả timestamps: lịch sử + 24h tương lai

# Bước 4: Dự báo
forecast = m.predict(future)
# → Cột quan trọng: 'ds' (timestamp), 'yhat' (dự báo), 'yhat_lower', 'yhat_upper'

# Bước 5: Lọc chỉ lấy tương lai
last_historical_date = df['ds'].max()
future_forecast = forecast[forecast['ds'] > last_historical_date].head(hours_ahead)

# Bước 6: Post-processing — giới hạn AQI trong khoảng hợp lệ [0, 500]
results = []
for _, row in future_forecast.iterrows():
    predicted_aqi = max(0, min(500, int(round(row['yhat']))))
    results.append({
        "recorded_at": row['ds'].isoformat() + "Z",
        "aqi": predicted_aqi,
        "is_forecast": True
    })
```

### 1.5 Fallback Mock Khi Thiếu Dữ Liệu

Khi `len(logs) < 10` hoặc Prophet không được cài đặt:

```python
def _generate_mock_forecast(self, hours: int, base_aqi: int = 60):
    """Random walk từ base_aqi, dao động ±5 đến +8 mỗi giờ."""
    current_aqi = base_aqi
    for i in range(1, hours + 1):
        future_time = now + timedelta(hours=i)
        current_aqi += random.randint(-5, 8)   # Xu hướng tăng nhẹ
        current_aqi = max(10, min(300, current_aqi))  # Bounded [10, 300]
        results.append(...)
```

**Khi nào kích hoạt fallback:**

| Điều kiện | Hành động |
|-----------|-----------|
| `prophet` chưa cài | Dùng mock ngay |
| `len(logs) < 10` | Dùng mock với `base_aqi = logs[-1].aqi` |
| `Prophet.fit()` raise exception | Dùng mock với `base_aqi = 60` |

### 1.6 Cache Strategy

```
GET /air-quality/forecast?latitude=21.02&longitude=105.85
    │
    ▼
Redis GET "aqi:forecast:21.02:105.85"
    │
    ├── HIT  → trả về ngay (không train lại)
    │
    └── MISS → train Prophet → lưu Redis SETEX 3600s → trả về
```

- **Cache key**: `aqi:forecast:{lat:.2f}:{lon:.2f}` (làm tròn 2 chữ số thập phân ≈ 1.1km)
- **TTL**: 3600 giây (1 giờ) — training Prophet tốn ~2-3s, không thể làm mỗi request

---

## 2. Personalization Service

> **File**: `app/services/personalization_service.py`
> **Không có cache** — tính toán thuần Python, không DB, nhanh (<1ms)

### 2.1 Công Thức Tính Perceived AQI

$$\text{Perceived\_AQI} = \text{Real\_AQI} \times \underbrace{\max(\text{age\_weight},\ \text{condition\_weight})}_{\text{base\_weight}} \times \text{sensitivity\_factor}$$

Trong đó:
$$\text{sensitivity\_factor} = 0.8 + (\text{sensitivity\_level} - 1) \times 0.1$$

**Ví dụ tính toán:**
- Real AQI = 80, Bệnh hen suyễn, Sensitivity Level = 4
- `condition_weight = 2.5` (asthma)
- `age_weight = 1.0` (30 tuổi, bình thường)
- `base_weight = max(1.0, 2.5) = 2.5`
- `sensitivity_factor = 0.8 + (4-1) × 0.1 = 1.1`
- `Perceived_AQI = 80 × 2.5 × 1.1 = 220` → **HAZARDOUS** (dù Real AQI chỉ 80)

### 2.2 Bảng Trọng Số Tuổi (Age Weights)

| Điều kiện | Trọng số | Quy tắc |
|-----------|---------|---------|
| Bình thường (12–64 tuổi) | `1.0` | Mặc định |
| Trẻ em (≤ 12 tuổi) | `1.3` | Phổi đang phát triển, nhạy hơn |
| Người cao tuổi (≥ 65 tuổi) | `1.5` | Sức đề kháng yếu, nguy cơ cao |
| Không có `birth_year` | `1.0` | Dùng giá trị mặc định |

### 2.3 Bảng Trọng Số Bệnh Lý (Condition Weights)

| Bệnh lý | `condition` tag | Trọng số | Lý do |
|---------|----------------|---------|-------|
| Bình thường | *(không có)* | `1.0` | Baseline |
| Dị ứng | `"allergies"` | `1.5` | Nhạy với PM2.5 |
| Thai phụ | `"pregnant"` | `1.6` | Ảnh hưởng thai nhi |
| Viêm xoang | `"sinus"` | `1.8` | Đường hô hấp nhạy cảm |
| Bệnh tim | `"heart_disease"` | `2.2` | Tim phải làm việc nhiều hơn khi không khí ô nhiễm |
| **Hen suyễn** | `"asthma"` | **`2.5`** | Ô nhiễm kích thích cơn hen |
| **COPD** | `"copd"` | **`2.8`** | Bệnh phổi tắc nghẽn mãn tính — nặng nhất |

> **Logic**: Nếu user có nhiều bệnh, chỉ lấy `max(all_condition_weights)` — không cộng dồn.

### 2.4 Bảng Sensitivity Factor

| Sensitivity Level | Factor | Ý nghĩa |
|-----------------|--------|---------|
| 1 (Thấp nhất) | `0.8` | User tự đánh giá ít nhạy cảm |
| 2 | `0.9` | Dưới trung bình |
| 3 (Mặc định) | `1.0` | Trung bình (không điều chỉnh) |
| 4 | `1.1` | Trên trung bình |
| 5 (Cao nhất) | `1.2` | User rất nhạy cảm |

### 2.5 Phân Loại Risk Level

```python
def get_risk_level(self, perceived_aqi: float) -> RiskLevel:
    if perceived_aqi <= 50:   return RiskLevel.LOW         # Tốt
    elif perceived_aqi <= 100: return RiskLevel.MODERATE    # Trung bình
    elif perceived_aqi <= 150: return RiskLevel.HIGH        # Không tốt
    elif perceived_aqi <= 200: return RiskLevel.VERY_HIGH   # Không lành mạnh
    else:                      return RiskLevel.HAZARDOUS   # Nguy hiểm
```

**`is_high_risk = perceived_aqi > 150`** → kích hoạt warning message đặc biệt.

### 2.6 Code: Hàm Tính Toán Chính

```python
# app/services/personalization_service.py

def calculate_health_weight(
    self,
    birth_year: Optional[int] = None,
    conditions: Optional[List[str]] = None,
    sensitivity_level: int = 3
) -> float:
    # Tính trọng số tuổi
    age_weight = self.calculate_age_weight(birth_year)
    # Tính trọng số bệnh lý (max trong tất cả conditions)
    condition_weight = self.calculate_condition_weight(conditions)
    # Lấy max của hai trọng số → base_weight
    base_weight = max(age_weight, condition_weight)
    # Áp dụng sensitivity factor: level 1→0.8, 2→0.9, 3→1.0, 4→1.1, 5→1.2
    sensitivity_factor = 0.8 + (sensitivity_level - 1) * 0.1
    return base_weight * sensitivity_factor


def get_personalized_advice(
    self,
    real_aqi: int,
    birth_year: Optional[int] = None,
    conditions: Optional[List[str]] = None,
    sensitivity_level: int = 3,
    lang: str = "vi",
) -> PersonalizedAdvice:
    # Bước 1: Tính Perceived AQI
    perceived_aqi = self.calculate_perceived_aqi(real_aqi, birth_year, conditions, sensitivity_level)
    # Bước 2: Phân loại risk
    risk_level = self.get_risk_level(perceived_aqi)
    # Bước 3: Flag cảnh báo cao
    is_high_risk = perceived_aqi > self.HIGH_RISK_THRESHOLD  # 150
    # Bước 4: Lấy khuyến nghị từ i18n JSON (vi.json / en.json)
    recommendations = self.get_recommendations(risk_level, conditions, lang)
    # Bước 5: Warning message nếu high risk
    warning_message = None
    if is_high_risk:
        i18n = _load_i18n(lang)
        template = i18n.get("warnings", {}).get("high_risk", "")
        warning_message = template.format(perceived_aqi=int(perceived_aqi))

    return PersonalizedAdvice(
        perceived_aqi=perceived_aqi,
        risk_level=risk_level,
        is_high_risk=is_high_risk,
        recommendations=recommendations,
        warning_message=warning_message,
    )
```

### 2.7 Internationalization (i18n)

Recommendations được load từ JSON file:
- `app/i18n/vi.json` — tiếng Việt (mặc định)
- `app/i18n/en.json` — tiếng Anh

Header `Accept-Language: vi` hoặc `Accept-Language: en` từ mobile quyết định ngôn ngữ.
Dùng `@lru_cache(maxsize=4)` để cache file đã đọc trong bộ nhớ.

---

## 3. Routing Service

> **File**: `app/services/routing_service.py`
> **External**: Google Maps Directions API (optional) + Haversine fallback

### 3.1 Công Thức Cost Function

$$\text{Cost} = \frac{\text{distance\_km}}{\text{speed\_kmh}} \times \left(1 + \alpha \times \text{aqi\_factor}\right)$$

Trong đó:
- **`distance_km`**: Khoảng cách đoạn đường (km)
- **`speed_kmh`**: Tốc độ theo phương tiện (km/h)
- **`α (alpha)`**: Trọng số AQI = `0.5` (cấu hình qua `ROUTING_ALPHA`)
- **`aqi_factor`**: AQI đã chuẩn hóa về `[0.0, 1.0]`

**Ý nghĩa**: Chi phí = thời gian di chuyển cơ bản × hệ số phạt ô nhiễm. `aqi_factor = 0` → không phạt. `aqi_factor = 1.0` → tăng chi phí 50%.

### 3.2 AQI Normalization (5 Breakpoints)

```python
def normalize_aqi(self, aqi: int) -> float:
    """Chuyển AQI [0–500] → aqi_factor [0.0–1.0] theo thang phi tuyến."""
    if aqi <= 50:    return aqi / 500                       # [0.000 – 0.100]  Tốt
    elif aqi <= 100: return 0.1 + (aqi - 50) / 250         # [0.100 – 0.300]  TB
    elif aqi <= 150: return 0.3 + (aqi - 100) / 250        # [0.300 – 0.500]  Kém
    elif aqi <= 200: return 0.5 + (aqi - 150) / 250        # [0.500 – 0.700]  Xấu
    elif aqi <= 300: return 0.7 + (aqi - 200) / 500        # [0.700 – 0.900]  Rất xấu
    else:            return min(1.0, 0.9 + (aqi - 300)/1000) # [0.900 – 1.000]  Nguy hiểm
```

**Bảng AQI → Factor:**

| AQI | Factor | Mức độ |
|-----|--------|--------|
| 0 | 0.000 | Rất sạch |
| 50 | 0.100 | Tốt |
| 100 | 0.300 | Trung bình |
| 150 | 0.500 | Kém |
| 200 | 0.700 | Xấu |
| 300 | 0.900 | Rất xấu |
| 500 | 1.000 | Nguy hiểm |

### 3.3 Tốc Độ Theo Phương Tiện

| Mode | Tốc độ | Mô tả |
|------|--------|-------|
| `"driving"` | 40 km/h | Tốc độ đô thị Việt Nam |
| `"cycling"` | 15 km/h | Xe đạp |
| `"walking"` | 5 km/h | Đi bộ |

### 3.4 Tính Khoảng Cách: Haversine Formula

```python
def _haversine_km(self, a: Coordinate, b: Coordinate) -> float:
    """Công thức Haversine — khoảng cách đường thẳng trên mặt cầu."""
    R = 6371  # Bán kính Trái Đất (km)
    lat1, lon1, lat2, lon2 = map(math.radians, [a.latitude, a.longitude, b.latitude, b.longitude])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    h = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    return R * 2 * math.asin(math.sqrt(h))
```

$$d = 2R \cdot \arcsin\left(\sqrt{\sin^2\frac{\Delta\phi}{2} + \cos\phi_1 \cdot \cos\phi_2 \cdot \sin^2\frac{\Delta\lambda}{2}}\right)$$

### 3.5 So Sánh Fastest vs Cleanest Route

| | Fastest Route | Cleanest Route |
|---|---------------|----------------|
| **Thuật toán Google Maps** | `mode=driving` (không avoid) | `mode=driving, avoid=highways` |
| **Fallback (không có API key)** | `straight_km × 1.3` | `straight_km × 1.6` |
| **AQI Factor giả định** | `0.5` (đường chính = TB ô nhiễm) | `0.15` (công viên, khu dân cư) |
| **Ưu điểm** | Thời gian ngắn hơn | Phơi nhiễm ô nhiễm ít hơn |

### 3.6 Code: Logic Routing Chính

```python
async def find_routes(self, origin, destination, mode="driving"):
    speeds = {"driving": 40.0, "cycling": 15.0, "walking": 5.0}
    speed = speeds.get(mode, 40.0)
    straight_km = self._haversine_km(origin, destination)

    # ── Tuyến nhanh nhất ──
    gmap = await self._fetch_google_maps_route(origin, destination, mode)
    if gmap:
        fastest_distance = gmap["distance_km"]
        fastest_time = gmap["duration_minutes"]
    else:
        fastest_distance = round(straight_km * 1.3, 2)   # Hệ số đô thị 1.3
        fastest_time = (fastest_distance / speed) * 60

    fastest_cost = self.calculate_segment_cost(
        fastest_distance, speed, aqi_factor=0.5          # Đường lớn = ô nhiễm TB
    )

    # ── Tuyến sạch nhất ──
    gmap_clean = await self._fetch_google_maps_route(
        origin, destination, mode, avoid="highways"
    )
    if gmap_clean:
        clean_distance = gmap_clean["distance_km"]
        clean_time = gmap_clean["duration_minutes"]
    else:
        clean_distance = round(straight_km * 1.6, 2)     # Dài hơn 23% so với fastest
        clean_time = (clean_distance / speed) * 60

    clean_cost = self.calculate_segment_cost(
        clean_distance, speed, aqi_factor=0.15            # Công viên/khu dân cư = ô nhiễm thấp
    )

    return fastest_route, cleanest_route
```

### 3.7 Google Maps Integration

```python
async def _fetch_google_maps_route(self, origin, destination, mode, avoid=None):
    params = {
        "origin": f"{origin.latitude},{origin.longitude}",
        "destination": f"{destination.latitude},{destination.longitude}",
        "mode": mode,                       # driving / cycling / walking
        "key": settings.GOOGLE_MAPS_API_KEY,
        "departure_time": "now",            # Traffic-aware
    }
    if avoid:
        params["avoid"] = avoid             # "highways" cho cleanest route

    resp = await client.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        params=params
    )
    leg = resp.json()["routes"][0]["legs"][0]
    return {
        "distance_km": leg["distance"]["value"] / 1000,
        "duration_minutes": leg["duration"]["value"] / 60,
    }
```

**Nếu `GOOGLE_MAPS_API_KEY` không được cấu hình** → dùng Haversine với hệ số ước lượng (×1.3 fastest, ×1.6 cleanest).

---

## 4. Chatbot Service

> **File**: `app/services/chatbot_service.py`
> **AI Model**: Google Gemini `gemini-1.5-flash`
> **Session Storage**: Redis (TTL 24 giờ)

### 4.1 Kiến Trúc Chatbot

```
User Message
    │
    ▼
1. Get/Create Session (Redis)
    │
    ▼
2. Build Context (AQI data + user profile → JSON string)
    │
    ▼
3. Build Prompt (SYSTEM_PROMPT + context + conversation history)
    │
    ▼
4. Gemini API (gemini-1.5-flash)
    │
    ▼
5. Detect Action (keyword matching)
    │
    ▼
6. Save Session (Redis SETEX 86400s)
    │
    ▼
ChatResponse {session_id, message, action, sources}
```

### 4.2 System Prompt (Tiếng Việt)

```python
SYSTEM_PROMPT = """Bạn là **AirShield Assistant** - trợ lý AI thông minh chuyên về
chất lượng không khí và sức khỏe.

## Khả năng của bạn:
1. **Chất lượng không khí**: Giải thích AQI, PM2.5, PM10, O3, NO2, SO2, CO
2. **Tư vấn sức khỏe**: Đưa ra lời khuyên dựa trên mức AQI và tình trạng sức khỏe
3. **Thiết bị lọc khí**: Hướng dẫn sử dụng máy lọc không khí, thay filter
4. **Smart Home**: Điều khiển thiết bị (bật/tắt máy lọc không khí, quạt, điều hòa)

## Quy tắc:
- Trả lời bằng tiếng Việt, ngắn gọn, thân thiện
- Nếu được hỏi về AQI cụ thể, sử dụng context data được cung cấp
- Luôn đề xuất hành động cụ thể khi AQI > 100
...
"""
```

**Lưu ý**: SYSTEM_PROMPT chỉ được inject vào **tin nhắn đầu tiên** của session (khi `len(history) == 1`). Các tin nhắn tiếp theo chỉ truyền conversation history + context.

### 4.3 Context Injection

Khi user gửi `include_aqi_context=true` và cung cấp lat/lon, backend:
1. Tìm trạm gần nhất trong DB (trong vòng 2 giờ gần nhất)
2. Inject AQI data vào prompt dưới dạng JSON:

```python
def _build_context(self, aqi_data, user_profile) -> str:
    context_parts = []
    if aqi_data:
        context_parts.append(
            f"**Dữ liệu AQI hiện tại:**\n{json.dumps(aqi_data, ensure_ascii=False)}"
        )
    if user_profile:
        context_parts.append(
            f"**Hồ sơ sức khỏe người dùng:**\n{json.dumps(user_profile, ensure_ascii=False)}"
        )
    return "\n\n".join(context_parts)
```

**Prompt cuối cùng gửi Gemini:**
```
{SYSTEM_PROMPT}                      ← chỉ lần đầu

{context}                            ← AQI JSON + health profile JSON

**Câu hỏi:** {user_message}          ← tin nhắn user
```

### 4.4 Session Management (Redis)

```python
_SESSION_KEY_PREFIX = "chat_session:"
_SESSION_TTL = 86400  # 24 giờ

# Cấu trúc session lưu trong Redis:
session = {
    "user_id": "uuid-string",
    "messages": [
        {"role": "user",      "content": "..."},
        {"role": "assistant", "content": "..."},
        ...
    ],
    "created_at": "2026-04-26T08:00:00Z",
    "updated_at": "2026-04-26T08:30:00Z",
}
```

**Quy trình session:**
1. `session_id = null` → tạo UUID mới → `SETEX chat_session:{uuid} 86400 {json}`
2. `session_id = "abc"` → `GET chat_session:abc` → deserialize
3. Mỗi lần chat → append messages → `SETEX ... 86400 ...` (refresh TTL)
4. Session tự xóa sau 24h không hoạt động

### 4.5 Conversation History cho Gemini

```python
# Chuyển conversation history sang format Gemini yêu cầu
chat_history = []
for msg in history[:-1]:  # Trừ tin nhắn hiện tại (chưa có response)
    chat_history.append({
        "role": msg["role"],      # "user" hoặc "assistant"
        "parts": [msg["content"]]
    })

# Khởi tạo Gemini chat với history đã có
chat = self.model.start_chat(history=chat_history)

# Gửi tin nhắn mới (có context inject)
response = chat.send_message(prompt)
ai_response = response.text
```

### 4.6 Action Detection (Keyword Matching)

```python
def _detect_action(self, message: str, response: str) -> ChatAction:
    message_lower = message.lower()

    # Điều khiển thiết bị
    if any(kw in message_lower for kw in ["bật", "tắt", "mở", "đóng",
                                           "máy lọc", "purifier", "quạt"]):
        return ChatAction(action_type=ActionType.CONTROL_DEVICE,
                          payload={"suggested_action": "open_device_control"})

    # Hiển thị AQI
    if any(kw in message_lower for kw in ["aqi", "chất lượng không khí", "pm2.5"]):
        return ChatAction(action_type=ActionType.SHOW_AQI,
                          payload={"suggested_action": "refresh_aqi"})

    # Bản đồ
    if any(kw in message_lower for kw in ["bản đồ", "map", "vị trí"]):
        return ChatAction(action_type=ActionType.SHOW_MAP,
                          payload={"suggested_action": "open_map"})

    return ChatAction(action_type=ActionType.NONE)
```

Mobile app nhận `action.action_type` và tự điều hướng đến màn hình tương ứng.

### 4.7 Cấu Hình Gemini

| Tham số | Giá trị | Mô tả |
|---------|---------|-------|
| `model_name` | `gemini-1.5-flash` | Model nhanh, phù hợp chatbot real-time |
| `temperature` | `0.7` | Balanced — sáng tạo nhưng không quá tự do |
| `max_output_tokens` | `1024` | Giới hạn độ dài phản hồi (~700 từ) |

### 4.8 Fallback Khi Gemini Không Có

Nếu `GEMINI_API_KEY` chưa cấu hình hoặc Gemini lỗi → `_get_fallback_response()` trả về phản hồi cố định dựa trên keyword matching tiếng Việt.

---

## 5. Device Control — Tuya IoT Adapter

> **File**: `app/services/device_adapters/tuya_adapter.py`
> **API**: Tuya Cloud Open API `https://openapi.tuyaus.com`
> **Auth**: HMAC-SHA256

### 5.1 Kiến Trúc Adapter

```
BaseDeviceAdapter (ABC)
    │
    └── TuyaAdapter
            ├── _sign()              ← HMAC-SHA256 signature builder
            ├── _get_access_token()  ← Token management (cached in-memory)
            ├── send_command()       ← Gửi lệnh DP (Data Point)
            └── get_device_status()  ← Lấy trạng thái thiết bị
```

**Design Pattern**: Strategy Pattern — `BaseDeviceAdapter` định nghĩa interface, `TuyaAdapter` implements. Dễ mở rộng thêm `XiaomiAdapter`, `SwitchBotAdapter`.

### 5.2 Tuya Authentication — HMAC-SHA256

```python
def _sign(self, method: str, path: str, body: str = "", access_token: str = "") -> dict:
    ts = str(int(time.time() * 1000))  # Timestamp milliseconds

    # Chuỗi ký theo chuẩn Tuya
    sign_str = (
        self.client_id
        + (access_token or "")   # Trống khi lấy token, có giá trị khi gửi lệnh
        + ts
        + method.upper()         # "GET" hoặc "POST"
        + "\n"
        + ""                     # Content-MD5 (trống)
        + "\n"
        + ""                     # Content-Type (trống trong signature)
        + "\n"
        + path
    )

    # Nếu có body → hash SHA256 của body và thêm vào
    if body:
        body_hash = hashlib.sha256(body.encode()).hexdigest()
        sign_str = sign_str.replace("\n" + path, "\n" + body_hash + "\n" + path)

    # Ký bằng HMAC-SHA256 với client_secret
    signature = hmac.new(
        self.client_secret.encode(),
        sign_str.encode(),
        hashlib.sha256
    ).hexdigest().upper()

    return {
        "client_id": self.client_id,
        "access_token": access_token or "",
        "sign": signature,
        "sign_method": "HMAC-SHA256",
        "t": ts,
    }
```

### 5.3 Luồng Lấy Access Token

```
POST /smart-home/devices/{id}/command
    │
    ▼
TuyaAdapter._get_access_token()
    │
    ├── Token còn hạn? (time.time() < _token_expires)
    │       └── YES → return cached token
    │
    └── NO → GET /v1.0/token?grant_type=1
                headers = _sign("GET", path)  ← không có access_token
                response = {
                    "access_token": "...",
                    "expire_time": 7200         ← 2 giờ
                }
                _token_expires = time.time() + 7200 - 60  ← buffer 60s
```

### 5.4 Gửi Lệnh Điều Khiển (Data Point Commands)

```python
async def send_command(self, device_id, access_token, command, value):
    token = await self._get_access_token()

    # Map AirShield command → Tuya DP (Data Point) code
    dp_map = {
        "power":         "switch_1",          # True/False
        "set_mode":      "mode",              # "auto", "sleep", "turbo"
        "set_speed":     "fan_speed_enum",    # "low", "medium", "high"
        "set_fan_speed": "fan_speed_percent", # 0-100
    }
    dp_key = dp_map.get(command, command)

    # Tuya API endpoint
    path = f"/v1.0/iot-03/devices/{device_id}/commands"
    body = json.dumps({
        "commands": [{"code": dp_key, "value": value}]
    })
    headers = self._sign("POST", path, body, token)
    headers["Content-Type"] = "application/json"

    resp = await client.post(f"{TUYA_BASE_URL}{path}", headers=headers, content=body)
    data = resp.json()

    if data.get("success"):
        return {"success": True, "message": f"Command '{command}={value}' sent via Tuya Cloud"}
    else:
        return {"success": False, "message": data.get("msg", "Tuya command failed")}
```

### 5.5 Command Map: AirShield → Tuya DP

| AirShield Command | Tuya DP Code | Value Type | Ví dụ |
|------------------|-------------|-----------|-------|
| `"power"` | `switch_1` | `bool` | `true` / `false` |
| `"set_mode"` | `mode` | `string` | `"auto"`, `"sleep"`, `"turbo"` |
| `"set_speed"` | `fan_speed_enum` | `string` | `"low"`, `"medium"`, `"high"` |
| `"set_fan_speed"` | `fan_speed_percent` | `int` | `0`–`100` |

### 5.6 Graceful Degradation

Khi `TUYA_CLIENT_ID`/`TUYA_CLIENT_SECRET` chưa cấu hình:
```python
if not token:
    # Log lệnh nhưng không thực thi thực tế
    return {
        "success": True,
        "message": f"[Simulated] Command '{command}={value}' logged"
    }
```
→ Cho phép phát triển và test UI mà không cần thiết bị thật.

---

## 6. Background Tasks — AQI Collector

> **File**: `app/tasks/aqi_collector.py`
> **Scheduler**: APScheduler (chạy khi app khởi động)
> **Tần suất**: Mỗi **30 phút**
> **Data source**: IQAir AirVisual API

### 6.1 Các Thành Phần

```
APScheduler (30 phút interval)
    │
    ▼
collect_aqi_data(db: AsyncSession)
    │
    ├── IQAirClient.fetch_city_data()   ← Gọi IQAir API
    ├── Upsert Station                  ← Tạo/tìm trạm trong DB
    ├── INSERT AirQualityLog            ← Ghi dữ liệu mới
    └── _send_aqi_alerts()              ← FCM push nếu AQI > 100
```

### 6.2 Các Thành Phố Được Giám Sát

```python
MONITORED_LOCATIONS = [
    {"city": "Hanoi",           "lat": 21.0285, "lon": 105.8542, "name": "Hà Nội"},
    {"city": "Ho Chi Minh City","lat": 10.8231, "lon": 106.6297, "name": "TP. Hồ Chí Minh"},
    {"city": "Da Nang",         "lat": 16.0544, "lon": 108.2022, "name": "Đà Nẵng"},
    {"city": "Hai Phong",       "lat": 20.8449, "lon": 106.6881, "name": "Hải Phòng"},
    {"city": "Can Tho",         "lat": 10.0452, "lon": 105.7469, "name": "Cần Thơ"},
]
```

**5 thành phố lớn của Việt Nam** → 5 API calls mỗi 30 phút = **240 calls/ngày**.
IQAir Free Tier: 10,000 calls/tháng → **~41 calls/ngày** (cần nâng gói hoặc tăng interval).

### 6.3 IQAir API Client

```python
class IQAirClient:
    BASE_URL = "https://api.airvisual.com/v2"

    async def fetch_city_data(self, city: str, country: str = "Vietnam"):
        resp = await client.get(
            f"{self.BASE_URL}/city",
            params={"city": city, "country": country, "key": self.API_KEY}
        )
        data = resp.json()

        if data.get("status") != "success":
            return None

        pollution = data["data"]["current"]["pollution"]
        weather   = data["data"]["current"]["weather"]

        return {
            "aqi":         pollution.get("aqius"),     # US AQI standard
            "pm25":        pollution.get("conc", {}).get("p2"),
            "temperature": weather.get("tp"),           # Celsius
            "humidity":    weather.get("hu"),            # Percent
        }
```

### 6.4 ETL Pipeline (Mỗi 30 Phút)

```python
async def collect_aqi_data(db: AsyncSession) -> None:
    for loc in MONITORED_LOCATIONS:
        # Bước 1: Upsert Station (tạo nếu chưa có)
        station = await db.execute(
            select(Station).where(Station.name == loc["name"])
        ).scalar_one_or_none()
        if not station:
            station = Station(name=loc["name"], ...)
            db.add(station)
            await db.flush()  # Lấy station.id trước khi commit

        # Bước 2: Gọi IQAir API
        data = await client.fetch_city_data(city=loc["city"])
        if not data:
            failed += 1
            continue  # Bỏ qua, thử lại lần sau

        # Bước 3: Insert AirQualityLog
        log = AirQualityLog(
            station_id=station.id,
            aqi=data["aqi"],
            pm25=data["pm25"],
            temperature=data["temperature"],
            humidity=data["humidity"],
            recorded_at=datetime.now(timezone.utc),
        )
        db.add(log)

        # Bước 4: Gửi FCM alert nếu cần
        if data["aqi"] > AQI_ALERT_THRESHOLD:  # 100
            await _send_aqi_alerts(db, station, data["aqi"])

    await db.commit()  # Commit toàn bộ sau khi xử lý hết 5 thành phố
```

### 6.5 FCM Alert Logic (Tích Hợp Personalization)

```python
async def _send_aqi_alerts(db, station, aqi):
    # Lấy tất cả users có FCM token
    rows = await db.execute(
        select(User, HealthProfile)
        .join(HealthProfile, isouter=True)   # LEFT JOIN — user có thể không có profile
        .where(User.fcm_token.isnot(None))
    )

    personalization = PersonalizationService()
    for user, profile in rows:
        # Tính perceived AQI riêng cho từng user
        perceived_aqi = aqi  # default nếu không có profile
        if profile:
            perceived_aqi = personalization.calculate_perceived_aqi(
                real_aqi=aqi,
                birth_year=profile.birth_year,
                conditions=profile.conditions,
                sensitivity_level=profile.sensitivity_level,
            )

        # Chỉ gửi alert nếu perceived AQI > 100 (không phải real AQI)
        if perceived_aqi > AQI_ALERT_THRESHOLD:
            await notification_service.send_aqi_alert(
                fcm_token=user.fcm_token,
                aqi=aqi,
                station_name=station.name,
                perceived_aqi=perceived_aqi,
            )
```

**Điểm quan trọng**: Alert dựa trên **perceived AQI**, không phải real AQI. Người dùng bị hen suyễn sẽ nhận alert sớm hơn (khi AQI thật còn thấp nhưng perceived đã > 100).

### 6.6 Error Handling

| Lỗi | Hành động |
|-----|-----------|
| IQAir API lỗi (HTTP 4xx/5xx) | Log warning, `failed += 1`, bỏ qua thành phố, tiếp tục |
| IQAir API `status != "success"` | Log warning, `failed += 1`, bỏ qua |
| FCM gửi thất bại | Log error, bỏ qua, không retry |
| DB lỗi | Exception propagate lên APScheduler (log) |

**Không có retry logic** — lần chạy tiếp theo (30 phút sau) sẽ thử lại tự động.

---

## 7. Notification Service

> **File**: `app/services/notification_service.py`
> **Platform**: Firebase Cloud Messaging (FCM)
> **SDK**: `firebase-admin`

### 7.1 AQI Alert Messages

| AQI Range | Title | Nội dung thông báo |
|-----------|-------|-------------------|
| 51–100 | ⚠️ Chất Lượng Không Khí Trung Bình | Nhóm nhạy cảm cần chú ý |
| 101–150 | 🟠 Không Khí Kém | Hạn chế ra ngoài, đeo khẩu trang |
| 151–200 | 🔴 Không Khí Không Lành Mạnh | Tránh hoạt động ngoài trời |
| >200 | ☠️ Nguy Hiểm | Ở trong nhà, đóng cửa sổ ngay! |

### 7.2 FCM Message Format

```python
message = messaging.Message(
    notification=messaging.Notification(title=title, body=body),
    data={
        "type": "aqi_alert",
        "aqi": str(aqi),
        "station": station_name,
        "perceived_aqi": str(round(perceived_aqi)),
    },
    token=fcm_token,                    # Device FCM token (lưu trong users.fcm_token)
    android=messaging.AndroidConfig(priority="high"),    # Ưu tiên cao trên Android
    apns=messaging.APNSConfig(                           # iOS config
        payload=messaging.APNSPayload(
            aps=messaging.Aps(sound="default")           # Âm thanh thông báo
        )
    ),
)
```

---

## 8. Sơ Đồ Quan Hệ Giữa Các Service

```
┌──────────────────────────────────────────────────────────────────────┐
│                        AirShield Services                            │
│                                                                      │
│  ┌─────────────────┐         ┌──────────────────────┐               │
│  │  APScheduler    │         │   PersonalizationSvc  │               │
│  │  (30 phút)      │────────►│   Perceived AQI      │               │
│  └────────┬────────┘         │   Health Weights      │               │
│           │                  └──────────┬───────────┘               │
│           │ collect_aqi_data()          │ calculate_perceived_aqi()  │
│           ▼                             │                            │
│  ┌─────────────────┐                   │                            │
│  │   IQAirClient   │         ┌──────────▼───────────┐               │
│  │   fetch_city    │         │  NotificationService  │               │
│  │   (5 cities)    │────────►│  FCM Push Alerts      │               │
│  └─────────────────┘         └──────────────────────┘               │
│                                                                      │
│  ┌─────────────────┐         ┌──────────────────────┐               │
│  │  ForecastService│         │    ChatbotService     │               │
│  │  Prophet AI     │         │    Gemini + Redis     │               │
│  │  On-the-fly     │         │    Session Mgmt       │               │
│  │  training       │         └──────────────────────┘               │
│  └─────────────────┘                                                 │
│                                                                      │
│  ┌─────────────────┐         ┌──────────────────────┐               │
│  │  RoutingService │         │    TuyaAdapter        │               │
│  │  Haversine +    │         │    HMAC-SHA256        │               │
│  │  Google Maps    │         │    Device Commands    │               │
│  └─────────────────┘         └──────────────────────┘               │
└──────────────────────────────────────────────────────────────────────┘
```

### Phụ thuộc giữa các Service

| Service | Phụ thuộc |
|---------|-----------|
| `ForecastService` | `PostgreSQL` (lấy history), `Redis` (cache) |
| `PersonalizationService` | Không (pure Python, đọc i18n JSON) |
| `RoutingService` | `Google Maps API` (optional), `Haversine` (fallback) |
| `ChatbotService` | `Gemini API`, `Redis` (sessions), `PostgreSQL` (AQI context) |
| `TuyaAdapter` | `Tuya Cloud API` |
| `AQI Collector` | `IQAirClient`, `PersonalizationService`, `NotificationService`, `PostgreSQL` |
| `NotificationService` | `Firebase FCM` |

---

*Tài liệu này được tạo từ source code trực tiếp của AirShield.*
*Source: `app/services/`, `app/tasks/`, `app/core/`*
