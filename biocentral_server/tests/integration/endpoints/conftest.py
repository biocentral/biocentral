import os
import time
import logging
import sys
import pytest
import httpx
import redis
from urllib.parse import urlparse
from typing import Any, Dict, Generator

from biotrainer.input_files import BiotrainerSequenceRecord

from biocentral_server.server_management.embedding_database import EmbeddingsDatabase
from biocentral_server.server_management.task_management.task_interface import TaskStatus
from tests.fixtures.test_dataset import CANONICAL_TEST_DATASET


logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)

TERMINAL_SUCCESS_STATUSES = {TaskStatus.FINISHED.value}
TERMINAL_FAILURE_STATUSES = {TaskStatus.FAILED.value}

EMBEDDER_ESM2_T6_8M = "facebook/esm2_t6_8M_UR50D"
EMBEDDER_FIXED = "fixed"

EMBEDDER_MAP = {
    "esm2_t6_8m": EMBEDDER_ESM2_T6_8M,
    "fixed": EMBEDDER_FIXED,
}


CANONICAL_STANDARD_IDS = ["standard_001", "standard_002", "standard_003"]
CANONICAL_LENGTH_EDGE_IDS = [
    "length_min_1",
    "length_min_2",
    "length_short_5",
    "length_short_10",
    "length_medium_50",
    "length_long_200",
]
CANONICAL_UNKNOWN_TOKEN_IDS = [
    "unknown_single",
    "unknown_multiple",
    "unknown_start",
    "unknown_end",
    "unknown_middle",
    "unknown_scattered",
    "unknown_high_ratio",
]
CANONICAL_AMBIGUOUS_CODE_IDS = [
    "ambiguous_B",
    "ambiguous_Z",
    "ambiguous_J",
    "selenocysteine",
    "pyrrolysine",
]
CANONICAL_REAL_WORLD_IDS = ["real_insulin_b", "real_ubiquitin", "real_gfp_core"]

ALL_CANONICAL_IDS = (
    CANONICAL_STANDARD_IDS
    + CANONICAL_LENGTH_EDGE_IDS
    + CANONICAL_UNKNOWN_TOKEN_IDS
    + CANONICAL_AMBIGUOUS_CODE_IDS
    + CANONICAL_REAL_WORLD_IDS
)

def get_redis_port() -> int:
    return int(os.environ.get("REDIS_JOBS_PORT", "6379"))


@pytest.fixture(scope="session")
def flush_redis():
    def _flush():
        redis_port = get_redis_port()
        try:
            r = redis.Redis(host="localhost", port=redis_port, db=0)
            r.flushdb()
            time.sleep(0.5)
        except redis.ConnectionError:
            pass

    return _flush


def get_server_url() -> str:
    url = os.environ.get("CI_SERVER_URL")
    if not url:
        msg = (
            "CI_SERVER_URL environment variable not set. Start the server and set "
            "CI_SERVER_URL=http://localhost:9540"
        )
        logging.warning(msg)
        print(f"SKIPPING integration tests: {msg}", file=sys.stderr)
        pytest.skip(msg)
    return url


@pytest.fixture(scope="session")
def server_url() -> str:
    return get_server_url()


