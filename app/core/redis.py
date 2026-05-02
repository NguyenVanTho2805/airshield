"""
Redis connection configuration.
Provides async Redis client for caching.
"""

import redis.asyncio as redis
from typing import AsyncGenerator

from .config import settings

# Redis connection pool
redis_pool = redis.ConnectionPool.from_url(
    settings.REDIS_URL,
    decode_responses=True,
)


async def get_redis() -> AsyncGenerator[redis.Redis, None]:
    """
    Dependency that provides a Redis client.
    """
    client = redis.Redis(connection_pool=redis_pool)
    try:
        yield client
    finally:
        await client.close()


async def init_redis() -> redis.Redis:
    """Initialize and return Redis client."""
    return redis.Redis(connection_pool=redis_pool)


async def close_redis():
    """Close Redis connections."""
    await redis_pool.disconnect()
