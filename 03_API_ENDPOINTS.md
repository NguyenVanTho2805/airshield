# 03 — API Endpoints Documentation

> **AirShield Backend API** · FastAPI · Base URL: `http://localhost:8000/api/v1`
> Swagger UI: http://localhost:8000/docs | ReDoc: http://localhost:8000/redoc

---

## MỤC LỤC

1. [Tổng Quan Endpoints](#1-tổng-quan-endpoints)
2. [Authentication Module — `/auth`](#2-authentication-module)
3. [Air Quality Module — `/air-quality`](#3-air-quality-module)
4. [Routing Module — `/routing`](#4-routing-module)
5. [Health Profile Module — `/user/health`](#5-health-profile-module)
6. [Community Module — `/community`](#6-community-module)
7. [Smart Home Module — `/smart-home`](#7-smart-home-module)
8. [AI Chatbot Module — `/chatbot`](#8-ai-chatbot-module)
9. [Authentication Flow (JWT)](#9-authentication-flow-jwt)
10. [Rate Limiting & Caching](#10-rate-limiting--caching)
11. [Error Response Format](#11-error-response-format)

---

## 1. Tổng Quan Endpoints

### 1.1 Bảng Tất Cả Endpoints

| # | Method | Path | Mô tả | Auth |
|---|--------|------|-------|------|
| 1 | `POST` | `/auth/register` | Đăng ký tài khoản mới | ❌ |
| 2 | `POST` | `/auth/login` | Đăng nhập, lấy JWT | ❌ |
| 3 | `GET` | `/auth/me` | Xem thông tin bản thân | ✅ |
| 4 | `PUT` | `/auth/me/fcm-token` | Cập nhật FCM push token | ✅ |
| 5 | `GET` | `/air-quality/current` | AQI hiện tại theo vị trí | ❌ |
| 6 | `GET` | `/air-quality/history` | Lịch sử AQI (max 7 ngày) | ❌ |
| 7 | `GET` | `/air-quality/forecast` | Dự báo AQI 24h (Prophet AI) | ❌ |
| 8 | `POST` | `/routing/calculate` | Tính 2 tuyến đường (nhanh + sạch) | ❌ |
| 9 | `POST` | `/user/health/profile` | Tạo/cập nhật hồ sơ sức khỏe | ✅ |
| 10 | `GET` | `/user/health/recommendation` | Khuyến nghị cá nhân hóa | ✅ |
| 11 | `POST` | `/community/report` | Gửi báo cáo ô nhiễm | ✅ |
| 12 | `GET` | `/community/reports` | Danh sách báo cáo cộng đồng | ✅ |
| 13 | `POST` | `/community/report/{id}/verify` | Xác nhận/bác bỏ báo cáo | ✅ |
| 14 | `GET` | `/smart-home/devices` | Danh sách thiết bị IoT | ✅ |
| 15 | `POST` | `/smart-home/devices` | Đăng ký thiết bị mới | ✅ |
| 16 | `POST` | `/smart-home/devices/{id}/command` | Gửi lệnh điều khiển thiết bị | ✅ |
| 17 | `POST` | `/chatbot/chat` | Gửi tin nhắn tới AI chatbot | ✅ |
| 18 | `GET` | `/chatbot/sessions` | Danh sách phiên chat | ✅ |
| 19 | `GET` | `/chatbot/sessions/{id}` | Lịch sử tin nhắn của phiên | ✅ |
| 20 | `DELETE` | `/chatbot/sessions/{id}` | Xóa phiên chat | ✅ |

**Tổng**: 20 endpoints · 7 module · ✅ = cần JWT Bearer token

### 1.2 Phân Bổ Theo Module

```
Authentication  ████  4 endpoints
Air Quality     ███   3 endpoints
Routing         █     1 endpoint
Health Profile  ██    2 endpoints
Community       ███   3 endpoints
Smart Home      ███   3 endpoints
AI Chatbot      ████  4 endpoints
```

---

## 2. Authentication Module

> **Prefix**: `/api/v1/auth` · Tag: `Authentication`
> **File**: `app/api/v1/auth.py`

### 2.1 Endpoints Table

| Method | Path | Status | Auth |
|--------|------|--------|------|
| `POST` | `/auth/register` | `201 Created` | ❌ |
| `POST` | `/auth/login` | `200 OK` | ❌ |
| `GET` | `/auth/me` | `200 OK` | ✅ JWT |
| `PUT` | `/auth/me/fcm-token` | `200 OK` | ✅ JWT |

---

### `POST /auth/register`

Đăng ký tài khoản mới. Tự động hash password bằng **bcrypt** và trả về JWT ngay lập tức.

**Request Body:**
```json
{
  "email": "nguyen.van.a@gmail.com",
  "password": "SecurePass123!",
  "full_name": "Nguyễn Văn A"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `email` | `EmailStr` | ✅ | Format email hợp lệ |
| `password` | `string` | ✅ | Không có ràng buộc độ dài |
| `full_name` | `string \| null` | ❌ | Tuỳ chọn |

**Response 201 Created:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "nguyen.van.a@gmail.com",
    "full_name": "Nguyễn Văn A",
    "role": "user",
    "is_active": true
  }
}
```

**Errors:**
| Code | Condition | Message |
|------|-----------|---------|
| `400` | Email đã tồn tại | `"Email already registered"` |
| `422` | Sai format email/thiếu field | Pydantic validation error |

---

### `POST /auth/login`

Đăng nhập bằng email + password. Sử dụng **OAuth2 Password Form** (`username` = email).

**Request Body** (form-data, không phải JSON):
```
Content-Type: application/x-www-form-urlencoded

username=nguyen.van.a@gmail.com&password=SecurePass123!
```

> **Lưu ý**: FastAPI dùng `OAuth2PasswordRequestForm` — field tên là `username` nhưng giá trị là email.

**Response 200 OK:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "nguyen.van.a@gmail.com",
    "full_name": "Nguyễn Văn A",
    "role": "user",
    "is_active": true
  }
}
```

**Errors:**
| Code | Condition | Message |
|------|-----------|---------|
| `400` | Tài khoản bị vô hiệu hóa | `"Account is disabled"` |
| `401` | Sai email/password | `"Incorrect email or password"` |

---

### `GET /auth/me`

Lấy thông tin user hiện tại từ JWT token.

**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response 200 OK:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "nguyen.van.a@gmail.com",
  "full_name": "Nguyễn Văn A",
  "role": "user",
  "is_active": true
}
```

**Errors:** `401` nếu token không hợp lệ hoặc hết hạn.

---

### `PUT /auth/me/fcm-token`

Cập nhật FCM (Firebase Cloud Messaging) token cho push notification. Mobile app gọi mỗi khi token thay đổi.

**Request Body:**
```json
{
  "fcm_token": "dOl8x2mK4jE:APA91bEV..."
}
```

**Response 200 OK:**
```json
{
  "message": "FCM token updated successfully"
}
```

---

## 3. Air Quality Module

> **Prefix**: `/api/v1/air-quality` · Tag: `Air Quality`
> **File**: `app/api/v1/air_quality.py`
> **Thuật toán**: Nearest station bằng Euclidean distance · Redis cache

### 3.1 Endpoints Table

| Method | Path | Cache | Auth |
|--------|------|-------|------|
| `GET` | `/air-quality/current` | Redis 5 phút | ❌ |
| `GET` | `/air-quality/history` | Không cache | ❌ |
| `GET` | `/air-quality/forecast` | Redis 1 giờ | ❌ |

---

### `GET /air-quality/current`

Lấy AQI hiện tại tại vị trí người dùng. Tìm trạm gần nhất bằng Euclidean distance và trả về reading mới nhất.

**Query Parameters:**

| Param | Type | Required | Validation | Ví dụ |
|-------|------|----------|------------|-------|
| `latitude` | `float` | ✅ | `-90 ≤ lat ≤ 90` | `21.0285` |
| `longitude` | `float` | ✅ | `-180 ≤ lon ≤ 180` | `105.8542` |

**Ví dụ request:**
```
GET /api/v1/air-quality/current?latitude=21.0285&longitude=105.8542
```

**Response 200 OK:**
```json
{
  "aqi": 78,
  "pm25": 23.4,
  "temperature": 28.5,
  "humidity": 72.0,
  "station_name": "Hà Nội - Hoàn Kiếm",
  "recorded_at": "2026-04-26T08:30:00Z"
}
```

| Field | Type | Mô tả |
|-------|------|-------|
| `aqi` | `int` | Chỉ số AQI (0–500) |
| `pm25` | `float \| null` | Nồng độ PM2.5 (µg/m³) |
| `temperature` | `float \| null` | Nhiệt độ (°C) |
| `humidity` | `float \| null` | Độ ẩm (%) |
| `station_name` | `string` | Tên trạm đo gần nhất |
| `recorded_at` | `datetime` | Thời điểm đo (UTC) |

**Cache**: Key `aqi:current:{lat:.2f}:{lon:.2f}` · TTL **300 giây (5 phút)**

**Errors:** `404` nếu không có trạm active hoặc không có dữ liệu.

---

### `GET /air-quality/history`

Lấy lịch sử AQI để vẽ biểu đồ xu hướng. Tìm trạm gần nhất và trả về các readings trong khoảng thời gian chỉ định.

**Query Parameters:**

| Param | Type | Default | Validation | Ví dụ |
|-------|------|---------|------------|-------|
| `latitude` | `float` | - | `-90 ≤ lat ≤ 90` | `21.0285` |
| `longitude` | `float` | - | `-180 ≤ lon ≤ 180` | `105.8542` |
| `hours` | `int` | `24` | `1 ≤ hours ≤ 168` | `48` |

**Ví dụ request:**
```
GET /api/v1/air-quality/history?latitude=21.0285&longitude=105.8542&hours=48
```

**Response 200 OK:**
```json
{
  "station_name": "Hà Nội - Hoàn Kiếm",
  "data": [
    {
      "aqi": 65,
      "pm25": 18.2,
      "recorded_at": "2026-04-24T08:00:00Z"
    },
    {
      "aqi": 72,
      "pm25": 21.0,
      "recorded_at": "2026-04-24T09:00:00Z"
    }
  ]
}
```

**Errors:** `404` nếu không có trạm active.

---

### `GET /air-quality/forecast`

Dự báo AQI 24 giờ tới bằng mô hình **Prophet** (Facebook time-series AI). Training on-the-fly từ 7 ngày dữ liệu lịch sử trong DB.

**Query Parameters:**

| Param | Type | Required | Ví dụ |
|-------|------|----------|-------|
| `latitude` | `float` | ✅ | `10.7769` |
| `longitude` | `float` | ✅ | `106.7009` |

**Response 200 OK:**
```json
{
  "data": [
    {
      "aqi": 71,
      "recorded_at": "2026-04-26T09:00:00Z",
      "is_forecast": true
    },
    {
      "aqi": 68,
      "recorded_at": "2026-04-26T10:00:00Z",
      "is_forecast": true
    }
  ]
}
```

> Trả về **24 data points** (1 per hour, 24 giờ tới). `is_forecast: true` để phân biệt với historical data.

**Cache**: Key `aqi:forecast:{lat:.2f}:{lon:.2f}` · TTL **3600 giây (1 giờ)**

**Errors:** `404` nếu không đủ dữ liệu lịch sử để train model.

---

## 4. Routing Module

> **Prefix**: `/api/v1/routing` · Tag: `Routing`
> **File**: `app/api/v1/routing.py`
> **Thuật toán**: Haversine distance + AQI cost-weighting

### 4.1 Endpoints Table

| Method | Path | Auth |
|--------|------|------|
| `POST` | `/routing/calculate` | ❌ |

---

### `POST /routing/calculate`

Tính **2 tuyến đường** tối ưu giữa 2 điểm: nhanh nhất và sạch nhất (AQI thấp nhất dọc tuyến).

**Cost Formula:**
```
Cost = (distance_km / speed_kmh) × (1 + α × AQI_factor)
```
Trong đó `α = 0.5` (ROUTING_ALPHA), `AQI_factor = station_aqi / 100`

**Request Body:**
```json
{
  "start": {
    "latitude": 21.0285,
    "longitude": 105.8542
  },
  "end": {
    "latitude": 21.0245,
    "longitude": 105.8412
  },
  "mode": "driving"
}
```

| Field | Type | Default | Values |
|-------|------|---------|--------|
| `start` | `Coordinate` | - | `{latitude, longitude}` |
| `end` | `Coordinate` | - | `{latitude, longitude}` |
| `mode` | `TravelMode` | `"driving"` | `"driving"`, `"cycling"`, `"walking"` |

**Response 200 OK:**
```json
{
  "fastest": {
    "route_type": "fastest",
    "total_distance_km": 3.2,
    "total_time_minutes": 12.5,
    "weighted_cost": 18.4,
    "segments": [
      { "distance_km": 1.8, "aqi_factor": 0.72 },
      { "distance_km": 1.4, "aqi_factor": 0.65 }
    ]
  },
  "cleanest": {
    "route_type": "cleanest",
    "total_distance_km": 4.1,
    "total_time_minutes": 16.8,
    "weighted_cost": 15.2,
    "segments": [
      { "distance_km": 2.0, "aqi_factor": 0.45 },
      { "distance_km": 2.1, "aqi_factor": 0.38 }
    ]
  }
}
```

| Field | Mô tả |
|-------|-------|
| `route_type` | `"fastest"` hoặc `"cleanest"` |
| `total_distance_km` | Tổng khoảng cách (km) |
| `total_time_minutes` | Ước tính thời gian di chuyển (phút) |
| `weighted_cost` | Chi phí có trọng số (thấp hơn = tốt hơn) |
| `segments[].aqi_factor` | Hệ số AQI tại đoạn đường đó (station_aqi / 100) |

---

## 5. Health Profile Module

> **Prefix**: `/api/v1/user/health` · Tag: `Health Profile`
> **File**: `app/api/v1/health.py`
> **Service**: `app/services/personalization_service.py`

### 5.1 Endpoints Table

| Method | Path | Auth |
|--------|------|------|
| `POST` | `/user/health/profile` | ✅ JWT |
| `GET` | `/user/health/recommendation` | ✅ JWT |

---

### `POST /user/health/profile`

Tạo hoặc cập nhật hồ sơ sức khỏe. Nếu profile đã tồn tại → **upsert** (ghi đè).

**Request Body:**
```json
{
  "birth_year": 1990,
  "conditions": ["asthma", "heart_disease"],
  "sensitivity_level": 4
}
```

| Field | Type | Default | Validation |
|-------|------|---------|------------|
| `birth_year` | `int \| null` | `null` | `1900 ≤ year ≤ 2025` |
| `conditions` | `string[] \| null` | `[]` | Danh sách bệnh lý |
| `sensitivity_level` | `int` | `3` | `1 ≤ level ≤ 5` |

**`conditions` values thông dụng:**
- `"asthma"` — Hen suyễn
- `"heart_disease"` — Bệnh tim
- `"elderly"` — Người cao tuổi
- `"pregnant"` — Thai phụ
- `"child"` — Trẻ em

**Response 200 OK:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "birth_year": 1990,
  "conditions": ["asthma", "heart_disease"],
  "sensitivity_level": 4
}
```

---

### `GET /user/health/recommendation`

Lấy khuyến nghị sức khỏe cá nhân hóa dựa trên AQI hiện tại và hồ sơ sức khỏe.

**Perceived AQI Formula:**
```
Perceived_AQI = Real_AQI × max(age_weight, condition_weight) × sensitivity_factor
```
Trong đó:
- `age_weight`: Người cao tuổi (>65) → 1.3, Trẻ em (<12) → 1.2
- `condition_weight`: Hen suyễn → 1.4, Tim mạch → 1.3
- `sensitivity_factor`: Level 5 → 1.5, Level 1 → 0.8

**Query Parameters:**

| Param | Type | Required |
|-------|------|----------|
| `latitude` | `float` | ✅ |
| `longitude` | `float` | ✅ |

**Headers:**
```
Accept-Language: vi    (mặc định — tiếng Việt)
Accept-Language: en    (tiếng Anh)
```

**Response 200 OK:**
```json
{
  "real_aqi": 78,
  "perceived_aqi": 109.2,
  "risk_level": "moderate",
  "is_high_risk": false,
  "recommendations": [
    "Hạn chế hoạt động ngoài trời kéo dài",
    "Đeo khẩu trang N95 khi ra ngoài",
    "Bật máy lọc không khí trong nhà"
  ],
  "warning_message": "Người bị hen suyễn cần thận trọng"
}
```

| `risk_level` | AQI Range | Mô tả |
|-------------|-----------|-------|
| `"low"` | 0–50 | Tốt |
| `"moderate"` | 51–100 | Trung bình |
| `"high"` | 101–150 | Không tốt |
| `"very_high"` | 151–200 | Không lành mạnh |
| `"hazardous"` | >200 | Nguy hiểm |

**Errors:** `404` nếu chưa có health profile (cần gọi `POST /user/health/profile` trước).

---

## 6. Community Module

> **Prefix**: `/api/v1/community` · Tag: `Community`
> **File**: `app/api/v1/community.py`
> **Spatial**: PostGIS `GEOMETRY(POINT, 4326)` để lưu vị trí báo cáo

### 6.1 Endpoints Table

| Method | Path | Auth |
|--------|------|------|
| `POST` | `/community/report` | ✅ JWT |
| `GET` | `/community/reports` | ✅ JWT |
| `POST` | `/community/report/{report_id}/verify` | ✅ JWT |

---

### `POST /community/report`

Gửi báo cáo sự cố ô nhiễm. Vị trí được lưu dưới dạng PostGIS Point (`GEOMETRY(POINT, 4326)`). `trust_score` khởi tạo = `0.5`.

**Request Body:**
```json
{
  "incident_type": "burning",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "image_url": "https://storage.airshield.app/reports/abc123.jpg",
  "description": "Đốt rác tại khu công nghiệp, khói đen dày đặc"
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| `incident_type` | `IncidentType` | ✅ | `"burning"`, `"dust"`, `"smoke"`, `"chemical"`, `"other"` |
| `latitude` | `float` | ✅ | `-90 ≤ lat ≤ 90` |
| `longitude` | `float` | ✅ | `-180 ≤ lon ≤ 180` |
| `image_url` | `string \| null` | ❌ | URL ảnh minh chứng |
| `description` | `string \| null` | ❌ | Mô tả chi tiết |

**Response 201 Created:**
```json
{
  "id": 42,
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "incident_type": "burning",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "image_url": "https://storage.airshield.app/reports/abc123.jpg",
  "description": "Đốt rác tại khu công nghiệp",
  "status": "pending",
  "trust_score": 0.5,
  "created_at": "2026-04-26T08:30:00Z"
}
```

---

### `GET /community/reports`

Danh sách báo cáo cộng đồng, sắp xếp mới nhất trước. Hỗ trợ lọc theo trạng thái.

**Query Parameters:**

| Param | Type | Default | Values |
|-------|------|---------|--------|
| `status` | `string` | `null` (all) | `"pending"`, `"verified"`, `"rejected"` |
| `limit` | `int` | `20` | `1 ≤ limit ≤ 100` |

**Ví dụ request:**
```
GET /api/v1/community/reports?status=verified&limit=10
```

**Response 200 OK:**
```json
[
  {
    "id": 42,
    "incident_type": "burning",
    "latitude": 21.0285,
    "longitude": 105.8542,
    "description": "Đốt rác tại khu công nghiệp",
    "status": "verified",
    "trust_score": 0.8,
    "created_at": "2026-04-26T08:30:00Z"
  }
]
```

---

### `POST /community/report/{report_id}/verify`

Xác nhận hoặc bác bỏ một báo cáo. Áp dụng thuật toán **Trust Score**. Người dùng không thể tự verify báo cáo của mình.

**Trust Score Algorithm:**
```
Verify:  trust_score = min(1.0, trust_score + 0.1)
Reject:  trust_score = max(0.0, trust_score - 0.15)

Auto status update:
  trust_score ≥ 0.7  →  status = "verified"
  trust_score ≤ 0.1  →  status = "rejected"
  else               →  status giữ nguyên ("pending")
```

**Path Parameter:** `report_id` (integer)

**Request Body:**
```json
{
  "verified": true,
  "comment": "Đã xác nhận thực tế tại hiện trường"
}
```

| Field | Type | Required |
|-------|------|----------|
| `verified` | `bool` | ✅ |
| `comment` | `string \| null` | ❌ |

**Response 200 OK:**
```json
{
  "report_id": 42,
  "action": "verified",
  "new_trust_score": 0.6,
  "new_status": "pending",
  "comment": "Đã xác nhận thực tế tại hiện trường"
}
```

**Errors:**
| Code | Condition |
|------|-----------|
| `400` | Tự verify báo cáo của mình |
| `404` | Báo cáo không tồn tại |

---

## 7. Smart Home Module

> **Prefix**: `/api/v1/smart-home` · Tag: `Smart Home`
> **File**: `app/api/v1/smart_home.py`
> **Adapter**: `app/services/device_adapters/tuya_adapter.py` (Tuya IoT Platform)

### 7.1 Endpoints Table

| Method | Path | Auth |
|--------|------|------|
| `GET` | `/smart-home/devices` | ✅ JWT |
| `POST` | `/smart-home/devices` | ✅ JWT |
| `POST` | `/smart-home/devices/{device_id}/command` | ✅ JWT |

---

### `GET /smart-home/devices`

Lấy danh sách tất cả thiết bị IoT đã đăng ký của user hiện tại.

**Response 200 OK:**
```json
[
  {
    "device_id": "bf3da901234abcd5678",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "provider": "tuya",
    "device_name": "Máy lọc không khí phòng ngủ",
    "is_active": true
  }
]
```

---

### `POST /smart-home/devices`

Đăng ký thiết bị IoT mới cho user. Device ID phải là ID thật từ Tuya/provider.

**Request Body:**
```json
{
  "device_id": "bf3da901234abcd5678",
  "provider": "tuya",
  "access_token": "tuya_access_token_here",
  "device_name": "Máy lọc không khí phòng ngủ"
}
```

| Field | Type | Default | Mô tả |
|-------|------|---------|-------|
| `device_id` | `string` | - | ID thiết bị từ Tuya platform |
| `provider` | `string` | - | Hiện chỉ hỗ trợ `"tuya"` |
| `access_token` | `string \| null` | `null` | Tuya access token |
| `device_name` | `string` | `"Air Purifier"` | Tên hiển thị |

**Response 200 OK:** (DeviceResponse như trên)

**Errors:** `400` nếu device_id đã được đăng ký.

---

### `POST /smart-home/devices/{device_id}/command`

Gửi lệnh điều khiển thiết bị. Backend gọi Tuya IoT Platform API với HMAC-SHA256 authentication.

**Tuya API Flow:**
```
AirShield → POST https://openapi.tuyaus.com/v1.0/devices/{id}/commands
           (HMAC-SHA256 signed với client_id + client_secret)
```

**Path Parameter:** `device_id` (string, Tuya device ID)

**Request Body:**
```json
{
  "command": "set_mode",
  "value": "turbo"
}
```

**Các lệnh hỗ trợ:**

| `command` | `value` type | Ví dụ | Mô tả |
|-----------|-------------|-------|-------|
| `"power"` | `string` | `"on"` / `"off"` | Bật/tắt thiết bị |
| `"set_mode"` | `string` | `"auto"`, `"turbo"`, `"sleep"` | Chế độ hoạt động |
| `"set_speed"` | `int` | `1`–`5` | Tốc độ quạt |
| `"set_timer"` | `int` | `60` | Hẹn giờ (phút) |

**Response 200 OK:**
```json
{
  "success": true,
  "device_id": "bf3da901234abcd5678",
  "command": "set_mode",
  "message": "Command sent successfully"
}
```

**Errors:**
| Code | Condition |
|------|-----------|
| `400` | Thiết bị đang inactive |
| `404` | Thiết bị không thuộc user này |
| `501` | Provider không được hỗ trợ (chỉ hỗ trợ `tuya`) |

---

## 8. AI Chatbot Module

> **Prefix**: `/api/v1/chatbot` · Tag: `AI Chatbot`
> **File**: `app/api/v1/chatbot.py`
> **AI**: Google Gemini `gemini-1.5-flash` · **Storage**: Redis (TTL 24h)

### 8.1 Endpoints Table

| Method | Path | Auth |
|--------|------|------|
| `POST` | `/chatbot/chat` | ✅ JWT |
| `GET` | `/chatbot/sessions` | ✅ JWT |
| `GET` | `/chatbot/sessions/{session_id}` | ✅ JWT |
| `DELETE` | `/chatbot/sessions/{session_id}` | ✅ JWT |

---

### `POST /chatbot/chat`

Gửi tin nhắn tới AI chatbot (Gemini). Chatbot có thể:
- Trả lời câu hỏi về chất lượng không khí
- Đề xuất khuyến nghị sức khỏe
- Gợi ý điều khiển thiết bị thông minh
- Cung cấp tư vấn cá nhân hóa

**Session Management:**
- `session_id = null` → tạo session mới, trả về `session_id` mới
- `session_id = "abc-123"` → tiếp tục conversation hiện có
- Session lưu trong Redis với TTL **24 giờ**

**Request Body:**
```json
{
  "message": "Chất lượng không khí hôm nay thế nào?",
  "session_id": "abc-123-def-456",
  "latitude": 21.0285,
  "longitude": 105.8542,
  "include_aqi_context": true
}
```

| Field | Type | Default | Mô tả |
|-------|------|---------|-------|
| `message` | `string` | - | Tin nhắn (1–2000 ký tự) |
| `session_id` | `string \| null` | `null` | ID session (null = tạo mới) |
| `latitude` | `float \| null` | `null` | Vĩ độ người dùng |
| `longitude` | `float \| null` | `null` | Kinh độ người dùng |
| `include_aqi_context` | `bool` | `true` | Tự động inject AQI data vào context |

**Response 200 OK:**
```json
{
  "session_id": "abc-123-def-456",
  "message": "Chất lượng không khí hiện tại ở Hà Nội là Trung bình (AQI: 78). PM2.5 đang ở mức 23.4 µg/m³. Khuyến nghị hạn chế hoạt động ngoài trời kéo dài.",
  "action": {
    "action_type": "show_aqi",
    "payload": { "aqi": 78 }
  },
  "sources": ["IQAir API - Hoàn Kiếm Station"],
  "timestamp": "2026-04-26T08:30:00Z"
}
```

**`action_type` values:**

| Value | Hành động mobile app |
|-------|---------------------|
| `"none"` | Chỉ hiển thị text |
| `"show_aqi"` | Navigate đến màn hình AQI |
| `"show_map"` | Mở bản đồ ô nhiễm |
| `"control_device"` | Gửi lệnh đến thiết bị |
| `"navigate_to"` | Điều hướng đến screen khác |

---

### `GET /chatbot/sessions`

Lấy danh sách tất cả session chat của user hiện tại (từ Redis).

**Response 200 OK:**
```json
[
  {
    "id": "abc-123-def-456",
    "title": "Hỏi về AQI Hà Nội",
    "created_at": "2026-04-26T08:00:00Z",
    "updated_at": "2026-04-26T08:30:00Z",
    "message_count": 6
  }
]
```

---

### `GET /chatbot/sessions/{session_id}`

Lấy toàn bộ lịch sử tin nhắn của một session.

**Response 200 OK:**
```json
{
  "session_id": "abc-123-def-456",
  "messages": [
    { "role": "user", "content": "Chất lượng không khí hôm nay thế nào?" },
    { "role": "assistant", "content": "Chất lượng không khí hiện tại ở Hà Nội là Trung bình..." }
  ],
  "message_count": 2
}
```

**Errors:** `404` nếu session không tồn tại.

---

### `DELETE /chatbot/sessions/{session_id}`

Xóa session và toàn bộ lịch sử tin nhắn khỏi Redis.

**Response 200 OK:**
```json
{
  "message": "Session 'abc-123-def-456' deleted successfully"
}
```

**Errors:** `404` nếu session không tồn tại.

---

## 9. Authentication Flow (JWT)

### 9.1 Luồng Đăng Ký / Đăng Nhập

```
┌─────────┐     POST /auth/register      ┌─────────┐
│  Client  │ ───────────────────────────► │ Backend │
│         │  {email, password, full_name} │         │
│         │                               │  1. Check duplicate email
│         │                               │  2. bcrypt hash password
│         │                               │  3. INSERT INTO users
│         │                               │  4. Create JWT (HS256)
│         │ ◄─────────────────────────── │         │
│         │    {access_token, user}        │         │
└─────────┘                               └─────────┘

┌─────────┐     POST /auth/login         ┌─────────┐
│  Client  │ ───────────────────────────► │ Backend │
│         │  form: username=email,         │         │
│         │         password=...           │  1. Lookup user by email
│         │                               │  2. bcrypt verify password
│         │                               │  3. Check is_active = True
│         │                               │  4. Create JWT (HS256)
│         │ ◄─────────────────────────── │         │
│         │    {access_token, user}        │         │
└─────────┘                               └─────────┘
```

### 9.2 Sử Dụng Token

Sau khi có token, thêm vào **mọi request** tới protected endpoints:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBl...
```

### 9.3 Cấu Trúc JWT Payload

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "exp": 1745625600,
  "iat": 1745020800
}
```

| Claim | Nội dung |
|-------|---------|
| `sub` | UUID của user |
| `exp` | Hết hạn — **7 ngày** từ lúc tạo |
| `iat` | Thời điểm tạo token |

**Config JWT:**
```
Algorithm : HS256
Expiry    : 60 × 24 × 7 = 10080 phút = 7 ngày
Secret Key: settings.SECRET_KEY (từ .env)
Token URL : /api/v1/auth/login
```

### 9.4 Xử Lý Token Hết Hạn

```
Request với token hết hạn
        │
        ▼
Backend trả về 401 Unauthorized
{
  "detail": "Could not validate credentials"
}
        │
        ▼
Mobile app phát hiện 401
        │
        ▼
Chuyển hướng user về màn hình Login
(không có refresh token — phải đăng nhập lại)
```

> **Lưu ý**: Hệ thống hiện không có **refresh token**. Khi token hết hạn (sau 7 ngày), user phải đăng nhập lại.

### 9.5 Xác Thực Trong Code

```python
# Dependency được inject vào protected endpoints
from app.core.auth import get_current_active_user

@router.get("/profile")
async def get_profile(
    current_user: User = Depends(get_current_active_user)
):
    # current_user đã được xác thực và active
    return current_user
```

**Quy trình kiểm tra:**
1. Trích xuất token từ `Authorization: Bearer <token>`
2. Decode JWT với `SECRET_KEY` + `HS256`
3. Lấy `user_id` từ claim `sub`
4. Query DB: `SELECT * FROM users WHERE id = user_id`
5. Kiểm tra `is_active = True`
6. Inject `current_user` vào handler

---

## 10. Rate Limiting & Caching

### 10.1 Rate Limiting

| Endpoint Category | Giới hạn | Scope |
|------------------|---------|-------|
| Auth (login/register) | **5 req/phút** | Per IP |
| AI Chatbot | **20 req/phút** | Per user |
| Public (AQI, forecast) | **60 req/phút** | Per user |
| Authenticated (khác) | **120 req/phút** | Per user |

> Khi vượt giới hạn: `429 Too Many Requests`

### 10.2 Redis Cache Strategy

| Endpoint | Cache Key Pattern | TTL | Ghi chú |
|----------|------------------|-----|---------|
| `GET /air-quality/current` | `aqi:current:{lat:.2f}:{lon:.2f}` | **300s (5 phút)** | Rounded 2dp ≈ 1.1km |
| `GET /air-quality/forecast` | `aqi:forecast:{lat:.2f}:{lon:.2f}` | **3600s (1 giờ)** | Prophet training tốn kém |
| `GET /air-quality/history` | *(không cache)* | - | Query trực tiếp DB |
| Chat sessions | `chat:sessions:{user_id}` | **86400s (24 giờ)** | Auto-expire khi inactive |
| Chat messages | `chat:session:{session_id}:messages` | **86400s (24 giờ)** | Toàn bộ conversation |

### 10.3 Cache Pattern Chuẩn

```python
# 1. Thử đọc cache
cache_key = f"aqi:current:{latitude:.2f}:{longitude:.2f}"
cached = await redis.get(cache_key)
if cached:
    return AirQualityResponse(**json.loads(cached))

# 2. Fallback: query DB
data = await fetch_from_db(...)

# 3. Ghi vào cache (setex = set + expire)
payload = data.model_dump()
await redis.setex(cache_key, settings.CACHE_TTL_AQI, json.dumps(payload))
return data
```

### 10.4 Cache Miss Scenarios

| Tình huống | Hành động |
|-----------|-----------|
| Redis không khả dụng | Log warning, query DB trực tiếp (graceful degradation) |
| Cache miss bình thường | Query DB, ghi cache cho lần sau |
| Data stale trong cache | Tự động expire theo TTL |

---

## 11. Error Response Format

### 11.1 Chuẩn Error Response

```json
{
  "detail": "Email already registered",
  "status_code": 400,
  "error_code": "EMAIL_DUPLICATE"
}
```

### 11.2 Pydantic Validation Error (422)

```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    },
    {
      "loc": ["body", "sensitivity_level"],
      "msg": "ensure this value is less than or equal to 5",
      "type": "value_error.number.not_le",
      "ctx": { "limit_value": 5 }
    }
  ]
}
```

### 11.3 HTTP Status Code Summary

| Code | Khi nào |
|------|---------|
| `200 OK` | GET/PUT/PATCH thành công |
| `201 Created` | POST tạo resource thành công |
| `204 No Content` | DELETE thành công (không áp dụng hiện tại) |
| `400 Bad Request` | Business logic error (email duplicate, inactive account...) |
| `401 Unauthorized` | Thiếu/sai/hết hạn JWT |
| `403 Forbidden` | Không có quyền (ví dụ: verify báo cáo của chính mình) |
| `404 Not Found` | Resource không tồn tại |
| `422 Unprocessable` | Pydantic validation failed (sai type, thiếu field) |
| `429 Too Many Requests` | Rate limit exceeded |
| `501 Not Implemented` | Provider chưa được hỗ trợ |
| `500 Internal Server Error` | Server error không mong muốn |

---

## Phụ Lục: Sequence Diagrams

### A. AQI Request với Cache

```
Mobile        Backend        Redis         PostgreSQL
  │                │              │               │
  │─ GET /current ─►              │               │
  │                │─ GET key ───►│               │
  │                │◄─ HIT ───────│               │
  │◄─ 200 (cached)─│              │               │
  │                │              │               │
  │─ GET /current ─►              │               │ (cache miss)
  │                │─ GET key ───►│               │
  │                │◄─ MISS ──────│               │
  │                │─────────────────── SELECT ──►│
  │                │◄─────────────────── rows ────│
  │                │─ SETEX ─────►│               │
  │◄─ 200 (fresh) ─│              │               │
```

### B. Chat với AI

```
Mobile          Backend          Redis           Gemini API
  │                │               │                 │
  │─ POST /chat ──►│               │                 │
  │  {message,     │               │                 │
  │   session_id}  │─ GET history ►│                 │
  │                │◄─ messages ───│                 │
  │                │               │                 │
  │                │─ send context + history ────────►│
  │                │◄─────────────────── AI response ─│
  │                │               │                 │
  │                │─ RPUSH msg ──►│                 │
  │                │─ EXPIRE 24h ─►│                 │
  │◄─ 200 response─│               │                 │
```

### C. IoT Device Command

```
Mobile          Backend          Tuya Cloud
  │                │                 │
  │─ POST /command►│                 │
  │  {command,val} │                 │
  │                │ Verify device   │
  │                │ belongs to user │
  │                │                 │
  │                │─ HMAC-SHA256 ──►│
  │                │  signed request │
  │                │◄─ result ───────│
  │◄─ 200 result ──│                 │
```

---

*Tài liệu này được tạo tự động từ source code của AirShield Backend.*
*Source: `app/api/v1/`, `app/schemas/`, `app/core/`*
