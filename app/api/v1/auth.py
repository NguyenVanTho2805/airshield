"""
Auth API Router - Register, Login, Profile.
Endpoints: /api/v1/auth
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, EmailStr
from typing import Optional
from uuid import UUID

from app.core.database import get_db
from app.core.auth import (
    hash_password,
    verify_password,
    create_access_token,
    get_current_active_user,
)
from app.models.user import User


router = APIRouter()


# ============ Schemas ============

class UserRegisterRequest(BaseModel):
    """Request body for user registration."""
    email: EmailStr
    password: str
    full_name: Optional[str] = None


class UserResponse(BaseModel):
    """Public user data (no sensitive fields)."""
    id: UUID
    email: str
    full_name: Optional[str]
    role: str
    is_active: bool

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """JWT token response."""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class FcmTokenUpdate(BaseModel):
    """Request to update FCM push token."""
    fcm_token: str


# ============ Endpoints ============

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    request: UserRegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Register a new user account.

    - Checks for duplicate email
    - Hashes password with bcrypt
    - Returns JWT access token immediately
    """
    # Check duplicate email
    stmt = select(User).where(User.email == request.email)
    result = await db.execute(stmt)
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    # Create new user
    user = User(
        email=request.email,
        hashed_password=hash_password(request.password),
        full_name=request.full_name,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    # Issue token
    access_token = create_access_token(subject=str(user.id))

    return TokenResponse(
        access_token=access_token,
        user=UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            role=user.role.value,
            is_active=user.is_active,
        ),
    )


@router.post("/login", response_model=TokenResponse)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db),
):
    """
    Login with email and password.

    Uses OAuth2 password form (username = email).
    Returns JWT access token.
    """
    # Fetch user by email
    stmt = select(User).where(User.email == form_data.username)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()

    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(status_code=400, detail="Account is disabled")

    access_token = create_access_token(subject=str(user.id))

    return TokenResponse(
        access_token=access_token,
        user=UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            role=user.role.value,
            is_active=user.is_active,
        ),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: User = Depends(get_current_active_user),
):
    """
    Get current authenticated user profile.
    Requires Bearer token in Authorization header.
    """
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role.value,
        is_active=current_user.is_active,
    )


@router.put("/me/fcm-token", response_model=dict)
async def update_fcm_token(
    body: FcmTokenUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update the user's FCM push notification token.
    Called by mobile app whenever the FCM token changes.
    """
    current_user.fcm_token = body.fcm_token
    await db.commit()
    return {"message": "FCM token updated successfully"}
