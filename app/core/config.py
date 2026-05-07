"""
Application configuration using Pydantic Settings.
Loads environment variables with sensible defaults.
"""

from pydantic import field_validator
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Application
    APP_NAME: str = "AirShield"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # CORS — comma-separated list of allowed origins
    # Production: set CORS_ORIGINS=https://airshield.app,https://api.airshield.app
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8080,http://localhost:8000"

    # Database — REQUIRED in production, local dev default is safe placeholder only
    DATABASE_URL: str = "postgresql+asyncpg://airshield:airshield_dev@localhost:5432/airshield_db"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Cache TTL (seconds) — configurable via environment variables
    CACHE_TTL_AQI: int = 300        # 5 minutes — AQI current reading
    CACHE_TTL_FORECAST: int = 3600  # 1 hour   — Prophet forecast (expensive)
    CACHE_TTL_HISTORY: int = 600    # 10 minutes — historical data

    # MQTT (IoT)
    MQTT_BROKER_HOST: str = "localhost"
    MQTT_BROKER_PORT: int = 1883

    # Routing Algorithm
    ROUTING_ALPHA: float = 0.5
    GOOGLE_MAPS_API_KEY: str = ""

    # Authentication (JWT) — SECRET_KEY REQUIRED, must be set via .env
    SECRET_KEY: str = ""
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days

    # API
    API_V1_PREFIX: str = "/api/v1"

    # External APIs — REQUIRED, must be set via .env
    IQAIR_API_KEY: str = ""
    IQAIR_BASE_URL: str = "https://api.airvisual.com/v2"

    # AI/LLM Configuration
    GEMINI_API_KEY: str = ""
    LLM_MODEL_NAME: str = "gemini-2.5-flash"
    LLM_MAX_TOKENS: int = 1024
    LLM_TEMPERATURE: float = 0.7

    # Smart Home - Tuya IoT Platform
    TUYA_CLIENT_ID: str = ""
    TUYA_CLIENT_SECRET: str = ""

    # Push Notifications - Firebase
    FIREBASE_CREDENTIALS_PATH: str = "app/firebase_credentials.json"

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

    @field_validator('IQAIR_API_KEY')
    @classmethod
    def iqair_key_required(cls, v: str) -> str:
        if not v:
            raise ValueError(
                "IQAIR_API_KEY is required for air quality data.\n"
                "Register free at https://www.iqair.com/air-pollution-data-api\n"
                "Then set IQAIR_API_KEY=<your_key> in your .env file."
            )
        return v

    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """Cached settings instance."""
    return Settings()


settings = get_settings()
