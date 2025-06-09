# schemas/user.py
from pydantic import BaseModel, EmailStr, Field, UUID4, HttpUrl
from datetime import datetime
from typing import Optional

# --- Schemas de Entrada ---

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=100)
    email: EmailStr # Pydantic valida formato de e-mail
    password: str = Field(..., min_length=6) # Senha em texto puro (será hashed no backend)
    profile_picture_url: Optional[HttpUrl] = None

class UserLogin(BaseModel):
    username: str
    password: str

# --- Schemas de Saída ---

class UserInDBBase(BaseModel):
    username: str
    email: EmailStr
    is_active: bool = True
    profile_picture_url: Optional[HttpUrl] = None

    class Config:
        from_attributes = True # Permite que o Pydantic leia dados de um ORM model

class UserInDB(UserInDBBase):
    id: UUID4
    created_at: datetime
    updated_at: datetime
    # hashed_password NÃO deve ser retornado para o frontend

class UserUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=3, max_length=100)
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=6)
    profile_picture_url: Optional[HttpUrl] = None # NOVO CAMPO: Permite atualizar a foto
    is_active: Optional[bool] = None

# --- Schemas para Tokens JWT ---

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    username: Optional[str] = None # Informação dentro do token (payload)
    # Aqui você pode adicionar user_id, roles, etc.