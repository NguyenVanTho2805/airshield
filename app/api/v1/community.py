"""
Community API Router.
Endpoints: /api/v1/community

Handles crowdsourced pollution incident reports with trust scoring.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from datetime import datetime
from uuid import UUID

from geoalchemy2.functions import ST_SetSRID, ST_MakePoint

from app.core.database import get_db
from app.core.auth import get_current_active_user
from app.models.user import User
from app.models.cgs import CommunityReport, IncidentType, ReportStatus
from app.schemas.schemas import (
    CommunityReportCreate,
    CommunityReportResponse,
)

router = APIRouter()


# ============ Additional Schemas ============

class VerifyReportRequest(BaseModel):
    """Verify or reject a community report."""
    verified: bool  # True = verified accurate, False = reject
    comment: Optional[str] = None


class ReportListItem(BaseModel):
    """Lightweight report item for listing."""
    id: int
    incident_type: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    description: Optional[str] = None
    status: str
    trust_score: float
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ============ Endpoints ============

@router.post("/report", response_model=CommunityReportResponse)
async def create_pollution_report(
    report_data: CommunityReportCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Submit a pollution incident report.

    Community members can report local pollution events with location and images.
    Initial trust_score = 0.5. Increases when others verify it.
    """
    geom = ST_SetSRID(
        ST_MakePoint(report_data.longitude, report_data.latitude),
        4326
    )

    incident_type_map = {
        "burning": IncidentType.BURNING,
        "dust": IncidentType.DUST,
        "smoke": IncidentType.SMOKE,
        "chemical": IncidentType.CHEMICAL,
        "other": IncidentType.OTHER,
    }

    report = CommunityReport(
        user_id=current_user.id,
        incident_type=incident_type_map.get(
            report_data.incident_type.value,
            IncidentType.OTHER
        ),
        geom=geom,
        image_url=report_data.image_url,
        description=report_data.description,
        status=ReportStatus.PENDING,
        trust_score=0.5,
    )

    db.add(report)
    await db.commit()
    await db.refresh(report)

    return CommunityReportResponse(
        id=report.id,
        user_id=report.user_id,
        incident_type=report_data.incident_type,
        latitude=report_data.latitude,
        longitude=report_data.longitude,
        image_url=report.image_url,
        description=report.description,
        status=report.status.value,
        trust_score=report.trust_score,
        created_at=report.created_at,
    )


@router.get("/reports", response_model=List[ReportListItem])
async def list_reports(
    status: Optional[str] = Query(None, description="Filter by status: pending, verified, rejected"),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    List community pollution reports.

    Returns the most recent reports, optionally filtered by status.
    Accessible to all authenticated users.
    """
    stmt = select(CommunityReport).order_by(CommunityReport.created_at.desc()).limit(limit)

    if status:
        status_map = {
            "pending": ReportStatus.PENDING,
            "verified": ReportStatus.VERIFIED,
            "rejected": ReportStatus.REJECTED,
        }
        if status in status_map:
            stmt = stmt.where(CommunityReport.status == status_map[status])

    result = await db.execute(stmt)
    reports = result.scalars().all()

    return [
        ReportListItem(
            id=r.id,
            incident_type=r.incident_type.value,
            description=r.description,
            status=r.status.value,
            trust_score=r.trust_score,
            created_at=r.created_at,
        )
        for r in reports
    ]


@router.post("/report/{report_id}/verify")
async def verify_report(
    report_id: int,
    body: VerifyReportRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Verify or reject a community pollution report.

    **Trust Score Algorithm:**
    - Each verification → trust_score += 0.1 (max 1.0)
    - Each rejection → trust_score -= 0.15 (min 0.0)
    - Status → VERIFIED when trust_score >= 0.7
    - Status → REJECTED when trust_score <= 0.1

    Users cannot verify their own reports.
    """
    stmt = select(CommunityReport).where(CommunityReport.id == report_id)
    result = await db.execute(stmt)
    report = result.scalar_one_or_none()

    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    # Prevent self-verification
    if report.user_id == current_user.id:
        raise HTTPException(
            status_code=400,
            detail="You cannot verify your own report"
        )

    # Apply trust score delta
    if body.verified:
        report.trust_score = min(1.0, round(report.trust_score + 0.1, 2))
    else:
        report.trust_score = max(0.0, round(report.trust_score - 0.15, 2))

    # Auto-update status based on trust score
    if report.trust_score >= 0.7:
        report.status = ReportStatus.VERIFIED
    elif report.trust_score <= 0.1:
        report.status = ReportStatus.REJECTED
    # else stays PENDING

    await db.commit()

    return {
        "report_id": report_id,
        "action": "verified" if body.verified else "rejected",
        "new_trust_score": report.trust_score,
        "new_status": report.status.value,
        "comment": body.comment,
    }
