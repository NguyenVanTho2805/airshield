# AirShield — Tổng Quan & Thống Kê Dự Án

> Tài liệu phân tích codebase phục vụ viết khoá luận tốt nghiệp.  
> Cập nhật: 2026-04-26

---

## 1. THỐNG KÊ CODEBASE

### 1.1 Tổng Số File & Dòng Code

| Thành phần | Số file (viết tay) | Số file (tổng) | Tổng dòng code |
|------------|-------------------|----------------|----------------|
| Backend Python (`app/` + `main.py`) | 40 | 40 | **4.113** |
| Tests Python (`tests/`) | 6 | 6 | **453** |
| Mobile Dart (`lib/`) — viết tay | 70 | 80 | **15.086** |
| Mobile Dart — generated (`*.freezed.dart`, `*.g.dart`) | — | 10 | 2.779 |
| **TỔNG CỘNG** | **116** | **126** | **≈ 19.652** |

> Ghi chú: Generated files (Freezed + json_serializable) không tính vào metrics code thực.

---

### 1.2 Phân Bổ File Theo Thư Mục

#### Backend (Python)

```
airshield/                            (1 file: main.py — 173 dòng)
├── app/
│   ├── api/v1/                       (7 files: routers)
│   │   ├── __init__.py
│   │   ├── air_quality.py
│   │   ├── auth.py
│   │   ├── chatbot.py
│   │   ├── community.py
│   │   ├── health.py
│   │   ├── routing.py
│   │   └── smart_home.py
│   ├── core/                         (4 files: infrastructure)
│   │   ├── auth.py
│   │   ├── config.py
│   │   ├── database.py
│   │   └── redis.py
│   ├── models/                       (7 files: SQLAlchemy ORM)
│   │   ├── base.py
│   │   ├── user.py
│   │   ├── aqs.py
│   │   ├── cgs.py
│   │   ├── chatbot.py
│   │   ├── dps.py
│   │   └── sha.py
│   ├── schemas/                      (2 files: Pydantic schemas)
│   │   ├── chatbot.py
│   │   └── schemas.py
│   ├── scripts/                      (1 file: seeding)
│   │   └── seed_data.py
│   ├── services/                     (5 files + 2 device adapters)
│   │   ├── chatbot_service.py
│   │   ├── forecast_service.py
│   │   ├── notification_service.py
│   │   ├── personalization_service.py
│   │   ├── routing_service.py
│   │   └── device_adapters/
│   │       ├── base_adapter.py
│   │       └── tuya_adapter.py
│   └── tasks/                        (1 file: scheduler)
│       └── aqi_collector.py
└── tests/                            (5 test files + 1 conftest)
    ├── conftest.py
    ├── test_health_check.py
    ├── test_api_aqs.py
    ├── test_api_chatbot.py
    └── test_api_modules.py
```

| Thư mục | Số file .py | Vai trò |
|---------|------------|---------|
| `app/api/v1/` | 8 | HTTP routers, request/response handling |
| `app/core/` | 4 | Auth JWT, DB session, Redis pool, Settings |
| `app/models/` | 7 | SQLAlchemy ORM models (10 tables) |
| `app/schemas/` | 2 | Pydantic request/response schemas |
| `app/services/` | 7 | Business logic, AI, IoT adapters |
| `app/tasks/` | 1 | APScheduler ETL background job |
| `tests/` | 6 | Pytest test suite |

#### Mobile (Dart)

