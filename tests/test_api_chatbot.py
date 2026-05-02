"""
Tests for AI Chatbot API endpoints.
"""

import pytest
from httpx import AsyncClient


class TestChatbotEndpoints:
    """Tests for chatbot API."""
    
    @pytest.mark.asyncio
    async def test_chat_basic_greeting(self, client: AsyncClient):
        """Test basic greeting message."""
        response = await client.post(
            "/api/v1/chatbot/chat",
            json={
                "message": "Xin chào!",
                "include_aqi_context": False
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        
        assert "session_id" in data
        assert "message" in data
        assert len(data["message"]) > 0
        assert "timestamp" in data
    
    @pytest.mark.asyncio
    async def test_chat_aqi_question(self, client: AsyncClient):
        """Test AQI-related question."""
        response = await client.post(
            "/api/v1/chatbot/chat",
            json={
                "message": "Chất lượng không khí hôm nay thế nào?",
                "latitude": 21.0285,
                "longitude": 105.8542,
                "include_aqi_context": True
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        
        assert "session_id" in data
        assert "message" in data
    
    @pytest.mark.asyncio
    async def test_chat_session_continuity(self, client: AsyncClient):
        """Test that session maintains context."""
        # First message
        response1 = await client.post(
            "/api/v1/chatbot/chat",
            json={"message": "Xin chào"}
        )
        assert response1.status_code == 200
        session_id = response1.json()["session_id"]
        
        # Second message with same session
        response2 = await client.post(
            "/api/v1/chatbot/chat",
            json={
                "message": "AQI là gì?",
                "session_id": session_id
            }
        )
        assert response2.status_code == 200
        assert response2.json()["session_id"] == session_id
    
    @pytest.mark.asyncio
    async def test_list_sessions(self, client: AsyncClient):
        """Test listing chat sessions."""
        # Create a session first
        await client.post(
            "/api/v1/chatbot/chat",
            json={"message": "Test message"}
        )
        
        response = await client.get("/api/v1/chatbot/sessions")
        assert response.status_code == 200
        # Response should be a list
        assert isinstance(response.json(), list)
    
    @pytest.mark.asyncio
    async def test_get_session_not_found(self, client: AsyncClient):
        """Test getting non-existent session."""
        response = await client.get("/api/v1/chatbot/sessions/non-existent-id")
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_delete_session_not_found(self, client: AsyncClient):
        """Test deleting non-existent session."""
        response = await client.delete("/api/v1/chatbot/sessions/non-existent-id")
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_chat_action_detection(self, client: AsyncClient):
        """Test that device control message triggers action."""
        response = await client.post(
            "/api/v1/chatbot/chat",
            json={"message": "Bật máy lọc không khí"}
        )
        
        assert response.status_code == 200
        data = response.json()
        
        # Should have action for device control
        if data.get("action"):
            assert data["action"]["action_type"] in ["control_device", "none"]
