# routers/training_blocks.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from models import training_block as models_training_block
from schemas import training_block as schemas_training_block
from models.user import User
from routers.auth import get_current_user
from database import get_db

router = APIRouter(
    prefix="/training_blocks",
    tags=["Training Blocks"], 
)

# --- Endpoint para Criar um Novo Bloco de Treino ---
@router.post("/", response_model=schemas_training_block.TrainingBlockInDB, status_code=status.HTTP_201_CREATED)
def create_training_block(
    training_block: schemas_training_block.TrainingBlockCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_training_block = models_training_block.TrainingBlock(
        **training_block.model_dump(),
        user_id=current_user.id
    )
    db.add(db_training_block)
    db.commit()
    db.refresh(db_training_block)
    return db_training_block

# --- Endpoint para Listar Blocos de Treino ---
@router.get("/", response_model=List[schemas_training_block.TrainingBlockInDB])
def read_training_blocks(
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    training_blocks = db.query(models_training_block.TrainingBlock)\
                        .filter(models_training_block.TrainingBlock.user_id == current_user.id)\
                        .offset(skip).limit(limit).all()
    return training_blocks

# --- Endpoint para Obter um Bloco de Treino por ID ---
@router.get("/{block_id}", response_model=schemas_training_block.TrainingBlockInDB)
def read_training_block(
    block_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_training_block = db.query(models_training_block.TrainingBlock)\
                        .filter(models_training_block.TrainingBlock.id == block_id)\
                        .filter(models_training_block.TrainingBlock.user_id == current_user.id)\
                        .first()
    if db_training_block is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training block not found")
    return db_training_block

# --- Endpoint para Atualizar um Bloco de Treino ---
@router.put("/{block_id}", response_model=schemas_training_block.TrainingBlockInDB)
def update_training_block(
    block_id: str,
    training_block_update: schemas_training_block.TrainingBlockUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_training_block = db.query(models_training_block.TrainingBlock)\
                        .filter(models_training_block.TrainingBlock.id == block_id)\
                        .filter(models_training_block.TrainingBlock.user_id == current_user.id)\
                        .first()
    if db_training_block is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training block not found")

    update_data = training_block_update.model_dump(exclude_unset=True) # Exclui campos que não foram definidos no payload
    for key, value in update_data.items():
        setattr(db_training_block, key, value)

    db.add(db_training_block)
    db.commit()
    db.refresh(db_training_block)
    return db_training_block

# --- Endpoint para Deletar um Bloco de Treino ---
@router.delete("/{block_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_training_block(
    block_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_training_block = db.query(models_training_block.TrainingBlock)\
                        .filter(models_training_block.TrainingBlock.id == block_id)\
                        .filter(models_training_block.TrainingBlock.user_id == current_user.id)\
                        .first()
    
    if db_training_block is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training block not found")

    db.delete(db_training_block)
    db.commit()
    return {"message": "Training block deleted successfully"}