```
airshield_mobile/lib/                 (81 file .dart)
├── main.dart                         (entry point — 200+ dòng)
├── core/                             (12 file — shared infrastructure)
│   ├── l10n/
│   │   ├── app_localizations.dart    (i18n delegate: vi/en)
│   │   └── language_bloc.dart        (BLoC theme ngôn ngữ)
│   ├── network/
│   │   └── api_client.dart           (Dio wrapper + interceptors)
│   ├── services/
│   │   └── location_service.dart     (GPS + fallback Hà Nội)
│   ├── storage/
│   │   ├── secure_storage.dart       (flutter_secure_storage)
│   │   └── preferences_storage.dart  (shared_preferences)
│   ├── theme/
│   │   ├── app_theme.dart            (Material 3 + Poppins)
│   │   └── theme_bloc.dart           (dark/light mode BLoC)
│   └── utils/
│       ├── error_handler.dart        (Sentry + FlutterError)
│       ├── validators.dart           (form validation)
│       ├── common_widgets.dart       (LoadingIndicator, ErrorDisplay...)
│       └── error_boundary.dart       (BlocErrorHandler wrapper)
└── features/                         (69 file — feature modules)
    ├── auth/                         (5 file)
    │   ├── data/models/user.dart
    │   ├── data/repositories/auth_repository.dart
    │   ├── presentation/bloc/auth_bloc.dart
    │   └── presentation/pages/
    │       ├── login_page.dart
    │       └── register_page.dart
    ├── dashboard/                    (10 file)
    │   ├── data/models/
    │   │   ├── dashboard_data.dart
    │   │   ├── aqi_history.dart
    │   │   ├── aqi_forecast.dart
    │   │   └── aqi_data_point.dart
    │   ├── data/repositories/dashboard_repository.dart
    │   ├── presentation/bloc/
    │   │   ├── dashboard_bloc.dart
    │   │   └── aqi_history_bloc.dart
    │   └── presentation/pages/
    │       ├── dashboard_page.dart
    │       └── aqi_history_page.dart
    ├── map/                          (4 file)
    │   ├── data/models/station.dart
    │   ├── data/repositories/map_repository.dart
    │   ├── presentation/bloc/map_bloc.dart
    │   └── presentation/pages/map_page.dart
    ├── notifications/                (4 file)
    ├── smart_home/                   (7 file)
    │   ├── data/models/
    │   │   ├── device.dart
    │   │   └── device_activity.dart
    │   ├── data/repositories/smart_home_repository.dart
    │   ├── presentation/bloc/smart_home_bloc.dart
    │   └── presentation/pages/
    │       ├── devices_page.dart
    │       └── device_details_page.dart
    ├── chatbot/                      (6 file)
    │   ├── data/models/chat_message.dart
    │   ├── data/repositories/chatbot_repository.dart
    │   ├── presentation/bloc/chatbot_bloc.dart
    │   ├── presentation/pages/chatbot_page.dart
    │   └── presentation/widgets/
    │       ├── chat_input.dart
    │       └── chat_bubble.dart
    ├── automation/                   (5 file)
    │   ├── data/models/automation_rule.dart
    │   ├── data/repositories/automation_repository.dart
    │   ├── presentation/bloc/automation_bloc.dart
    │   └── presentation/pages/
    │       ├── automation_rules_page.dart
    │       └── create_rule_page.dart
    └── profile/                      (12 file)
        ├── data/models/
        │   ├── health_condition.dart
        │   └── saved_location.dart
        ├── data/repositories/profile_repository.dart
        ├── presentation/bloc/
        │   ├── profile_bloc.dart
        │   └── locations_bloc.dart
        └── presentation/pages/
            ├── profile_page.dart
            ├── settings_page.dart
            ├── edit_profile_page.dart
            ├── health_preferences_page.dart
            ├── saved_locations_page.dart
            ├── about_page.dart
            ├── privacy_policy_page.dart
            └── terms_page.dart
```

---

## 2. TECHNOLOGY STACK

### 2.1 Backend — Python Dependencies

