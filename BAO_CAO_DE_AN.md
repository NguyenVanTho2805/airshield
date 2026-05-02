# BÁO CÁO ĐỀ ÁN TỐT NGHIỆP

---

## AIRSHIELD — NỀN TẢNG GIÁM SÁT CHẤT LƯỢNG KHÔNG KHÍ VÀ ĐIỀU KHIỂN NHÀ THÔNG MINH

---

## CHƯƠNG 1: TỔNG QUAN ĐỀ TÀI

### 1.1 Giới thiệu

AirShield là nền tảng giám sát chất lượng không khí thông minh tích hợp công nghệ IoT, trí tuệ nhân tạo và ứng dụng di động. Hệ thống thu thập dữ liệu AQI (Air Quality Index) theo thời gian thực từ các trạm quan trắc, phân tích và đưa ra khuyến cáo sức khỏe cá nhân hóa, đồng thời cho phép điều khiển thiết bị lọc không khí thông minh trong nhà.

### 1.2 Mục tiêu đề tài

| STT | Mục tiêu |
|-----|----------|
| 1 | Xây dựng hệ thống thu thập và hiển thị AQI theo thời gian thực |
| 2 | Dự báo chất lượng không khí 24 giờ tới bằng mô hình Prophet |
| 3 | Cá nhân hóa khuyến cáo sức khỏe dựa trên hồ sơ người dùng |
| 4 | Tìm tuyến đường ít ô nhiễm nhất (Clean Routing) |
| 5 | Cho phép người dùng báo cáo sự cố ô nhiễm cộng đồng |
| 6 | Điều khiển thiết bị IoT (máy lọc không khí) qua mobile app |
| 7 | Tích hợp trợ lý AI (chatbot) hỗ trợ tư vấn sức khỏe |

### 1.3 Phạm vi

- **Backend:** REST API phục vụ mobile app và các client khác
- **Mobile:** Ứng dụng Android/iOS viết bằng Flutter
- **Dữ liệu:** Tập trung vào 5 thành phố lớn tại Việt Nam
- **Thiết bị:** Hỗ trợ thiết bị Tuya IoT (máy lọc không khí)

---

## CHƯƠNG 2: PHÂN TÍCH YÊU CẦU

### 2.1 Yêu cầu chức năng

#### Module AQS — Air Quality Service
- Hiển thị AQI hiện tại theo vị trí GPS
- Xem lịch sử AQI 24h, 7 ngày
- Xem dự báo AQI 24 giờ tới
- Xem bản đồ chất lượng không khí

#### Module DPS — Deep Personalization Service
- Tạo hồ sơ sức khỏe (năm sinh, bệnh lý, mức độ nhạy cảm)
- Nhận khuyến cáo cá nhân hóa theo AQI cảm nhận

#### Module CGS — Community & Gamification Service
- Gửi báo cáo sự cố ô nhiễm kèm ảnh và vị trí
- Xem danh sách sự cố từ cộng đồng
- Hệ thống điểm tin cậy (trust score)

#### Module SHA — Smart Home Automation
- Đăng ký, quản lý thiết bị IoT
- Gửi lệnh điều khiển (bật/tắt, chế độ)
- Tạo quy tắc tự động theo AQI

#### Module ACB — AI Chatbot
- Hỏi đáp về chất lượng không khí
- Nhận tư vấn sức khỏe từ AI
- Điều khiển thiết bị qua hội thoại
- Nhập liệu bằng giọng nói

#### Module Routing
- Tính tuyến đường nhanh nhất và sạch nhất
- So sánh thời gian và mức độ phơi nhiễm

### 2.2 Yêu cầu phi chức năng

| Yêu cầu | Chỉ tiêu |
|---------|---------|
| Hiệu năng API | Response time < 500ms (non-forecast) |
| Cache AQI | TTL 5 phút (Redis) |
| Bảo mật | JWT HS256, bcrypt password hashing |
| Khả dụng | Backend uptime ≥ 99% |
| Offline | Mobile app hiển thị dữ liệu cache khi mất mạng |
| Đa ngôn ngữ | Tiếng Việt + Tiếng Anh |