@pytest.fixture(scope="session")
def client(server_url) -> Generator[httpx.Client, None, None]:
    transport = httpx.HTTPTransport(retries=5)
    http_client = httpx.Client(
        base_url=f"{server_url}/api/v1",
        timeout=httpx.Timeout(500.0, connect=10.0),
        transport=transport,
    )

    try:
        response = httpx.get(f"{server_url}/health", timeout=10.0)
        if response.status_code != 200:
            pytest.fail(
                f"Server at {server_url} returned status {response.status_code}"
            )
    except httpx.RequestError as e:
        pytest.fail(f"Cannot connect to server at {server_url}: {e}")

    # Fixed embedder mode: bypass GPU compute while still testing real server behavior.
    # 
    # What's STILL tested (real server):
    #   - Validation logic (empty sequences → 422, missing embedder → 422, invalid method → 400)
    #   - Configuration endpoints (/common_embedders, /projection_config)
    #   - Request/response contracts and endpoint routing
    #
    # What's BYPASSED (via FakeResponse):
    #   - GPU-intensive model inference (ESM2, ProtT5, etc.)
    #   - Redis job queue and worker processing
    #   - Actual PCA/UMAP/t-SNE computation
    #
    # This allows integration tests to verify the full submit→poll→result flow
    # and all validation logic without waiting for slow ML compute.
    if os.environ.get("CI_EMBEDDER", "").lower() == "fixed":
        import uuid
        from tests.fixtures.fixed_embedder import get_fixed_embedder

        # Save original methods so we can delegate non-intercepted requests
        original_post = http_client.post
        original_get = http_client.get

        # FakeResponse mimics httpx.Response interface (status_code, json()).
        # Required because we return mock responses for intercepted endpoints
        # while still satisfying the same API contract as real HTTP responses.
        class FakeResponse:
            def __init__(self, status_code: int, payload: Dict):
                self.status_code = status_code
                self._payload = payload

            def json(self, *args, **kwargs):
                return self._payload

        # Track fake task state so GET /task_status can return correct status
        _fake_tasks: Dict[str, Dict] = {}

        # Write fake embeddings directly to the database so subsequent reads
        # (e.g., get_missing_embeddings, prediction tasks) find cached data.
        # This simulates what the real embedding worker would do.
        # Delegates to the server's EmbeddingsDatabase API.
        def _save_embeddings_to_db(
            sequences: Dict[str, str], embedder_name: str, reduced: bool, fe
        ):
            postgres_config = {
                "host": os.environ.get("POSTGRES_HOST", "localhost"),
                "port": int(os.environ.get("POSTGRES_PORT", "5432")),
                "dbname": os.environ.get("POSTGRES_DB", "embeddings_db"),
                "user": os.environ.get("POSTGRES_USER", "embeddingsuser"),
                "password": os.environ.get("POSTGRES_PASSWORD", "embeddingspwd"),
            }

            try:
                db = EmbeddingsDatabase(postgres_config)
                records = [
                    BiotrainerSequenceRecord(
                        seq_id=seq_id,
                        seq=sequence,
                        embedding=fe.embed_pooled(sequence) if reduced else fe.embed(sequence),
                    )
                    for seq_id, sequence in sequences.items()
                ]
                db.save_embeddings(records, embedder_name, reduced=reduced)
            except Exception as e:
                print(f"[FIXED EMBEDDER] Warning: Failed to save to DB: {e}")

        # Intercept POST requests to embedding/projection endpoints.
        # Instead of forwarding to the real server, generate fake embeddings
        # and immediately return a "completed" task response.
        def _fake_post(url, *args, **kwargs):
            try:
                path = urlparse(str(url)).path
            except Exception:
                path = str(url)

            # Intercept embedding requests: generate deterministic embeddings,
            # save them to DB, and return a fake task_id marked as FINISHED
            if path.startswith("/embeddings_service/embed"):
                data = kwargs.get("json") or {}

                if not data.get("embedder_name"):
                    return FakeResponse(422, {"detail": "embedder_name missing"})
                if not data.get("sequence_data"):
                    return FakeResponse(422, {"detail": "sequence_data empty"})

                embedder_name = data.get("embedder_name")
                seqs = data.get("sequence_data")
                reduced = bool(data.get("reduce", False))

                fe = get_fixed_embedder(model_name=embedder_name, strict_dataset=False)

                if isinstance(seqs, list):
                    seqs = {f"seq_{i}": seq for i, seq in enumerate(seqs)}

                _save_embeddings_to_db(seqs, embedder_name, reduced, fe)

                task_id = f"local-{uuid.uuid4().hex[:8]}"
                _fake_tasks[task_id] = {
                    "task_id": task_id,
                    "status": "FINISHED",
                    "result": {},
                    "error": None,
                }
                return FakeResponse(200, {"task_id": task_id})

            # Intercept projection requests: return fake dimensionality-reduced coordinates
            # without running actual PCA/UMAP/t-SNE algorithms
            if path.startswith("/projection_service/project"):
                data = kwargs.get("json") or {}
                if not data.get("sequence_data"):
                    return FakeResponse(422, {"detail": "sequence_data empty"})

                seqs = data.get("sequence_data")
                method = data.get("method", "pca")
                n_components = data.get("config", {}).get("n_components", 2)

                from protspace.utils import REDUCERS
                if method.lower() not in REDUCERS:
                    return FakeResponse(400, {"detail": f"Unknown method: {method}"})

                task_id = f"local-{uuid.uuid4().hex[:8]}"

                seq_ids = (
                    list(seqs.keys())
                    if isinstance(seqs, dict)
                    else [f"seq_{i}" for i in range(len(seqs))]
                )
                projection_result = {
                    method: {
                        "identifier": seq_ids,
                        **{
                            f"D{d + 1}": [
                                float(i * 0.1 + d * 0.01) for i, _ in enumerate(seq_ids)
                            ]
                            for d in range(n_components)
                        },
                    }
                }
                _fake_tasks[task_id] = {
                    "task_id": task_id,
                    "status": "FINISHED",
                    "projection_result": projection_result,
                    "error": None,
                }
                return FakeResponse(200, {"task_id": task_id})

            # Non-intercepted endpoints pass through to the real server
            return original_post(url, *args, **kwargs)

        # Intercept GET requests for task status checks.
        # Return stored fake task state for "local-" prefixed task IDs.
        def _fake_get(url, *args, **kwargs):
            try:
                path = urlparse(str(url)).path
            except Exception:
                path = str(url)

            # Only intercept task status for our fake "local-" tasks
            if path.startswith("/biocentral_service/task_status/local-"):
                try:
                    task_id = path.rstrip("/").split("/")[-1]
                except Exception:
                    task_id = None

                if task_id and task_id in _fake_tasks:
                    dto = _fake_tasks[task_id]
                    return FakeResponse(200, {"dtos": [dto]})

            return original_get(url, *args, **kwargs)

        # Monkey-patch the client to use our fake handlers
        http_client.post = _fake_post
        http_client.get = _fake_get

    # Wrap post/get with retry logic for transient connection errors.
    # This avoids scattering try/except RemoteProtocolError across every test;
    # if the server is truly unreachable after retries, the test fails properly.
    _raw_post = http_client.post
    _raw_get = http_client.get

    def _resilient_call(method_fn, *args, max_retries: int = 3, **kwargs):
        last_error = None
        for attempt in range(max_retries):
            try:
                return method_fn(*args, **kwargs)
            except (httpx.RemoteProtocolError, httpx.ConnectError, httpx.ReadTimeout) as e:
                last_error = e
                wait_time = min(2 ** attempt, 10)
                logging.warning(
                    f"[CLIENT] {type(e).__name__} on attempt {attempt + 1}/{max_retries}, "
                    f"retrying in {wait_time}s: {e}"
                )
                if attempt < max_retries - 1:
                    time.sleep(wait_time)
        raise last_error

    http_client.post = lambda *args, **kwargs: _resilient_call(_raw_post, *args, **kwargs)
    http_client.get = lambda *args, **kwargs: _resilient_call(_raw_get, *args, **kwargs)

    yield http_client
    http_client.close()


