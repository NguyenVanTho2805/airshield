"""
Device Adapter Base Class.
Defines the interface that all device adapters must implement.
"""

from abc import ABC, abstractmethod
from typing import Any


class BaseDeviceAdapter(ABC):
    """
    Abstract base class for IoT device providers.

    Implement this interface for each supported provider
    (Tuya, Xiaomi, SwitchBot, etc.)
    """

    @abstractmethod
    async def send_command(
        self,
        device_id: str,
        access_token: str,
        command: str,
        value: Any,
    ) -> dict:
        """
        Send a control command to a device.

        Args:
            device_id: Provider-specific device identifier
            access_token: OAuth/API token for the device
            command: Command name (e.g. 'power', 'set_mode', 'set_speed')
            value: Command value (e.g. True, 'turbo', 5)

        Returns:
            dict with 'success': bool and 'message': str
        """
        raise NotImplementedError

    @abstractmethod
    async def get_device_status(
        self,
        device_id: str,
        access_token: str,
    ) -> dict:
        """
        Fetch current device status/properties.

        Returns:
            dict with device properties or empty dict on error
        """
        raise NotImplementedError
