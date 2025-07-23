from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from datetime import date

from models import exercise_log as models_log
from models import exercise as models_exercise
from models import training_block as models_training_block
from schemas import exercise_log as schemas_log
from database import get_db
from models.user import User
from routers.auth import get_current_user

router = APIRouter(
    prefix="/exercise_logs",
    tags=["Exercise Logs"],
)

@router.post("/", response_model=schemas_log.ExerciseLogInDB, status_code=status.HTTP_201_CREATED)
def create_exercise_log(
    log: schemas_log.ExerciseLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    training_block = db.query(models_training_block.TrainingBlock)\
                    .filter(models_training_block.TrainingBlock.id == log.training_block_id)\
                    .filter(models_training_block.TrainingBlock.user_id == current_user.id)\
                    .first()
    if not training_block:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Training block not found")

    exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == log.exercise_id).first()
    if not exercise:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")

    db_log = models_log.ExerciseLog(
        **log.model_dump(),
        user_id=current_user.id
    )
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/", response_model=List[schemas_log.ExerciseLogWithDetails])
def read_exercise_logs(
    current_user: User = Depends(get_current_user),
    training_block_id: Optional[str] = None,
    exercise_id: Optional[str] = None,
    log_date: Optional[date] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    query = db.query(models_log.ExerciseLog)\
            .options(joinedload(models_log.ExerciseLog.exercise))\
            .options(joinedload(models_log.ExerciseLog.training_block))\
            .filter(models_log.ExerciseLog.user_id == current_user.id) 

    if training_block_id:
        query = query.filter(models_log.ExerciseLog.training_block_id == training_block_id)
    if exercise_id:
        query = query.filter(models_log.ExerciseLog.exercise_id == exercise_id)
    if log_date:
        query = query.filter(models_log.ExerciseLog.log_date == log_date)

    logs = query.order_by(models_log.ExerciseLog.log_date.desc(), models_log.ExerciseLog.created_at.desc()).offset(skip).limit(limit).all()

    return logs

@router.get("/{log_id}", response_model=schemas_log.ExerciseLogWithDetails)
def read_exercise_log(
    log_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_log = db.query(models_log.ExerciseLog)\
                .options(joinedload(models_log.ExerciseLog.exercise))\
                .options(joinedload(models_log.ExerciseLog.training_block))\
                .filter(models_log.ExerciseLog.id == log_id)\
                .filter(models_log.ExerciseLog.user_id == current_user.id)\
                .first()
    if db_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise log not found")
    return db_log

@router.put("/{log_id}", response_model=schemas_log.ExerciseLogInDB)
def update_exercise_log(
    log_id: str,
    log_update: schemas_log.ExerciseLogUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_log = db.query(models_log.ExerciseLog)\
            .filter(models_log.ExerciseLog.id == log_id)\
            .filter(models_log.ExerciseLog.user_id == current_user.id)\
            .first()
    if db_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise log not found")

    if log_update.training_block_id and log_update.training_block_id != db_log.training_block_id:
        new_training_block = db.query(models_training_block.TrainingBlock)\
                            .filter(models_training_block.TrainingBlock.id == log_update.training_block_id)\
                            .filter(models_training_block.TrainingBlock.user_id == current_user.id)\
                            .first()
        if not new_training_block:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="New training block not found or not owned by user.")

    update_data = log_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_log, key, value)

    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.delete("/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_exercise_log(
    log_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_log = db.query(models_log.ExerciseLog)\
            .filter(models_log.ExerciseLog.id == log_id)\
            .filter(models_log.ExerciseLog.user_id == current_user.id)\
            .first()
    if db_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise log not found")

    db.delete(db_log)
    db.commit()
    return {"message": "Exercise log deleted successfully"}