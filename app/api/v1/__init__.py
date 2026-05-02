# API v1 routers
from fastapi import APIRouter

from .auth import router as auth_router
from .air_quality import router as air_quality_router
from .routing import router as routing_router
from .health import router as health_router
from .community import router as community_router
from .smart_home import router as smart_home_router
from .chatbot import router as chatbot_router

api_router = APIRouter()

api_router.include_router(auth_router, prefix="/auth", tags=["Authentication"])
api_router.include_router(air_quality_router, prefix="/air-quality", tags=["Air Quality"])
api_router.include_router(routing_router, prefix="/routing", tags=["Routing"])
api_router.include_router(health_router, prefix="/user/health", tags=["Health Profile"])
api_router.include_router(community_router, prefix="/community", tags=["Community"])
api_router.include_router(smart_home_router, prefix="/smart-home", tags=["Smart Home"])
api_router.include_router(chatbot_router, prefix="/chatbot", tags=["AI Chatbot"])


