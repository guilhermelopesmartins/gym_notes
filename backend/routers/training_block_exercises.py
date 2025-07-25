from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from typing import List

from models import training_block_exercise as models_tbe
from models import training_block as models_training_block
from models import exercise as models_exercise
from schemas import training_block_exercise as schemas_tbe
from database import get_db

router = APIRouter(
    prefix="/training_block_exercises",
    tags=["Training Block Exercises"],
)

@router.post("/", response_model=schemas_tbe.TrainingBlockExerciseInDB, status_code=status.HTTP_201_CREATED)
def add_exercise_to_training_block(
    tbe: schemas_tbe.TrainingBlockExerciseCreate,
    db: Session = Depends(get_db)
):
    training_block = db.query(models_training_block.TrainingBlock).filter(models_training_block.TrainingBlock.id == tbe.training_block_id).first()
    if not training_block:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training block not found")

    exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == tbe.exercise_id).first()
    if not exercise:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")

    existing_tbe = db.query(models_tbe.TrainingBlockExercise).filter(
        models_tbe.TrainingBlockExercise.training_block_id == tbe.training_block_id,
        models_tbe.TrainingBlockExercise.exercise_id == tbe.exercise_id
    ).first()
    if existing_tbe:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Exercise already exists in this training block.")

    db_tbe = models_tbe.TrainingBlockExercise(**tbe.model_dump())
    db.add(db_tbe)
    db.commit()
    db.refresh(db_tbe)
    return db_tbe

@router.get("/by_block/{training_block_id}", response_model=List[schemas_tbe.TrainingBlockExerciseWithDetails])
def get_exercises_for_training_block(
    training_block_id: str,
    db: Session = Depends(get_db)
):
    training_block = db.query(models_training_block.TrainingBlock).filter(models_training_block.TrainingBlock.id == training_block_id).first()
    if not training_block:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training block not found.")

    block_exercises = db.query(models_tbe.TrainingBlockExercise)\
                        .options(joinedload(models_tbe.TrainingBlockExercise.exercise))\
                        .filter(models_tbe.TrainingBlockExercise.training_block_id == training_block_id)\
                        .order_by(models_tbe.TrainingBlockExercise.order_in_block)\
                        .all()
    return block_exercises

@router.get("/{tbe_id}", response_model=schemas_tbe.TrainingBlockExerciseInDB)
def get_training_block_exercise(
    tbe_id: str,
    db: Session = Depends(get_db)
):
    db_tbe = db.query(models_tbe.TrainingBlockExercise).filter(models_tbe.TrainingBlockExercise.id == tbe_id).first()
    if not db_tbe:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training Block Exercise link not found")
    return db_tbe

@router.put("/{tbe_id}", response_model=schemas_tbe.TrainingBlockExerciseInDB)
def update_training_block_exercise(
    tbe_id: str,
    tbe_update: schemas_tbe.TrainingBlockExerciseUpdate,
    db: Session = Depends(get_db)
):
    db_tbe = db.query(models_tbe.TrainingBlockExercise).filter(models_tbe.TrainingBlockExercise.id == tbe_id).first()
    if not db_tbe:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training Block Exercise link not found")

    update_data = tbe_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_tbe, key, value)

    db.add(db_tbe)
    db.commit()
    db.refresh(db_tbe)
    return db_tbe

@router.delete("/{tbe_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_training_block_exercise(
    tbe_id: str,
    db: Session = Depends(get_db)
):
    db_tbe = db.query(models_tbe.TrainingBlockExercise).filter(models_tbe.TrainingBlockExercise.id == tbe_id).first()
    if not db_tbe:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training Block Exercise link not found")

    db.delete(db_tbe)
    db.commit()
    return {"message": "Training Block Exercise link deleted successfully"}