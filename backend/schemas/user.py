# schemas/user.py
from pydantic import BaseModel, EmailStr, Field, UUID4, HttpUrl
from datetime import datetime
from typing import Optional


class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=100)
    email: EmailStr 
    password: str = Field(..., min_length=6) 
    profile_picture_url: Optional[HttpUrl] = None

class UserLogin(BaseModel):
    username: str
    password: str


class UserInDBBase(BaseModel):
    username: str
    email: EmailStr
    is_active: bool = True
    profile_picture_url: Optional[HttpUrl] = None

    class Config:
        from_attributes = True 

class UserInDB(UserInDBBase):
    id: UUID4
    created_at: datetime
    updated_at: datetime

class UserUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=3, max_length=100)
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=6)
    profile_picture_url: Optional[HttpUrl] = None 
    is_active: Optional[bool] = None


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    username: Optional[str] = None