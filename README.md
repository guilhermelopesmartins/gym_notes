# Gym Notes

Gerencie e otimize seus treinos com o Gym Notes, seu assistente pessoal de academia. Registre exercícios, acompanhe seu progresso e mantenha o foco em seus objetivos de condicionamento físico.

---

## 📋 Tabela de Conteúdo

* [Sobre o Gym Notes](#-sobre-o-gym-notes)
* [Funcionalidades](#-funcionalidades)
* [Tecnologias Utilizadas](#-tecnologias-utilizadas)
* [Como Começar (Desenvolvedor)](#-como-começar-desenvolvedor)
    * [Pré-requisitos](#pré-requisitos)
    * [Configuração do Ambiente](#configuração-do-ambiente)
    * [Executando o Backend (FastAPI)](#executando-o-backend-fastapi)
    * [Executando o Frontend (Flutter)](#executando-o-frontend-flutter)
* [Estrutura do Projeto](#-estrutura-do-projeto)
* [Contribuição](#-contribuição)
* [Licença](#-licença)
* [Contato](#-contato)

---

## 🏋️ Sobre o Gym Notes

O Gym Notes é um aplicativo móvel desenvolvido em Flutter com um backend em FastAPI que permite aos usuários registrar e acompanhar seus treinos de academia de forma eficiente. Nosso objetivo é simplificar a gestão de rotinas de exercícios, permitindo que você visualize seu progresso e se mantenha motivado.

---

## ✨ Funcionalidades

* **Autenticação de Usuário:** Registro, login e gestão de perfil (atualização de nome, e-mail e foto de perfil).
* **Gerenciamento de Treinos:** Crie, edite e organize seus blocos de treino.
* **Registro de Exercícios:** Adicione exercícios específicos a cada bloco de treino, definindo séries, repetições e carga.
* **Acompanhamento de Progresso:** Registre o desempenho de cada série durante o treino, incluindo carga e repetições.
* **Persistência de Dados:** Seus dados de treino são salvos e acessíveis a qualquer momento.

---

## 🛠️ Tecnologias Utilizadas

### Frontend (Flutter)

* **Flutter:** Framework UI para construção de aplicativos móveis (Android/iOS).
* **Provider:** Gerenciamento de estado.
* **`http`:** Pacote para requisições HTTP.
* **`shared_preferences`:** Armazenamento local de dados (token de autenticação, ID do usuário).
* **`json_annotation` & `json_serializable`:** Geração automática de código para serialização/desserialização JSON.
* **`image_picker`:** Seleção de imagens da galeria ou câmera.
* **`path_provider`:** Obtenção de caminhos do sistema de arquivos.

### Backend (FastAPI)

* **FastAPI:** Framework web para construção de APIs em Python.
* **SQLAlchemy:** ORM para interação com o banco de dados.
* **Pydantic:** Validação de dados e serialização.
* **`python-jose`:** Manipulação de JWT (JSON Web Tokens).
* **`passlib`:** Hashing de senhas.
* **Uvicorn:** Servidor ASGI de alta performance.
* **PostgreSQL:** Banco de dados relacional (recomendado).

---

## 🚀 Como Começar (Desenvolvedor)

Siga estas instruções para configurar e executar o projeto em seu ambiente de desenvolvimento.

### Pré-requisitos

* [**Flutter SDK**](https://flutter.dev/docs/get-started/install): Versão 3.x.x ou superior.
* [**Python**](https://www.python.org/downloads/): Versão 3.9 ou superior.
* [**pip**](https://pip.pypa.org/en/stable/installation/): Gerenciador de pacotes Python.
* [**Poetry**](https://python-poetry.org/docs/#installation-and-first-steps) (opcional, mas recomendado para gerenciamento de dependências Python).
* **Banco de Dados PostgreSQL:** Um servidor PostgreSQL rodando e acessível.
* **Git:** Para clonar o repositório.

### Configuração do Ambiente

1.  **Clone o Repositório:**
    ```bash
    git clone https://github.com/guilhermelopesmartins/gym_notes.git
    cd gym_notes # Navegue para a pasta raiz do seu projeto
    ```

2.  **Configuração do Backend:**

    Navegue até a pasta do backend:
    ```bash
    cd backend
    ```

    Instale as dependências (usando Poetry):
    ```bash
    poetry install
    ```
    Ou usando pip e virtualenv (se não usar Poetry):
    ```bash
    python -m venv venv
    source venv/bin/activate # No Windows: venv\Scripts\activate
    pip install -r requirements.txt # Certifique-se de ter um requirements.txt atualizado
    ```

    **Variáveis de Ambiente:**
    Crie um arquivo `.env` na pasta `backend` com as seguintes variáveis (substitua pelos seus valores):
    ```env
    DB_HOST=****
    DB_PORT=****
    DB_USER=****
    DB_PASSWORD=****
    DB_NAME=****
    SECRET_KEY=****
    ```
    **Lembre-se de configurar o seu banco de dados PostgreSQL** e criar as tabelas (geralmente via migrations ou um script inicial).

3.  **Configuração do Frontend:**

    Navegue até a pasta do frontend:
    ```bash
    cd frontend # Assumindo que o frontend está em uma subpasta 'frontend'
    ```

    Instale as dependências do Flutter:
    ```bash
    flutter pub get
    ```

    **Gerar Arquivos de Modelo (`.g.dart`):**
    É crucial gerar os arquivos de serialização/desserialização JSON:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
    Para que os arquivos sejam gerados automaticamente a cada mudança, você pode usar:
    ```bash
    flutter pub run build_runner watch --delete-conflicting-outputs
    ```

    **Configuração da URL da API:**
    No arquivo `lib/utils/constants.dart` (ou similar), defina a `BASE_URL` para apontar para o seu backend. Se estiver rodando no emulador Android:
    ```dart
    class Constants {
      static const String BASE_URL = 'http://10.0.2.2:8000'; // Para emulador Android
      // Para iOS/Simulador: static const String BASE_URL = 'http://localhost:8000';
      // Para dispositivo físico na mesma rede: static const String BASE_URL = 'http://SEU_IP_LOCAL:8000';
    }
    ```

### Executando o Backend (FastAPI)

Na pasta `backend`, inicie o servidor FastAPI:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
