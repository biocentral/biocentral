"""Triton inference repository with circuit breaker and connection pooling."""

import asyncio
from abc import ABC, abstractmethod
from typing import List, Dict, Optional
import numpy as np

try:
    import tritonclient.grpc.aio as triton_grpc
    from circuitbreaker import circuit

    TRITON_AVAILABLE = True
except ImportError:
    TRITON_AVAILABLE = False
    triton_grpc = None
    circuit = None

from ...utils import get_logger
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
    async def compute_embeddings(
        self, sequences: List[str], model_name: str, pooled: bool = False
    ) -> List[np.ndarray]:
        """Compute embeddings for sequences."""
        pass

    @abstractmethod
    async def compute_predictions(
        self,
        embeddings: np.ndarray,
        model_name: str,
    ) -> np.ndarray:
        """Compute predictions from embeddings."""
        pass

    @abstractmethod
    async def health_check(self, model_name: str) -> Dict[str, bool]:
        """Check inference server health for specific model."""
        pass

    @abstractmethod
    async def get_model_metadata(self, model_name: str) -> Dict:
        """Get model metadata."""
        pass

    @abstractmethod
    def get_repository_stats(self) -> Dict:
        """Get repository statistics and metrics."""
        pass

    @abstractmethod
    async def connect(self) -> None:
        """Connect to the inference backend."""
        pass

    @abstractmethod
    async def disconnect(self) -> None:
        """Disconnect from the inference backend."""
        pass


