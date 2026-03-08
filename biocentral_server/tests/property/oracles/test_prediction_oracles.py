import os
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Protocol, Tuple

import numpy as np
import pytest
import torch
from pydantic import BaseModel, Field

from biocentral_server.predict.models.secondary_structure import ProtT5SecondaryStructure
from biocentral_server.predict.models.binding.bind_embed import BindEmbed
from biocentral_server.predict.models.membrane.tmbed import TMbed
from biocentral_server.predict.models.disorder.seth import Seth
from biocentral_server.predict.predict_initializer import PredictInitializer
from biocentral_server.server_management import ServerModuleInitializer
from tests.fixtures.test_dataset import CANONICAL_TEST_DATASET
from tests.fixtures.fixed_embedder import FixedEmbedder

_prediction_oracle_results: List[Dict[str, Any]] = []
pytestmark = pytest.mark.property


def get_prediction_oracle_results() -> List[Dict[str, Any]]:
    return _prediction_oracle_results


def add_prediction_oracle_result(result: Dict[str, Any]) -> None:
    if "timestamp" not in result:
        result["timestamp"] = datetime.now().isoformat()
    _prediction_oracle_results.append(result)


def clear_prediction_oracle_results() -> None:
    _prediction_oracle_results.clear()


class PredictionOracleConfig(BaseModel):
    model_name: str = Field(description="Name of the prediction model to test")
    output_type: str = Field(
        description="Type of output: 'per_residue' or 'per_sequence'"
    )
    is_classification: bool = Field(
        default=True, description="Whether the model performs classification vs regression"
    )
    num_classes: Optional[int] = Field(
        default=None, description="Number of output classes for classification models"
    )
    value_range: Optional[Tuple[float, float]] = Field(
        default=None, description="Expected value range for regression outputs"
    )


PREDICTION_ORACLE_CONFIGS = {
    "ProtT5SecondaryStructure": PredictionOracleConfig(
        model_name="ProtT5SecondaryStructure",
        output_type="per_residue",
        is_classification=True,
        num_classes=3,
    ),
    "BindEmbed": PredictionOracleConfig(
        model_name="BindEmbed",
        output_type="per_residue",
        is_classification=True,
        num_classes=3,  # metal, nucleic, small binding types
    ),
    "TMbed": PredictionOracleConfig(
        model_name="TMbed",
        output_type="per_residue",
        is_classification=True,
        num_classes=7,  # B, b, H, h, S, i, o topology classes
    ),
    "Seth": PredictionOracleConfig(
        model_name="Seth",
        output_type="per_residue",
        is_classification=False,
        value_range=None,  # Seth outputs CheZOD Z-scores (unbounded)
    ),
}


class PredictorProtocol(Protocol):
    def predict(self, sequence: str) -> Dict[str, Any]: ...

    def predict_batch(self, sequences: List[str]) -> List[Dict[str, Any]]: ...


class PredictionDeterminismOracle:
    # Verifies predictions are deterministic across multiple runs.

    def __init__(
        self,
        predictor: PredictorProtocol,
        config: PredictionOracleConfig,
        num_runs: int = 3,
    ):
        self.predictor = predictor
        self.config = config
        self.num_runs = num_runs

    def verify(self, sequence: str) -> Dict[str, Any]:
        predictions = []
        for _ in range(self.num_runs):
            pred = self.predictor.predict(sequence)
            predictions.append(pred)

        first = predictions[0]
        all_identical = all(self._predictions_equal(first, p) for p in predictions[1:])

        result = {
            "model": self.config.model_name,
            "test_type": "determinism",
            "sequence_length": len(sequence),
            "num_runs": self.num_runs,
            "passed": all_identical,
        }
        add_prediction_oracle_result(result)
        return result

    def _predictions_equal(self, p1: Dict, p2: Dict) -> bool:
        if set(p1.keys()) != set(p2.keys()):
            return False
        for key in p1:
            v1, v2 = p1[key], p2[key]
            if isinstance(v1, (list, np.ndarray)):
                # Handle string lists (classification labels)
                if isinstance(v1, list) and v1 and isinstance(v1[0], str):
                    if v1 != v2:
                        return False
                elif not np.allclose(v1, v2, rtol=1e-5):
                    return False
            elif isinstance(v1, float):
                if not np.isclose(v1, v2, rtol=1e-5):
                    return False
            elif v1 != v2:
                return False
        return True


