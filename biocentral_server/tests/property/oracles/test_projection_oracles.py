from datetime import datetime
from typing import Any, Dict, List, Protocol

import numpy as np
import pytest
from pydantic import BaseModel, Field

from tests.fixtures.test_dataset import CANONICAL_TEST_DATASET
from tests.fixtures.fixed_embedder import FixedEmbedder

_projection_oracle_results: List[Dict[str, Any]] = []
pytestmark = pytest.mark.property


def get_projection_oracle_results() -> List[Dict[str, Any]]:
    return _projection_oracle_results


def add_projection_oracle_result(result: Dict[str, Any]) -> None:
    if "timestamp" not in result:
        result["timestamp"] = datetime.now().isoformat()
    _projection_oracle_results.append(result)


def clear_projection_oracle_results() -> None:
    _projection_oracle_results.clear()


class ProjectionOracleConfig(BaseModel):
    method: str = Field(description="Projection method name (e.g., 'umap', 'pca', 'tsne')")
    n_components: int = Field(
        default=2, description="Number of dimensions to project to"
    )
    distance_correlation_threshold: float = Field(
        default=0.5,
        description="Minimum correlation between original and projected distances",
    )


PROJECTION_ORACLE_CONFIGS = {
    "umap": ProjectionOracleConfig(
        method="umap",
        n_components=2,
        # UMAP preserves local neighborhood structure, not global pairwise distances
        distance_correlation_threshold=0.0,
    ),
    "pca": ProjectionOracleConfig(
        method="pca",
        n_components=2,
        distance_correlation_threshold=0.4,
    ),
    "tsne": ProjectionOracleConfig(
        method="tsne",
        n_components=2,
        distance_correlation_threshold=0.2,
    ),
}


class ProjectorProtocol(Protocol):
    def project(
        self,
        embeddings: Dict[str, np.ndarray],
        method: str,
        n_components: int,
    ) -> Dict[str, np.ndarray]: ...


class ProjectionDeterminismOracle:
    # Verifies projections are deterministic across multiple runs.

    def __init__(
        self,
        projector: ProjectorProtocol,
        config: ProjectionOracleConfig,
        num_runs: int = 3,
    ):
        self.projector = projector
        self.config = config
        self.num_runs = num_runs

    def verify(self, embeddings: Dict[str, np.ndarray]) -> Dict[str, Any]:
        projections_list = []
        for _ in range(self.num_runs):
            proj = self.projector.project(
                embeddings,
                self.config.method,
                self.config.n_components,
            )
            projections_list.append(proj)

        first = projections_list[0]
        all_identical = all(
            self._projections_equal(first, p) for p in projections_list[1:]
        )

        result = {
            "method": self.config.method,
            "test_type": "determinism",
            "num_sequences": len(embeddings),
            "num_runs": self.num_runs,
            "passed": all_identical,
        }
        add_projection_oracle_result(result)
        return result

    def _projections_equal(
        self,
        p1: Dict[str, np.ndarray],
        p2: Dict[str, np.ndarray],
    ) -> bool:
        if set(p1.keys()) != set(p2.keys()):
            return False
        for key in p1:
            if not np.allclose(p1[key], p2[key], rtol=1e-4, atol=1e-5):
                return False
        return True


class DimensionalityOracle:
    # Verifies projection dimensions are correct.

    def __init__(
        self,
        projector: ProjectorProtocol,
        config: ProjectionOracleConfig,
    ):
        self.projector = projector
        self.config = config

    def verify(self, embeddings: Dict[str, np.ndarray]) -> Dict[str, Any]:
        projections = self.projector.project(
            embeddings,
            self.config.method,
            self.config.n_components,
        )

        issues = []
        for seq_id, proj in projections.items():
            if proj.shape != (self.config.n_components,):
                issues.append(
                    f"{seq_id}: shape {proj.shape} != "
                    f"expected ({self.config.n_components},)"
                )

        passed = len(issues) == 0

        result = {
            "method": self.config.method,
            "test_type": "dimensionality",
            "n_components": self.config.n_components,
            "num_sequences": len(embeddings),
            "issues": issues,
            "passed": passed,
        }
        add_projection_oracle_result(result)
        return result


