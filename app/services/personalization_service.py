"""
Personalization Service - Health-based AQI Adjustment.
Calculates perceived AQI based on user health profile.
"""

import json
import os
from functools import lru_cache
from dataclasses import dataclass
from typing import List, Optional
from enum import Enum


class RiskLevel(Enum):
    """Risk level categories."""
    LOW = "low"
    MODERATE = "moderate"
    HIGH = "high"
    VERY_HIGH = "very_high"
    HAZARDOUS = "hazardous"


@dataclass
class HealthWeights:
    """Health condition weights for AQI adjustment."""
    # Base weights
    NORMAL: float = 1.0
    ELDERLY: float = 1.5  # Age > 65
    CHILD: float = 1.3    # Age < 12
    
    # Condition-specific weights
    ASTHMA: float = 2.5
    COPD: float = 2.8
    HEART_DISEASE: float = 2.2
    SINUS: float = 1.8
    ALLERGIES: float = 1.5
    PREGNANT: float = 1.6


@dataclass
class PersonalizedAdvice:
    """Personalized advice based on perceived AQI."""
    perceived_aqi: float
    risk_level: RiskLevel
    is_high_risk: bool
    recommendations: List[str]
    warning_message: Optional[str] = None


# i18n directory
_I18N_DIR = os.path.join(os.path.dirname(__file__), "..", "i18n")


@lru_cache(maxsize=4)
def _load_i18n(lang: str) -> dict:
    """
    Load i18n JSON file for the given language.
    Falls back to English if language file not found.
    """
    path = os.path.join(_I18N_DIR, f"{lang}.json")
    if not os.path.exists(path):
        path = os.path.join(_I18N_DIR, "en.json")
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}