| Package | Phiên bản | Mục đích |
|---------|-----------|---------|
| **fastapi** | ≥0.109.0 | Web framework async, tự động sinh OpenAPI docs |
| **uvicorn[standard]** | ≥0.27.0 | ASGI server chạy FastAPI |
| **sqlalchemy[asyncio]** | ≥2.0.25 | ORM async cho PostgreSQL |
| **asyncpg** | ≥0.29.0 | Driver async PostgreSQL (hiệu năng cao) |
| **psycopg2-binary** | ≥2.9.9 | Driver sync PostgreSQL (chỉ dùng cho Alembic migrations) |
| **greenlet** | ≥3.0.0 | Dependency của SQLAlchemy async |
| **alembic** | ≥1.13.0 | Database migration tool |
| **geoalchemy2** | ≥0.14.0 | PostGIS geometry types cho SQLAlchemy |
| **pydantic** | ≥2.5.0 | Data validation, serialization (v2) |
| **pydantic-settings** | ≥2.1.0 | Load config từ `.env` file |
| **redis** | ≥5.0.0 | Redis client async (`redis.asyncio`) |
| **aiomqtt** | ≥2.0.0 | MQTT async client cho IoT protocol |
| **python-multipart** | ≥0.0.6 | Parse form data (OAuth2 login) |
| **python-dotenv** | ≥1.0.0 | Load `.env` file |
| **google-generativeai** | ≥0.3.0 | Google Gemini AI SDK (chatbot) |
| **prophet** | ≥1.1.5 | Meta Prophet — time-series forecasting AQI |
| **pandas** | ≥2.1.0 | DataFrame input cho Prophet |
| **python-jose[cryptography]** | ≥3.3.0 | JWT encode/decode (HS256) |
| **passlib[bcrypt]** | ≥1.7.4 | Password hashing (bcrypt) |
| **apscheduler** | ≥3.10.0 | Background scheduler (AQI collector mỗi 30 phút) |
| **httpx** | ≥0.27.0 | Async HTTP client (gọi IQAir, Tuya, Google Maps) |
| **firebase-admin** | ≥6.4.0 | Firebase Admin SDK (FCM push notification) |

### 2.2 Mobile — Flutter Dependencies

| Package | Phiên bản | Mục đích |
|---------|-----------|---------|
| **flutter_bloc** | ^8.1.0 | State management (BLoC/Cubit pattern) |
| **equatable** | ^2.0.5 | So sánh object trong BLoC events/states |
| **dio** | ^5.4.0 | HTTP client với interceptors (token injection, error handling) |
| **go_router** | ^13.0.0 | Khai báo trong pubspec, chưa dùng (Navigator 1.0 được dùng thực tế) |
| **freezed_annotation** | ^2.4.1 | Annotation cho code generation (immutable models) |
| **json_annotation** | ^4.8.1 | Annotation cho JSON serialization |
| **freezed** | ^2.4.7 (dev) | Code generator: copyWith, equality, pattern matching |
| **json_serializable** | ^6.7.1 (dev) | Code generator: fromJson/toJson |
| **build_runner** | ^2.4.8 (dev) | Chạy code generation |
| **google_fonts** | ^6.1.0 | Font Poppins cho UI |
| **fl_chart** | ^0.66.0 | Biểu đồ AQI history và forecast |
| **flutter_svg** | ^2.0.9 | Render SVG icons |
| **cupertino_icons** | ^1.0.8 | iOS-style icons |
| **intl** | ^0.20.2 | Định dạng ngày giờ, số (i18n) |
| **flutter_secure_storage** | ^9.0.0 | Lưu JWT token an toàn (Keychain/Keystore) |
| **shared_preferences** | ^2.2.2 | Lưu theme mode, language code |
| **package_info_plus** | ^9.0.1 | Thông tin app (version, build number) |
| **image_picker** | ^1.0.7 | Chọn ảnh avatar từ camera/gallery |
| **path_provider** | ^2.1.2 | Truy cập filesystem (cache dir) |
| **permission_handler** | ^11.3.0 | Runtime permissions (location, camera) |
| **geolocator** | ^13.0.0 | GPS getCurrentPosition với fallback |
| **sentry_flutter** | ^9.0.0 | Error monitoring và crash reporting |
| **url_launcher** | ^6.3.0 | Mở URL, email client, app store |
| **flutter_map** | ^6.1.0 | Bản đồ OpenStreetMap (FlutterMap + TileLayer) |
| **latlong2** | ^0.9.0 | LatLng coordinates cho flutter_map |
| **firebase_core** | ^2.24.0 | Firebase SDK initialization |
| **firebase_messaging** | ^14.7.0 | FCM push notifications receiver |
| **flutter_local_notifications** | ^17.2.4 | Hiện notification trên thiết bị |
| **speech_to_text** | ^7.0.0 | Voice input trong chatbot |
| **flutter_tts** | ^4.2.5 | Text-to-speech đọc kết quả chatbot |
| **get_it** | ^7.6.0 | Service locator (khai báo nhưng dùng constructor injection) |
| **injectable** | ^2.3.2 | Code generation cho get_it (khai báo, chưa dùng) |