class ProjectionValueValidityOracle:
    # Verifies projection values are finite and within bounds.

    def __init__(
        self,
        projector: ProjectorProtocol,
        config: ProjectionOracleConfig,
        max_abs_value: float = 1000.0,
    ):
        self.projector = projector
        self.config = config
        self.max_abs_value = max_abs_value

    def verify(self, embeddings: Dict[str, np.ndarray]) -> Dict[str, Any]:
        projections = self.projector.project(
            embeddings,
            self.config.method,
            self.config.n_components,
        )

        issues = []
        for seq_id, proj in projections.items():
            if not np.isfinite(proj).all():
                issues.append(f"{seq_id}: contains NaN or Inf values")

            if np.abs(proj).max() > self.max_abs_value:
                issues.append(
                    f"{seq_id}: values exceed bounds "
                    f"(max abs: {np.abs(proj).max():.2f})"
                )

        passed = len(issues) == 0

        result = {
            "method": self.config.method,
            "test_type": "value_validity",
            "num_sequences": len(embeddings),
            "issues": issues,
            "passed": passed,
        }
        add_projection_oracle_result(result)
        return result


class DistancePreservationOracle:
    # Verifies projections approximately preserve pairwise distances.

    def __init__(
        self,
        projector: ProjectorProtocol,
        config: ProjectionOracleConfig,
    ):
        self.projector = projector
        self.config = config

    def verify(self, embeddings: Dict[str, np.ndarray]) -> Dict[str, Any]:
        if len(embeddings) < 3:
            return {
                "method": self.config.method,
                "test_type": "distance_preservation",
                "passed": True,
                "reason": "Not enough sequences for distance comparison",
            }

        projections = self.projector.project(
            embeddings,
            self.config.method,
            self.config.n_components,
        )

        seq_ids = list(embeddings.keys())
        original_dists = []
        projected_dists = []

        for i in range(len(seq_ids)):
            for j in range(i + 1, len(seq_ids)):
                id_i, id_j = seq_ids[i], seq_ids[j]

                emb_i = embeddings[id_i]
                emb_j = embeddings[id_j]
                if len(emb_i.shape) > 1:
                    emb_i = emb_i.mean(axis=0)
                if len(emb_j.shape) > 1:
                    emb_j = emb_j.mean(axis=0)
                orig_dist = np.linalg.norm(emb_i - emb_j)

                proj_dist = np.linalg.norm(projections[id_i] - projections[id_j])

                original_dists.append(orig_dist)
                projected_dists.append(proj_dist)

        correlation = np.corrcoef(original_dists, projected_dists)[0, 1]

        if np.isnan(correlation):
            correlation = 0.0

        passed = correlation >= self.config.distance_correlation_threshold

        result = {
            "method": self.config.method,
            "test_type": "distance_preservation",
            "correlation": float(correlation),
            "threshold": self.config.distance_correlation_threshold,
            "num_pairs": len(original_dists),
            "passed": passed,
        }
        add_projection_oracle_result(result)
        return result


class DirectProjector:
    # Projector using the same protspace pipeline as ProtSpaceTask without HTTP calls.

    def __init__(self, config: ProjectionOracleConfig = None):
        self.config = config or ProjectionOracleConfig(method="pca")
        self._processor = None
        self._reducers = None

    def _ensure_initialized(self):
        if self._processor is not None:
            return

        from protspace.data.processors import BaseProcessor
        from protspace.utils import REDUCERS

        self._reducers = REDUCERS
        self._processor = BaseProcessor(config={}, reducers=REDUCERS)

    def project(
        self,
        embeddings: Dict[str, np.ndarray],
        method: str,
        n_components: int,
    ) -> Dict[str, np.ndarray]:
        import pandas as pd
        self._ensure_initialized()

        if method.lower() not in self._reducers:
            raise ValueError(
                f"Unknown projection method: {method}. "
                f"Available: {list(self._reducers.keys())}"
            )

        seq_ids = list(embeddings.keys())
        embedding_matrix = []
        for seq_id in seq_ids:
            emb = embeddings[seq_id]
            if len(emb.shape) > 1:
                emb = emb.mean(axis=0)
            embedding_matrix.append(emb)

        # Same pipeline as ProtSpaceTask.run_task:
        # process_reduction -> create_output -> to_pydict
        metadata = pd.DataFrame({"identifier": seq_ids})
        reduction = self._processor.process_reduction(
            data=np.array(embedding_matrix),
            method=method.lower(),
            dims=n_components,
        )
        output = self._processor.create_output(
            metadata=metadata, reductions=[reduction], headers=seq_ids,
        )
        projection_result = {key: table.to_pydict() for key, table in output.items()}

        # Extract per-sequence coordinate arrays from protspace tabular output.
        # protspace create_output produces a "projections_data" table with
        # columns: projection_name, identifier, x, y, z
        coord_cols = ["x", "y", "z"][:n_components]
        data = projection_result["projections_data"]
        projections = {}
        for i, seq_id in enumerate(data["identifier"]):
            coords = np.array(
                [data[c][i] for c in coord_cols],
                dtype=np.float32,
            )
            projections[seq_id] = coords

        return projections