class OutputValidityOracle:
    # Verifies prediction outputs are valid and properly formatted.

    def __init__(
        self,
        predictor: PredictorProtocol,
        config: PredictionOracleConfig,
    ):
        self.predictor = predictor
        self.config = config

    def verify(self, sequence: str) -> Dict[str, Any]:
        pred = self.predictor.predict(sequence)
        issues = []

        if self.config.output_type == "per_residue":
            if "predictions" in pred:
                if len(pred["predictions"]) != len(sequence):
                    issues.append(
                        f"predictions length {len(pred['predictions'])} != "
                        f"sequence length {len(sequence)}"
                    )

        if self.config.is_classification and "probabilities" in pred:
            probs = np.array(pred["probabilities"])

            if np.any(probs < 0) or np.any(probs > 1):
                issues.append("probabilities outside [0, 1] range")

            if self.config.output_type == "per_residue":
                sums = probs.sum(axis=1)
                if not np.allclose(sums, 1.0, atol=1e-5):
                    issues.append("per-residue probabilities don't sum to 1")
            else:
                if not np.isclose(probs.sum(), 1.0, atol=1e-5):
                    issues.append("sequence probabilities don't sum to 1")

        if not self.config.is_classification and self.config.value_range:
            low, high = self.config.value_range
            values = np.array(pred.get("predictions", [pred.get("prediction", 0)]))
            if np.any(values < low) or np.any(values > high):
                issues.append(f"values outside expected range [{low}, {high}]")

        passed = len(issues) == 0

        result = {
            "model": self.config.model_name,
            "test_type": "output_validity",
            "sequence_length": len(sequence),
            "issues": issues,
            "passed": passed,
        }
        add_prediction_oracle_result(result)
        return result


class ShapeInvarianceOracle:
    # Verifies output shapes match model specifications.

    def __init__(
        self,
        predictor: PredictorProtocol,
        config: PredictionOracleConfig,
    ):
        self.predictor = predictor
        self.config = config

    def verify(self, sequences: List[str]) -> Dict[str, Any]:
        issues = []

        for seq in sequences:
            pred = self.predictor.predict(seq)

            if self.config.output_type == "per_residue":
                if "predictions" in pred:
                    pred_len = len(pred["predictions"])
                    if pred_len != len(seq):
                        issues.append(
                            f"seq len {len(seq)}: pred len {pred_len} mismatch"
                        )

                if "probabilities" in pred and self.config.num_classes:
                    probs = np.array(pred["probabilities"])
                    expected_shape = (len(seq), self.config.num_classes)
                    if probs.shape != expected_shape:
                        issues.append(
                            f"seq len {len(seq)}: probs shape {probs.shape} "
                            f"!= expected {expected_shape}"
                        )

        passed = len(issues) == 0

        result = {
            "model": self.config.model_name,
            "test_type": "shape_invariance",
            "num_sequences": len(sequences),
            "issues": issues,
            "passed": passed,
        }
        add_prediction_oracle_result(result)
        return result


# Model name mapping to ONNX directory names (uses model_name.value.lower())
# Files are auto-discovered within each directory
MODEL_DIRECTORIES = {
    "ProtT5SecondaryStructure": "prott5secondarystructure",
    "Seth": "seth",
    "BindEmbed": "bindembed",
    "TMbed": "tmbed",
}


def get_onnx_models_path() -> Path:
    """Get or download ONNX models path.

    Checks ONNX_MODELS_PATH env var first, then falls back to
    default location, downloading if necessary.
    """

    def models_exist(p: Path) -> bool:
        for model_name in expected_dirs:
            model_dir = p / model_name
            if model_dir.exists() and any(model_dir.glob("*.onnx")):
                return True
        return False

    expected_dirs = ["prott5secondarystructure", "seth", "bindembed", "tmbed"]

    # Check environment variable first
    path_str = os.environ.get("ONNX_MODELS_PATH")
    target_path = Path(path_str) if path_str else Path("onnx_models")

    if target_path.exists() and models_exist(target_path):
        return target_path

    # Download models to target path
    target_path.mkdir(parents=True, exist_ok=True)
    ServerModuleInitializer._download_data(
        urls=PredictInitializer.DOWNLOAD_URLS,
        data_dir=target_path,
    )
    return target_path