---

## CHƯƠNG 3: KIẾN TRÚC HỆ THỐNG

### 3.1 Kiến trúc tổng thể

```
┌───────────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE APP                         │
│   Dashboard · Map · SmartHome · Chatbot · Profile · Auth     │
│              BLoC Pattern + Repository Pattern                │
└──────────────────────────┬────────────────────────────────────┘
                           │ HTTPS / JWT
                           ▼
┌───────────────────────────────────────────────────────────────┐
│                    FASTAPI BACKEND                            │
│  /auth  /air-quality  /routing  /health  /community  /chatbot│
│                  Async · Pydantic v2 · JWT                   │
└──────────────────────────┬────────────────────────────────────┘
                           │
          ┌────────────────┼──────────────────┐
          ▼                ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐
│  PostgreSQL  │  │    Redis     │  │    External APIs     │
│   PostGIS    │  │   Cache      │  │ IQAir · Gemini · Tuya│
│  (Port 5432) │  │  (Port 6379) │  │ Firebase · GGMaps    │
└──────────────┘  └──────────────┘  └──────────────────────┘
```

### 3.2 Kiến trúc Backend (FastAPI)

```
app/
├── api/v1/          ← Tầng giao tiếp (Router)
├── services/        ← Tầng nghiệp vụ (Business Logic)
├── models/          ← Tầng dữ liệu (SQLAlchemy ORM)
├── schemas/         ← Tầng xác thực (Pydantic)
├── core/            ← Hạ tầng (Config, DB, Redis, Auth)
└── tasks/           ← Tác vụ nền (APScheduler)
```

### 3.3 Kiến trúc Mobile (Flutter — Clean Architecture)

```
lib/
├── features/        ← Tính năng (Clean Architecture)
│   └── feature_x/
│       ├── data/        (datasource, model, repository impl)
│       ├── domain/      (entity, repository contract, usecase)
│       └── presentation/ (bloc, page, widget)
└── core/            ← Hạ tầng dùng chung
    ├── network/     (ApiClient — Dio)
    ├── storage/     (SecureStorage, PreferencesStorage)
    ├── services/    (LocationService)
    ├── theme/       (ThemeBloc, AppTheme)
    └── l10n/        (vi, en)
```

---

## CHƯƠNG 4: THIẾT KẾ CƠ SỞ DỮ LIỆU

### 4.1 Sơ đồ quan hệ thực thể (ERD)

```
users
  │ id (UUID, PK)
  │ email (unique)
  │ hashed_password
  │ full_name
  │ role: USER | ADMIN
  │ fcm_token
  └── 1:1 ──► health_profiles (user_id FK)
  └── 1:N ──► user_devices (user_id FK)
  └── 1:N ──► automation_rules (user_id FK)
  └── 1:N ──► community_reports (user_id FK)

stations
  │ id (INT, PK)
  │ name
  │ source: IQAIR | PAMAIR
  │ latitude, longitude
  │ is_active
  └── 1:N ──► air_quality_logs (station_id FK)

air_quality_logs
  │ id (INT, PK)
  │ station_id (FK)
  │ aqi, pm25, temperature, humidity
  │ recorded_at
  INDEX (station_id, recorded_at)

health_profiles
  │ user_id (UUID, PK = FK → users)
  │ birth_year
  │ conditions: ARRAY[string]
  │ sensitivity_level: 1–5

user_devices
  │ device_id (STRING, PK)
  │ user_id (FK)
  │ provider: tuya | xiaomi | samsung...
  │ device_name, access_token
  │ current_filter_life (0–100%)

automation_rules
  │ id (INT, PK)
  │ user_id (FK)
  │ trigger_metric: outdoor_aqi | pm25
  │ threshold_value
  │ action_payload: JSON

community_reports
  │ id (INT, PK)
  │ user_id (FK)
  │ incident_type: BURNING|DUST|SMOKE|CHEMICAL|OTHER
  │ geom: PostGIS POINT(4326)
  │ image_url, description
  │ status: PENDING|VERIFIED|REJECTED
  │ trust_score: 0.0–1.0
```

