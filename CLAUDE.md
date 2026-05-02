# AirShield - Hướng Dẫn Dự Án

> 🌬️ Intelligent Air Quality Monitoring & Smart Home Control Platform

## 1. Tổng Quan

AirShield là nền tảng giám sát chất lượng không khí thông minh, kết hợp IoT, AI và mobile app.

| Layer | Tech | Path |
|-------|------|------|
| Backend | Python 3.11+ / FastAPI (async) | `./` (root) |
| Mobile | Flutter 3.10+ / Dart (BLoC) | `airshield_mobile/` |
| Database | PostgreSQL 15 + PostGIS | via Docker |
| Cache | Redis 7 | via Docker |
| AI | Google Gemini (`gemini-1.5-flash`) | `app/services/chatbot_service.py` |
| Forecast | Prophet | `app/services/forecast_service.py` |
| IoT | MQTT + Tuya IoT Platform | `app/services/device_adapters/` |

## 2. Kiến Trúc

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  Flutter Mobile   │◄──►│  FastAPI Backend  │◄──►│  PostgreSQL/     │
│  (BLoC Pattern)   │    │  (Async, JWT)     │    │  PostGIS + Redis │
└──────────────────┘    └────────┬───────────┘    └──────────────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼             ▼
              ┌──────────┐ ┌──────────┐ ┌──────────┐
              │ IQAir API│ │ Gemini   │ │ Tuya IoT │
              │ (AQI)    │ │ (Chat)   │ │ (Devices)│
              └──────────┘ └──────────┘ └──────────┘
```

## 3. Backend Modules

| Module | Code | Chức năng |
|--------|------|-----------|
| AQS | `app/api/v1/`, `app/models/aqs.py` | Air Quality - real-time AQI |
| DPS | `app/services/personalization_service.py` | Health recommendations |
| CGS | `app/models/cgs.py` | Community reports |
| SHA | `app/models/sha.py`, `app/services/device_adapters/` | Smart Home |
| ACB | `app/services/chatbot_service.py` | AI Chatbot (Gemini) |
| Forecast | `app/services/forecast_service.py` | AQI prediction (Prophet) |

## 4. Quy Tắc Bắt Buộc

### Backend
- **LUÔN async/await** — DB qua `AsyncSession`, HTTP qua `httpx.AsyncClient`
- **Pydantic v2** — `model_config = ConfigDict(from_attributes=True)`
- **API versioning** — Mọi endpoint trong `/api/v1/`
- **JWT Auth** — `get_current_user` dependency cho protected endpoints
- **No secrets** — Dùng `app/core/config.py` → `Settings`, KHÔNG hardcode

### Mobile
- **BLoC pattern** — KHÔNG dùng `setState()` trực tiếp
- **Repository pattern** — Data layer tách riêng, inject qua constructor
- **Theme system** — `core/theme/`, KHÔNG hardcode colors
- **Null safety** — Bắt buộc, xử lý nullable types đúng cách

### Chung
- **Commit**: `feat:` `fix:` `refactor:` `docs:` `test:` `chore:`
- **Không commit**: `.env`, `venv/`, `__pycache__/`, `.dart_tool/`, `build/`
- **Test trước push**: `pytest tests/ -v` (backend) | `flutter test` (mobile)

## 5. Chạy Dự Án

```bash
# Backend
docker-compose up -d          # PostgreSQL + Redis
alembic upgrade head          # Migrations
uvicorn main:app --reload     # API server :8000

# Mobile
cd airshield_mobile
flutter pub get && flutter run
```

**API Docs**: http://localhost:8000/docs | http://localhost:8000/redoc

## 6. Hệ Thống Cấu Hình (.claude/)

Thứ tự ưu tiên khi đọc:

```
.claude/
├── settings.json              ← [1] Quyền hạn & context
├── rules/                     ← [2] Quy tắc NỀN TẢNG (đọc trước)
│   ├── code-style.md          ←     Cách viết code Python & Dart
│   ├── api-conventions.md     ←     Chuẩn API RESTful & caching
│   └── testing.md             ←     Cách viết & chạy tests
├── commands/                  ← [3] Workflows (áp dụng rules)
│   ├── review.md              ←     /review code → dùng rules/*
│   └── fix-issue.md           ←     /fix-issue → debug workflow
└── skills/                    ← [4] Skill nâng cao
    └── security-review/       ←     Security audit toàn diện
```

> **Nguyên tắc**: Rules định nghĩa CHUẨN → Commands/Skills THỰC THI theo chuẩn đó.
