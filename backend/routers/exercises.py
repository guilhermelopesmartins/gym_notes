# routers/exercises.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

# Importa os models e schemas necessários
from models import exercise as models_exercise
from schemas import exercise as schemas_exercise
from database import get_db

router = APIRouter(
    prefix="/exercises",  # Todos os endpoints aqui terão /exercises como prefixo
    tags=["Exercises"],   # Agrupamento para a documentação do FastAPI (Swagger UI)
)

# --- Endpoint para Criar um Novo Exercício ---
@router.post("/", response_model=schemas_exercise.ExerciseInDB, status_code=status.HTTP_201_CREATED)
def create_exercise(
    exercise: schemas_exercise.ExerciseCreate,
    db: Session = Depends(get_db)
):
    # Verifica se já existe um exercício com o mesmo nome (case-insensitive)
    existing_exercise = db.query(models_exercise.Exercise).filter(
        models_exercise.Exercise.name.ilike(exercise.name) # .ilike para busca case-insensitive
    ).first()

    if existing_exercise:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, # 409 Conflict indica que a requisição conflita com o estado atual do servidor
            detail="Exercise with this name already exists."
        )

    db_exercise = models_exercise.Exercise(**exercise.model_dump())
    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

# --- Endpoint para Listar Exercícios ---
@router.get("/", response_model=List[schemas_exercise.ExerciseInDB])
def read_exercises(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None, # Parâmetro de filtro opcional por categoria
    search: Optional[str] = None,   # Parâmetro de busca opcional por nome
    db: Session = Depends(get_db)
):
    query = db.query(models_exercise.Exercise)

    if category:
        query = query.filter(models_exercise.Exercise.category.ilike(f"%{category}%")) # Busca parcial na categoria

    if search:
        query = query.filter(models_exercise.Exercise.name.ilike(f"%{search}%")) # Busca parcial no nome

    exercises = query.offset(skip).limit(limit).all()
    print(exercises)
    return exercises

# --- Endpoint para Obter um Exercício por ID ---
@router.get("/{exercise_id}", response_model=schemas_exercise.ExerciseInDB)
def read_exercise(
    exercise_id: str, # O ID será passado na URL
    db: Session = Depends(get_db)
):
    db_exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == exercise_id).first()
    if db_exercise is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")
    return db_exercise

# --- Endpoint para Atualizar um Exercício ---
@router.put("/{exercise_id}", response_model=schemas_exercise.ExerciseInDB)
def update_exercise(
    exercise_id: str,
    exercise_update: schemas_exercise.ExerciseUpdate,
    db: Session = Depends(get_db)
):
    db_exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == exercise_id).first()
    if db_exercise is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")

    # Se um novo nome for fornecido, verifica se já existe (ignorando o próprio exercício atual)
    if exercise_update.name is not None and exercise_update.name != db_exercise.name:
        existing_exercise = db.query(models_exercise.Exercise).filter(
            models_exercise.Exercise.name.ilike(exercise_update.name)
        ).first()
        if existing_exercise and existing_exercise.id != db_exercise.id:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Another exercise with this name already exists."
            )

    # Atualiza apenas os campos que foram fornecidos na requisição
    update_data = exercise_update.model_dump(exclude_unset=True) # Exclui campos que não foram definidos no payload
    for key, value in update_data.items():
        setattr(db_exercise, key, value)

    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

# --- Endpoint para Deletar um Exercício ---
@router.delete("/{exercise_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_exercise(
    exercise_id: str,
    db: Session = Depends(get_db)
):
    db_exercise = db.query(models_exercise.Exercise).filter(models_exercise.Exercise.id == exercise_id).first()
    if db_exercise is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")

    # Implementação do ON DELETE RESTRICT (se houver foreign keys apontando para este exercício)
    # No SQL, configuramos ON DELETE RESTRICT para exercises no training_block_exercises e exercise_logs.
    # Isso significa que o banco de dados já impede a exclusão se houver referências.
    # Você pode adicionar uma checagem explícita aqui se quiser uma mensagem mais amigável,
    # mas o erro do banco de dados já cuidaria disso.
    # Exemplo de checagem manual (opcional, pois o DB já faz):
    # if db_exercise.training_block_exercises or db_exercise.exercise_logs:
    #     raise HTTPException(
    #         status_code=status.HTTP_400_BAD_REQUEST,
    #         detail="Cannot delete exercise as it is linked to training blocks or logs. Remove links first."
    #     )

    db.delete(db_exercise)
    db.commit()
    return {"message": "Exercise deleted successfully"} # Mensagem de sucesso (204 No Content não envia body)

@router.get("/by_training_block/{training_block_id}", response_model=List[schemas_exercise.ExerciseInDB])
def get_exercises_by_training_block(
    training_block_id: str,
    db: Session = Depends(get_db)
):
    # Assumindo que você tem uma tabela intermediária TrainingBlockExercise
    # e um relacionamento que permite buscar os Exercises através dela
    exercises = db.query(models_exercise.Exercise)\
                  .join(models_exercise.TrainingBlockExercise)\
                  .filter(models_exercise.TrainingBlockExercise.training_block_id == training_block_id)\
                  .all()
    if not exercises:
        # Opcional: retornar 404 se o bloco não tiver exercícios ou o bloco não existir
        # Mas geralmente uma lista vazia é aceitável se não houver exercícios
        # raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No exercises found for this training block or training block not found.")
        pass
    return exercises