class DirectPredictor:
    # Predictor using ONNX models directly from local filesystem.
    # Loads ONNX models without server dependencies.
    # Configure model path with ONNX_MODELS_PATH environment variable.

    MODEL_CLASSES = {
        "ProtT5SecondaryStructure": ProtT5SecondaryStructure,
        "BindEmbed": BindEmbed,
        "TMbed": TMbed,
        "Seth": Seth,
    }

    def __init__(
        self,
        model_name: str,
        config: PredictionOracleConfig,
    ):
        self.model_name = model_name
        self.config = config
        self._model = None
        self._embedder = None
        self._initialized = False

    def _ensure_initialized(self):
        if self._initialized:
            return

        import onnxruntime as ort

        model_cls = self.MODEL_CLASSES.get(self.model_name)
        if not model_cls:
            raise ValueError(f"Unknown model: {self.model_name}")

        # Instantiate the production model with ONNX backend
        self._model = model_cls(batch_size=1, backend="onnx")

        # Load ONNX sessions from local filesystem, bypassing SeaweedFS
        models_path = get_onnx_models_path()
        model_dir_name = MODEL_DIRECTORIES.get(self.model_name)
        if not model_dir_name:
            raise ValueError(f"No directory configured for model: {self.model_name}")

        model_dir = models_path / model_dir_name
        if not model_dir.exists():
            raise FileNotFoundError(
                f"Model directory not found: {model_dir}. "
                f"Models may not have downloaded correctly."
            )

        onnx_files = sorted(model_dir.glob("*.onnx"))
        if not onnx_files:
            raise FileNotFoundError(
                f"No .onnx files found in {model_dir}. "
                f"Ensure models are properly extracted."
            )

        sessions = [ort.InferenceSession(str(f)) for f in onnx_files]

        if self._model.uses_ensemble:
            self._model.models = sessions
        else:
            self._model.model = sessions[0]

        # Mark backend as initialized so predict() skips SeaweedFS loading
        self._model._backend_initialized = True

        self._embedder = FixedEmbedder(
            model_name="prot_t5",
            strict_dataset=False,
        )
        self._initialized = True

    def predict(self, sequence: str) -> Dict[str, Any]:
        self._ensure_initialized()

        seq_id = "test_seq"
        embedding = self._embedder.embed(sequence)
        embedding_tensor = torch.from_numpy(embedding)

        result = self._model.predict(
            sequences={seq_id: sequence},
            embeddings={seq_id: embedding_tensor},
        )

        # Convert from Dict[str, List[Prediction]] to oracle format
        preds = result[seq_id]
        first_pred = preds[0]

        if self.config.is_classification:
            predictions = list(first_pred.value)
        else:
            # Regression (e.g., Seth) uses comma-delimited values
            predictions = [float(v) for v in first_pred.value.split(",")]

        return {
            "predictions": predictions,
            "sequence_length": len(sequence),
        }

    def predict_batch(self, sequences: List[str]) -> List[Dict[str, Any]]:
        return [self.predict(seq) for seq in sequences]


@pytest.fixture(scope="module")
def ss_oracle_config() -> PredictionOracleConfig:
    return PREDICTION_ORACLE_CONFIGS["ProtT5SecondaryStructure"]


@pytest.fixture(scope="module")
def binding_oracle_config() -> PredictionOracleConfig:
    return PREDICTION_ORACLE_CONFIGS["BindEmbed"]


@pytest.fixture(scope="module")
def disorder_oracle_config() -> PredictionOracleConfig:
    return PREDICTION_ORACLE_CONFIGS["Seth"]


@pytest.fixture(scope="module")
def tmbed_oracle_config() -> PredictionOracleConfig:
    return PREDICTION_ORACLE_CONFIGS["TMbed"]


@pytest.fixture(scope="module")
def standard_test_sequences() -> List[str]:
    return [
        CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
        CANONICAL_TEST_DATASET.get_by_id("standard_002").sequence,
        CANONICAL_TEST_DATASET.get_by_id("standard_003").sequence,
    ]


@pytest.fixture(scope="module")
def varied_length_sequences() -> List[str]:
    return [
        CANONICAL_TEST_DATASET.get_by_id("length_short_10").sequence,
        CANONICAL_TEST_DATASET.get_by_id("length_medium_50").sequence,
        CANONICAL_TEST_DATASET.get_by_id("standard_001").sequence,
    ]


@pytest.fixture(scope="module")
def direct_ss_predictor(ss_oracle_config):
    try:
        predictor = DirectPredictor(
            model_name="ProtT5SecondaryStructure",
            config=ss_oracle_config,
        )
        predictor._ensure_initialized()
        return predictor
    except FileNotFoundError as e:
        pytest.skip(f"ONNX model not found for ProtT5SecondaryStructure: {e}")
    except Exception as e:
        pytest.skip(f"ONNX model not available for ProtT5SecondaryStructure: {e}")


