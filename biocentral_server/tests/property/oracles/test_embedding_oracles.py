import random
import hashlib
from datetime import datetime
from typing import Any, Dict, List, Protocol, Optional, Union
from pathlib import Path
import csv
import numpy as np
import pytest
from pydantic import BaseModel, Field
from biotrainer.input_files import BiotrainerSequenceRecord

from tests.fixtures.test_dataset import (
    get_test_sequences,
)

_oracle_results: List[Dict[str, Any]] = []
pytestmark = pytest.mark.property


def _stable_sort_key(row: Dict[str, Any]) -> tuple:
    # Use masking_ratio for numerical sorting if present, otherwise fall back to parameter string
    masking_ratio = row.get("masking_ratio")
    seq_idx = (
        row.get("parameter", "").split("_")[0]
        if "mask" in row.get("parameter", "")
        else ""
    )
    return (
        str(row.get("embedder", "")),
        str(row.get("model", "")),
        str(row.get("method", "")),
        str(row.get("test_type", "")),
        seq_idx,
        masking_ratio if masking_ratio is not None else float("inf"),
        str(row.get("parameter", "")),
    )


def _format_float(value: Any, precision: int = 8) -> str:
    try:
        return f"{float(value):.{precision}f}"
    except (TypeError, ValueError):
        return ""


def compute_cosine_distance(a: np.ndarray, b: np.ndarray) -> float:
    a_flat = _ensure_1d(a)
    b_flat = _ensure_1d(b)

    norm_a = np.linalg.norm(a_flat)
    norm_b = np.linalg.norm(b_flat)

    if norm_a == 0 or norm_b == 0:
        return 1.0

    cosine_similarity = np.dot(a_flat, b_flat) / (norm_a * norm_b)

    cosine_similarity = np.clip(cosine_similarity, -1.0, 1.0)
    return float(1.0 - cosine_similarity)


def compute_l2_distance(a: np.ndarray, b: np.ndarray) -> float:
    a_flat = _ensure_1d(a)
    b_flat = _ensure_1d(b)

    return float(np.linalg.norm(a_flat - b_flat))


def compute_all_metrics(a: np.ndarray, b: np.ndarray) -> Dict[str, float]:
    return {
        "cosine_distance": compute_cosine_distance(a, b),
        "l2_distance": compute_l2_distance(a, b),
    }


def _ensure_1d(arr: np.ndarray) -> np.ndarray:
    if arr.ndim == 1:
        return arr
    elif arr.ndim == 2:
        return arr.mean(axis=0)
    else:
        raise ValueError(f"Expected 1D or 2D array, got {arr.ndim}D")


def format_metrics_table(
    results: List[Dict[str, Any]],
    title: Optional[str] = None,
) -> str:
    if not results:
        return "No results to display."

    headers = [
        "Embedder",
        "Test Type",
        "Parameter",
        "Cosine",
        "L2",
        "Threshold",
        "Passed",
    ]
    col_widths = [15, 20, 12, 10, 10, 10, 8]

    lines = []

    if title:
        lines.append(f"\n{'=' * 97}")
        lines.append(f"  {title}")
        lines.append(f"{'=' * 97}")

    header_row = " | ".join(h.ljust(w) for h, w in zip(headers, col_widths))
    lines.append(header_row)
    lines.append("-" * len(header_row))

    for row in sorted(results, key=_stable_sort_key):
        values = [
            str(row.get("embedder", ""))[:15],
            str(row.get("test_type", ""))[:20],
            str(row.get("parameter", ""))[:12],
            f"{row.get('cosine_distance', 0):.6f}",
            f"{row.get('l2_distance', 0):.4f}",
            f"{row.get('threshold', 0):.4f}",
            "✓" if row.get("passed", False) else "✗",
        ]
        data_row = " | ".join(v.ljust(w) for v, w in zip(values, col_widths))
        lines.append(data_row)

    lines.append("")
    return "\n".join(lines)


