# Biocentral Server Test Strategy

This document explains the testing strategy for the biocentral server application.

## Overview

The test suite is organized into four main categories:

| Category | Purpose | Location |
|----------|---------|----------|
| **Unit Tests** | Test isolated components with mocked dependencies | `tests/unit/` |
| **Integration Tests** | End-to-end tests against a running server | `tests/integration/` |
| **Property-Based Tests** | Verify invariants using oracles | `tests/property/` |

## Running Tests

```shell
# Run all tests
pytest

# Run specific category
pytest tests/unit/
pytest tests/integration/
pytest tests/property/

# Run with markers
pytest -m integration
pytest -m "not slow"

# Run integration tests with fixed embedder 
CI_EMBEDDER=fixed CI_SERVER_URL=http://localhost:9540 pytest tests/integration/
```

## Test Infrastructure

### Shared Fixtures

Located in `tests/fixtures/`:

- **`test_dataset.py`** - Canonical test sequences loaded from `test_sequences.fasta`
- **`fixed_embedder.py`** - Deterministic embedder for reproducible testing without GPU
- **`server_embedder.py`** - Embedder that calls server endpoints or uses FixedEmbedder

### Fixed Embedder Mode

Integration tests support a "fixed embedder" mode (`CI_EMBEDDER=fixed`) that:
- Bypasses GPU-intensive model inference (ESM2, ProtT5, etc.)
- Generates deterministic embeddings based on sequence hash
- Still tests validation logic, endpoint routing, and request/response contracts
- Enables fast CI without GPU resources

### Canonical Test Dataset

All tests use sequences from `tests/fixtures/test_sequences.fasta` for consistency:
- Standard sequences for happy-path testing
- Edge cases: minimum length, unknown tokens, ambiguous codes
- Real-world sequences (insulin, ubiquitin, GFP)

---

## Unit Tests

**Purpose**: Test isolated components with mocked dependencies.

**Location**: `tests/unit/`

### What to Unit Test

- **Pure functions** - Any function without side effects (e.g., `calculate_levenshtein_distances`)
- **Endpoint validation** - Request validation, error responses, parameter handling
- **Server management classes** - Database strategies, task management, file management
- **FixedEmbedder** - Determinism, dimension handling, batch processing

### Endpoint Tests

Each endpoint module has corresponding unit tests:

| Endpoint | Test File | Key Validations |
|----------|-----------|-----------------|
| Embeddings | `test_embeddings.py` | Empty sequences rejected, missing embedder rejected, task_id returned |
| Predictions | `test_predict.py` | Unknown model rejected, sequence length limits, empty inputs rejected |
| Projections | `test_projection.py` | Unknown method rejected, missing fields rejected, config passthrough |
| Custom Models | `test_custom_models.py` | Invalid protocol rejected, config verification, training/inference lifecycle |

### Writing Unit Tests

```python
# Example: Testing endpoint validation
def test_embed_empty_sequences(self, client):
    response = client.post("/embed", json={"sequences": {}, "embedder_name": "model"})
    assert response.status_code == 422

# Example: Testing with mocks
@patch("module.TaskManager")
def test_embed_returns_task_id(self, mock_task_manager, client):
    mock_task_manager.submit.return_value = "task-123"
    response = client.post("/embed", json=valid_request)
    assert response.json()["task_id"] == "task-123"
```

---

## Integration Tests

**Purpose**: Verify end-to-end flows against a running server.

**Location**: `tests/integration/endpoints/`

### Prerequisites

Integration tests require running infrastructure:
```shell
docker compose -f docker-compose.dev.yml up -d
```

Environment variables:
- `CI_SERVER_URL` - Server URL (e.g., `http://localhost:9540`)
- `CI_EMBEDDER` - Embedder mode: `esm2_t6_8m` (real) or `fixed` (mock)

### Test Flows

| Flow | Test File | What It Verifies |
|------|-----------|------------------|
| Embedding | `test_embed_flow.py` | Submit → poll → cache populated |
| Projection | `test_project_flow.py` | Submit → poll → result schema |
| Prediction | `test_predict_flow.py` | Submit → poll → predictions match input |
| Training/Inference | `test_train_inference_flow.py` | Train → get files → inference → predictions |

### Writing Integration Tests

```python
@pytest.mark.integration
def test_embed_and_wait_for_completion(self, client, poll_task, embedder_name):
    # Submit task
    response = client.post("/embeddings_service/embed", json={
        "embedder_name": embedder_name,
        "sequence_data": {"seq1": "MVLSPADKTN"},
    })
    assert response.status_code == 200
    
    # Poll until complete
    result = poll_task(response.json()["task_id"], timeout=120)
    assert result["status"].upper() == "FINISHED"
```

---

## Property-Based Tests (Oracles)

**Purpose**: Verify mathematical invariants and properties that should always hold.

**Location**: `tests/property/oracles/`

### Oracle Types

| Oracle | What It Verifies | Example |
|--------|------------------|---------|
| **Batch Invariance** | Same embedding regardless of batch composition | Embedding alone == embedding in batch of 10 |
| **Masking Robustness** | Stability under progressive X-masking | Cosine distance increases monotonically |
| **Determinism** | Identical outputs across runs | Multiple calls return same result |
| **Output Validity** | Outputs properly formatted | Probabilities in [0,1], sum to 1 |
| **Shape Invariance** | Output shapes match specifications | Per-residue output length == sequence length |
| **Distance Preservation** | Projections preserve relative distances | Pairwise distance correlation > threshold |

### Writing Oracle Tests

```python
class BatchInvarianceOracle:
    """Verify embedding is invariant to batch composition."""
    
    def verify(self, sequence: str, embedder) -> OracleResult:
        # Embed alone
        alone = embedder.embed_pooled(sequence)
        
        # Embed in batch with other sequences
        batch_result = embedder.embed_batch([sequence, "MVLS", "ACDE"], pooled=True)
        in_batch = batch_result[0]
        
        distance = cosine_distance(alone, in_batch)
        return OracleResult(passed=distance < 0.01, metric=distance)
```

## Best Practices

### Test Isolation

- Unit tests should mock all external dependencies
- Integration tests use session-scoped fixtures to avoid repeated setup
- Each test should be independent and not rely on state from other tests

### Fixtures

- Use `CANONICAL_TEST_DATASET` for consistent test sequences
- Use `FixedEmbedder` for deterministic, GPU-free testing
- Session-scoped fixtures for expensive resources (DB connections, HTTP clients)

### Markers

```python
@pytest.mark.integration  # Requires running server
@pytest.mark.slow         # Long-running test
@pytest.mark.gpu          # Requires GPU
```

### Error Handling

Integration tests should handle transient failures gracefully:
```python
try:
    result = poll_task(task_id, timeout=60)
except TimeoutError:
    pytest.skip("Task timed out - CI resource constraints")
```

---

## Adding New Tests

### New Endpoint

1. Add unit tests in `tests/unit/endpoints/test_<service>.py`
2. Add integration tests in `tests/integration/endpoints/test_<service>_flow.py`
3. Test validation (empty inputs, invalid params, missing fields)
4. Test happy path (task submission, polling, result schema)

### New Model/Algorithm

1. Add test sequences to `tests/fixtures/test_sequences.fasta` if needed
2. Add oracle tests for invariants (determinism, output validity)
3. Add performance benchmarks if compute-intensive

### New Invariant

1. Create oracle class in `tests/property/oracles/`
2. Define clear pass/fail criteria with measurable metrics
3. Document expected behavior and tolerance thresholds
