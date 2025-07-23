from pydantic import BaseModel, Field, UUID4
from datetime import datetime
from typing import Optional, List

from schemas.user import UserInDBBase

class TrainingBlockBase(BaseModel):
    title: str = Field(..., max_length=255)
    description: Optional[str] = None
    color_hex: str = Field('#FFFFFF', max_length=7, pattern="^#[0-9a-fA-F]{6}$")

class TrainingBlockCreate(TrainingBlockBase):
    pass

class TrainingBlockUpdate(TrainingBlockBase):
    title: Optional[str] = Field(None, max_length=255)

class TrainingBlockInDB(TrainingBlockBase):
    id: UUID4
    user_id: UUID4
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class TrainingBlockWithUser(TrainingBlockInDB):
    user: UserInDBBase