# AirShield - Intelligent Air Quality Assistant

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://python.org)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-green.svg)](https://fastapi.tiangolo.com)

> 🌬️ Comprehensive air quality monitoring and smart home control platform

## Features

### Backend (FastAPI)
- **AQS** - Air Quality Service: Real-time AQI monitoring
- **DPS** - Deep Personalization: Health-aware recommendations
- **CGS** - Community & Gamification: Crowdsourced reports
- **SHA** - Smart Home Automation: Device control & rules
- **ACB** - AI Chatbot: Gemini-powered assistant

### Mobile App (Flutter)
- Dashboard with AQI visualization
- Interactive AQI Map
- Smart Home device control
- Automation rules
- AI Chatbot assistant
- Notifications
- Multi-language (EN/VI)

## Quick Start

### Backend

```bash
cd airshield

# Setup Python environment
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your API keys

# Start databases
docker-compose up -d

# Run migrations
alembic upgrade head

# Start server
uvicorn main:app --reload

# API Docs: http://localhost:8000/docs
```

### Mobile App

```bash
cd airshield_mobile

# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release
```

## Project Structure

```
airshield/
├── main.py                 # FastAPI entrypoint
├── requirements.txt
├── docker-compose.yml
├── .env.example
├── app/
│   ├── api/v1/            # REST endpoints
│   ├── core/              # Config, DB, Redis
│   ├── models/            # SQLAlchemy models
│   ├── schemas/           # Pydantic schemas
│   └── services/          # Business logic
├── tests/                 # Pytest tests
└── alembic/               # DB migrations

airshield_mobile/
├── lib/
│   ├── core/              # Theme, network, utils
│   └── features/          # Feature modules (BLoC)
│       ├── auth/
│       ├── dashboard/
│       ├── chatbot/
│       ├── smart_home/
│       ├── automation/
│       ├── map/
│       ├── profile/
│       └── notifications/
└── pubspec.yaml
```

## API Endpoints

| Module | Endpoint | Description |
|--------|----------|-------------|
| AQS | `GET /api/v1/air-quality/current` | Current AQI |
| AQS | `GET /api/v1/air-quality/history` | 24h history |
| DPS | `POST /api/v1/user/health/profile` | Update profile |
| DPS | `GET /api/v1/user/health/recommendation` | Get advice |
| CGS | `POST /api/v1/community/report` | Submit report |
| SHA | `GET /api/v1/smart-home/devices` | List devices |
| SHA | `POST /api/v1/smart-home/devices/{id}/command` | Control |
| ACB | `POST /api/v1/chatbot/chat` | Chat with AI |
| Routing | `POST /api/v1/routing/calculate` | Clean route |

## Configuration

Copy `.env.example` to `.env` and configure:

```env
# Required
DATABASE_URL=postgresql+asyncpg://...
GEMINI_API_KEY=your_key_here

# Optional
IQAIR_API_KEY=your_key_here
```

## Testing

```bash
# Backend
cd airshield
pytest tests/ -v

# Mobile
cd airshield_mobile
flutter test
```

## License

MIT License
