"""
Tuya IoT Platform Adapter.

Integrates with Tuya Cloud API to control Tuya-compatible devices
(air purifiers, fans, AC units, etc.)

API Docs: https://developer.tuya.com/en/docs/cloud/
"""

import logging
import hashlib
import hmac
import time
import json
from typing import Any, Optional
import httpx

from .base_adapter import BaseDeviceAdapter

logger = logging.getLogger(__name__)

TUYA_BASE_URL = "https://openapi.tuyaus.com"  # US data center


class TuyaAdapter(BaseDeviceAdapter):
    """
    Adapter for Tuya IoT Platform.

    Supports control of any Tuya-compatible device via Tuya Cloud Open API.
    Device access_token in our DB stores the Tuya device_id (device-specific).
    """

    def __init__(self, client_id: str = "", client_secret: str = ""):
        """
        Args:
            client_id: Tuya Cloud app client_id
            client_secret: Tuya Cloud app client_secret
        Both are configured in .env as TUYA_CLIENT_ID, TUYA_CLIENT_SECRET.
        """
        from app.core.config import settings
        self.client_id = client_id or getattr(settings, "TUYA_CLIENT_ID", "")
        self.client_secret = client_secret or getattr(settings, "TUYA_CLIENT_SECRET", "")
        self._access_token: Optional[str] = None
        self._token_expires: float = 0

    def _sign(self, method: str, path: str, body: str = "", access_token: str = "") -> dict:
        """Build Tuya API headers with HMAC-SHA256 signature."""
        ts = str(int(time.time() * 1000))
        sign_str = self.client_id + (access_token or "") + ts + method.upper() + "\n" + \
                   "" + "\n" + "" + "\n" + path
        if body:
            import hashlib as hl
            h = hl.sha256(body.encode()).hexdigest()
            sign_str = sign_str.replace("\n" + path, "\n" + h + "\n" + path)

        signature = hmac.new(
            self.client_secret.encode(),
            sign_str.encode(),
            hashlib.sha256
        ).hexdigest().upper()

        return {
            "client_id": self.client_id,
            "access_token": access_token or "",
            "sign": signature,
            "sign_method": "HMAC-SHA256",
            "t": ts,
        }

    async def _get_access_token(self) -> Optional[str]:
        """Get or refresh Tuya platform access token."""
        if self._access_token and time.time() < self._token_expires:
            return self._access_token

        if not self.client_id or not self.client_secret:
            logger.warning("Tuya credentials not configured. Set TUYA_CLIENT_ID and TUYA_CLIENT_SECRET in .env")
            return None

        path = "/v1.0/token?grant_type=1"
        headers = self._sign("GET", path)

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(f"{TUYA_BASE_URL}{path}", headers=headers)
                resp.raise_for_status()
                data = resp.json()

            if data.get("success"):
                self._access_token = data["result"]["access_token"]
                self._token_expires = time.time() + data["result"]["expire_time"] - 60
                return self._access_token
        except Exception as e:
            logger.error(f"Tuya token fetch failed: {e}")

        return None

    async def send_command(self, device_id: str, access_token: str, command: str, value: Any) -> dict:
        """
        Send a DP (Data Point) command to a Tuya device.

        Common command mappings:
          - power on/off: {"switch_1": True/False}
          - set_mode: {"mode": "auto"/"sleep"/"turbo"}
          - set_speed: {"fan_speed_enum": "low"/"medium"/"high"}
        """
        token = await self._get_access_token()

        if not token:
            logger.warning(f"Tuya: no access token, simulating command {command}={value} for {device_id}")
            return {
                "success": True,
                "message": f"[Simulated] Command '{command}={value}' logged (Tuya credentials not configured)",
            }

        # Map generic command → Tuya DP
        dp_map = {
            "power": "switch_1",
            "set_mode": "mode",
            "set_speed": "fan_speed_enum",
            "set_fan_speed": "fan_speed_percent",
        }
        dp_key = dp_map.get(command, command)

        path = f"/v1.0/iot-03/devices/{device_id}/commands"
        body = json.dumps({"commands": [{"code": dp_key, "value": value}]})
        headers = self._sign("POST", path, body, token)
        headers["Content-Type"] = "application/json"

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(
                    f"{TUYA_BASE_URL}{path}",
                    headers=headers,
                    content=body,
                )
                resp.raise_for_status()
                data = resp.json()

            if data.get("success"):
                logger.info(f"Tuya: {device_id} executed {command}={value}")
                return {"success": True, "message": f"Command '{command}={value}' sent via Tuya Cloud"}
            else:
                logger.error(f"Tuya command failed: {data}")
                return {"success": False, "message": data.get("msg", "Tuya command failed")}

        except Exception as e:
            logger.error(f"Tuya send_command error: {e}")
            return {"success": False, "message": str(e)}

    async def get_device_status(self, device_id: str, access_token: str) -> dict:
        """Fetch current device properties from Tuya Cloud."""
        token = await self._get_access_token()
        if not token:
            return {}

        path = f"/v1.0/iot-03/devices/{device_id}/status"
        headers = self._sign("GET", path, access_token=token)

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(f"{TUYA_BASE_URL}{path}", headers=headers)
                resp.raise_for_status()
                data = resp.json()

            if data.get("success"):
                return {dp["code"]: dp["value"] for dp in data.get("result", [])}
        except Exception as e:
            logger.error(f"Tuya get_device_status error: {e}")

        return {}


# Singleton
tuya_adapter = TuyaAdapter()