### 2.3 Database & Infrastructure

| Thành phần | Phiên bản | Vai trò |
|------------|-----------|---------|
| **PostgreSQL** | 15 | Relational database chính |
| **PostGIS** | 3.4 | Extension địa lý: lưu coordinates (`Geometry POINT SRID 4326`), dùng cho `CommunityReport` |
| **Redis** | 7 (Alpine) | In-memory cache: AQI data (5 phút TTL), forecast (1 giờ), chat sessions (24 giờ) |
| **Docker** | latest | Container hoá PostgreSQL + Redis |
| **Alembic** | ≥1.13.0 | Database migration management |

### 2.4 External APIs & Services

| Dịch vụ | Vai trò | Endpoint chính |
|---------|---------|----------------|
| **IQAir AirVisual** | Nguồn dữ liệu AQI thực | `https://api.airvisual.com/v2/city` |
| **Google Gemini** | AI chatbot (`gemini-1.5-flash`) | `google-generativeai` SDK |
| **Tuya Cloud** | Điều khiển thiết bị IoT | `https://openapi.tuyaus.com/v1.0/` |
| **Firebase FCM** | Push notifications | Firebase Admin SDK |
| **Google Maps Directions** | Tính toán tuyến đường | `https://maps.googleapis.com/maps/api/directions/json` |
| **OpenStreetMap** | Tile map trong mobile | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |

---

## 3. KIẾN TRÚC TỔNG THỂ

### 3.1 Architecture Diagram (Mermaid)

```mermaid
graph TB
    subgraph Mobile["📱 Flutter Mobile App"]
        UI[Presentation Layer<br/>Pages + Widgets]
        BLoC[BLoC Layer<br/>State Management]
        Repo[Repository Layer<br/>Data Access]
        ApiClient[ApiClient<br/>Dio + Interceptors]
        Storage[Storage<br/>SecureStorage / SharedPrefs]
        UI --> BLoC --> Repo --> ApiClient
        BLoC --- Storage
    end

    subgraph Backend["⚙️ FastAPI Backend (Python)"]
        Router[API Routers<br/>app/api/v1/]
        Services[Business Services<br/>Forecast · Personalization · Routing · Chatbot]
        Tasks[Background Tasks<br/>APScheduler — AQI Collector]
        Auth[Auth Layer<br/>JWT · bcrypt]
        Router --> Services
        Router --> Auth
        Tasks --> Services
    end

    subgraph DataStore["🗄️ Data Layer"]
        PG[(PostgreSQL 15<br/>+ PostGIS 3.4)]
        Redis[(Redis 7<br/>Cache + Sessions)]
    end

    subgraph External["🌐 External Services"]
        IQAir[IQAir AirVisual<br/>AQI Data]
        Gemini[Google Gemini<br/>gemini-1.5-flash]
        Tuya[Tuya Cloud<br/>IoT Devices]
        FCM[Firebase FCM<br/>Push Notifications]
        GMaps[Google Maps<br/>Directions API]
    end

    ApiClient <-->|REST / JSON<br/>Bearer JWT| Router
    Router <-->|SQLAlchemy<br/>AsyncSession| PG
    Router <-->|redis.asyncio| Redis
    Services <-->|AsyncSession| PG
    Services <-->|redis.asyncio| Redis

    Tasks -->|httpx async| IQAir
    Services -->|google-generativeai SDK| Gemini
    Services -->|HMAC-SHA256 signed<br/>httpx| Tuya
    Services -->|firebase-admin SDK| FCM
    Services -->|httpx async| GMaps
```

