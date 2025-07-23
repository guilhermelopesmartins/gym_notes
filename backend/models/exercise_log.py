from sqlalchemy import Column, String, Text, Date, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime, date
import uuid

from database import Base

class ExerciseLog(Base):
    __tablename__ = "exercise_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    training_block_id = Column(UUID(as_uuid=True), ForeignKey("training_blocks.id"), nullable=False)
    exercise_id = Column(UUID(as_uuid=True), ForeignKey("exercises.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    log_date = Column(Date, default=date.today, nullable=False)
    sets_reps_data = Column(JSONB)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), default=datetime.now)
    updated_at = Column(DateTime(timezone=True), default=datetime.now, onupdate=datetime.now)

    user = relationship("User", back_populates="exercise_logs")
    training_block = relationship("TrainingBlock", back_populates="exercise_logs")
    exercise = relationship("Exercise", back_populates="exercise_logs")

    def __repr__(self):
        return f"<ExerciseLog(id={self.id}, log_date={self.log_date}, exercise_id={self.exercise_id}, user_id={self.user_id})>"