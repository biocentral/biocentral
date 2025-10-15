# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Environment Setup
```bash
# Install dependencies with UV (replaces Poetry)
uv sync --group dev

# Copy environment file for local development
cp .env.local .env

# Start development dependencies (Redis, PostgreSQL)
docker compose -f docker-compose.dev.yml up -d
```

### Running the Server
```bash
# Simple development server
uv run python run-biocentral_server.py

# Development server with workers (recommended for development)
uv run python run-local.py

# Production with Docker
docker compose up -d
```

### Testing and Code Quality
```bash
# Run tests
uv run pytest

# Run specific test file
uv run pytest tests/path/to/test_file.py

# Lint and format with Ruff
uv run ruff check --fix
uv run ruff format

# Run pre-commit hooks
uv run pre-commit run --all-files
```

## Architecture Overview

### High-Level Structure
Biocentral Server is a Flask-based REST API that provides bioinformatics functionality to the biocentral frontend. It uses:
- **Task Management**: Redis Queue (RQ) for background job processing
- **Database**: PostgreSQL for embeddings and metadata storage
- **File Storage**: Local filesystem with configurable backends
- **Workers**: Multi-process architecture for compute-intensive tasks

### Core Components

#### Server Initialization
- `ServerAppState` (singleton): Manages Flask app lifecycle and initialization
- `ServerInitializationManager`: Coordinates module initialization
- Entry points: `run-biocentral_server.py` (simple) and `run-local.py` (with workers)

#### Task Management System
- `TaskManager` (singleton): Redis-backed job queue management
- `TaskInterface`: Base class for all background tasks
- Priority queues: "high", "default", "low"
- Task lifecycle: pending → running → finished/failed

#### Module Structure
Each functional module follows this pattern:
```
module_name/
├── __init__.py
├── module_endpoint.py    # Flask routes
├── module_task.py       # Background tasks
└── module_specific.py   # Core logic
```

#### Key Modules
- **predict/**: Protein prediction models (binding, conservation, disorder, etc.)
- **embeddings/**: Protein sequence embedding generation
- **ppi/**: Protein-protein interaction analysis
- **proteins/**: Protein data management and taxonomy
- **prediction_models/**: Model training and evaluation
- **bayesian_optimization/**: Hyperparameter optimization
- **plm_eval/**: Protein language model evaluation

#### Server Management
- **file_management/**: Storage abstraction layer
- **embedding_database/**: Database strategy pattern for embeddings
- **task_management/**: Job queue and worker coordination
- **user_manager.py**: Request authentication and user handling

### Configuration
- Environment variables in `.env` (copy from `.env.local` or `.env.example`)
- Server config in `biocentral_server/utils/constants.py`
- Gunicorn config in `gunicorn.conf.py`
- Default port: 9540

### Development Workflow
1. Use UV instead of Poetry for dependency management
2. Follow GitFlow with feature branches: `<module>/feature/description`
3. All endpoints require integration tests (see `docs/Contributing/testing.md`)
4. Code formatting enforced via pre-commit hooks (Ruff)
5. PEP 8 compliance required

### External Dependencies
The server integrates with several external bioinformatics tools:
- biotrainer: Model training framework
- TMbed: Transmembrane prediction
- VespaG: Variant effect prediction
- protspace: Protein space analysis
- hvi_toolkit: Host-virus interaction tools

### Storage and Data
- Embeddings stored in `storage/embeddings/`
- User files in `storage/files/`
- Temporary files in `storage/server_temp_files/`
- Logs in `logs/` directory