### 4.2 Mô tả các bảng

#### Bảng `users`
| Trường | Kiểu | Mô tả |
|--------|------|-------|
| id | UUID | Khóa chính, tự sinh |
| email | VARCHAR(255) | Unique, indexed |
| hashed_password | VARCHAR(255) | bcrypt |
| full_name | VARCHAR(255) | Nullable |
| role | ENUM | USER / ADMIN |
| is_active | BOOLEAN | Mặc định True |
| fcm_token | VARCHAR(512) | Firebase push token |
| created_at | TIMESTAMPTZ | UTC |

#### Bảng `stations`
| Trường | Kiểu | Mô tả |
|--------|------|-------|
| id | INTEGER | Khóa chính, tự tăng |
| name | VARCHAR(255) | Tên trạm |
| source | ENUM | IQAIR / PAMAIR |
| latitude | FLOAT | Vĩ độ |
| longitude | FLOAT | Kinh độ |
| is_active | BOOLEAN | Trạng thái hoạt động |

#### Bảng `air_quality_logs`
| Trường | Kiểu | Mô tả |
|--------|------|-------|
| id | INTEGER | Khóa chính |
| station_id | INTEGER | FK → stations |
| aqi | INTEGER | Chỉ số AQI |
| pm25 | FLOAT | Nồng độ PM2.5 |
| temperature | FLOAT | Nhiệt độ (°C) |
| humidity | FLOAT | Độ ẩm (%) |
| recorded_at | TIMESTAMPTZ | Thời điểm ghi nhận |

#### Bảng `health_profiles`
| Trường | Kiểu | Mô tả |
|--------|------|-------|
| user_id | UUID | PK = FK → users |
| birth_year | INTEGER | Năm sinh |
| conditions | ARRAY(TEXT) | Danh sách bệnh lý |
| sensitivity_level | INTEGER | Mức nhạy cảm 1–5 |

#### Bảng `community_reports`
| Trường | Kiểu | Mô tả |
|--------|------|-------|
| id | INTEGER | Khóa chính |
| user_id | UUID | FK → users |
| incident_type | ENUM | Loại sự cố |
| geom | GEOMETRY(POINT, 4326) | Tọa độ PostGIS |
| image_url | TEXT | URL ảnh |
| status | ENUM | PENDING/VERIFIED/REJECTED |
| trust_score | FLOAT | Điểm tin cậy 0.0–1.0 |

### 4.3 Chiến lược Caching (Redis)

| Dữ liệu | Cache Key | TTL |
|---------|-----------|-----|
| AQI hiện tại | `aqi:current:{lat:.2f}:{lon:.2f}` | 5 phút |
| Dự báo AQI | `aqi:forecast:{lat:.2f}:{lon:.2f}` | 60 phút |
| Chat session | `chat_session:{session_id}` | 24 giờ |

---

## CHƯƠNG 5: THIẾT KẾ API

### 5.1 Quy ước chung

- Base URL: `http://host:8000/api/v1`
- Authentication: `Authorization: Bearer <JWT_TOKEN>`
- Content-Type: `application/json`
- Phiên bản: tất cả endpoint nằm trong `/api/v1/`

### 5.2 Danh sách API Endpoints

#### Authentication (`/auth`)

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/auth/register` | Đăng ký tài khoản | Không |
| POST | `/auth/login` | Đăng nhập | Không |
| GET | `/auth/me` | Thông tin user hiện tại | Có |
| PUT | `/auth/me/fcm-token` | Cập nhật FCM token | Có |

#### Air Quality (`/air-quality`)

| Method | Endpoint | Mô tả | Cache |
|--------|----------|-------|-------|
| GET | `/air-quality/current` | AQI hiện tại | 5 phút |
| GET | `/air-quality/history` | Lịch sử AQI | 10 phút |
| GET | `/air-quality/forecast` | Dự báo 24h (Prophet) | 60 phút |

**Tham số truy vấn:**
```
GET /api/v1/air-quality/current?latitude=21.0285&longitude=105.8542
GET /api/v1/air-quality/history?latitude=21.0285&longitude=105.8542&hours=24
GET /api/v1/air-quality/forecast?latitude=21.0285&longitude=105.8542
```

#### Health Profile (`/user/health`)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/user/health/profile` | Tạo/cập nhật hồ sơ sức khỏe |
| GET | `/user/health/recommendation` | Khuyến cáo cá nhân hóa |

