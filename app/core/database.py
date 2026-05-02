"""
Async SQLAlchemy database configuration.
Uses asyncpg driver for PostgreSQL connections.
"""

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.pool import NullPool
from typing import AsyncGenerator

from .config import settings

# Create async engine
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    poolclass=NullPool,  # Recommended for async
)

# Session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

# Alias for use in background tasks (outside request context)
async_session_factory = AsyncSessionLocal


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency that provides a database session.
    Yields a session and ensures cleanup after request.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def init_db():
    """Initialize database tables."""
    from app.models.base import Base
    
    async with engine.begin() as conn:
        # Create PostGIS extension if not exists
        await conn.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
        await conn.run_sync(Base.metadata.create_all)


async def close_db():
    """Close database connections."""
    await engine.dispose()