class PersonalizationService:
    """
    Personalization Engine.
    Calculates perceived AQI based on user health profile.
    
    Formula: Perceived_AQI = Real_AQI * Health_Weight
    Where Health_Weight is determined by user's age and conditions.
    """
    
    CONDITION_WEIGHTS = {
        "asthma": HealthWeights.ASTHMA,
        "copd": HealthWeights.COPD,
        "heart_disease": HealthWeights.HEART_DISEASE,
        "sinus": HealthWeights.SINUS,
        "allergies": HealthWeights.ALLERGIES,
        "pregnant": HealthWeights.PREGNANT,
    }
    
    HIGH_RISK_THRESHOLD = 150
    
    def calculate_age_weight(self, birth_year: Optional[int]) -> float:
        """
        Calculate weight based on user's age.
        
        Args:
            birth_year: User's birth year
        
        Returns:
            Age-based weight multiplier
        """
        if birth_year is None:
            return HealthWeights.NORMAL
        
        from datetime import datetime
        current_year = datetime.now().year
        age = current_year - birth_year
        
        if age >= 65:
            return HealthWeights.ELDERLY
        elif age <= 12:
            return HealthWeights.CHILD
        else:
            return HealthWeights.NORMAL
    
    def calculate_condition_weight(self, conditions: Optional[List[str]]) -> float:
        """
        Calculate weight based on health conditions.
        Uses the highest weight among all conditions.
        
        Args:
            conditions: List of health condition tags
        
        Returns:
            Maximum condition weight
        """
        if not conditions:
            return HealthWeights.NORMAL
        
        max_weight = HealthWeights.NORMAL
        for condition in conditions:
            condition_lower = condition.lower().replace(" ", "_")
            weight = self.CONDITION_WEIGHTS.get(condition_lower, HealthWeights.NORMAL)
            max_weight = max(max_weight, weight)
        
        return max_weight
    
    def calculate_health_weight(
        self,
        birth_year: Optional[int] = None,
        conditions: Optional[List[str]] = None,
        sensitivity_level: int = 3
    ) -> float:
        """
        Calculate combined health weight.
        
        The final weight is the maximum of age and condition weights,
        adjusted by user's sensitivity preference.
        
        Args:
            birth_year: User's birth year
            conditions: List of health conditions
            sensitivity_level: User preference 1-5 (default 3)
        
        Returns:
            Combined health weight multiplier
        """
        age_weight = self.calculate_age_weight(birth_year)
        condition_weight = self.calculate_condition_weight(conditions)
        
        # Use maximum of age and condition weights
        base_weight = max(age_weight, condition_weight)
        
        # Adjust by sensitivity level (1-5 maps to 0.8-1.2)
        sensitivity_factor = 0.8 + (sensitivity_level - 1) * 0.1
        
        return base_weight * sensitivity_factor
    
    def calculate_perceived_aqi(
        self,
        real_aqi: int,
        birth_year: Optional[int] = None,
        conditions: Optional[List[str]] = None,
        sensitivity_level: int = 3
    ) -> float:
        """
        Calculate perceived AQI for a user.
        
        Formula: Perceived_AQI = Real_AQI * Health_Weight
        
        Args:
            real_aqi: Actual AQI reading
            birth_year: User's birth year
            conditions: List of health conditions
            sensitivity_level: User preference 1-5
        
        Returns:
            Perceived AQI value
        """
        health_weight = self.calculate_health_weight(
            birth_year, conditions, sensitivity_level
        )
        return real_aqi * health_weight
    
    def get_risk_level(self, perceived_aqi: float) -> RiskLevel:
        """
        Determine risk level based on perceived AQI.
        
        Args:
            perceived_aqi: Calculated perceived AQI
        
        Returns:
            Risk level category
        """
        if perceived_aqi <= 50:
            return RiskLevel.LOW
        elif perceived_aqi <= 100:
            return RiskLevel.MODERATE
        elif perceived_aqi <= 150:
            return RiskLevel.HIGH
        elif perceived_aqi <= 200:
            return RiskLevel.VERY_HIGH
        else:
            return RiskLevel.HAZARDOUS
    
    def get_recommendations(
        self,
        risk_level: RiskLevel,
        conditions: Optional[List[str]] = None,
        lang: str = "vi",
    ) -> List[str]:
        """
        Get personalized recommendations based on risk level and language.

        Args:
            risk_level: Calculated risk level
            conditions: User's health conditions
            lang: Language code ('vi' or 'en'), defaults to Vietnamese

        Returns:
            List of recommendation strings in the requested language
        """
        i18n = _load_i18n(lang)
        rec_map = i18n.get("recommendations", {})
        cond_map = i18n.get("conditions", {})

        risk_key = risk_level.value  # 'low', 'moderate', 'high', 'very_high', 'hazardous'
        recommendations = list(rec_map.get(risk_key, []))

        # Add condition-specific advice
        if conditions:
            for condition in conditions:
                cond_key = condition.lower().replace(" ", "_")
                if cond_key in cond_map:
                    recommendations.append(cond_map[cond_key])

        return recommendations
    
    def get_personalized_advice(
        self,
        real_aqi: int,
        birth_year: Optional[int] = None,
        conditions: Optional[List[str]] = None,
        sensitivity_level: int = 3,
        lang: str = "vi",
    ) -> PersonalizedAdvice:
        """
        Generate complete personalized advice for a user.

        Args:
            real_aqi: Actual AQI reading
            birth_year: User's birth year
            conditions: List of health conditions
            sensitivity_level: User preference 1-5
            lang: Language code ('vi' or 'en')

        Returns:
            PersonalizedAdvice with recommendations in the requested language
        """
        perceived_aqi = self.calculate_perceived_aqi(
            real_aqi, birth_year, conditions, sensitivity_level
        )
        risk_level = self.get_risk_level(perceived_aqi)
        is_high_risk = perceived_aqi > self.HIGH_RISK_THRESHOLD
        recommendations = self.get_recommendations(risk_level, conditions, lang)

        warning_message = None
        if is_high_risk:
            i18n = _load_i18n(lang)
            template = i18n.get("warnings", {}).get("high_risk", "")
            warning_message = template.format(perceived_aqi=int(perceived_aqi))

        return PersonalizedAdvice(
            perceived_aqi=perceived_aqi,
            risk_level=risk_level,
            is_high_risk=is_high_risk,
            recommendations=recommendations,
            warning_message=warning_message,
        )
