# app/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from fastapi.staticfiles import StaticFiles

# Importa tudo que você criou
from routers import exercises as exercises
from routers import training_blocks as training_blocks_router
from routers import training_block_exercises as tbe_router
from routers import exercise_logs as exercise_logs_router
from routers import auth as auth_router

import models

from database import engine, Base

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Gym Notes API",
    description="API para gerenciar exercícios e blocos de treino.",
    version="0.1.0",
    docs_url="/documentation",
    redoc_url="/redoc"
)

from fastapi.middleware.cors import CORSMiddleware

origins = [
    "http://localhost",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    "http://localhost:3000",
    "http://localhost:5000"
]

# rodar o fluter com uma porta especifica se usar um browser, ex.: flutter run -d chrome --web-port 3000

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(auth_router.router)
app.include_router(training_blocks_router.router)
app.include_router(tbe_router.router)
app.include_router(exercises.router)
app.include_router(exercise_logs_router.router)


@app.get("/")
def read_root():
    return {"message": "Bem-vindo à Gym Notes API! Acesse /documentation para ver os endpoints."}