"""
Smart Home API Router.
Endpoints: /api/v1/smart-home
Manages IoT devices and commands.
"""

from uuid import UUID
from typing import List, Any
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel

from app.core.database import get_db
from app.core.auth import get_current_active_user
from app.models.user import User
from app.models.sha import UserDevice, AutomationRule
from app.services.device_adapters.tuya_adapter import tuya_adapter


# ============ Schemas ============

class DeviceResponse(BaseModel):
    """Device response schema."""
    device_id: str
    user_id: UUID
    provider: str
    device_name: str
    is_active: bool
    
    class Config:
        from_attributes = True


class DeviceCreate(BaseModel):
    """Request to register a new device."""
    device_id: str
    provider: str  # "xiaomi", "samsung", etc.
    access_token: str | None = None
    device_name: str = "Air Purifier"


class DeviceCommand(BaseModel):
    """Command to send to device."""
    command: str  # "set_mode", "power", etc.
    value: str | int | bool  # "turbo", True, etc.


class CommandResponse(BaseModel):
    """Response after sending command."""
    success: bool
    device_id: str
    command: str
    message: str


# ============ Router ============

router = APIRouter()


@router.get("/devices", response_model=List[DeviceResponse])
async def list_devices(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Return list of devices for the current authenticated user.
    """
    stmt = select(UserDevice).where(UserDevice.user_id == current_user.id)
    result = await db.execute(stmt)
    devices = result.scalars().all()
    
    return [
        DeviceResponse(
            device_id=d.device_id,
            user_id=d.user_id,
            provider=d.provider,
            device_name=d.device_name,
            is_active=d.is_active,
        )
        for d in devices
    ]


@router.post("/devices", response_model=DeviceResponse)
async def register_device(
    request: DeviceCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Register a new IoT device for the current user.
    """
    # Check if device already exists
    stmt = select(UserDevice).where(UserDevice.device_id == request.device_id)
    result = await db.execute(stmt)
    existing = result.scalar_one_or_none()
    
    if existing:
        raise HTTPException(status_code=400, detail="Device already registered")
    
    device = UserDevice(
        device_id=request.device_id,
        user_id=current_user.id,
        provider=request.provider,
        access_token=request.access_token,
        device_name=request.device_name,
        is_active=True,
    )
    
    db.add(device)
    await db.commit()
    await db.refresh(device)
    
    return DeviceResponse(
        device_id=device.device_id,
        user_id=device.user_id,
        provider=device.provider,
        device_name=device.device_name,
        is_active=device.is_active,
    )


@router.post("/devices/{device_id}/command", response_model=CommandResponse)
async def send_command(
    device_id: str,
    command: DeviceCommand,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Send a command to control a device via the appropriate provider adapter.

    Example commands:
    - {"command": "power", "value": "on"}
    - {"command": "set_mode", "value": "turbo"}
    - {"command": "set_speed", "value": 5}
    """
    # Verify device belongs to current user
    stmt = select(UserDevice).where(
        UserDevice.device_id == device_id,
        UserDevice.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    device = result.scalar_one_or_none()

    if not device:
        raise HTTPException(status_code=404, detail="Device not found")

    if not device.is_active:
        raise HTTPException(status_code=400, detail="Device is inactive")

    # Route to provider-specific adapter
    provider = (device.provider or "").lower()

    if provider == "tuya":
        result_data = await tuya_adapter.send_command(
            device_id=device_id,
            access_token=device.access_token or "",
            command=command.command,
            value=command.value,
        )
    else:
        raise HTTPException(
            status_code=501,
            detail=f"Provider '{provider}' is not yet supported. Supported: tuya",
        )

    return CommandResponse(
        success=result_data["success"],
        device_id=device_id,
        command=command.command,
        message=result_data["message"],
    )
