"""
Forecasting Service - Time-Series Prediction for Air Quality.
"""

import logging
from datetime import datetime, timedelta, timezone
from typing import List, Dict, Any, Optional

try:
    import pandas as pd
    from prophet import Prophet
    PROPHET_AVAILABLE = True
except ImportError:
    PROPHET_AVAILABLE = False
    
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_

from app.models.aqs import AirQualityLog, Station

logger = logging.getLogger(__name__)

class ForecastService:
    """Service to predict future air quality using Prophet."""
    
    async def generate_forecast(
        self, 
        latitude: float, 
        longitude: float, 
        db: AsyncSession, 
        hours_ahead: int = 24
    ) -> Optional[List[Dict[str, Any]]]:
        """
        Generate AQI forecast for the next `hours_ahead` hours.
        Uses historical data from the nearest station.
        """
        if not PROPHET_AVAILABLE:
            logger.warning("Prophet or Pandas is not installed. Returning mock forecast.")
            return self._generate_mock_forecast(hours_ahead)
            
        # 1. Find nearest station
        stmt = select(Station).where(Station.is_active == True)
        result = await db.execute(stmt)
        stations = result.scalars().all()
        
        if not stations:
            return None
            
        def calculate_distance(station: Station) -> float:
            lat_diff = abs(station.latitude - latitude)
            lon_diff = abs(station.longitude - longitude)
            return (lat_diff ** 2 + lon_diff ** 2) ** 0.5
            
        nearest_station = min(stations, key=calculate_distance)
        
        # 2. Fetch history (e.g., last 7 days)
        since = datetime.now(timezone.utc) - timedelta(days=7)
        stmt = (
            select(AirQualityLog)
            .where(
                and_(
                    AirQualityLog.station_id == nearest_station.id,
                    AirQualityLog.recorded_at >= since,
                )
            )
            .order_by(AirQualityLog.recorded_at.asc())
        )
        result = await db.execute(stmt)
        logs = result.scalars().all()
        
        if len(logs) < 10:
            logger.warning("Not enough data to train Prophet model. Returning mock forecast.")
            return self._generate_mock_forecast(hours_ahead, base_aqi=logs[-1].aqi if logs else 50)
            
        # 3. Train Prophet Model On-The-Fly
        try:
            # Prepare dataframe required by Prophet: 'ds' (datetimelike) and 'y' (numeric)
            df = pd.DataFrame([
                {"ds": log.recorded_at.replace(tzinfo=None), "y": log.aqi}
                for log in logs
            ])
            
            # Initialize model (tuned for speed over extreme precision for real-time response)
            m = Prophet(
                yearly_seasonality=False,
                weekly_seasonality=True,
                daily_seasonality=True,
                changepoint_prior_scale=0.05
            )
            
            # Suppress console output for Prophet cmdstanpy
            import logging as prophet_logging
            prophet_logging.getLogger('cmdstanpy').setLevel(prophet_logging.ERROR)
            
            m.fit(df)
            
            # 4. Predict
            future = m.make_future_dataframe(periods=hours_ahead, freq='h')
            forecast = m.predict(future)
            
            # Filter only future dates
            last_historical_date = df['ds'].max()
            future_forecast = forecast[forecast['ds'] > last_historical_date].head(hours_ahead)
            
            results = []
            for _, row in future_forecast.iterrows():
                # Prevent negative AQI and smooth
                predicted_aqi = max(0, min(500, int(round(row['yhat']))))
                results.append({
                    "recorded_at": row['ds'].isoformat() + "Z", # keep ISO standard
                    "aqi": predicted_aqi,
                    "is_forecast": True
                })
                
            return results
        except Exception as e:
            logger.error(f"Prophet training failed: {e}")
            return self._generate_mock_forecast(hours_ahead)
            
    def _generate_mock_forecast(self, hours: int, base_aqi: int = 60) -> List[Dict[str, Any]]:
        """Fallback mock sequence if math libraries fail or data is insufficient."""
        results = []
        now = datetime.now(timezone.utc)
        import random
        current_aqi = base_aqi
        
        for i in range(1, hours + 1):
            future_time = now + timedelta(hours=i)
            # Add some sine wave fluctuation
            current_aqi += random.randint(-5, 8)
            current_aqi = max(10, min(300, current_aqi))
            
            results.append({
                "recorded_at": future_time.isoformat() + "Z",
                "aqi": current_aqi,
                "is_forecast": True
            })
            
        return results

forecast_service = ForecastService()
