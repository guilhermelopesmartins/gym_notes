# routers/exercises.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from models import exercise as models_exercise
from schemas import exercise as schemas_exercise
from database import get_db

router = APIRouter(
    prefix="/exercises",  
    tags=["Exercises"],   
)

@router.post("/", response_model=schemas_exercise.ExerciseInDB, status_code=status.HTTP_201_CREATED)
def create_exercise(
    exercise: schemas_exercise.ExerciseCreate,
    db: Session = Depends(get_db)
):
    existing_exercise = db.query(models_exercise.Exercise).filter(
        models_exercise.Exercise.name.ilike(exercise.name) 
    ).first()

    if existing_exercise:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, 
            detail="Exercise with this name already exists."
        )

    db_exercise = models_exercise.Exercise(**exercise.model_dump())
    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

@router.get("/", response_model=List[schemas_exercise.ExerciseInDB])
def read_exercises(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None, 
    search: Optional[str] = None,   
    db: Session = Depends(get_db)
):
    query = db.query(models_exercise.Exercise)

    if category:
        query = query.filter(models_exercise.Exercise.category.ilike(f"%{category}%")) 

    if search:
        query = query.filter(models_exercise.Exercise.name.ilike(f"%{search}%")) 

    exercises = query.offset(skip).limit(limit).all()
    print(exercises)
    return exercises

@router.get("/{exercise_id}", response_model=schemas_exercise.ExerciseInDB)
def read_exercise(
    exercise_id: str, 
    db: Session = Depends(get_db)
):
    db_exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == exercise_id).first()
    if db_exercise is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")
    return db_exercise

@router.put("/{exercise_id}", response_model=schemas_exercise.ExerciseInDB)
def update_exercise(
    exercise_id: str,
    exercise_update: schemas_exercise.ExerciseUpdate,
    db: Session = Depends(get_db)
):
    db_exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == exercise_id).first()
    if db_exercise is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")

    if exercise_update.name is not None and exercise_update.name != db_exercise.name:
        existing_exercise = db.query(models_exercise.Exercise).filter(
            models_exercise.Exercise.name.ilike(exercise_update.name)
        ).first()
        if existing_exercise and existing_exercise.id != db_exercise.id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Another exercise with this name already exists."
            )

    update_data = exercise_update.model_dump(exclude_unset=True) 
    for key, value in update_data.items():
        setattr(db_exercise, key, value)

    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

@router.delete("/{exercise_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_exercise(
    exercise_id: str,
    db: Session = Depends(get_db)
):
    db_exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == exercise_id).first()
    if db_exercise is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")


    db.delete(db_exercise)
    db.commit()
    return {"message": "Exercise deleted successfully"} 

@router.get("/by_training_block/{training_block_id}", response_model=List[schemas_exercise.ExerciseInDB])
def get_exercises_by_training_block(
    training_block_id: str,
    db: Session = Depends(get_db)
):
    exercises = db.query(models_exercise.Exercise)\
                  .join(models_exercise.TrainingBlockExercise)\
                  .filter(models_exercise.TrainingBlockExercise.training_block_id == training_block_id)\
                  .all()
    if not exercises:
        pass
    return exercises