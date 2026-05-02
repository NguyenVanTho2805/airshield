"""
Test health check endpoint.
Verifies the application is running correctly.
"""

import pytest
from httpx import AsyncClient


class TestHealthCheck:
    """Test suite for health check endpoints."""
    
    @pytest.mark.asyncio
    async def test_root_returns_200(self, client: AsyncClient):
        """
        Test that GET / returns 200 OK.
        """
        response = await client.get("/")
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "AirShield"
        assert data["status"] == "healthy"
    
    @pytest.mark.asyncio
    async def test_health_endpoint_returns_200(self, client: AsyncClient):
        """
        Test that GET /health returns 200 OK.
        """
        response = await client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
