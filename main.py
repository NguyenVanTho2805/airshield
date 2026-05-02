"""
AirShield - Intelligent Air Assistant
Main application entry point.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger

from app.core.config import settings
from app.core.database import init_db, close_db, async_session_factory
from app.core.redis import close_redis
from app.api.v1 import api_router
from app.tasks.aqi_collector import collect_aqi_data

# Background scheduler instance
scheduler = AsyncIOScheduler()


async def _run_aqi_collection():
    """Wrapper to run AQI collection with its own DB session."""
    async with async_session_factory() as session:
        await collect_aqi_data(session)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.
    Handles startup and shutdown events.
    """
    # Startup
    print(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION}")

    # Initialize database tables
    try:
        await init_db()
        print("✅ Database initialized")
    except Exception as e:
        print(f"⚠️ Database initialization skipped: {e}")

    # Start background AQI collection (every 30 minutes)
    scheduler.add_job(
        _run_aqi_collection,
        trigger=IntervalTrigger(minutes=30),
        id="aqi_collector",
        replace_existing=True,
        misfire_grace_time=60,
    )
    scheduler.start()
    print("⏱️ AQI collector scheduled every 30 minutes")

    # Run immediately on startup to seed data
    try:
        await _run_aqi_collection()
        print("✅ Initial AQI data collected")
    except Exception as e:
        print(f"⚠️ Initial AQI collection failed: {e}")

    yield

    # Shutdown
    print("🛑 Shutting down...")
    scheduler.shutdown(wait=False)
    await close_db()
    await close_redis()
    print("✅ Cleanup complete")



# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    description="""
    🌬️ **AirShield** - Your Intelligent Air Quality Assistant
    
    An all-in-one air quality application that goes beyond monitoring 
    to provide **Action & Protection**.
    
    ## Features
    
    * 🌍 **Real-time Air Quality** - Get current AQI based on your location
    * 📊 **Historical Data** - View 24-hour air quality trends
    * 🛣️ **Clean Routing** - Find routes that minimize pollution exposure
    * 👤 **Personalization** - Health-aware recommendations
    * 👥 **Community Reports** - Crowdsourced pollution incidents
    
    ## Modules
    
    * **AQS** - Air Quality Service
    * **DPS** - Deep Personalization Service
    * **CGS** - Community & Gamification Service
    * **SHA** - Smart Home Automation
    * **ACB** - AI Chatbot Assistant
    """,
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# CORS middleware — origins loaded from CORS_ORIGINS env var (comma-separated)
_cors_origins = [o.strip() for o in settings.CORS_ORIGINS.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)

# Include API routers
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/", tags=["Root"])
async def root():
    """Health check endpoint."""
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "healthy",
        "docs": "/docs",
    }


@app.get("/health", tags=["Root"])
async def health_check():
    """Detailed health check — probes DB and Redis."""
    from sqlalchemy import text
    import redis.asyncio as aioredis
    from app.core.database import async_session_factory
    from app.core.redis import init_redis

    db_ok = False
    redis_ok = False

    try:
        async with async_session_factory() as session:
            await session.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        pass

    r: aioredis.Redis | None = None
    try:
        r = await init_redis()
        await r.ping()
        redis_ok = True
    except Exception:
        pass
    finally:
        if r:
            await r.aclose()

    status = "healthy" if db_ok and redis_ok else "degraded"
    return {
        "status": status,
        "database": "connected" if db_ok else "disconnected",
        "redis": "connected" if redis_ok else "disconnected",
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
    )