def write_metrics_csv(
    results: List[Dict[str, Any]],
    path: Union[str, Path],
) -> None:
    path = Path(path)

    path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        "timestamp",
        "embedder",
        "test_type",
        "parameter",
        "cosine_distance",
        "l2_distance",
        "threshold",
        "passed",
    ]

    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for row in sorted(results, key=_stable_sort_key):
            csv_row = {
                "timestamp": row.get("timestamp", ""),
                "embedder": row.get("embedder", ""),
                "test_type": row.get("test_type", ""),
                "parameter": row.get("parameter", ""),
                "cosine_distance": _format_float(row.get("cosine_distance", 0.0)),
                "l2_distance": _format_float(row.get("l2_distance", 0.0)),
                "threshold": _format_float(row.get("threshold", 0.0)),
                "passed": row.get("passed", False),
            }
            writer.writerow(csv_row)


def get_default_report_path() -> Path:
    return Path(__file__).parent.parent.parent / "reports" / "oracle_metrics.csv"

def get_oracle_results() -> List[Dict[str, Any]]:
    return _oracle_results


def add_oracle_result(result: Dict[str, Any]) -> None:
    if "timestamp" not in result:
        result["timestamp"] = datetime.now().isoformat()
    _oracle_results.append(result)


def clear_oracle_results() -> None:
    _oracle_results.clear()


class EmbedderProtocol(Protocol):
    def embed(self, sequence: str) -> np.ndarray: ...

    def embed_pooled(self, sequence: str) -> np.ndarray: ...

    def embed_batch(
        self, sequences: List[str], pooled: bool = False
    ) -> List[np.ndarray]: ...