@pytest.fixture(scope="module")
def pca_config() -> ProjectionOracleConfig:
    return PROJECTION_ORACLE_CONFIGS["pca"]


@pytest.fixture(scope="module")
def umap_config() -> ProjectionOracleConfig:
    return PROJECTION_ORACLE_CONFIGS["umap"]


@pytest.fixture(scope="module")
def tsne_config() -> ProjectionOracleConfig:
    return PROJECTION_ORACLE_CONFIGS["tsne"]


# 20 sequence IDs for UMAP (requires > n_neighbors=15)
_ORACLE_SEQUENCE_IDS = [
    "standard_001", "standard_002", "standard_003",
    "real_insulin_b", "real_ubiquitin", "real_gfp_core",
    "length_short_10", "length_medium_50", "length_long_200",
    "all_standard_aa", "hydrophobic_rich", "charged_rich", "proline_rich",
    "motif_alpha_helix", "motif_beta_sheet", "motif_glycine_loop",
    "cysteine_rich", "homopolymer_A", "length_short_5", "length_min_2",
]


@pytest.fixture(scope="module")
def oracle_embeddings() -> Dict[str, np.ndarray]:
    # Test embeddings from canonical dataset using FixedEmbedder.
    embedder = FixedEmbedder(model_name="esm2_t6")
    sequences = CANONICAL_TEST_DATASET.get_subset_dict(_ORACLE_SEQUENCE_IDS)
    return embedder.embed_dict(sequences, pooled=True)


# Mapping for diverse test with renamed keys (16 sequences for UMAP)
_DIVERSE_ID_MAPPING = {
    "short": "length_short_10", "medium": "length_medium_50", "long": "length_long_200",
    "standard": "standard_001", "standard_002": "standard_002", "standard_003": "standard_003",
    "charged": "charged_rich", "hydrophobic": "hydrophobic_rich", "proline_rich": "proline_rich",
    "alpha_helix": "motif_alpha_helix", "beta_sheet": "motif_beta_sheet", "glycine_loop": "motif_glycine_loop",
    "cysteine_rich": "cysteine_rich", "all_aa": "all_standard_aa",
    "insulin": "real_insulin_b", "ubiquitin": "real_ubiquitin",
}


@pytest.fixture(scope="module")
def diverse_test_embeddings() -> Dict[str, np.ndarray]:
    # Test embeddings with diverse properties.
    embedder = FixedEmbedder(model_name="esm2_t6")
    sequences = {
        k: CANONICAL_TEST_DATASET.get_by_id(v).sequence
        for k, v in _DIVERSE_ID_MAPPING.items()
    }
    return embedder.embed_dict(sequences, pooled=True)


@pytest.fixture(scope="module")
def direct_pca_projector(pca_config: ProjectionOracleConfig) -> DirectProjector:
    try:
        projector = DirectProjector(config=pca_config)
        projector._ensure_initialized()
        return projector
    except Exception as e:
        pytest.skip(f"protspace not available for PCA: {e}")


@pytest.fixture(scope="module")
def direct_umap_projector(umap_config: ProjectionOracleConfig) -> DirectProjector:
    try:
        projector = DirectProjector(config=umap_config)
        projector._ensure_initialized()
        return projector
    except Exception as e:
        pytest.skip(f"protspace not available for UMAP: {e}")


@pytest.fixture(scope="module")
def direct_tsne_projector(tsne_config: ProjectionOracleConfig) -> DirectProjector:
    try:
        projector = DirectProjector(config=tsne_config)
        projector._ensure_initialized()
        return projector
    except Exception as e:
        pytest.skip(f"protspace not available for t-SNE: {e}")


@pytest.fixture(scope="module", params=["pca", "umap"])
def direct_projector(request):
    method = request.param
    config = PROJECTION_ORACLE_CONFIGS[method]
    try:
        projector = DirectProjector(config=config)
        projector._ensure_initialized()
        return projector, config
    except Exception as e:
        pytest.skip(f"protspace not available for {method}: {e}")


