"""Triton inference repository with connection pooling."""

import time
import queue
import threading
from abc import ABC, abstractmethod
from typing import List, Dict, Optional, Set
import numpy as np

try:
    import tritonclient.grpc as triton_grpc

    TRITON_AVAILABLE = True
except ImportError:
    TRITON_AVAILABLE = False
    triton_grpc = None


from biocentral_server.utils import get_logger
from .config import TritonClientConfig
from .exceptions import (
    TritonTimeoutError,
    TritonConnectionError,
    TritonModelError,
    TritonInferenceError,
    TritonResourceExhaustionError,
)

logger = get_logger(__name__)


class InferenceRepository(ABC):
    """Abstract repository for ML inference operations."""

    @abstractmethod
    def compute_embeddings(
        self, sequences: List[str], model_name: str, pooled: bool = False
    ) -> List[np.ndarray]:
        """Compute embeddings for sequences."""
        pass

    @abstractmethod
    def health_check(self, model_name: str) -> Dict[str, bool]:
        """Check inference server health for specific model."""
        pass

    @abstractmethod
    def get_model_metadata(self, model_name: str) -> Dict:
        """Get model metadata."""
        pass

    @abstractmethod
    def get_repository_stats(self) -> Dict:
        """Get repository statistics and metrics."""
        pass

    @abstractmethod
    def connect(self) -> None:
        """Connect to the inference backend."""
        pass

    @abstractmethod
    def disconnect(self) -> None:
        """Disconnect from the inference backend."""
        pass


