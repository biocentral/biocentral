---
name: add_server_endpoint
description: End-to-end guide for adding a new endpoint to the Biocentral server, generating OpenAPI clients (Python & Dart), integrating with high-level Python and CLI APIs, writing tests, and updating documentation.
version: 1.0.0
tags:
  - biocentral
  - fastapi
  - openapi
  - code-generation
  - python
  - dart
  - celery
---

# Skill: Adding a New Endpoint to Biocentral Server and Clients

This Skill defines the standardized, multi-tier architectural process for adding a new service endpoint to Biocentral. It ensures consistency across backend server endpoints, async task execution, OpenAPI client generation (Python and Dart), high-level API abstractions, CLI commands, testing, and documentation.

---

## 1. Architectural Overview

Biocentral features a decoupled multi-package architecture:

```
[ biotrainer_core ] (Canonical domain data classes & enums)
        │
        ▼
[ biocentral_server ] (FastAPI endpoints + Celery worker tasks)
        │
        ├─ OpenAPI Spec Export (openapi.json)
        ▼
[ _global/bin/generate_openapi_client.py ]
        ├──> [ biocentral_api/python ] (Generated models & high-level client)
        └──> [ biocentral_api/dart ]   (Generated OpenAPI client & high-level API)
                     │
                     ▼
[ biocentral_python ] (Unified Python facade: Local backend vs API backend)
        │
        ▼
[ biocentral CLI ] & [ biocentral_docs ]
```

---

## 2. Step-by-Step Implementation Workflow

### Step 1: Check for Reusable Data Classes in `biotrainer_core`

**Best Practice:** Never create duplicate data models or enums if a canonical version already exists in `biotrainer_core`.

1. Inspect `biotrainer_core` (e.g. `biotrainer_core.data_classes`, `biotrainer_core.protocol`, etc.) for existing dataclasses or enums matching your request/response domain (e.g., `SequenceData`, `ZeroShotMethod`, `Protocol`).
2. If available:
   - Import and use the `biotrainer_core` class in `biocentral_server` request/response schemas and task DTOs.
   - Register the type in `_global/bin/generate_openapi_client.py` under `IMPORT_MAPPINGS` (see Step 4).

---

### Step 2: Implement Server Task & Endpoint (`biocentral_server`)

1. **Shared Models / DTOs:**
   - Define request/response models in `biocentral_server/server_management/shared_endpoint_models/` (e.g. `PerplexityRequest`, `PerplexityResult`).
   - If the endpoint runs asynchronously as a background task, add the result field to `TaskDTO` in `biocentral_server/server_management/shared_endpoint_models/task_dto.py`.

2. **Celery Worker Task:**
   - Create or update the task module in the respective domain directory (e.g. `biocentral_server/proteins/perplexity_task.py`).
   - Use `@celery_app.task` and handle status transitions (`PROCESSING` -> `FINISHED` / `FAILED`).
   - Set the corresponding result field on `TaskDTO`.

3. **FastAPI Endpoint:**
   - Add the endpoint in the service endpoint module (e.g. `biocentral_server/proteins/proteins_endpoint.py`).
   - Use standard status codes (`202 Accepted` for async task triggers, `200 OK` for synchronous responses).
   - Ensure input validation (e.g. non-empty sequences, valid enum members).

---

### Step 3: OpenAPI Spec Export & Code Generation

1. **Update Import Mappings in Generator:**
   - Open `_global/bin/generate_openapi_client.py`.
   - In `IMPORT_MAPPINGS`, add any external types imported from `biotrainer_core`:
     ```python
     IMPORT_MAPPINGS = {
         "SequenceData": "biotrainer_core.data_classes.SequenceData",
         "ZeroShotMethod": "biotrainer_core.data_classes.ZeroShotMethod",
     }
     ```
   - This ensures post-processing removes redundant generated models and maps imports directly to `biotrainer_core`.

2. **Run the OpenAPI Generator:**
   ```bash
   python _global/bin/generate_openapi_client.py
   ```
   This regenerates `biocentral_api/python/biocentral_api/_generated/` and `biocentral_api/dart/lib/src/`.

---

### Step 4: Python API Client Integration (`biocentral_api/python`)

1. **Export Models:**
   - Export any new models or enums from `biocentral_api/python/biocentral_api/__init__.py` and include them in `__all__`.