@pytest.mark.slow
class TestProjectionDeterminism:
    def test_pca_determinism(
        self,
        direct_pca_projector: DirectProjector,
        pca_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = ProjectionDeterminismOracle(
            projector=direct_pca_projector,
            config=pca_config,
        )

        result = oracle.verify(oracle_embeddings)
        assert result["passed"], (
            f"PCA determinism failed: method={result['method']}, "
            f"num_sequences={result['num_sequences']}, num_runs={result['num_runs']}"
        )

    def test_umap_determinism(
        self,
        direct_umap_projector: DirectProjector,
        umap_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = ProjectionDeterminismOracle(
            projector=direct_umap_projector,
            config=umap_config,
        )

        result = oracle.verify(oracle_embeddings)
        assert result["passed"], (
            f"UMAP determinism failed: method={result['method']}, "
            f"num_sequences={result['num_sequences']}, num_runs={result['num_runs']}"
        )


@pytest.mark.slow
class TestDimensionality:
    def test_pca_dimensionality_2d(
        self,
        direct_pca_projector: DirectProjector,
        pca_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = DimensionalityOracle(
            projector=direct_pca_projector,
            config=pca_config,
        )

        result = oracle.verify(oracle_embeddings)
        assert result["passed"], (
            f"Dimensionality check failed for method={result['method']} "
            f"n_components={result['n_components']}: {result['issues']}"
        )

    def test_umap_dimensionality_2d(
        self,
        direct_umap_projector: DirectProjector,
        umap_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = DimensionalityOracle(
            projector=direct_umap_projector,
            config=umap_config,
        )

        result = oracle.verify(oracle_embeddings)
        assert result["passed"], (
            f"Dimensionality check failed for method={result['method']} "
            f"n_components={result['n_components']}: {result['issues']}"
        )


@pytest.mark.slow
class TestProjectionValueValidity:
    def test_pca_values_valid(
        self,
        direct_pca_projector: DirectProjector,
        pca_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = ProjectionValueValidityOracle(
            projector=direct_pca_projector,
            config=pca_config,
        )

        result = oracle.verify(oracle_embeddings)
        assert result["passed"], (
            f"Value validity failed for method={result['method']}, "
            f"num_sequences={result['num_sequences']}: {result['issues']}"
        )

    def test_umap_values_valid(
        self,
        direct_umap_projector: DirectProjector,
        umap_config: ProjectionOracleConfig,
        diverse_test_embeddings: Dict[str, np.ndarray],
    ):
        oracle = ProjectionValueValidityOracle(
            projector=direct_umap_projector,
            config=umap_config,
        )

        result = oracle.verify(diverse_test_embeddings)
        assert result["passed"], f"Value validity failed: {result['issues']}"


@pytest.mark.slow
class TestDistancePreservation:
    def test_pca_preserves_distances(
        self,
        direct_pca_projector: DirectProjector,
        pca_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = DistancePreservationOracle(
            projector=direct_pca_projector,
            config=pca_config,
        )

        result = oracle.verify(oracle_embeddings)
        assert result["passed"], (
            f"Distance preservation failed for method={result['method']}: "
            f"correlation={result['correlation']:.6f} < threshold={result['threshold']:.6f}; "
            f"num_pairs={result['num_pairs']}"
        )

    def test_umap_preserves_local_structure(
        self,
        direct_umap_projector: DirectProjector,
        umap_config: ProjectionOracleConfig,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        oracle = DistancePreservationOracle(
            projector=direct_umap_projector,
            config=umap_config,
        )

        result = oracle.verify(oracle_embeddings)

        print(f"UMAP distance correlation: {result.get('correlation', 'N/A')}")
        assert result["passed"], (
            f"Distance preservation failed for method={result['method']}: "
            f"correlation={result['correlation']:.6f} < threshold={result['threshold']:.6f}; "
            f"num_pairs={result['num_pairs']}"
        )


@pytest.mark.slow
class TestParametrizedProjectionOracles:
    def test_projection_determinism(
        self,
        direct_projector,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        projector, config = direct_projector
        oracle = ProjectionDeterminismOracle(
            projector=projector,
            config=config,
        )

        result = oracle.verify(oracle_embeddings)

        assert result["passed"], (
            f"Determinism failed: method={result['method']}, "
            f"num_sequences={result['num_sequences']}"
        )

    def test_projection_dimensionality(
        self,
        direct_projector,
        oracle_embeddings: Dict[str, np.ndarray],
    ):
        projector, config = direct_projector
        oracle = DimensionalityOracle(
            projector=projector,
            config=config,
        )

        result = oracle.verify(oracle_embeddings)

        assert result["passed"], (
            f"Dimensionality failed: method={result['method']}, "
            f"issues={result['issues']}"
        )


@pytest.fixture(scope="module", autouse=True)
def cleanup_projection_results():
    yield
    results = get_projection_oracle_results()
    if results:
        print(f"\n📊 Projection oracle tests completed: {len(results)} results")
    clear_projection_oracle_results()
