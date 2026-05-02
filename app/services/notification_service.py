"""
Push Notification Service (FCM - Firebase Cloud Messaging).

Sends push notifications to mobile devices when:
- AQI exceeds user threshold
- Automation rule triggers
- System alerts

Setup:
1. Create Firebase project at https://console.firebase.google.com/
2. Download service account JSON → save as app/firebase_credentials.json
3. Set FIREBASE_CREDENTIALS_PATH in .env
"""

import logging
from typing import Optional, List

logger = logging.getLogger(__name__)

try:
    import firebase_admin
    from firebase_admin import credentials, messaging
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    logger.warning("firebase-admin not installed. Run: pip install firebase-admin")


class NotificationService:
    """
    Firebase Cloud Messaging (FCM) notification service.

    Gracefully falls back to logging when Firebase is not configured.
    """

    def __init__(self):
        self._initialized = False
        self._initialize()

    def _initialize(self):
        """Initialize Firebase Admin SDK."""
        if not FIREBASE_AVAILABLE:
            return

        from app.core.config import settings
        cred_path = getattr(settings, "FIREBASE_CREDENTIALS_PATH", "")

        if not cred_path:
            logger.info("FIREBASE_CREDENTIALS_PATH not set. Notifications will be logged only.")
            return

        try:
            if not firebase_admin._apps:
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
            self._initialized = True
            logger.info("✅ Firebase Admin SDK initialized")
        except Exception as e:
            logger.error(f"Firebase init failed: {e}")

    async def send_to_user(
        self,
        fcm_token: str,
        title: str,
        body: str,
        data: Optional[dict] = None,
    ) -> bool:
        """
        Send a push notification to a specific device.

        Args:
            fcm_token: Device FCM registration token (stored in users.fcm_token)
            title: Notification title
            body: Notification body text
            data: Optional additional data payload

        Returns:
            True if sent successfully, False otherwise.
        """
        if not fcm_token:
            logger.warning("send_to_user: no FCM token provided")
            return False

        if not self._initialized:
            # Graceful fallback: log the notification
            logger.info(f"[FCM Simulated] → {fcm_token[:12]}... | {title}: {body}")
            return True

        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                data={str(k): str(v) for k, v in (data or {}).items()},
                token=fcm_token,
                android=messaging.AndroidConfig(priority="high"),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(sound="default")
                    )
                ),
            )
            response = messaging.send(message)
            logger.info(f"FCM sent: {response} → {title}")
            return True
        except Exception as e:
            logger.error(f"FCM send failed: {e}")
            return False

    async def send_aqi_alert(
        self,
        fcm_token: str,
        aqi: int,
        station_name: str,
        perceived_aqi: Optional[float] = None,
    ) -> bool:
        """
        Send AQI threshold alert notification.

        Called when AQI exceeds safe threshold for a user.
        """
        if aqi <= 50:
            return False  # Good air quality, no alert needed

        # Determine severity and Vietnamese message
        if aqi <= 100:
            title = "⚠️ Chất Lượng Không Khí Trung Bình"
            body = f"AQI {aqi} tại {station_name}. Nhóm nhạy cảm cần chú ý."
        elif aqi <= 150:
            title = "🟠 Không Khí Kém"
            body = f"AQI {aqi} tại {station_name}. Hạn chế ra ngoài, đeo khẩu trang."
        elif aqi <= 200:
            title = "🔴 Không Khí Không Lành Mạnh"
            body = f"AQI {aqi} tại {station_name}! Tránh hoạt động ngoài trời."
        else:
            title = "☠️ Nguy Hiểm - Không Khí Cực Kỳ Ô Nhiễm"
            body = f"AQI {aqi} tại {station_name}! Ở trong nhà, đóng cửa sổ ngay!"

        data = {
            "type": "aqi_alert",
            "aqi": str(aqi),
            "station": station_name,
        }
        if perceived_aqi:
            data["perceived_aqi"] = str(round(perceived_aqi))

        return await self.send_to_user(fcm_token, title, body, data)

    async def send_automation_triggered(
        self,
        fcm_token: str,
        device_name: str,
        action: str,
        trigger_aqi: int,
    ) -> bool:
        """
        Notify user that an automation rule was triggered.
        """
        title = "🏠 Smart Home Tự Động"
        body = f"{device_name}: {action} (AQI={trigger_aqi})"
        return await self.send_to_user(
            fcm_token, title, body,
            {"type": "automation_triggered", "aqi": str(trigger_aqi)}
        )


# Singleton
notification_service = NotificationService()