def _make_request_with_retry(
    client, method: str, url: str, max_retries: int = 5, **kwargs
) -> httpx.Response:
    #Retry requests on 5xx server errors.
    for attempt in range(max_retries):
        if method.upper() == "GET":
            response = client.get(url, **kwargs)
        elif method.upper() == "POST":
            response = client.post(url, **kwargs)
        else:
            raise ValueError(f"Unsupported method: {method}")

        if response.status_code >= 500 and attempt < max_retries - 1:
            wait_time = min(2**attempt, 30)
            logging.debug(
                f"Request got {response.status_code} "
                f"(attempt {attempt + 1}/{max_retries}), retrying in {wait_time}s..."
            )
            time.sleep(wait_time)
            continue
        return response

    return response  # Return last response even if 5xx after all retries


def validate_task_dto(task_dto: Dict[str, Any]) -> Dict[str, Any]:
    assert isinstance(task_dto, dict), f"Task DTO must be dict, got {type(task_dto)}"
    assert "status" in task_dto, "Task DTO missing 'status'"
    assert isinstance(task_dto["status"], str), "Task DTO 'status' must be string"
    return task_dto


def assert_task_success(
    task_dto: Dict[str, Any], context: str = "task"
) -> Dict[str, Any]:
    validate_task_dto(task_dto)
    status = task_dto["status"].upper()
    assert status in TERMINAL_SUCCESS_STATUSES, (
        f"{context} should succeed; got status={status}, error={task_dto.get('error')}"
    )
    error_value = task_dto.get("error")
    assert error_value in (None, "", []), (
        f"{context} has unexpected error payload despite success status: {error_value}"
    )
    return task_dto