### 3.2 Luồng Dữ Liệu Chính

#### Luồng 1: Xem AQI thời gian thực

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as FastAPI
    participant Redis as Redis Cache
    participant DB as PostgreSQL
    participant IQAir as IQAir API

    Note over DB,IQAir: Background (mỗi 30 phút)
    API->>IQAir: GET /city?city=Hanoi&key=...
    IQAir-->>API: {aqi, pm25, temp, humidity}
    API->>DB: INSERT air_quality_logs

    Note over App,Redis: User request
    App->>API: GET /api/v1/air-quality/current?lat=...&lon=...
    API->>Redis: GET "aqi:current:{lat}:{lon}"
    alt Cache HIT (TTL 5 phút)
        Redis-->>API: JSON cached
    else Cache MISS
        API->>DB: SELECT nearest station + latest log
        DB-->>API: AQI data
        API->>Redis: SET với TTL 300s
    end
    API-->>App: AirQualityResponse {aqi, pm25, station_name, ...}
    App->>App: DashboardBloc emits DashboardLoaded
```

#### Luồng 2: Dự báo AQI (Prophet)

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as FastAPI
    participant Redis as Redis
    participant DB as PostgreSQL
    participant Prophet as Prophet Model

    App->>API: GET /api/v1/air-quality/forecast?lat=...&lon=...
    API->>Redis: GET "aqi:forecast:{lat}:{lon}"
    alt Cache MISS (TTL 1 giờ)
        API->>DB: SELECT air_quality_logs WHERE recorded_at >= now()-7d
        DB-->>API: List[AQILog] (≥10 records)
        API->>Prophet: DataFrame{ds, y} → m.fit() → m.predict(24h)
        Prophet-->>API: forecast[yhat] clamped [0,500]
        API->>Redis: SET với TTL 3600s
    end
    API-->>App: AqiForecastResponse {data: [{aqi, recorded_at, is_forecast:true}]}
```

#### Luồng 3: Chatbot AI

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as FastAPI
    participant Redis as Redis
    participant DB as PostgreSQL
    participant Gemini as Gemini API

    App->>API: POST /api/v1/chatbot/chat {message, session_id?, lat?, lon?}
    API->>DB: SELECT air_quality_logs (nếu include_aqi_context=true)
    DB-->>API: AQI context data
    API->>Redis: GET "chat_session:{session_id}"
    alt Session không tồn tại
        API->>Redis: SET new session {user_id, messages:[]} TTL 24h
    end
    API->>Gemini: chat.send_message(SYSTEM_PROMPT + context + message)
    Gemini-->>API: AI response text
    API->>Redis: SET updated session (append messages, refresh TTL)
    API-->>App: ChatResponse {session_id, message, action?, timestamp}
```

#### Luồng 4: Điều khiển thiết bị IoT

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant API as FastAPI
    participant DB as PostgreSQL
    participant Tuya as Tuya Cloud

    App->>API: POST /api/v1/smart-home/devices/{id}/command {command, value}
    API->>DB: SELECT user_devices WHERE device_id=? AND user_id=?
    DB-->>API: UserDevice {provider: "tuya", access_token}
    API->>Tuya: GET /v1.0/token (HMAC-SHA256 signed)
    Tuya-->>API: access_token
    API->>Tuya: POST /v1.0/iot-03/devices/{id}/commands [{code:"switch_1", value:true}]
    Tuya-->>API: {result: true}
    API-->>App: CommandResponse {success: true, message: "..."}
```

---

## 4. PROJECT METRICS

### 4.1 Tổng Hợp Chỉ Số