2. **DTO Handler & Client Method:**
   - In the appropriate client under `biocentral_api/python/biocentral_api/clients/` (e.g., `proteins_client.py`):
     - Implement a private `_TaskDtoHandler` subclass (e.g., `_PerplexityDTOHandler`) that extracts the result from `TaskDTO`.
     - Implement the client method returning a `BiocentralServerTask[ResultType]`.
   - Expose the method on `BiocentralAPI` in `biocentral_api/python/biocentral_api/api.py`.

---

### Step 5: Dart API Client Integration (`biocentral_api/dart`)

1. **Generate `built_value` Builders:**
   - Run `build_runner` to generate `.g.dart` serializers and builders for new models:
     ```bash
     cd biocentral_api/dart && dart run build_runner build --delete-conflicting-outputs
     ```

2. **Implement DTO Handler & High-Level API:**
   - In `biocentral_api/dart/lib/src/clients/` (e.g., `proteins_client.dart`), implement the `DtoHandler<T>` and the client method returning `BiocentralServerTask<T>`.
   - Add the extension method on `BiocentralAPI` in `biocentral_api/dart/lib/src/high_level_api.dart`.
   - Re-export the new result and enum types in `biocentral_api/dart/lib/biocentral_api.dart`.

3. **Verify Static Analysis:**
   ```bash
   dart analyze biocentral_api/dart
   ```

---

### Step 6: High-Level Python Integration & CLI (`biocentral_python`)

1. **Backend Implementations (`biocentral_python/biocentral/`):**
   - **Base Backend (`base/backend.py`):** Define the abstract method signature.
   - **Local Backend (`local/local_backend.py`):** Implement local computation using underlying libraries (e.g., `biotrainer.bioengineer` or PyTorch).
   - **API Backend (`api/api_backend.py`):** Call the `biocentral_api` client and call `.run()` or handle task polling.
   - **Facade (`biocentral.py`):** Expose the method on the `Biocentral` class, delegating to the configured backend.

2. **CLI Command (`biocentral/cli/cli.py`):**
   - Add the Click command supporting `--mode [api|local]`, `--server-url`, and `--device`.
   - Format and output results cleanly.

---

### Step 7: Testing Strategy

1. **Unit Tests:**
   - Add unit tests in `biocentral_api/python/tests/unit/unittests.py` covering:
     - DTO handler extraction logic.
     - Model serialization / deserialization.
     - Type identity checks against `biotrainer_core`.

2. **Server Endpoint Integration Tests:**
   - In `biocentral_api/python/tests/integration/<domain>/`:
     - Test direct endpoint execution using generated API client (e.g., `test_<domain>_server_endpoints.py`).
     - Test request validation and error cases (empty sequence data, missing parameters).
     - Test high-level API execution (e.g., `test_<domain>.py`).

3. **Local vs API Equivalence Tests:**
   - In `biocentral_python/tests/integration/test_local_vs_api_<feature>.py`:
     - Execute the computation locally and via the API.
     - Assert that output formats and numerical results match.

---

### Step 8: Documentation Updates (`biocentral_docs`)

1. **Documentation Pages:**
   - Update or create the domain documentation page in `biocentral_websites/biocentral_docs/content/docs/(biocentral)/<domain>/index.mdx`.
   - Include code examples for **API** (Python), **CLI**, and GUI where applicable.
2. **Overview & CLI Docs:**
   - Update `biocentral_websites/biocentral_docs/content/docs/(biocentral)/index.mdx` module overview.
   - Add the new CLI command and options to `biocentral_websites/biocentral_docs/content/docs/biocentral_cli/index.mdx`.
   - Update package quickstarts in `biocentral_websites/biocentral_docs/content/docs/biocentral_python/index.mdx`.

---

## 3. Best Practices Checklist

- [ ] Reusable data classes checked in `biotrainer_core` and mapped in generator.
- [ ] Server endpoint input validation (empty inputs, length checks, enum values).
- [ ] Async tasks update `TaskDTO` with consistent task status.
- [ ] OpenAPI generator executed and imports post-processed cleanly.
- [ ] Dart models compiled with `build_runner` and analyzed with `dart analyze`.
- [ ] Python API exports updated in `__all__`.
- [ ] Both Local and API backends implemented in `biocentral_python`.
- [ ] CLI command implemented with `--mode` support.
- [ ] Integration tests verify server responses, error validation, and local/API equivalence.
- [ ] Docs in `biocentral_docs` updated with working code snippets and CLI flags.
