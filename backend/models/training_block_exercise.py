from sqlalchemy import Column, String, Text, Integer, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from database import Base

class TrainingBlockExercise(Base):
    __tablename__ = "training_block_exercises"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    training_block_id = Column(UUID(as_uuid=True), ForeignKey("training_blocks.id"), nullable=False)
    exercise_id = Column(UUID(as_uuid=True), ForeignKey("exercises.id"), nullable=False)
    order_in_block = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.now)
    updated_at = Column(DateTime(timezone=True), default=datetime.now, onupdate=datetime.now)

    # Relacionamentos para facilitar o acesso
    training_block = relationship("TrainingBlock", back_populates="block_exercises")
    exercise = relationship("Exercise", back_populates="training_block_exercises")

    def __repr__(self):
        return f"<TrainingBlockExercise(id={self.id}, training_block_id={self.training_block_id}, exercise_id={self.exercise_id})>"