#### Community (`/community`)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/community/report` | Gửi báo cáo sự cố |
| GET | `/community/reports` | Danh sách sự cố |
| POST | `/community/report/{id}/verify` | Xác minh sự cố |

#### Smart Home (`/smart-home`)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/smart-home/devices` | Danh sách thiết bị |
| POST | `/smart-home/devices` | Thêm thiết bị |
| POST | `/smart-home/devices/{id}/command` | Gửi lệnh điều khiển |

**Ví dụ lệnh điều khiển:**
```json
{ "command": "power",    "value": "on"    }
{ "command": "set_mode", "value": "turbo" }
{ "command": "set_speed","value": 5       }
```

#### Chatbot (`/chatbot`)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/chatbot/chat` | Gửi tin nhắn AI |
| GET | `/chatbot/sessions` | Danh sách phiên chat |
| GET | `/chatbot/sessions/{id}` | Lịch sử phiên chat |
| DELETE | `/chatbot/sessions/{id}` | Xóa phiên chat |

#### Routing (`/routing`)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/routing/calculate` | Tính tuyến nhanh & sạch nhất |

---

## CHƯƠNG 6: CÁC THUẬT TOÁN VÀ MÔ HÌNH

### 6.1 Dự báo AQI — Prophet Model

**Quy trình:**
1. Truy vấn dữ liệu lịch sử 7 ngày từ trạm gần nhất
2. Chuẩn bị DataFrame theo định dạng Prophet (`ds`, `y`)
3. Train mô hình với: weekly + daily seasonality, changepoint_prior = 0.05
4. Dự báo 24 giờ tới
5. Giới hạn AQI dự báo trong khoảng [0, 500]
6. Cache kết quả trong Redis 1 giờ

**Fallback:** Nếu dữ liệu < 10 bản ghi → mock forecast với biến động ngẫu nhiên

### 6.2 AQI Cảm nhận — Deep Personalization

**Công thức:**
```
AQI_cảm_nhận = AQI_thực × max(Trọng_số_tuổi, Trọng_số_bệnh) × Hệ_số_nhạy_cảm
```

**Trọng số bệnh lý:**

| Bệnh lý | Trọng số |
|---------|---------|
| COPD | 2.8 |
| Hen suyễn | 2.5 |
| Tim mạch | 2.2 |
| Viêm xoang | 1.8 |
| Dị ứng | 1.5 |
| Phụ nữ mang thai | 1.6 |
| Người cao tuổi (>65) | 1.5 |
| Trẻ em (<12) | 1.3 |
| Người bình thường | 1.0 |

**Hệ số nhạy cảm:** Mức 1→5 tương ứng 0.8→1.2

**Phân loại mức rủi ro:**

| AQI cảm nhận | Mức rủi ro |
|---|---|
| 0–50 | Thấp (LOW) |
| 51–100 | Trung bình (MODERATE) |
| 101–150 | Cao (HIGH) |
| 151–200 | Rất cao (VERY_HIGH) |
| 201+ | Nguy hiểm (HAZARDOUS) |

### 6.3 Clean Routing — Tuyến đường ít ô nhiễm nhất

**Công thức chi phí tuyến đường:**
```
Cost = (Distance_km / Speed_kmh) × (1 + α × AQI_Factor)

α         = 0.5  (trọng số ô nhiễm, cấu hình qua ROUTING_ALPHA)
AQI_Factor = giá trị chuẩn hóa AQI (0.0 = sạch, 1.0 = ô nhiễm nặng)
```

**So sánh hai tuyến:**