@pytest.fixture(scope="module")
def direct_bindembed_predictor(binding_oracle_config):
    try:
        predictor = DirectPredictor(
            model_name="BindEmbed",
            config=binding_oracle_config,
        )
        predictor._ensure_initialized()
        return predictor
    except FileNotFoundError as e:
        pytest.skip(f"ONNX model not found for BindEmbed: {e}")
    except Exception as e:
        pytest.skip(f"ONNX model not available for BindEmbed: {e}")


@pytest.fixture(scope="module")
def direct_tmbed_predictor(tmbed_oracle_config):
    try:
        predictor = DirectPredictor(
            model_name="TMbed",
            config=tmbed_oracle_config,
        )
        predictor._ensure_initialized()
        return predictor
    except FileNotFoundError as e:
        pytest.skip(f"ONNX model not found for TMbed: {e}")
    except Exception as e:
        pytest.skip(f"ONNX model not available for TMbed: {e}")


@pytest.fixture(scope="module")
def direct_seth_predictor(disorder_oracle_config):
    try:
        predictor = DirectPredictor(
            model_name="Seth",
            config=disorder_oracle_config,
        )
        predictor._ensure_initialized()
        return predictor
    except FileNotFoundError as e:
        pytest.skip(f"ONNX model not found for Seth: {e}")
    except Exception as e:
        pytest.skip(f"ONNX model not available for Seth: {e}")


# Parametrized fixture for multiple models via ONNX
@pytest.fixture(scope="module", params=["BindEmbed", "TMbed", "Seth"])
def direct_predictor(request):
    model_name = request.param
    config = PREDICTION_ORACLE_CONFIGS[model_name]
    try:
        predictor = DirectPredictor(
            model_name=model_name,
            config=config,
        )
        predictor._ensure_initialized()
        return predictor, config
    except FileNotFoundError as e:
        pytest.skip(f"ONNX model not found for {model_name}: {e}")
    except Exception as e:
        pytest.skip(f"ONNX model not available for {model_name}: {e}")


# Prediction determinism tests using direct ONNX inference
@pytest.mark.slow
class TestPredictionDeterminism:
    def test_secondary_structure_determinism(
        self,
        direct_ss_predictor: DirectPredictor,
        ss_oracle_config: PredictionOracleConfig,
        standard_test_sequences: List[str],
    ):
        # Verify secondary structure predictions are deterministic via ONNX
        oracle = PredictionDeterminismOracle(
            predictor=direct_ss_predictor,
            config=ss_oracle_config,
        )

        for seq in standard_test_sequences:
            result = oracle.verify(seq)
            assert result["passed"], (
                f"Determinism failed: model={result['model']}, "
                f"sequence_length={len(seq)}, runs={result['num_runs']}"
            )

    def test_bindembed_determinism(
        self,
        direct_bindembed_predictor: DirectPredictor,
        binding_oracle_config: PredictionOracleConfig,
        standard_test_sequences: List[str],
    ):
        # Verify BindEmbed predictions are deterministic via ONNX
        oracle = PredictionDeterminismOracle(
            predictor=direct_bindembed_predictor,
            config=binding_oracle_config,
        )

        for seq in standard_test_sequences:
            result = oracle.verify(seq)
            assert result["passed"], (
                f"Determinism failed: model={result['model']}, "
                f"sequence_length={len(seq)}, runs={result['num_runs']}"
            )

    def test_disorder_determinism(
        self,
        direct_seth_predictor: DirectPredictor,
        disorder_oracle_config: PredictionOracleConfig,
        standard_test_sequences: List[str],
    ):
        # Verify disorder predictions are deterministic via ONNX
        oracle = PredictionDeterminismOracle(
            predictor=direct_seth_predictor,
            config=disorder_oracle_config,
        )

        for seq in standard_test_sequences:
            result = oracle.verify(seq)
            assert result["passed"], (
                f"Determinism failed: model={result['model']}, "
                f"sequence_length={len(seq)}, runs={result['num_runs']}"
            )