class TritonInferenceRepository(InferenceRepository):
    """Triton inference repository with circuit breaker and connection pooling.

    Follows the architecture pattern from biocentral_emb_server:
    - Connection pooling via asyncio.Queue
    - Circuit breaker for infrastructure failures
    - Automatic retries and fallback handling
    """

    def __init__(self, config: TritonClientConfig):
        if not TRITON_AVAILABLE:
            raise ImportError(
                "Triton client dependencies not available. "
                "Install with: pip install tritonclient[grpc] circuitbreaker"
            )

        self.config = config
        self._clients: Optional[asyncio.Queue] = None
        self._initialized = False

        # Circuit breaker for infrastructure failures only
        infrastructure_exceptions = (
            TritonConnectionError,
            TritonTimeoutError,
            TritonResourceExhaustionError,
            ConnectionError,
            OSError,
            asyncio.TimeoutError,
        )

        self._circuit_breaker = circuit(
            failure_threshold=config.triton_circuit_breaker_failure_threshold,
            recovery_timeout=config.triton_circuit_breaker_timeout,
            expected_exception=infrastructure_exceptions,
        )

    async def connect(self) -> None:
        """Initialize connection pool."""
        if self._initialized:
            return

        # Create connection pool
        self._clients = asyncio.Queue(maxsize=self.config.triton_pool_size)

        # Create client pool
        grpc_url = self.config.get_grpc_url_without_protocol()
        for i in range(self.config.triton_pool_size):
            client = triton_grpc.InferenceServerClient(url=grpc_url, verbose=False)
            await self._clients.put(client)

        # Test connection
        test_client = await self._clients.get()
        try:
            await asyncio.wait_for(
                test_client.is_server_ready(),
                timeout=self.config.triton_connection_timeout,
            )
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
            await self._clients.put(test_client)

        self._initialized = True

    async def disconnect(self) -> None:
        """Close all connections."""
        if not self._initialized or self._clients is None:
            return

        while not self._clients.empty():
            try:
                client = self._clients.get_nowait()
                await client.close()
            except asyncio.QueueEmpty:
                break
        self._initialized = False

    async def compute_embeddings(
        self, sequences: List[str], model_name: str, pooled: bool = False
    ) -> List[np.ndarray]:
        """Compute embeddings via Triton inference."""
        # Validate batch size
        if len(sequences) > self.config.triton_max_batch_size:
            raise TritonInferenceError(
                f"Batch size {len(sequences)} exceeds maximum {self.config.triton_max_batch_size}"
            )

        # Use circuit breaker for the actual computation
        return await self._circuit_breaker(self._compute_embeddings_impl)(
            sequences, model_name, pooled
        )

    async def _compute_embeddings_impl(
        self, sequences: List[str], model_name: str, pooled: bool = False
    ) -> List[np.ndarray]:
        """Direct implementation of compute_embeddings."""
        start_time = asyncio.get_event_loop().time()

        # Get client from pool
        try:
            client = await asyncio.wait_for(
                self._clients.get(),
                timeout=self.config.triton_pool_acquisition_timeout,
            )
        except asyncio.TimeoutError:
            raise TritonResourceExhaustionError("Client pool exhausted")

        try:
            # Direct Triton inference
            embeddings = await self._infer_embeddings_batch(
                client, sequences, model_name, pooled
            )

            # Logging
            inference_time = asyncio.get_event_loop().time() - start_time
            logger.info(
                f"Triton embedding inference completed: {len(sequences)} sequences "
                f"in {inference_time * 1000:.1f}ms (model: {model_name})"
            )

            return embeddings

        except (
            TritonTimeoutError,
            TritonResourceExhaustionError,
            TritonInferenceError,
        ):
            raise
        except Exception as e:
            if "connection" in str(e).lower() or "unavailable" in str(e).lower():
                raise TritonConnectionError(f"Connection failed: {e}") from e
            elif "model" in str(e).lower():
                raise TritonModelError(f"Model error: {e}") from e
            else:
                raise TritonInferenceError(f"Inference failed: {e}") from e

        finally:
            # Always return client to pool
            await self._clients.put(client)

    async def _infer_embeddings_batch(
        self,
        client: triton_grpc.InferenceServerClient,
        sequences: List[str],
        model_name: str,
        pooled: bool,
    ) -> List[np.ndarray]:
        """Direct Triton inference for embeddings."""
        # Prepare input tensor
        sequences_array = np.array(sequences, dtype=object).reshape(-1, 1)

        inputs = [triton_grpc.InferInput("sequences", sequences_array.shape, "BYTES")]
        inputs[0].set_data_from_numpy(sequences_array)

        outputs = [triton_grpc.InferRequestedOutput("embeddings")]

        # Make inference request with timeout
        try:
            response = await asyncio.wait_for(
                client.infer(
                    model_name=model_name,
                    inputs=inputs,
                    outputs=outputs,
                    timeout=int(self.config.triton_timeout),
                ),
                timeout=self.config.triton_timeout,
            )
        except asyncio.TimeoutError:
            raise TritonTimeoutError(
                f"Inference timeout after {self.config.triton_timeout}s"
            )

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
        embeddings = []
        for i in range(len(sequences)):
            seq_embeddings = embeddings_tensor[i]

            if pooled:
                pooled_embedding = np.mean(seq_embeddings, axis=0)
                embeddings.append(pooled_embedding)
            else:
                embeddings.append(seq_embeddings)

        return embeddings

    async def compute_predictions(
        self,
        embeddings: np.ndarray,
        model_name: str,
    ) -> np.ndarray:
        """Compute predictions from embeddings via Triton."""
        return await self._circuit_breaker(self._compute_predictions_impl)(
            embeddings, model_name
        )

    async def _compute_predictions_impl(
        self,
        embeddings: np.ndarray,
        model_name: str,
    ) -> np.ndarray:
        """Direct implementation of compute_predictions."""
        start_time = asyncio.get_event_loop().time()

        # Get client from pool
        try:
            client = await asyncio.wait_for(
                self._clients.get(),
                timeout=self.config.triton_pool_acquisition_timeout,
            )
        except asyncio.TimeoutError:
            raise TritonResourceExhaustionError("Client pool exhausted")

        try:
            # Prepare input tensor
            if len(embeddings.shape) == 2:
                # Add batch dimension if needed
                embeddings = np.expand_dims(embeddings, axis=0)

            inputs = [
                triton_grpc.InferInput(
                    "embeddings", embeddings.shape, "FP32"
                )
            ]
            inputs[0].set_data_from_numpy(embeddings)

            outputs = [triton_grpc.InferRequestedOutput("predictions")]

            # Make inference request with timeout
            try:
                response = await asyncio.wait_for(
                    client.infer(
                        model_name=model_name,
                        inputs=inputs,
                        outputs=outputs,
                        timeout=int(self.config.triton_timeout),
                    ),
                    timeout=self.config.triton_timeout,
                )
            except asyncio.TimeoutError:
                raise TritonTimeoutError(
                    f"Inference timeout after {self.config.triton_timeout}s"
                )

            # Process response
            predictions = response.as_numpy("predictions")

            inference_time = asyncio.get_event_loop().time() - start_time
            logger.info(
                f"Triton prediction inference completed in {inference_time * 1000:.1f}ms "
                f"(model: {model_name})"
            )

            return predictions

        finally:
            await self._clients.put(client)

    async def health_check(self, model_name: str) -> Dict[str, bool]:
        """Check Triton server health."""
        return await self._circuit_breaker(self._health_check_impl)(model_name)

    async def _health_check_impl(self, model_name: str) -> Dict[str, bool]:
        """Direct health check implementation."""
        client = await asyncio.wait_for(
            self._clients.get(), timeout=self.config.triton_connection_timeout
        )

        try:
            server_ready = await client.is_server_ready()
            server_live = await client.is_server_live()

            try:
                model_ready = await client.is_model_ready(model_name)
            except Exception:
                model_ready = False

            return {
                "connected": True,
                "server_ready": server_ready,
                "server_live": server_live,
                "model_ready": model_ready,
                "circuit_breaker_open": self._circuit_breaker.state == "open",
                "circuit_breaker_state": self._circuit_breaker.state,
            }

        finally:
            await self._clients.put(client)

    async def get_model_metadata(self, model_name: str) -> Dict:
        """Get model metadata."""
        return await self._circuit_breaker(self._get_model_metadata_impl)(model_name)

    async def _get_model_metadata_impl(self, model_name: str) -> Dict:
        """Direct metadata retrieval."""
        client = await asyncio.wait_for(
            self._clients.get(), timeout=self.config.triton_connection_timeout
        )

        try:
            metadata = await client.get_model_metadata(model_name)

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
            await self._clients.put(client)

    def get_repository_stats(self) -> Dict:
        """Get comprehensive repository statistics."""
        return {
            "circuit_breaker_state": self._circuit_breaker.state,
            "circuit_breaker_failure_count": getattr(
                self._circuit_breaker, "_failure_count", 0
            ),
            "circuit_breaker_failure_threshold": self.config.triton_circuit_breaker_failure_threshold,
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
