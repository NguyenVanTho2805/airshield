"""
Routing Service - Clean Routing Algorithm.
Calculates optimal routes considering air quality.

In production: integrates with Google Maps Directions API to get real routes.
Falls back to simplified calculation if API key not configured.
"""

import logging
from dataclasses import dataclass
from typing import List, Tuple, Optional
import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)


@dataclass
class Coordinate:
    """Geographic coordinate."""
    latitude: float
    longitude: float


@dataclass
class RouteSegment:
    """A segment of a route with distance and AQI data."""
    start: Coordinate
    end: Coordinate
    distance_km: float
    aqi_factor: float  # Normalized 0.0 to 1.0


@dataclass
class Route:
    """Complete route with segments and total cost."""
    segments: List[RouteSegment]
    total_distance_km: float
    total_time_minutes: float
    weighted_cost: float
    route_type: str  # "fastest" or "cleanest"


class RoutingService:
    """
    Clean Routing Engine.
    Calculates routes optimized for air quality exposure.

    Formula: Cost = (Distance / Speed) * (1 + alpha * AQI_Factor)
    Where:
        - AQI_Factor is normalized pollution (0.0 = clean, 1.0 = very polluted)
        - alpha is the weight for air quality consideration
    """

    def __init__(self, alpha: float = None):
        self.alpha = alpha if alpha is not None else settings.ROUTING_ALPHA

    def normalize_aqi(self, aqi: int) -> float:
        """Normalize AQI value to 0.0-1.0 range."""
        if aqi <= 50:
            return aqi / 500
        elif aqi <= 100:
            return 0.1 + (aqi - 50) / 250
        elif aqi <= 150:
            return 0.3 + (aqi - 100) / 250
        elif aqi <= 200:
            return 0.5 + (aqi - 150) / 250
        elif aqi <= 300:
            return 0.7 + (aqi - 200) / 500
        else:
            return min(1.0, 0.9 + (aqi - 300) / 1000)

    def calculate_segment_cost(self, distance_km: float, speed_kmh: float, aqi_factor: float) -> float:
        """Calculate cost for a route segment."""
        base_time = distance_km / speed_kmh
        return base_time * (1 + self.alpha * aqi_factor)

    def calculate_route_cost(self, segments: List[RouteSegment], speed_kmh: float = 30.0) -> float:
        """Calculate total cost for a complete route."""
        return sum(
            self.calculate_segment_cost(s.distance_km, speed_kmh, s.aqi_factor)
            for s in segments
        )

    async def _fetch_google_maps_route(
        self,
        origin: Coordinate,
        destination: Coordinate,
        mode: str,
        avoid: Optional[str] = None,
    ) -> Optional[dict]:
        """
        Call Google Maps Directions API.

        Returns parsed route info or None if API unavailable / not configured.
        """
        if not settings.GOOGLE_MAPS_API_KEY:
            logger.debug("GOOGLE_MAPS_API_KEY not set, using approximation.")
            return None

        params = {
            "origin": f"{origin.latitude},{origin.longitude}",
            "destination": f"{destination.latitude},{destination.longitude}",
            "mode": mode,
            "key": settings.GOOGLE_MAPS_API_KEY,
            "departure_time": "now",
        }
        if avoid:
            params["avoid"] = avoid  # e.g. "highways" for cleaner route

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(
                    "https://maps.googleapis.com/maps/api/directions/json",
                    params=params,
                )
                resp.raise_for_status()
                data = resp.json()

            if data.get("status") != "OK" or not data.get("routes"):
                logger.warning(f"Google Maps API: {data.get('status')}")
                return None

            leg = data["routes"][0]["legs"][0]
            distance_m = leg["distance"]["value"]
            duration_s = leg["duration"]["value"]

            return {
                "distance_km": distance_m / 1000,
                "duration_minutes": duration_s / 60,
            }
        except Exception as e:
            logger.error(f"Google Maps fetch failed: {e}")
            return None

    def _haversine_km(self, a: Coordinate, b: Coordinate) -> float:
        """Approximate straight-line distance in km using Haversine formula."""
        import math
        R = 6371
        lat1, lon1, lat2, lon2 = map(math.radians, [a.latitude, a.longitude, b.latitude, b.longitude])
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
        return R * 2 * math.asin(math.sqrt(h))

    async def find_routes(
        self,
        origin: Coordinate,
        destination: Coordinate,
        mode: str = "driving",
    ) -> Tuple[Route, Route]:
        """
        Find both fastest and cleanest routes.

        - If GOOGLE_MAPS_API_KEY is set: calls Google Directions API.
        - Otherwise: uses Haversine approximation with realistic assumptions.
        """
        speeds = {"driving": 40.0, "cycling": 15.0, "walking": 5.0}
        speed = speeds.get(mode, 40.0)

        straight_km = self._haversine_km(origin, destination)

        # --- Fastest Route: via Google Maps (or approximation) ---
        gmap_fastest = await self._fetch_google_maps_route(origin, destination, mode)

        if gmap_fastest:
            fastest_distance = gmap_fastest["distance_km"]
            fastest_time = gmap_fastest["duration_minutes"]
        else:
            # Realistic urban factor (roads ~30% longer than straight line)
            fastest_distance = round(straight_km * 1.3, 2)
            fastest_time = (fastest_distance / speed) * 60

        # AQI factor: main roads tend to be more polluted (assume 0.5 moderate)
        fastest_aqi_factor = 0.5
        fastest_segment = RouteSegment(
            start=origin,
            end=destination,
            distance_km=fastest_distance,
            aqi_factor=fastest_aqi_factor,
        )
        fastest_cost = self.calculate_segment_cost(fastest_distance, speed, fastest_aqi_factor)
        fastest_route = Route(
            segments=[fastest_segment],
            total_distance_km=fastest_distance,
            total_time_minutes=round(fastest_time, 1),
            weighted_cost=round(fastest_cost, 4),
            route_type="fastest",
        )

        # --- Cleanest Route: avoid highways → longer but less polluted ---
        gmap_clean = await self._fetch_google_maps_route(origin, destination, mode, avoid="highways")

        if gmap_clean:
            clean_distance = gmap_clean["distance_km"]
            clean_time = gmap_clean["duration_minutes"]
        else:
            # Parks/residential roads: ~50% longer but much less polluted
            clean_distance = round(straight_km * 1.6, 2)
            clean_time = (clean_distance / speed) * 60

        # Cleaner roads: trees, parks = low AQI factor
        clean_aqi_factor = 0.15
        clean_segment = RouteSegment(
            start=origin,
            end=destination,
            distance_km=clean_distance,
            aqi_factor=clean_aqi_factor,
        )
        clean_cost = self.calculate_segment_cost(clean_distance, speed, clean_aqi_factor)
        cleanest_route = Route(
            segments=[clean_segment],
            total_distance_km=clean_distance,
            total_time_minutes=round(clean_time, 1),
            weighted_cost=round(clean_cost, 4),
            route_type="cleanest",
        )

        logger.info(
            f"Routes: fastest={fastest_distance:.1f}km, "
            f"cleanest={clean_distance:.1f}km "
            f"(straight={straight_km:.1f}km, via={'GoogleMaps' if gmap_fastest else 'Haversine'})"
        )

        return fastest_route, cleanest_route