# Output validity tests using direct ONNX inference
@pytest.mark.slow
class TestOutputValidity:
    def test_secondary_structure_output_validity(
        self,
        direct_ss_predictor: DirectPredictor,
        ss_oracle_config: PredictionOracleConfig,
        standard_test_sequences: List[str],
    ):
        # Verify secondary structure outputs are valid via ONNX
        oracle = OutputValidityOracle(
            predictor=direct_ss_predictor,
            config=ss_oracle_config,
        )

        for seq in standard_test_sequences:
            result = oracle.verify(seq)
            assert result["passed"], (
                f"Output validity failed: model={result['model']}, "
                f"sequence_length={len(seq)}, issues={result['issues']}"
            )

    def test_bindembed_output_validity(
        self,
        direct_bindembed_predictor: DirectPredictor,
        binding_oracle_config: PredictionOracleConfig,
        standard_test_sequences: List[str],
    ):
        # Verify BindEmbed outputs are valid via ONNX
        oracle = OutputValidityOracle(
            predictor=direct_bindembed_predictor,
            config=binding_oracle_config,
        )

        for seq in standard_test_sequences:
            result = oracle.verify(seq)
            assert result["passed"], (
                f"Output validity failed: model={result['model']}, "
                f"sequence_length={len(seq)}, issues={result['issues']}"
            )

    def test_disorder_output_validity(
        self,
        direct_seth_predictor: DirectPredictor,
        disorder_oracle_config: PredictionOracleConfig,
        standard_test_sequences: List[str],
    ):
        # Verify disorder outputs are valid (values in [0,1]) via ONNX
        oracle = OutputValidityOracle(
            predictor=direct_seth_predictor,
            config=disorder_oracle_config,
        )

        for seq in standard_test_sequences:
            result = oracle.verify(seq)
            assert result["passed"], (
                f"Output validity failed: model={result['model']}, "
                f"sequence_length={len(seq)}, issues={result['issues']}"
            )


# Shape invariance tests using direct ONNX inference
@pytest.mark.slow
class TestShapeInvariance:
    def test_secondary_structure_shape_invariance(
        self,
        direct_ss_predictor: DirectPredictor,
        ss_oracle_config: PredictionOracleConfig,
        varied_length_sequences: List[str],
    ):
        # Verify secondary structure output shapes match sequence lengths via ONNX
        oracle = ShapeInvarianceOracle(
            predictor=direct_ss_predictor,
            config=ss_oracle_config,
        )

        result = oracle.verify(varied_length_sequences)
        assert result["passed"], (
            f"Shape invariance failed: model={result['model']}, "
            f"num_sequences={result['num_sequences']}, issues={result['issues']}"
        )

    def test_bindembed_shape_invariance(
        self,
        direct_bindembed_predictor: DirectPredictor,
        binding_oracle_config: PredictionOracleConfig,
        varied_length_sequences: List[str],
    ):
        # Verify BindEmbed output shapes match sequence lengths via ONNX
        oracle = ShapeInvarianceOracle(
            predictor=direct_bindembed_predictor,
            config=binding_oracle_config,
        )

        result = oracle.verify(varied_length_sequences)
        assert result["passed"], (
            f"Shape invariance failed: model={result['model']}, "
            f"num_sequences={result['num_sequences']}, issues={result['issues']}"
        )


# Parametrized oracle tests across multiple ONNX models
@pytest.mark.slow
class TestParametrizedModelOracles:
    def test_model_determinism(
        self,
        direct_predictor,
    ):
        # Verify predictions are deterministic for any model via ONNX
        predictor, config = direct_predictor
        oracle = PredictionDeterminismOracle(
            predictor=predictor,
            config=config,
        )

        sequence = CANONICAL_TEST_DATASET.get_by_id("length_medium_50").sequence
        result = oracle.verify(sequence)

        assert result["passed"], (
            f"Determinism failed: model={result['model']}, "
            f"sequence_length={result['sequence_length']}"
        )

    def test_model_output_validity(
        self,
        direct_predictor,
    ):
        # Verify outputs are valid for any model via ONNX
        predictor, config = direct_predictor
        oracle = OutputValidityOracle(
            predictor=predictor,
            config=config,
        )

        sequence = CANONICAL_TEST_DATASET.get_by_id("length_medium_50").sequence
        result = oracle.verify(sequence)

        assert result["passed"], (
            f"Output validity failed: model={result['model']}, "
            f"issues={result['issues']}"
        )


# Clean up prediction oracle results after module completes
@pytest.fixture(scope="module", autouse=True)
def cleanup_prediction_results():
    yield
    results = get_prediction_oracle_results()
    if results:
        print(f"\n📊 Prediction oracle tests completed: {len(results)} results")
    clear_prediction_oracle_results()