| | Tuyến nhanh nhất | Tuyến sạch nhất |
|-|--|--|
| Loại đường | Đường chính | Đường nhỏ, công viên |
| AQI_Factor | 0.5 | 0.15 |
| Tối ưu | Thời gian di chuyển | Mức phơi nhiễm |

### 6.4 Community Trust Score

```
Xác minh : trust_score += 0.1   (tối đa 1.0)
Bác bỏ   : trust_score -= 0.15  (tối thiểu 0.0)

Ngưỡng VERIFIED  : trust_score ≥ 0.7
Ngưỡng REJECTED  : trust_score ≤ 0.1
```

---

## CHƯƠNG 7: CÔNG NGHỆ SỬ DỤNG

### 7.1 Backend

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|---------|
| Python | 3.11+ | Ngôn ngữ chính |
| FastAPI | ≥0.109 | Web framework async |
| SQLAlchemy | ≥2.0 | ORM async |
| PostgreSQL | 15 | Cơ sở dữ liệu quan hệ |
| PostGIS | — | Dữ liệu địa lý |
| Redis | 7 | In-memory cache |
| Prophet | ≥1.1.5 | Dự báo chuỗi thời gian |
| Google Gemini | gemini-1.5-flash | LLM cho AI Chatbot |
| APScheduler | ≥3.10 | Background task scheduler |
| Alembic | ≥1.13 | Database migrations |
| python-jose | ≥3.3 | JWT authentication |
| passlib/bcrypt | ≥1.7.4 | Password hashing |
| httpx | ≥0.27 | Async HTTP client |
| firebase-admin | ≥6.4 | Push notifications |
| aiomqtt | ≥2.0 | MQTT protocol (IoT) |

### 7.2 Mobile

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|---------|
| Flutter | 3.10+ | Cross-platform framework |
| Dart | 3.10+ | Ngôn ngữ lập trình |
| flutter_bloc | ^8.1.0 | State management |
| dio | ^5.4.0 | HTTP client |
| geolocator | ^13.0.0 | Dịch vụ vị trí GPS |
| fl_chart | ^0.66.0 | Biểu đồ AQI |
| flutter_map | ^6.1.0 | Bản đồ tương tác |
| speech_to_text | ^7.0.0 | Nhận dạng giọng nói |
| flutter_tts | ^4.2.5 | Text-to-speech |
| sentry_flutter | ^9.0.0 | Giám sát lỗi production |
| firebase_messaging | ^14.7.0 | Push notifications |
| flutter_secure_storage | ^9.0.0 | Lưu token mã hóa |
| go_router | ^13.0.0 | Điều hướng màn hình |
| google_fonts | ^6.1.0 | Typography |
| permission_handler | ^11.3.0 | Xử lý quyền truy cập |

### 7.3 DevOps & Dịch vụ ngoài

| Dịch vụ | Mục đích |
|---------|---------|
| Docker + Docker Compose | Container hóa toàn bộ hệ thống |
| IQAir AirVisual API | Nguồn dữ liệu AQI thực tế |
| Tuya IoT Platform | Điều khiển thiết bị thông minh |
| Firebase Cloud Messaging | Push notifications đa nền tảng |
| Google Maps Directions API | Tính khoảng cách thực tế cho routing |
| Sentry | Giám sát và báo cáo lỗi |

---

## CHƯƠNG 8: BẢO MẬT

### 8.1 Luồng xác thực JWT

```
1. POST /auth/login     →  Server xác thực email + bcrypt password
2. Server tạo JWT       →  HS256, TTL 7 ngày, payload: {sub: user_id}
3. Client lưu token     →  flutter_secure_storage (mã hóa thiết bị)
4. Mỗi request          →  Authorization: Bearer {token}
5. Server giải mã       →  Lấy user_id → truy vấn DB → trả dữ liệu
6. Token hết hạn (401)  →  Client xóa session → chuyển về Login
```

### 8.2 Các biện pháp bảo mật đã triển khai