| Chỉ số | Số lượng |
|--------|---------|
| **API Endpoints** | **22** |
| **Database Tables** | **10** |
| **Màn hình Mobile (Pages)** | **19** |
| **BLoC / State managers** | **12** |
| **Repositories (mobile)** | **7** |
| **Services (backend)** | **7** |
| **Background Tasks** | **1** (APScheduler) |
| **Test functions** | **18** |
| **Test files** | **5** |

### 4.2 API Endpoints Chi Tiết (22 endpoints)

| Module | Method | Path | Auth |
|--------|--------|------|------|
| **Root** | GET | `/` | — |
| **Root** | GET | `/health` | — |
| **Auth** | POST | `/api/v1/auth/register` | — |
| **Auth** | POST | `/api/v1/auth/login` | — |
| **Auth** | GET | `/api/v1/auth/me` | JWT |
| **Auth** | PUT | `/api/v1/auth/me/fcm-token` | JWT |
| **AQS** | GET | `/api/v1/air-quality/current` | — |
| **AQS** | GET | `/api/v1/air-quality/history` | — |
| **AQS** | GET | `/api/v1/air-quality/forecast` | — |
| **DPS** | POST | `/api/v1/user/health/profile` | JWT |
| **DPS** | GET | `/api/v1/user/health/recommendation` | JWT |
| **Routing** | POST | `/api/v1/routing/calculate` | — |
| **CGS** | POST | `/api/v1/community/report` | JWT |
| **CGS** | GET | `/api/v1/community/reports` | JWT |
| **CGS** | POST | `/api/v1/community/report/{id}/verify` | JWT |
| **SHA** | GET | `/api/v1/smart-home/devices` | JWT |
| **SHA** | POST | `/api/v1/smart-home/devices` | JWT |
| **SHA** | POST | `/api/v1/smart-home/devices/{id}/command` | JWT |
| **ACB** | POST | `/api/v1/chatbot/chat` | JWT |
| **ACB** | GET | `/api/v1/chatbot/sessions` | JWT |
| **ACB** | GET | `/api/v1/chatbot/sessions/{id}` | JWT |
| **ACB** | DELETE | `/api/v1/chatbot/sessions/{id}` | JWT |

> Tỷ lệ endpoints được bảo vệ: **15/22 (68%)**

### 4.3 Database Tables (10 tables)

| Table | Module | Quan hệ | Ghi chú |
|-------|--------|---------|---------|
| `users` | Auth | — | UUID PK, bcrypt password |
| `stations` | AQS | 1→N `air_quality_logs` | Source: iqair/pamair |
| `air_quality_logs` | AQS | N→1 `stations` | Composite index (station_id, recorded_at) |
| `health_profiles` | DPS | 1→1 `users` | ARRAY column cho conditions |
| `advice_rules` | DPS | — | Template-based advice |
| `community_reports` | CGS | — | PostGIS POINT geometry |
| `user_devices` | SHA | — | Provider: tuya/xiaomi/samsung |
| `automation_rules` | SHA | — | JSON payload cho actions |
| `chat_sessions` | ACB | 1→N `chat_messages` | Định nghĩa trong DB, dùng Redis |
| `chat_messages` | ACB | N→1 `chat_sessions` | Định nghĩa trong DB, dùng Redis |

### 4.4 Màn Hình Mobile (19 pages)

