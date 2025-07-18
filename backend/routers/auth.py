# routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import Optional
from starlette.responses import FileResponse
import os
import uuid

from models import user as models_user
from schemas import user as schemas_user
from database import get_db
from security import verify_password, get_password_hash, create_access_token, decode_access_token

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    username: str = payload.get("sub") 
    if username is None:
        raise credentials_exception

    user = db.query(models_user.User).filter(models_user.User.username == username).first()
    if user is None:
        raise credentials_exception
    return user

@router.post("/register", response_model=schemas_user.UserInDB, status_code=status.HTTP_201_CREATED)
def register_user(
    user_data: schemas_user.UserCreate,
    db: Session = Depends(get_db)
):
    db_user_by_username = db.query(models_user.User).filter(models_user.User.username == user_data.username).first()
    if db_user_by_username:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Username already registered")

    db_user_by_email = db.query(models_user.User).filter(models_user.User.email == user_data.email).first()
    if db_user_by_email:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    hashed_password = get_password_hash(user_data.password)

    db_user = models_user.User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=hashed_password,
        profile_picture_url=str(user_data.profile_picture_url) if user_data.profile_picture_url else None 
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.post("/token", response_model=schemas_user.Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), 
    db: Session = Depends(get_db)
):
    user = db.query(models_user.User).filter(models_user.User.username == form_data.username).first()

    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user")

    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=schemas_user.UserInDB) 
async def read_users_me(current_user: models_user.User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=schemas_user.UserInDB)
async def update_users_me(
    user_update_data: schemas_user.UserUpdate,
    current_user: models_user.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    update_data = user_update_data.model_dump(exclude_unset=True, exclude={"password"})

    if user_update_data.password is not None:
        current_user.hashed_password = get_password_hash(user_update_data.password)

    if "profile_picture_url" in update_data:
        update_data["profile_picture_url"] = str(update_data["profile_picture_url"])

    for key, value in update_data.items():
        setattr(current_user, key, value)

    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user

UPLOAD_DIRECTORY = "static/profile_pics"
os.makedirs(UPLOAD_DIRECTORY, exist_ok=True)

@router.post("/upload_profile_picture")
async def upload_profile_picture(file: UploadFile = File(...)):
    file_extension = file.filename.split(".")[-1] if "." in file.filename else "jpg"
    allowed_extensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp"]
    if not file.content_type.startswith("image/") and file_extension not in allowed_extensions:
        raise HTTPException(status_code=400, detail="File must be a supported image type.")
    
    unique_filename = f"{uuid.uuid4()}.{file_extension if file_extension else 'jpg'}"
    file_path = os.path.join(UPLOAD_DIRECTORY, unique_filename)

    with open(file_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)

    return {"filename": unique_filename, "url": f"/static/profile_pics/{unique_filename}"}