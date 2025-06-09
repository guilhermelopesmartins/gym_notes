from sqlalchemy import Column, String, Text, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from database import Base

class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False, unique=True)
    description = Column(Text)
    category = Column(String(100))
    created_at = Column(DateTime(timezone=True), default=datetime.now)
    updated_at = Column(DateTime(timezone=True), default=datetime.now, onupdate=datetime.now)

    # Relacionamentos (opcional, dependendo de como você quer acessar)
    # Permite acessar os training_block_exercises associados a este exercício
    training_block_exercises = relationship("TrainingBlockExercise", back_populates="exercise")
    # Permite acessar os exercise_logs associados a este exercício
    exercise_logs = relationship("ExerciseLog", back_populates="exercise")

    def __repr__(self):
        return f"<Exercise(id={self.id}, name='{self.name}')>"