| Feature | Màn hình | Route (imperative) | BLoC |
|---------|----------|-------------------|------|
| Auth | `LoginPage` | Entry point khi Unauthenticated | `AuthBloc` |
| Auth | `RegisterPage` | Navigator.push từ LoginPage | `AuthBloc` |
| Dashboard | `DashboardPage` | Entry point khi Authenticated | `DashboardBloc` |
| Dashboard | `AQIHistoryPage` | push từ Dashboard | `AQIHistoryBloc` |
| Map | `MapPage` | push từ Dashboard / BottomNav | `MapBloc` |
| Notifications | `NotificationsPage` | push từ AppBar icon | `NotificationsBloc` |
| Smart Home | `DevicesPage` | push từ Dashboard / BottomNav | `SmartHomeBloc` |
| Smart Home | `DeviceDetailsPage` | push từ DeviceCard | `SmartHomeBloc` |
| Chatbot | `ChatbotPage` | push từ FAB | `ChatbotBloc` |
| Automation | `AutomationRulesPage` | push từ ProfilePage | `AutomationBloc` |
| Automation | `CreateRulePage` | push từ FAB trong AutomationRules | `AutomationBloc` |
| Profile | `ProfilePage` | push từ BottomNav | `ProfileBloc` |
| Profile | `EditProfilePage` | push từ ProfilePage | `ProfileBloc` |
| Profile | `HealthPreferencesPage` | push từ ProfilePage | `ProfileBloc` |
| Profile | `SavedLocationsPage` | push từ ProfilePage | `LocationsBloc` |
| Profile | `SettingsPage` | push từ ProfilePage / AppBar | `ThemeBloc`, `LanguageBloc` |
| Profile | `AboutPage` | push từ SettingsPage | — |
| Profile | `PrivacyPolicyPage` | push từ SettingsPage | — |
| Profile | `TermsPage` | push từ SettingsPage | — |

### 4.5 BLoC Instances (12 BLoCs)

| BLoC | Scope | Events | States |
|------|-------|--------|--------|
| `AuthBloc` | Global | CheckAuthStatus, LoginRequested, RegisterRequested, LogoutRequested | AuthInitial, AuthLoading, Authenticated, Unauthenticated, AuthError |
| `DashboardBloc` | Global | LoadDashboardData, RefreshDashboardData | DashboardInitial, DashboardLoading, DashboardLoaded, DashboardError |
| `ThemeBloc` | Global | LoadTheme, ChangeTheme | ThemeState{themeMode} |
| `LanguageBloc` | Global | LoadLanguage, ChangeLanguage | LanguageState{locale} |
| `NotificationsBloc` | Global | LoadNotifications, MarkAsRead, MarkAllAsRead, DeleteNotification, ClearAll | NotificationsLoaded, NotificationsError |
| `AQIHistoryBloc` | Feature | LoadAQIHistory, ChangeTimeRange | AQIHistoryLoading, AQIHistoryLoaded, AQIHistoryError |
| `MapBloc` | Feature | LoadStations | MapLoading, MapLoaded, MapError |
| `SmartHomeBloc` | Feature | LoadDevices, TogglePower, ChangeMode, AddDevice, RenameDevice | SmartHomeLoading, SmartHomeLoaded, SmartHomeError |
| `ChatbotBloc` | Feature | SendMessage, ClearChat, LoadSession | ChatbotInitial, ChatbotLoading, ChatbotReady, ChatbotError |
| `AutomationBloc` | Feature | LoadRules, CreateRule, UpdateRule, DeleteRule, ToggleRule | AutomationLoaded, RuleCreated, RuleUpdated, RuleDeleted |
| `ProfileBloc` | Feature | LoadProfile, UpdateProfile, UploadAvatar, LoadHealthConditions | ProfileLoaded, ProfileUpdated, ProfileError |
| `LocationsBloc` | Feature | LoadLocations, AddLocation, UpdateLocation, DeleteLocation, SetDefaultLocation | LocationsLoaded, LocationsError |

### 4.6 Backend Services (7 services)

| Service | File | Chức năng chính |
|---------|------|----------------|
| `ForecastService` | `services/forecast_service.py` | Prophet time-series AQI prediction (24h) |
| `PersonalizationService` | `services/personalization_service.py` | Perceived AQI = Real AQI × health weight |
| `RoutingService` | `services/routing_service.py` | Fastest vs cleanest route (cost function + Haversine) |
| `ChatbotService` | `services/chatbot_service.py` | Gemini AI integration + Redis session management |
| `NotificationService` | `services/notification_service.py` | FCM push notifications |
| `TuyaAdapter` | `services/device_adapters/tuya_adapter.py` | Tuya Cloud API (HMAC-SHA256 auth) |
| `AQICollector` | `tasks/aqi_collector.py` | Scheduled ETL: IQAir → PostgreSQL (mỗi 30 phút) |