class OracleConfig(BaseModel):
    embedder_name: str = Field(description="Name of the embedder model to test")
    cosine_threshold: float = Field(
        description="Maximum cosine distance allowed for batch invariance checks"
    )
    batch_sizes: List[int] = Field(
        default=[1, 5, 10],
        description="List of batch sizes to test for batch invariance",
    )
    masking_ratios: List[float] = Field(
        default=[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
        description="Ratios of sequence masking to test for metamorphic relations",
    )


ORACLE_CONFIGS = {
    "esm2_t6_8m": OracleConfig(
        embedder_name="esm2_t6_8m",
        cosine_threshold=0.25,  # Allow some variation in larger batches
    ),
}


class BatchInvarianceOracle:
    # Oracle verifying that embeddings are invariant to batch composition.

    def __init__(
        self,
        embedder: EmbedderProtocol,
        config: OracleConfig,
    ):
        # Initialize BatchInvarianceOracle.
        self.embedder = embedder
        self.config = config

    def verify(
        self,
        target_sequence: str,
        filler_sequences: List[str],
    ) -> List[Dict[str, Any]]:
        # Verify batch invariance for a target sequence.
        results = []

        single_embedding = self.embedder.embed_pooled(target_sequence)

        for batch_size in self.config.batch_sizes:
            batch = self._create_batch(target_sequence, filler_sequences, batch_size)
            target_idx = batch.index(target_sequence)

            batch_embeddings = self.embedder.embed_batch(batch, pooled=True)
            batched_embedding = batch_embeddings[target_idx]

            metrics = compute_all_metrics(single_embedding, batched_embedding)

            passed = metrics["cosine_distance"] <= self.config.cosine_threshold

            result = {
                "embedder": self.config.embedder_name,
                "test_type": "batch_invariance",
                "parameter": f"batch_{batch_size}",
                "cosine_distance": metrics["cosine_distance"],
                "l2_distance": metrics["l2_distance"],
                "threshold": self.config.cosine_threshold,
                "passed": passed,
            }
            results.append(result)
            add_oracle_result(result)

        return results

    def _create_batch(
        self,
        target: str,
        fillers: List[str],
        batch_size: int,
    ) -> List[str]:
        if batch_size == 1:
            return [target]

        n_fillers = batch_size - 1
        selected_fillers = []
        for i in range(n_fillers):
            selected_fillers.append(fillers[i % len(fillers)])

        batch = selected_fillers.copy()
        seed_material = f"{self.config.embedder_name}:{batch_size}:{target}".encode(
            "utf-8"
        )
        seed = int.from_bytes(hashlib.sha256(seed_material).digest()[:8], "big")
        rng = random.Random(seed)
        insert_pos = rng.randint(0, len(batch))
        batch.insert(insert_pos, target)

        return batch

@pytest.fixture(scope="module")
def esm2_t6_8m_oracle_config() -> OracleConfig:
    return ORACLE_CONFIGS["esm2_t6_8m"]


@pytest.fixture(scope="module")
def esm2_t6_8m_embedder():
    # Load real ESM2-T6-8M embedder.
    try:
        import torch
        from biotrainer.embedders import get_embedding_service

        embedding_service = get_embedding_service(
            embedder_name="facebook/esm2_t6_8M_UR50D",
            use_half_precision=False,
            custom_tokenizer_config=None,
            device=torch.device("cpu"),
        )

        return ESM2EmbedderWrapper(embedding_service)

    except ImportError as e:
        pytest.fail(
            f"Failed to import biotrainer embedders. "
            f"Ensure biotrainer is installed: {e}"
        )
    except Exception as e:
        pytest.fail(
            f"Failed to load ESM2-T6-8M model. "
            f"Model must be available for oracle tests: {e}"
        )


class ESM2EmbedderWrapper:
    # Wrapper to adapt biotrainer EmbeddingService to EmbedderProtocol.

    def __init__(self, embedding_service):
        self.embedding_service = embedding_service

    def _to_records(self, sequences: List[str]) -> List[BiotrainerSequenceRecord]:
        return [
            BiotrainerSequenceRecord(seq_id=f"seq_{i}", seq=seq)
            for i, seq in enumerate(sequences)
        ]

    def embed(self, sequence: str) -> np.ndarray:
        records = self._to_records([sequence])
        results = list(
            self.embedding_service.generate_embeddings(records, reduce=False)
        )
        if results:
            _, embedding = results[0]
            return np.array(embedding)
        return np.array([])

    def embed_pooled(self, sequence: str) -> np.ndarray:
        records = self._to_records([sequence])
        results = list(self.embedding_service.generate_embeddings(records, reduce=True))
        if results:
            _, embedding = results[0]
            return np.array(embedding)
        return np.array([])

    def embed_batch(
        self, sequences: List[str], pooled: bool = False
    ) -> List[np.ndarray]:
        records = self._to_records(sequences)
        results = list(
            self.embedding_service.generate_embeddings(records, reduce=pooled)
        )
        return [np.array(embedding) for _, embedding in results]


@pytest.fixture(scope="module")
def oracle_sequences() -> List[str]:
    return get_test_sequences(categories=["standard"])


@pytest.fixture(scope="module")
def filler_sequences() -> List[str]:
    return get_test_sequences(categories=["edge_case"])


class TestBatchInvarianceESM2:
    def test_embedding_matches_across_batch_sizes(
        self,
        esm2_t6_8m_embedder,
        esm2_t6_8m_oracle_config: OracleConfig,
        oracle_sequences: List[str],
        filler_sequences: List[str],
    ):
        oracle = BatchInvarianceOracle(
            embedder=esm2_t6_8m_embedder,
            config=esm2_t6_8m_oracle_config,
        )

        all_results = []
        for idx, seq in enumerate(oracle_sequences[:2]):
            results = oracle.verify(seq, filler_sequences)
            for result in results:
                result["sequence_index"] = idx
                result["sequence_length"] = len(seq)
            all_results.extend(results)

        table = format_metrics_table(
            all_results,
            title="Batch Invariance Oracle - ESM2-T6-8M",
        )
        print(table)

        for result in all_results:
            assert result["passed"], (
                f"Batch invariance failed for {result['parameter']}: "
                f"cosine_distance={result['cosine_distance']:.6f} > "
                f"threshold={result['threshold']:.4f}; "
                f"embedder={result['embedder']}; "
                f"sequence_index={result.get('sequence_index')}; "
                f"sequence_length={result.get('sequence_length')}"
            )


@pytest.fixture(scope="module", autouse=True)
def write_oracle_report(request):
    yield

    results = get_oracle_results()
    if results:
        report_path = get_default_report_path()
        write_metrics_csv(results, report_path)
        print(f"\n📊 Oracle metrics report written to: {report_path}")

    clear_oracle_results()
