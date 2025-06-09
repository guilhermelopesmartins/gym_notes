# models/__init__.py
# Importa todos os seus modelos aqui para que eles sejam registrados com o SQLAlchemy Base
from . import training_block
from . import exercise
from . import training_block_exercise
from . import exercise_log
from . import user

# Opcionalmente, você pode re-exportá-los para facilitar a importação em outros lugares:
# from .training_block import TrainingBlock
# from .exercise import Exercise
# from .training_block_exercise import TrainingBlockExercise
# from .exercise_log import ExerciseLog