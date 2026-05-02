# AirShield Backend - Walkthrough

## Project Structure
```
airshield/
├── main.py
├── requirements.txt
├── docker-compose.yml
├── alembic.ini
├── alembic/
│   ├── env.py
│   └── versions/
├── tests/
│   ├── conftest.py
│   ├── test_api_aqs.py
│   └── test_health_check.py
└── app/
    ├── core/
    │   ├── config.py
    │   ├── database.py
    │   └── redis.py
    ├── models/
    │   ├── aqs.py
    │   ├── dps.py
    │   ├── cgs.py
    │   └── sha.py
    ├── services/
    │   ├── routing_service.py
    │   └── personalization_service.py
    └── api/v1/
        ├── air_quality.py
        ├── routing.py
        ├── health.py
        ├── community.py
        └── smart_home.py
```

## Database Models

### AQS (Air Quality Service)
| Table | Columns |
|-------|---------|
| `stations` | id, name, source, latitude, longitude, is_active |
| `air_quality_logs` | id, station_id, aqi, pm25, temperature, humidity, recorded_at |

### DPS (Deep Personalization)
| Table | Columns |
|-------|---------|
| `health_profiles` | user_id, birth_year, conditions[], sensitivity_level |
| `advice_rules` | id, min_aqi_threshold, condition_tag, message_template, action_type |

### CGS (Community & Gamification)
| Table | Columns |
|-------|---------|
| `community_reports` | id, user_id, incident_type, geom (PostGIS), image_url, status, trust_score |

### SHA (Smart Home Automation)
| Table | Columns |
|-------|---------|
| `user_devices` | device_id (PK), user_id, provider, access_token, device_name, **current_filter_life**, is_active |
| `automation_rules` | id, user_id, trigger_metric, threshold_value, action_payload (JSON), is_enabled |

### ACB (AI Chatbot)
| Table | Columns |
|-------|---------|
| `chat_sessions` | id, user_id, title, created_at, updated_at |
| `chat_messages` | id, session_id, role, content, context_data, created_at |

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check |
| `/api/v1/air-quality/current` | GET | Current AQI by location |
| `/api/v1/air-quality/history` | GET | 24h history data |
| `/api/v1/routing/calculate` | POST | Fastest vs Cleanest routes |
| `/api/v1/user/health/profile` | POST | Update health profile |
| `/api/v1/user/health/recommendation` | GET | Personalized advice |
| `/api/v1/community/report` | POST | Submit pollution incident |
| `/api/v1/smart-home/devices` | GET | List user devices |
| `/api/v1/smart-home/devices` | POST | Register new device |
| `/api/v1/smart-home/devices/{id}/command` | POST | Control device |
| `/api/v1/chatbot/chat` | POST | Chat with AI assistant |
| `/api/v1/chatbot/sessions` | GET | List chat sessions |
| `/api/v1/chatbot/sessions/{id}` | GET/DELETE | Manage session |

## Key Algorithms

**Clean Routing:**
```
Cost = (Distance / Speed) × (1 + α × AQI_Factor)
```

**Personalization:**
```
Perceived_AQI = Real_AQI × Health_Weight
```
Weights: Normal=1.0, Elderly=1.5, Asthma=2.5

## Quick Start

```bash
# Start databases
docker-compose up -d

# Activate venv
venv\Scripts\activate

# Run migrations
alembic revision --autogenerate -m "initial"
alembic upgrade head

# Start server
uvicorn main:app --reload

# Run tests
pytest tests/ -v

# API Docs: http://localhost:8000/docs
```
