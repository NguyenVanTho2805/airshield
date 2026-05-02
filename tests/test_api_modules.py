"""
Tests for Smart Home API endpoints.
"""

import pytest
from httpx import AsyncClient


class TestSmartHomeEndpoints:
    """Tests for Smart Home API."""

    @pytest.mark.asyncio
    async def test_list_devices(self, client: AsyncClient):
        """Test listing devices (should return empty or mock data)."""
        response = await client.get(
            "/api/v1/smart-home/devices",
            params={"user_id": "test-user-123"}
        )
        
        # Should return 200 even if empty
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_register_device(self, client: AsyncClient):
        """Test registering a new device."""
        response = await client.post(
            "/api/v1/smart-home/devices",
            json={
                "user_id": "test-user-123",
                "device_id": "purifier-001",
                "device_name": "Bedroom Purifier",
                "provider": "xiaomi",
                "access_token": "mock_token_123"
            }
        )
        
        assert response.status_code in [200, 201]

    @pytest.mark.asyncio
    async def test_device_command(self, client: AsyncClient):
        """Test sending command to device."""
        response = await client.post(
            "/api/v1/smart-home/devices/purifier-001/command",
            json={
                "command": "power",
                "value": "on"
            }
        )
        
        # May return 200 or 404 if device doesn't exist
        assert response.status_code in [200, 404]


class TestCommunityEndpoints:
    """Tests for Community API."""

    @pytest.mark.asyncio
    async def test_submit_report(self, client: AsyncClient):
        """Test submitting a pollution report."""
        response = await client.post(
            "/api/v1/community/report",
            json={
                "user_id": "test-user-123",
                "incident_type": "burning",
                "latitude": 21.0285,
                "longitude": 105.8542,
                "description": "Someone burning trash nearby"
            }
        )
        
        assert response.status_code in [200, 201]


class TestRoutingEndpoints:
    """Tests for Routing API."""

    @pytest.mark.asyncio
    async def test_calculate_route(self, client: AsyncClient):
        """Test route calculation."""
        response = await client.post(
            "/api/v1/routing/calculate",
            json={
                "origin_lat": 21.0285,
                "origin_lon": 105.8542,
                "dest_lat": 21.0378,
                "dest_lon": 105.8342
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        # Should have route data
        assert "routes" in data or "fastest" in data or "message" in data


class TestHealthProfileEndpoints:
    """Tests for Health Profile API."""

    @pytest.mark.asyncio
    async def test_update_health_profile(self, client: AsyncClient):
        """Test updating health profile."""
        response = await client.post(
            "/api/v1/user/health/profile",
            json={
                "user_id": "test-user-123",
                "birth_year": 1990,
                "conditions": ["asthma"],
                "sensitivity_level": 4
            }
        )
        
        assert response.status_code in [200, 201]

    @pytest.mark.asyncio
    async def test_get_recommendation(self, client: AsyncClient):
        """Test getting health recommendation."""
        response = await client.get(
            "/api/v1/user/health/recommendation",
            params={
                "user_id": "test-user-123",
                "aqi": 120
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        # Should have recommendation data
        assert "recommendations" in data or "perceived_aqi" in data or "message" in data
