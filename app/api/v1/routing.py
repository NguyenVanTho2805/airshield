"""
Routing API Router.
Endpoints: /api/v1/routing
"""

from fastapi import APIRouter
from app.schemas.schemas import (
    RouteRequest,
    RoutesResponse,
    RouteResponse,
    RouteSegmentResponse,
)
from app.services.routing_service import RoutingService, Coordinate

router = APIRouter()


@router.post("/calculate", response_model=RoutesResponse)
async def calculate_routes(request: RouteRequest):
    """
    Calculate both fastest and cleanest routes.
    
    Input: Start point, end point, and travel mode.
    Output: Two route options with distance, time, and AQI-weighted cost.
    """
    routing_service = RoutingService()
    
    origin = Coordinate(
        latitude=request.start.latitude,
        longitude=request.start.longitude,
    )
    destination = Coordinate(
        latitude=request.end.latitude,
        longitude=request.end.longitude,
    )
    
    fastest, cleanest = await routing_service.find_routes(
        origin=origin,
        destination=destination,
        mode=request.mode.value,
    )
    
    def route_to_response(route) -> RouteResponse:
        return RouteResponse(
            route_type=route.route_type,
            total_distance_km=route.total_distance_km,
            total_time_minutes=route.total_time_minutes,
            weighted_cost=route.weighted_cost,
            segments=[
                RouteSegmentResponse(
                    distance_km=seg.distance_km,
                    aqi_factor=seg.aqi_factor,
                )
                for seg in route.segments
            ],
        )
    
    return RoutesResponse(
        fastest=route_to_response(fastest),
        cleanest=route_to_response(cleanest),
    )