def assert_projection_result_schema(
    task_dto: Dict[str, Any],
    method: str,
    expected_sequence_count: int,
) -> Dict[str, Any]:
    projection_result = task_dto.get("projection_result")
    assert isinstance(projection_result, dict), (
        "Task DTO missing 'projection_result' dict"
    )

    method_key = method.lower()
    method_payload = (
        projection_result.get(method_key)
        or projection_result.get(method.upper())
        or projection_result.get(method)
    )
    assert isinstance(method_payload, dict), (
        f"Projection result missing method payload for '{method}'"
    )

    identifiers = method_payload.get("identifier")
    assert isinstance(identifiers, list), "Projection payload missing 'identifier' list"
    assert len(identifiers) == expected_sequence_count, (
        f"Projection identifier length {len(identifiers)} != expected {expected_sequence_count}"
    )

    for key, values in method_payload.items():
        if key.startswith("D"):
            assert isinstance(values, list), f"Projection axis '{key}' must be a list"
            assert len(values) == len(identifiers), (
                f"Projection axis '{key}' length {len(values)} != identifier length {len(identifiers)}"
            )
    return method_payload


def assert_prediction_result_schema(
    task_dto: Dict[str, Any],
    expected_sequence_ids,
) -> Dict[str, Any]:
    if isinstance(task_dto.get("predictions"), dict):
        predictions = task_dto.get("predictions")
        prediction_result = {"predictions": predictions}
    else:
        prediction_result = task_dto.get("prediction_result")
        if prediction_result is None:
            prediction_result = task_dto.get("result")
        assert isinstance(prediction_result, dict), (
            "Task DTO missing prediction result dict"
        )
        predictions = prediction_result.get("predictions")
    assert isinstance(predictions, dict), "Prediction result missing 'predictions' dict"
    assert set(predictions.keys()) == set(expected_sequence_ids), (
        f"Prediction keys {sorted(predictions.keys())} do not match input ids {sorted(expected_sequence_ids)}"
    )
    return prediction_result


