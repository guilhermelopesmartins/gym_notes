# 200.19.1.18 if outside of ifsul / postgres.gravatai.ifsul.edu.br if inside ifsul
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = (
    f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

engine = create_engine(
        DATABASE_URL,
        pool_pre_ping=True
    )
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- Função de Dependência para o FastAPI ---
def get_db():
    db = SessionLocal() # Cria uma nova sessão para a requisição
    try:
        yield db # Retorna a sessão e permite que o endpoint a utilize
    finally:
        db.close() # Garante que a sessão seja fechada após a requisição, liberando recursos