| Biện pháp | Chi tiết |
|-----------|---------|
| Password hashing | bcrypt, salt tự động sinh |
| Token signing | JWT HS256 với SECRET_KEY từ biến môi trường |
| CORS restriction | Chỉ cho phép domain được cấu hình qua env |
| Secrets management | Toàn bộ API key trong `.env`, gitignored |
| Safe logging | Không log Authorization header |
| Startup validation | Pydantic validator từ chối khởi động nếu thiếu key bắt buộc |
| Platform routing | URL `10.0.2.2` chỉ dùng trong debug + Android |
| Error tracking | Sentry (non-fatal) — không lộ stack trace cho người dùng |
| Token storage | flutter_secure_storage (mã hóa cấp thiết bị) |

---

## CHƯƠNG 9: KẾT QUẢ VÀ ĐÁNH GIÁ

### 9.1 Luồng hoạt động chính (Dashboard)

```
GPS ──► LocationService ──► DashboardRepository
                                    │
                          ┌─────────┴─────────┐
                          ▼                   ▼
                  /air-quality/current   /air-quality/forecast
                          │                   │
                   Redis Cache?        Redis Cache?
                    Có ──► Trả về       Có ──► Trả về
                    Không ──► DB        Không ──► Prophet Train
                          │                   │
                          └─────────┬─────────┘
                                    ▼
                            DashboardLoaded State
                                    │
                          BlocBuilder ──► Rebuild UI
```

### 9.2 Danh sách tính năng đã hoàn thiện

| STT | Tính năng | Trạng thái |
|-----|-----------|-----------|
| 1 | Thu thập AQI tự động (30 phút/lần) | ✅ Hoàn thành |
| 2 | Dashboard AQI theo GPS | ✅ Hoàn thành |
| 3 | Biểu đồ lịch sử + dự báo | ✅ Hoàn thành |
| 4 | Bản đồ chất lượng không khí | ✅ Hoàn thành |
| 5 | Dự báo Prophet 24h | ✅ Hoàn thành |
| 6 | Hồ sơ sức khỏe + AQI cảm nhận | ✅ Hoàn thành |
| 7 | Báo cáo sự cố cộng đồng | ✅ Hoàn thành |
| 8 | Smart Home điều khiển Tuya | ✅ Hoàn thành |
| 9 | Automation rules theo ngưỡng AQI | ✅ Hoàn thành |
| 10 | AI Chatbot (Gemini) | ✅ Hoàn thành |
| 11 | Voice input / Text-to-speech | ✅ Hoàn thành |
| 12 | Push notifications (FCM) | ✅ Hoàn thành |
| 13 | Đa ngôn ngữ Tiếng Việt / Tiếng Anh | ✅ Hoàn thành |
| 14 | Error tracking (Sentry) | ✅ Hoàn thành |
| 15 | Clean routing (tuyến đường sạch) | ✅ Hoàn thành |

### 9.3 Hiệu năng hệ thống

| Endpoint | Thời gian phản hồi | Ghi chú |
|----------|------------------|---------|
| `/air-quality/current` (cache hit) | < 50ms | Redis |
| `/air-quality/current` (cache miss) | < 300ms | DB query |
| `/air-quality/forecast` (cache hit) | < 50ms | Redis |
| `/air-quality/forecast` (cache miss) | 2–10s | Prophet training |
| `/chatbot/chat` | 1–3s | Gemini API |
| `/auth/login` | < 200ms | bcrypt |

---

## CHƯƠNG 10: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN

### 10.1 Kết quả đạt được

Đề án đã xây dựng thành công nền tảng AirShield với đầy đủ các thành phần:

- **Backend**: FastAPI async với 7 module API hoàn chỉnh, caching Redis hai tầng, xác thực JWT, thu thập dữ liệu tự động mỗi 30 phút
- **AI/ML**: Tích hợp Prophet để dự báo chuỗi thời gian AQI; Google Gemini làm chatbot hỗ trợ người dùng bằng tiếng Việt
- **Mobile**: Flutter app cross-platform (Android/iOS) với Clean Architecture + BLoC, hỗ trợ GPS, nhận dạng giọng nói, push notification, đa ngôn ngữ
- **IoT**: Điều khiển thiết bị Tuya qua cloud API, automation rules phản ứng theo ngưỡng AQI
- **Bảo mật**: JWT HS256, bcrypt, secrets hoàn toàn qua biến môi trường, CORS restriction, Sentry monitoring

