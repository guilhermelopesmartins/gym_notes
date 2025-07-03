from pydantic import BaseModel, Field, UUID4
from datetime import datetime
from typing import Optional

# Importa schemas de outras tabelas para aninhamento (se necessário)
from schemas.exercise import ExerciseInDB
from schemas.training_block import TrainingBlockInDB

class TrainingBlockExerciseBase(BaseModel):
    training_block_id: UUID4
    exercise_id: UUID4
    order_in_block: int = Field(0, ge=0) # ge=0 significa "maior ou igual a 0"

class TrainingBlockExerciseCreate(TrainingBlockExerciseBase):
    pass

class TrainingBlockExerciseUpdate(BaseModel):
    order_in_block: Optional[int] = Field(None, ge=0)

class TrainingBlockExerciseInDB(TrainingBlockExerciseBase):
    id: UUID4
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Schema com relacionamentos (para retorno da API com dados aninhados)
class TrainingBlockExerciseWithDetails(TrainingBlockExerciseInDB):
    # Inclui o objeto completo do exercício associado
    exercise: ExerciseInDB

    class Config:
        from_attributes = True