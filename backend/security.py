# security.py
import os
from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext # Para hash de senhas

# Carrega variáveis de ambiente (se já não estiver carregado em database.py)
from dotenv import load_dotenv
load_dotenv()

# --- Configurações de Segurança ---
SECRET_KEY = os.getenv("SECRET_KEY", "super_secret_key_padrao_se_nao_definido")
ALGORITHM = "HS256" # Algoritmo de assinatura para o JWT
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7 # Token expira em 7 dias (60 min * 24h * 7 dias)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# --- Funções de Hash de Senhas ---
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica se a senha em texto puro corresponde à senha com hash."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Gera o hash de uma senha."""
    return pwd_context.hash(password)

# --- Funções de JWT ---
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Cria um novo JWT."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    """Decodifica e valida um JWT."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None # Token inválido ou expirado