class TritonInferenceRepository(InferenceRepository):
    """Triton inference repository with connection pooling.

    Provides synchronous interface for Triton Inference Server operations:
    - Connection pooling via queue.Queue
    - Thread-safe client management
    - Automatic error handling and retries
    """

    # Cache for available models (class-level)
    _available_models_cache: Optional[Set[str]] = None
    _cache_timestamp: Optional[float] = None
    _cache_ttl: float = 60.0  # 60 seconds TTL

    def __init__(self, config: TritonClientConfig):
        if not TRITON_AVAILABLE:
            raise ImportError(
                "Triton client dependencies not available. "
                "Install with: pip install tritonclient[grpc]"
            )

        self.config = config
        self._clients: Optional[queue.Queue] = None
        self._initialized = False
        self._lock = threading.Lock()

    def connect(self) -> None:
        """Initialize connection pool."""
        if self._initialized:
            return

        with self._lock:
            if self._initialized:
                return

            # Create connection pool
            self._clients = queue.Queue(maxsize=self.config.triton_pool_size)

            # Configure gRPC channel options
            # This prevents "Socket closed" errors during long-running inference
            channel_args = [
                # Message size limits (INT32_MAX ~2GB)
                ("grpc.max_send_message_length", self.config.triton_max_message_size),
                (
                    "grpc.max_receive_message_length",
                    self.config.triton_max_message_size,
                ),
                # Keepalive settings to prevent connection drops
                ("grpc.keepalive_time_ms", self.config.triton_grpc_keepalive_time_ms),
                (
                    "grpc.keepalive_timeout_ms",
                    self.config.triton_grpc_keepalive_timeout_ms,
                ),
                ("grpc.keepalive_permit_without_calls", False),
                (
                    "grpc.http2.max_pings_without_data",
                    self.config.triton_http2_max_pings_without_data,
                ),
            ]

            # Create client pool
            grpc_url = self.config.get_grpc_url_without_protocol()
            for i in range(self.config.triton_pool_size):
                client = triton_grpc.InferenceServerClient(
                    url=grpc_url, verbose=False, channel_args=channel_args
                )
                self._clients.put(client)

            # Test connection
            test_client = self._clients.get(
                timeout=self.config.triton_connection_timeout
            )
            try:
                if not test_client.is_server_ready():
                    raise TritonConnectionError("Triton server is not ready")
                logger.info(
                    f"Triton client pool initialized ({self.config.triton_pool_size} clients) "
                    f"at {self.config.triton_grpc_url}"
                )
            except Exception as e:
                logger.error(f"Failed to connect to Triton server: {e}")
                raise TritonConnectionError(
                    f"Failed to initialize Triton connection: {e}"
                ) from e
            finally:
                self._clients.put(test_client)

            self._initialized = True

    def disconnect(self) -> None:
        """Close all connections."""
        if not self._initialized or self._clients is None:
            return

        with self._lock:
            if not self._initialized:
                return

            while not self._clients.empty():
                try:
                    client = self._clients.get_nowait()
                    client.close()
                except queue.Empty:
                    break
            self._initialized = False

    def compute_embeddings(
        self, sequences: List[str], model_name: str, pooled: bool = False
    ) -> List[np.ndarray]:
        """Compute embeddings via Triton inference.

        Args:
            sequences: List of protein sequences
            model_name: Triton model name (e.g., "prot_t5_pipeline")
            pooled: Whether to pool embeddings per-sequence

        Returns:
            List of embedding arrays
        """
        # Validate batch size
        if len(sequences) > self.config.triton_max_batch_size:
            raise TritonInferenceError(
                f"Batch size {len(sequences)} exceeds maximum {self.config.triton_max_batch_size}"
            )

        start_time = time.time()

        # Get client from pool
        try:
            client = self._clients.get(
                timeout=self.config.triton_pool_acquisition_timeout
            )
        except queue.Empty:
            raise TritonResourceExhaustionError("Client pool exhausted")

        try:
            # Direct Triton inference
            embeddings = self._infer_embeddings_batch(
                client, sequences, model_name, pooled
            )

            # Logging
            inference_time = time.time() - start_time
            logger.info(
                f"Triton embedding inference completed: {len(sequences)} sequences "
                f"in {inference_time * 1000:.1f}ms (model: {model_name})"
            )

            return embeddings

        except Exception as e:
            if "connection" in str(e).lower() or "unavailable" in str(e).lower():
                raise TritonConnectionError(f"Connection failed: {e}") from e
            elif "model" in str(e).lower():
                raise TritonModelError(f"Model error: {e}") from e
            else:
                raise TritonInferenceError(f"Inference failed: {e}") from e

        finally:
            # Always return client to pool
            self._clients.put(client)

    def _infer_embeddings_batch(
        self,
        client: triton_grpc.InferenceServerClient,
        sequences: List[str],
        model_name: str,
        pooled: bool,
    ) -> List[np.ndarray]:
        """Direct Triton inference for embeddings.

        Args:
            client: Triton gRPC client
            sequences: List of protein sequences
            model_name: Triton model name
            pooled: Whether to pool embeddings

        Returns:
            List of embedding arrays
        """
        # Prepare input tensor
        sequences_array = np.array(sequences, dtype=object).reshape(-1, 1)

        inputs = [triton_grpc.InferInput("sequences", sequences_array.shape, "BYTES")]
        inputs[0].set_data_from_numpy(sequences_array)

        outputs = [triton_grpc.InferRequestedOutput("embeddings")]

        # Make inference request
        try:
            response = client.infer(
                model_name=model_name,
                inputs=inputs,
                outputs=outputs,
                client_timeout=self.config.triton_timeout,
            )
        except Exception as e:
            if "deadline" in str(e).lower() or "timeout" in str(e).lower():
                raise TritonTimeoutError(
                    f"Inference timeout after {self.config.triton_timeout}s"
                ) from e
            raise

        # Process response
        embeddings_tensor = response.as_numpy("embeddings").astype(np.float32)

        if len(embeddings_tensor.shape) != 3:
            raise TritonInferenceError(
                f"Invalid tensor shape: expected 3D, got {embeddings_tensor.shape}"
            )

        batch_size, seq_len, embed_dim = embeddings_tensor.shape
        if batch_size != len(sequences):
            raise TritonInferenceError(
                f"Batch size mismatch: expected {len(sequences)}, got {batch_size}"
            )

        # Process embeddings based on pooling preference
        # Note: Different tokenizers add different special tokens:
        # - ProtT5: adds 1 EOS token at end
        # - ESM2: adds BOS at start + EOS at end (2 tokens total)
        embeddings = []
        for i in range(len(sequences)):
            seq_embeddings = embeddings_tensor[i]
            seq_len = len(sequences[i])  # Actual sequence length without special tokens

            # Strip special tokens based on model
            if "prot_t5" in model_name.lower():
                # ProtT5 adds EOS at end: keep [:seq_len]
                seq_embeddings = seq_embeddings[:seq_len, :]
            elif "esm2" in model_name.lower():
                # ESM2 adds BOS at start + EOS at end: keep [1:seq_len+1]
                seq_embeddings = seq_embeddings[1 : seq_len + 1, :]
            # else: keep as is for other models

            if pooled:
                pooled_embedding = np.mean(seq_embeddings, axis=0)
                embeddings.append(pooled_embedding)
            else:
                embeddings.append(seq_embeddings)

        return embeddings

    def health_check(self, model_name: str) -> Dict[str, bool]:
        """Check Triton server health.

        Args:
            model_name: Model name to check

        Returns:
            Dictionary with health status
        """
        try:
            client = self._clients.get(timeout=self.config.triton_connection_timeout)
        except queue.Empty:
            return {
                "connected": False,
                "server_ready": False,
                "server_live": False,
                "model_ready": False,
                "error": "Client pool exhausted",
            }

        try:
            server_ready = client.is_server_ready()
            server_live = client.is_server_live()

            try:
                model_ready = client.is_model_ready(model_name)
            except Exception:
                model_ready = False

            return {
                "connected": True,
                "server_ready": server_ready,
                "server_live": server_live,
                "model_ready": model_ready,
            }

        except Exception as e:
            return {
                "connected": False,
                "server_ready": False,
                "server_live": False,
                "model_ready": False,
                "error": str(e),
            }
        finally:
            self._clients.put(client)

    def get_model_metadata(self, model_name: str) -> Dict:
        """Get model metadata.

        Args:
            model_name: Model name

        Returns:
            Dictionary with model metadata
        """
        try:
            client = self._clients.get(timeout=self.config.triton_connection_timeout)
        except queue.Empty:
            raise TritonResourceExhaustionError("Client pool exhausted")

        try:
            metadata = client.get_model_metadata(model_name)

            return {
                "name": metadata.name,
                "platform": metadata.platform,
                "versions": list(metadata.versions),
                "inputs": [
                    {
                        "name": inp.name,
                        "datatype": inp.datatype,
                        "shape": list(inp.shape),
                    }
                    for inp in metadata.inputs
                ],
                "outputs": [
                    {
                        "name": out.name,
                        "datatype": out.datatype,
                        "shape": list(out.shape),
                    }
                    for out in metadata.outputs
                ],
            }

        finally:
            self._clients.put(client)

    def _fetch_available_models(self) -> Set[str]:
        """Fetch list of available models from Triton server.

        Returns:
            Set of available model names
        """
        if not TRITON_AVAILABLE:
            logger.warning("Triton dependencies not available")
            return set()

        try:
            client = self._clients.get(timeout=self.config.triton_connection_timeout)
        except queue.Empty:
            logger.warning("Client pool exhausted when fetching models")
            return set()

        try:
            # Use Triton gRPC client's built-in method
            model_repository_index = client.get_model_repository_index()
            available_models = set()

            for model in model_repository_index.models:
                available_models.add(model.name)

            logger.info(
                f"Found {len(available_models)} available models in Triton: {sorted(available_models)}"
            )
            return available_models

        except Exception as e:
            logger.warning(f"Failed to fetch available models from Triton: {e}")
            return set()
        finally:
            self._clients.put(client)

    def get_available_models(self) -> Set[str]:
        """Get available models with caching.

        Returns:
            Set of available model names
        """
        current_time = time.time()

        # Check if cache is valid
        if (
            self._available_models_cache is not None
            and len(self._available_models_cache) > 0
            and self._cache_timestamp is not None
            and current_time - self._cache_timestamp < self._cache_ttl
        ):
            return self._available_models_cache

        # Fetch fresh data
        self._available_models_cache = self._fetch_available_models()
        self._cache_timestamp = current_time

        return self._available_models_cache

    def is_model_available(self, model_name: str) -> bool:
        """Check if a model is available in Triton.

        Args:
            model_name: Model name to check

        Returns:
            True if model is available, False otherwise
        """
        available_models = self.get_available_models()
        return model_name in available_models

    def get_repository_stats(self) -> Dict:
        """Get comprehensive repository statistics."""
        return {
            "pool_size": self.config.triton_pool_size,
            "available_clients": self._clients.qsize() if self._clients else 0,
            "triton_timeout": self.config.triton_timeout,
            "connection_timeout": self.config.triton_connection_timeout,
            "max_batch_size": self.config.triton_max_batch_size,
            "initialized": self._initialized,
        }


def create_triton_repository(
    config: Optional[TritonClientConfig] = None,
) -> TritonInferenceRepository:
    """Factory function to create a Triton inference repository.

    Args:
        config: Optional configuration. If None, uses environment variables.

    Returns:
        Initialized TritonInferenceRepository
    """
    if config is None:
        config = TritonClientConfig.from_env()

    return TritonInferenceRepository(config=config)
