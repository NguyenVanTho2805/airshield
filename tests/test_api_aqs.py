"""
Tests for Air Quality API endpoints.
"""

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.aqs import Station, AirQualityLog, StationSource
from datetime import datetime


class TestAirQualityAPI:
    """Test suite for /api/v1/air-quality endpoints."""
    
    @pytest.mark.asyncio
    async def test_get_current_returns_404_when_no_stations(
        self, client: AsyncClient
    ):
        """
        Test that GET /current returns 404 when no stations exist.
        """
        response = await client.get(
            "/api/v1/air-quality/current",
            params={"latitude": 10.8, "longitude": 106.7}
        )
        
        assert response.status_code == 404
        assert "No active stations found" in response.json()["detail"]
    
    @pytest.mark.asyncio
    async def test_get_current_returns_data_with_station(
        self, client: AsyncClient, db_session: AsyncSession
    ):
        """
        Test that GET /current returns AQI data when station exists.
        """
        # Create test station
        station = Station(
            name="Test Station HCMC",
            source=StationSource.IQAIR,
            latitude=10.8,
            longitude=106.7,
            is_active=True,
        )
        db_session.add(station)
        await db_session.commit()
        await db_session.refresh(station)
        
        # Create test log
        log = AirQualityLog(
            station_id=station.id,
            aqi=85,
            pm25=35.5,
            temperature=30.0,
            humidity=75.0,
            recorded_at=datetime.utcnow(),
        )
        db_session.add(log)
        await db_session.commit()
        
        # Test endpoint
        response = await client.get(
            "/api/v1/air-quality/current",
            params={"latitude": 10.8, "longitude": 106.7}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["aqi"] == 85
        assert data["pm25"] == 35.5
        assert data["station_name"] == "Test Station HCMC"
    
    @pytest.mark.asyncio
    async def test_get_history_returns_empty_list_when_no_data(
        self, client: AsyncClient, db_session: AsyncSession
    ):
        """
        Test that GET /history returns empty list when no history exists.
        """
        # Create test station
        station = Station(
            name="Test Station",
            source=StationSource.PAMAIR,
            latitude=21.0,
            longitude=105.8,
            is_active=True,
        )
        db_session.add(station)
        await db_session.commit()
        
        # Test endpoint
        response = await client.get(
            "/api/v1/air-quality/history",
            params={"latitude": 21.0, "longitude": 105.8, "hours": 24}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["station_name"] == "Test Station"
        assert data["data"] == []