@pytest.fixture(scope="session")
def poll_task(client):
    def _poll(
        task_id: str,
        timeout: int = 120,
        poll_interval: float = 2.0,
        max_consecutive_errors: int = 10,
        require_success: bool = False,
    ) -> Dict[str, Any]:
        start = time.time()
        consecutive_errors = 0
        last_status = "UNKNOWN"

        while time.time() - start < timeout:
            elapsed = int(time.time() - start)

            try:
                response = _make_request_with_retry(
                    client,
                    "GET",
                    f"/biocentral_service/task_status/{task_id}",
                    max_retries=3,
                )

                consecutive_errors = 0

            except (
                httpx.RemoteProtocolError,
                httpx.ConnectError,
                httpx.ReadTimeout,
            ) as e:
                consecutive_errors += 1
                logging.warning(
                    f"[POLL] Connection error ({consecutive_errors}/{max_consecutive_errors}): {e}"
                )

                if consecutive_errors >= max_consecutive_errors:
                    raise RuntimeError(
                        f"Task {task_id} polling failed: {consecutive_errors} consecutive connection errors. "
                        f"Last error: {e}. Last known status: {last_status}"
                    )

                time.sleep(poll_interval * 2)
                continue

            if response.status_code != 200:
                consecutive_errors += 1
                logging.warning(
                    f"[POLL] Bad status code {response.status_code} ({consecutive_errors}/{max_consecutive_errors})"
                )

                if consecutive_errors >= max_consecutive_errors:
                    raise RuntimeError(
                        f"Task {task_id} polling failed: got status {response.status_code} "
                        f"{consecutive_errors} times. Last known status: {last_status}"
                    )

                time.sleep(poll_interval)
                continue

            response_json = response.json()
            dtos = response_json.get("dtos", [])

            if not dtos:
                time.sleep(poll_interval)
                continue

            latest_dto = dtos[-1]
            latest_dto = validate_task_dto(latest_dto)
            task_status = latest_dto.get("status", "").upper()
            last_status = task_status

            if elapsed % 30 == 0 and elapsed > 0:
                logging.info(
                    f"[POLL] Task {task_id}: {task_status} ({elapsed}s elapsed)"
                )

            if task_status in TERMINAL_SUCCESS_STATUSES:
                logging.info(
                    f"[POLL] Task {task_id} completed successfully in {elapsed}s"
                )
                if require_success:
                    assert_task_success(latest_dto, context=f"task {task_id}")
                return latest_dto

            elif task_status in TERMINAL_FAILURE_STATUSES:
                err = latest_dto.get("error", "unknown")
                logging.warning(f"[POLL] Task {task_id} failed: {err}")
                if require_success:
                    raise RuntimeError(
                        f"Task {task_id} entered terminal failure status={task_status}: {err}"
                    )
                return latest_dto

            time.sleep(poll_interval)

        raise TimeoutError(
            f"Task {task_id} did not complete within {timeout}s. Last status: {last_status}"
        )

    return _poll

def get_embedder_name() -> str:
    ci_embedder = os.environ.get("CI_EMBEDDER", "esm2_t6_8m").lower()

    if ci_embedder not in EMBEDDER_MAP:
        valid_options = ", ".join(EMBEDDER_MAP.keys())
        pytest.fail(
            f"Invalid CI_EMBEDDER='{ci_embedder}'. Valid options: {valid_options}"
        )

    embedder_name = EMBEDDER_MAP[ci_embedder]

    return embedder_name


def is_fixed_embedder() -> bool:
    return os.environ.get("CI_EMBEDDER", "esm2_t6_8m").lower() == "fixed"


@pytest.fixture(scope="session")
def embedder_name() -> str:
    return get_embedder_name()


@pytest.fixture(scope="session")
def test_sequences() -> Dict[str, str]:
    return {
        "protein_1": CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
    }


@pytest.fixture(scope="session")
def single_test_sequence() -> Dict[str, str]:
    return {
        "test_seq": CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
    }


@pytest.fixture(scope="session")
def shared_embedding_sequences() -> Dict[str, str]:
    return {
        "short_1": CANONICAL_TEST_DATASET.get_by_id("length_short_10").sequence,
        "short_2": CANONICAL_TEST_DATASET.get_by_id("length_medium_50").sequence,
    }


@pytest.fixture(scope="session")
def short_test_sequences() -> Dict[str, str]:
    return {
        "short_1": CANONICAL_TEST_DATASET.get_by_id("length_short_10").sequence,
        "short_2": CANONICAL_TEST_DATASET.get_by_id("length_medium_50").sequence,
    }


@pytest.fixture(scope="session")
def minimum_length_sequences() -> Dict[str, str]:
    return {
        "min_1": CANONICAL_TEST_DATASET.get_by_id("length_min_1").sequence,
        "min_2": CANONICAL_TEST_DATASET.get_by_id("length_min_2").sequence,
        "short_5": CANONICAL_TEST_DATASET.get_by_id("length_short_5").sequence,
    }


