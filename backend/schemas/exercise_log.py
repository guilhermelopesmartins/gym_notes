from pydantic import BaseModel, Field, UUID4
from datetime import datetime, date
from typing import Optional, List, Dict, Any

from schemas.exercise import ExerciseInDB
from schemas.training_block import TrainingBlockInDB
from schemas.user import UserInDBBase

# Modelo para o JSONB de sets_reps_data
# Definindo a estrutura esperada para cada set
class SetData(BaseModel):
    set: int
    reps: int
    weight: float
    unit: Optional[str] = 'kg'
    rpe: Optional[int] = Field(None, ge=1, le=10) # RPE de 1 a 10
    notes: Optional[str] = None

class ExerciseLogBase(BaseModel):
    training_block_id: UUID4
    exercise_id: UUID4
    log_date: date = Field(default_factory=date.today)
    sets_reps_data: List[SetData]
    notes: Optional[str] = None

class ExerciseLogCreate(ExerciseLogBase):
    pass

class ExerciseLogUpdate(BaseModel):
    training_block_id: Optional[UUID4] = None
    exercise_id: Optional[UUID4] = None
    log_date: Optional[date] = None
    sets_reps_data: Optional[List[SetData]] = None
    notes: Optional[str] = None

class ExerciseLogInDB(ExerciseLogBase):
    id: UUID4
    user_id: UUID4
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Schema com relacionamentos (para retorno da API com dados aninhados)
class ExerciseLogWithDetails(ExerciseLogInDB):
    exercise: ExerciseInDB
    training_block: TrainingBlockInDB
    user: UserInDBBase

    class Config:
        from_attributes = True