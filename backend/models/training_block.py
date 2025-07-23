from sqlalchemy import Column, String, Text, DateTime, ForeignKey 
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from database import Base

class TrainingBlock(Base):
    __tablename__ = "training_blocks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    color_hex = Column(String(7), default='#FFFFFF')
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.now)
    updated_at = Column(DateTime(timezone=True), default=datetime.now, onupdate=datetime.now)

    user = relationship("User", back_populates="training_blocks")
    block_exercises = relationship("TrainingBlockExercise", back_populates="training_block", cascade="all, delete-orphan")
    exercise_logs = relationship("ExerciseLog", back_populates="training_block", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<TrainingBlock(id={self.id}, title='{self.title}, user_id={self.user_id}', user_id={self.user_id})>"