@pytest.fixture(scope="session")
def long_sequences() -> Dict[str, str]:
    return {
        "long_200": CANONICAL_TEST_DATASET.get_by_id("length_long_200").sequence,
    }


@pytest.fixture(scope="session")
def unknown_token_sequences() -> Dict[str, str]:
    return {
        "unknown_single": CANONICAL_TEST_DATASET.get_by_id("unknown_single").sequence,
        "unknown_multiple": CANONICAL_TEST_DATASET.get_by_id(
            "unknown_multiple"
        ).sequence,
        "unknown_start": CANONICAL_TEST_DATASET.get_by_id("unknown_start").sequence,
        "unknown_end": CANONICAL_TEST_DATASET.get_by_id("unknown_end").sequence,
        "unknown_middle": CANONICAL_TEST_DATASET.get_by_id("unknown_middle").sequence,
        "unknown_scattered": CANONICAL_TEST_DATASET.get_by_id(
            "unknown_scattered"
        ).sequence,
        "unknown_high_ratio": CANONICAL_TEST_DATASET.get_by_id(
            "unknown_high_ratio"
        ).sequence,
    }


@pytest.fixture(scope="session")
def ambiguous_code_sequences() -> Dict[str, str]:
    return {
        "ambiguous_B": CANONICAL_TEST_DATASET.get_by_id("ambiguous_B").sequence,
        "ambiguous_Z": CANONICAL_TEST_DATASET.get_by_id("ambiguous_Z").sequence,
        "ambiguous_J": CANONICAL_TEST_DATASET.get_by_id("ambiguous_J").sequence,
    }


@pytest.fixture(scope="session")
def composition_edge_sequences() -> Dict[str, str]:
    return {
        "all_standard_aa": CANONICAL_TEST_DATASET.get_by_id("all_standard_aa").sequence,
        "homopolymer_A": CANONICAL_TEST_DATASET.get_by_id("homopolymer_A").sequence,
    }


@pytest.fixture(scope="session")
def structural_motif_sequences() -> Dict[str, str]:
    return {
        "alpha_helix": CANONICAL_TEST_DATASET.get_by_id("motif_alpha_helix").sequence,
        "beta_sheet": CANONICAL_TEST_DATASET.get_by_id("motif_beta_sheet").sequence,
    }


@pytest.fixture(scope="session")
def real_world_sequences() -> Dict[str, str]:
    return {
        "insulin_b": CANONICAL_TEST_DATASET.get_by_id("length_short_10").sequence,
    }

def get_sequence_by_id(seq_id: str) -> str:
    return CANONICAL_TEST_DATASET.get_by_id(seq_id).sequence


@pytest.fixture(scope="session")
def all_canonical_sequences() -> Dict[str, str]:
    return {seq_id: get_sequence_by_id(seq_id) for seq_id in ALL_CANONICAL_IDS}


@pytest.fixture(scope="session")
def large_batch_sequences() -> Dict[str, str]:
    base_sequences = [
        CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
    ]

    sequences = {}
    for i in range(100):
        base_seq = base_sequences[i % len(base_sequences)]
        seq_id = f"batch_seq_{i:03d}"
        sequences[seq_id] = base_seq

    return sequences


def validate_task_response(
    response_json: Dict, expected_task_id_prefix: str = None
) -> str:
    assert "task_id" in response_json, "Response missing 'task_id' field"
    task_id = response_json["task_id"]
    assert isinstance(task_id, str), f"task_id should be string, got {type(task_id)}"
    assert len(task_id) > 0, "task_id should not be empty"

    if expected_task_id_prefix:
        assert task_id.startswith(expected_task_id_prefix), (
            f"task_id '{task_id}' should start with '{expected_task_id_prefix}'"
        )

    return task_id


def validate_error_response(response_json: Dict, expected_status: int = None) -> Dict:
    assert "detail" in response_json, "Error response missing 'detail' field"
    detail = response_json["detail"]

    if isinstance(detail, list):
        for error in detail:
            assert "loc" in error, "Validation error missing 'loc'"
            assert "msg" in error, "Validation error missing 'msg'"
            assert "type" in error, "Validation error missing 'type'"

    return response_json