---

## 5. REDIS CACHING STRATEGY

| Cache Key Pattern | TTL | Dữ liệu |
|-------------------|-----|---------|
| `aqi:current:{lat:.2f}:{lon:.2f}` | 300s (5 phút) | AQI hiện tại gần vị trí |
| `aqi:forecast:{lat:.2f}:{lon:.2f}` | 3600s (1 giờ) | Dự báo 24h từ Prophet |
| `aqi:history:{lat}:{lon}:{hours}` | 600s (10 phút) | Lịch sử AQI N giờ |
| `chat_session:{uuid}` | 86400s (24 giờ) | Lịch sử chat session |

---

## 6. DOCKER INFRASTRUCTURE

```yaml
# docker-compose.yml (tóm tắt)
services:
  postgres:
    image: postgis/postgis:15-3.4
    ports: "5432:5432"
    volumes: postgres_data:/var/lib/postgresql/data
    healthcheck: pg_isready -U airshield -d airshield_db

  redis:
    image: redis:7-alpine
    ports: "6379:6379"
    command: redis-server --appendonly yes   # AOF persistence
    healthcheck: redis-cli ping
```

> Không có Dockerfile cho FastAPI backend — chạy trực tiếp qua `uvicorn main:app --reload`

---

## 7. ENVIRONMENT VARIABLES (23 biến)

| Biến | Required | Default | Mô tả |
|------|----------|---------|-------|
| `SECRET_KEY` | **Bắt buộc** | — | JWT signing secret (HS256) |
| `IQAIR_API_KEY` | **Bắt buộc** | — | IQAir AirVisual API key |
| `DATABASE_URL` | Khuyến nghị | `postgresql+asyncpg://airshield:...@localhost/airshield_db` | Async PostgreSQL URL |
| `REDIS_URL` | Khuyến nghị | `redis://localhost:6379/0` | Redis connection URL |
| `GEMINI_API_KEY` | Optional | `""` | Google Gemini API key |
| `TUYA_CLIENT_ID` | Optional | `""` | Tuya IoT Platform Client ID |
| `TUYA_CLIENT_SECRET` | Optional | `""` | Tuya IoT Platform Secret |
| `FIREBASE_CREDENTIALS_PATH` | Optional | `app/firebase_credentials.json` | Path tới Firebase service account |
| `GOOGLE_MAPS_API_KEY` | Optional | `""` | Google Maps Directions API key |
| `DEBUG` | Optional | `False` | FastAPI debug mode |
| `LLM_MODEL_NAME` | Optional | `gemini-1.5-flash` | Gemini model version |
| `LLM_MAX_TOKENS` | Optional | `1024` | Max output tokens |
| `LLM_TEMPERATURE` | Optional | `0.7` | Sampling temperature |
| `CACHE_TTL_AQI` | Optional | `300` | Redis TTL AQI (giây) |
| `CACHE_TTL_FORECAST` | Optional | `3600` | Redis TTL forecast (giây) |
| `CACHE_TTL_HISTORY` | Optional | `600` | Redis TTL history (giây) |
| `ROUTING_ALPHA` | Optional | `0.5` | Weight AQI trong routing cost |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Optional | `10080` (7 ngày) | JWT expiry |
| `JWT_ALGORITHM` | Optional | `HS256` | JWT algorithm |
| `MQTT_BROKER_HOST` | Optional | `localhost` | MQTT broker host |
| `MQTT_BROKER_PORT` | Optional | `1883` | MQTT broker port |
| `APP_NAME` | Optional | `AirShield` | Application name |
| `APP_VERSION` | Optional | `1.0.0` | Application version |
| `CORS_ORIGINS` | Optional | `http://localhost:3000,...` | Allowed CORS origins |

---

*File này được tạo tự động từ phân tích codebase thực tế — 2026-04-26*
