# API Conventions — AirShield

> Tài liệu nền tảng. Được tham chiếu bởi: `commands/review.md`, `skills/security-review/SKILL.md`.

---

## PHẦN 1: URL & Versioning

### 1.1 Cấu trúc URL

```
/api/v1/{module}/{resource}
/api/v1/{module}/{resource}/{id}
/api/v1/{module}/{resource}/{id}/{sub-resource}
```

- Tất cả endpoints **PHẢI** nằm trong `/api/v1/`
- Breaking changes → tạo `/api/v2/` mới, **giữ v1 hoạt động**

### 1.2 Module Prefixes

| Module | Prefix | Ví dụ |
|--------|--------|-------|
| AQS | `/api/v1/air-quality/` | `/api/v1/air-quality/current` |
| Forecast | `/api/v1/air-quality/forecast` | `?days=7` |
| Auth | `/api/v1/auth/` | `/api/v1/auth/login` |
| DPS | `/api/v1/user/health/` | `/api/v1/user/health/profile` |
| ACB | `/api/v1/chatbot/` | `/api/v1/chatbot/chat` |
| SHA | `/api/v1/smart-home/` | `/api/v1/smart-home/devices` |
| CGS | `/api/v1/community/` | `/api/v1/community/report` |
| Routing | `/api/v1/routing/` | `/api/v1/routing/calculate` |

---

## PHẦN 2: HTTP Methods & Status Codes

### 2.1 HTTP Methods

| Method | Dùng cho | Idempotent |
|--------|---------|------------|
| `GET` | Đọc resource | ✅ |
| `POST` | Tạo resource mới | ❌ |
| `PUT` | Update toàn bộ | ✅ |
| `PATCH` | Update một phần | ❌ |
| `DELETE` | Xóa resource | ✅ |

### 2.2 HTTP Status Codes

| Code | Khi nào dùng |
|------|-------------|
| `200 OK` | GET/PUT/PATCH thành công |
| `201 Created` | POST tạo resource thành công |
| `204 No Content` | DELETE thành công |
| `400 Bad Request` | Input validation failed |
| `401 Unauthorized` | Thiếu/sai JWT token |
| `403 Forbidden` | Không có quyền |
| `404 Not Found` | Resource không tồn tại |
| `409 Conflict` | Duplicate (email đã tồn tại) |
| `422 Unprocessable` | Pydantic validation error |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Server error |

---

## PHẦN 3: Request & Response Format

### 3.1 Request Body

```python
# BẮT BUỘC dùng Pydantic schema
from pydantic import BaseModel, ConfigDict

class DeviceCommandRequest(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    command: str
    parameters: dict | None = None
```

### 3.2 Response Format

```json
// Success
{ "status": "success", "data": {}, "message": "..." }

// Success (list)
{ "status": "success", "data": [], "pagination": { "page": 1, "per_page": 20, "total": 100, "total_pages": 5 } }

// Error
{ "detail": "Device not found", "status_code": 404, "error_code": "DEVICE_NOT_FOUND" }
```

### 3.3 Query Parameters

```
# Filtering
GET /api/v1/air-quality/history?city=Hanoi&from=2024-01-01&to=2024-01-31

# Pagination
GET /api/v1/community/reports?page=1&per_page=20

# Sorting
GET /api/v1/smart-home/devices?sort_by=name&order=asc
```

---

## PHẦN 4: Authentication

### 4.1 Protected Endpoints (cần JWT)

```python
from app.core.auth import get_current_user

@router.get("/profile")
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user
```

### 4.2 Public Endpoints (không cần auth)

```python
@router.get("/air-quality/current")
async def get_current_aqi(city: str):
    ...
```

### 4.3 JWT Token

```
Authorization: Bearer <access_token>
```

---

## PHẦN 5: Caching (Redis)

### 5.1 TTL Policy

| Data | Cache Key | TTL |
|------|-----------|-----|
| AQI data | `aqi:{city}:{lat}:{lon}` | 5 phút |
| Forecast | `forecast:{city}:{days}` | 1 giờ |
| User profile | `user:{user_id}:profile` | 30 phút |
| Device list | `devices:{user_id}` | 2 phút |

### 5.2 Cache Pattern Chuẩn

```python
cache_key = f"aqi:{city}"
cached = await redis.get(cache_key)
if cached:
    return json.loads(cached)

data = await fetch_fresh_data()
await redis.setex(cache_key, 300, json.dumps(data))  # TTL 5 min
return data
```

---

## PHẦN 6: Security Config

### 6.1 Rate Limiting

| Endpoint | Giới hạn |
|---------|---------|
| Auth (login) | 5 req/min per IP |
| Chatbot | 20 req/min per user |
| Public (AQI) | 60 req/min per user |
| Authenticated | 120 req/min per user |

### 6.2 CORS

```python
# Development
origins = ["http://localhost:3000", "http://localhost:8080"]

# Production — KHÔNG dùng "*"
origins = ["https://airshield.app", "https://api.airshield.app"]
```