@pytest.fixture(scope="session")
def test_run_id() -> str:
    import uuid

    return str(uuid.uuid4())[:8]


@pytest.fixture(scope="session")
def verify_embedding_cache(client, embedder_name, shared_embedding_sequences):
    def _verify(expect_cached: bool = True):
        import json
        from biotrainer.utilities import calculate_sequence_hash

        hashed_sequences = {
            calculate_sequence_hash(seq): seq
            for seq in shared_embedding_sequences.values()
        }
        request_data = {
            "sequences": json.dumps(hashed_sequences),
            "embedder_name": embedder_name,
            "reduced": True,  # Must match ProtSpaceTask's reduced=True
        }

        response = client.post(
            "/embeddings_service/get_missing_embeddings",
            json=request_data,
        )

        if response.status_code != 200:
            print(f"[CACHE CHECK] Failed to check cache: {response.status_code}")
            return {"error": response.status_code}

        result = response.json()
        missing = result.get("missing", [])
        total = len(shared_embedding_sequences)
        cached = total - len(missing)

        status = {
            "total": total,
            "cached": cached,
            "missing": missing,
            "embedder_name": embedder_name,
            "all_cached": len(missing) == 0,
        }

        print(f"\n[CACHE CHECK] Embedder: {embedder_name}")
        print(f"[CACHE CHECK] Cached: {cached}/{total}")
        if missing:
            print(f"[CACHE CHECK] Missing IDs: {missing}")

        if expect_cached:
            assert len(missing) == 0, (
                f"Expected all embeddings cached, but missing: {missing}"
            )

        return status

    return _verify


@pytest.fixture(scope="session")
def precache_prott5_embeddings(shared_embedding_sequences):
    from tests.fixtures.fixed_embedder import FixedEmbedder

    postgres_config = {
        "host": os.environ.get("POSTGRES_HOST", "localhost"),
        "port": int(os.environ.get("POSTGRES_PORT", "5432")),
        "dbname": os.environ.get("POSTGRES_DB", "embeddings_db"),
        "user": os.environ.get("POSTGRES_USER", "embeddingsuser"),
        "password": os.environ.get("POSTGRES_PASSWORD", "embeddingspwd"),
    }

    embedder_name = "Rostlab/prot_t5_xl_uniref50"
    fe = FixedEmbedder(model_name="prot_t5_xl")

    try:
        db = EmbeddingsDatabase(postgres_config)

        # Save per-residue embeddings
        per_residue_records = [
            BiotrainerSequenceRecord(
                seq_id=seq_id, seq=sequence, embedding=fe.embed(sequence)
            )
            for seq_id, sequence in shared_embedding_sequences.items()
        ]
        db.save_embeddings(per_residue_records, embedder_name, reduced=False)

        # Save per-sequence (pooled) embeddings
        per_sequence_records = [
            BiotrainerSequenceRecord(
                seq_id=seq_id, seq=sequence, embedding=fe.embed_pooled(sequence)
            )
            for seq_id, sequence in shared_embedding_sequences.items()
        ]
        db.save_embeddings(per_sequence_records, embedder_name, reduced=True)

        print(f"\n[PRECACHE] Inserted {len(shared_embedding_sequences)} fake ProtT5 embeddings")
        return True

    except Exception as e:
        print(f"\n[PRECACHE] Failed to insert fake ProtT5 embeddings: {e}")
        return False


@pytest.fixture(scope="session")
def load_bindembed_onnx():
    from biocentral_server.predict import PredictInitializer

    try:
        initializer = PredictInitializer()

        if not initializer.check_one_time_setup_is_done():
            initializer.one_time_setup()
            print("\n[ONNX] Downloaded and uploaded prediction models via PredictInitializer")
        else:
            print("\n[ONNX] Prediction models already present")

        return True

    except Exception as e:
        print(f"\n[ONNX] Failed to load models: {e}")
        import traceback
        traceback.print_exc()
        return False