### 10.2 Hướng phát triển

| Hướng | Nội dung |
|-------|---------|
| Dữ liệu | Kết nối thêm nguồn PAMAIR, tích hợp trạm IoT cá nhân |
| AI | Fine-tune Prophet với dữ liệu khí hậu Việt Nam; nâng lên Gemini 2.0 |
| IoT | Thêm adapter cho Xiaomi, Samsung, Philips |
| Community | Gamification: điểm thưởng, huy hiệu khuyến khích báo cáo |
| Deployment | CI/CD pipeline, Kubernetes, multi-region |
| Wearable | Kết nối smartwatch để cảnh báo tức thì |
| Analytics | Dashboard admin phân tích xu hướng ô nhiễm theo vùng |

---

## PHỤ LỤC

### A. Cấu trúc thư mục đầy đủ

```
airshield/
├── app/
│   ├── api/v1/          auth · air_quality · routing · health
│   │                    community · smart_home · chatbot
│   ├── models/          user · aqs · dps · cgs · sha · chatbot
│   ├── services/        forecast · chatbot · personalization
│   │                    routing · notification · device_adapters/
│   ├── schemas/         Pydantic request/response schemas
│   ├── core/            config · database · redis · auth
│   └── tasks/           aqi_collector (APScheduler)
├── airshield_mobile/
│   ├── lib/
│   │   ├── features/    auth · dashboard · map · smart_home
│   │   │                automation · chatbot · notifications · profile
│   │   └── core/        network · storage · services · theme · l10n
│   └── android/         Kotlin 2.2.20 · AGP 8.11.1
├── alembic/             Database migrations
├── tests/               pytest test suite
├── scripts/             Seed data, env checker
├── docker-compose.yml   PostgreSQL · Redis · MQTT · Backend
├── main.py              FastAPI entry point
└── .env                 Environment variables (gitignored)
```

### B. Biến môi trường (.env)

| Biến | Bắt buộc | Mô tả |
|------|---------|-------|
| `SECRET_KEY` | ✅ | JWT signing key (32 bytes hex) |
| `DATABASE_URL` | ✅ | PostgreSQL async connection string |
| `IQAIR_API_KEY` | ✅ | Nguồn dữ liệu AQI (10k calls/month free) |
| `GEMINI_API_KEY` | ✅ | Google Gemini AI chatbot |
| `REDIS_URL` | ✅ | Redis cache connection |
| `POSTGRES_PASSWORD` | ✅ | PostgreSQL password (docker-compose) |
| `GOOGLE_MAPS_API_KEY` | ⚪ | Routing chính xác (fallback: Haversine) |
| `TUYA_CLIENT_ID` | ⚪ | Điều khiển thiết bị Tuya |
| `TUYA_CLIENT_SECRET` | ⚪ | Điều khiển thiết bị Tuya |
| `FIREBASE_CREDENTIALS_PATH` | ⚪ | Push notifications FCM |
| `CORS_ORIGINS` | ⚪ | Giới hạn domain truy cập API |

### C. Hướng dẫn khởi chạy nhanh

```bash
# 1. Backend
cp .env.example .env          # Điền các giá trị REQUIRED
docker-compose up -d          # Khởi động PostgreSQL + Redis
alembic upgrade head          # Tạo schema database
uvicorn main:app --reload     # Chạy API server tại :8000

# 2. Mobile
cd airshield_mobile
flutter pub get
flutter run                   # Android emulator hoặc thiết bị thật

# 3. Kiểm tra API
open http://localhost:8000/docs    # Swagger UI
open http://localhost:8000/health  # Health check
```

---

*AirShield v1.0.0 — Đề án tốt nghiệp*
*Ngày hoàn thành: 26/04/2026*
