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
    async def predict_per_residue(
        self, embeddings: List[np.ndarray], model_name: str
    ) -> List[np.ndarray]:
        """Compute per-residue predictions from embeddings.

        Args:
            embeddings: List of per-residue embeddings, one per sequence
            model_name: Name of the prediction model

        Returns:
            List of per-residue predictions, one array per sequence
        """
        pass

    @abstractmethod
    async def predict_sequence_level(
        self, embeddings: List[np.ndarray], model_name: str
    ) -> List[np.ndarray]:
        """Compute sequence-level predictions from embeddings.

        Args:
            embeddings: List of per-residue embeddings, one per sequence
            model_name: Name of the prediction model

        Returns:
            List of sequence-level predictions, one array per sequence
        """
        pass

    @abstractmethod
    async def predict_seth(
        self, sequences: List[str], model_name: str = "seth"
    ) -> List[np.ndarray]:
        """Predict disorder from sequences using SETH model.

        Args:
            sequences: List of protein sequences
            model_name: Name of the SETH model (default: "seth")

        Returns:
            List of per-residue disorder scores, one array per sequence
        """
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

        # Configure gRPC channel options for large messages (e.g., ESM2-T36 embeddings)
        channel_args = [
            ("grpc.max_send_message_length", self.config.triton_max_message_size),
            ("grpc.max_receive_message_length", self.config.triton_max_message_size),
            ("grpc.max_message_length", self.config.triton_max_message_size),
        ]

        # Create client pool
        grpc_url = self.config.get_grpc_url_without_protocol()
        for i in range(self.config.triton_pool_size):
            client = triton_grpc.InferenceServerClient(
                url=grpc_url, verbose=False, channel_args=channel_args
            )
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
                seq_embeddings = seq_embeddings[1:seq_len+1, :]
            # else: keep as is for other models

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

    async def predict_per_residue(
        self, embeddings: List[np.ndarray], model_name: str
    ) -> List[np.ndarray]:
        """Compute per-residue predictions from embeddings.

        Special handling for bind_embed ensemble model which outputs
        5 separate predictions that need sigmoid and averaging.

        Args:
            embeddings: List of per-residue embeddings, one per sequence
            model_name: Name of the prediction model

        Returns:
            List of per-residue predictions, one array per sequence
        """
        return await self._circuit_breaker(self._predict_per_residue_impl)(
            embeddings, model_name
        )

    async def _predict_per_residue_impl(
        self, embeddings: List[np.ndarray], model_name: str
    ) -> List[np.ndarray]:
        """Direct implementation of predict_per_residue."""
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
            # Pad embeddings to same length for batching
            max_len = max(emb.shape[0] for emb in embeddings)
            embed_dim = embeddings[0].shape[1]
            batch_size = len(embeddings)

            padded_batch = np.zeros(
                (batch_size, max_len, embed_dim), dtype=np.float32
            )
            for i, emb in enumerate(embeddings):
                padded_batch[i, : emb.shape[0], :] = emb

            # Prepare input tensor - transpose to (batch, embed_dim, seq_len) for bind_embed
            if model_name == "bind_embed":
                # bind_embed expects (batch, 1024, seq_len)
                input_tensor = np.transpose(padded_batch, (0, 2, 1))
                input_name = "ensemble_input"
            else:
                # Other models expect (batch, seq_len, embed_dim)
                input_tensor = padded_batch
                input_name = "input"

            inputs = [triton_grpc.InferInput(input_name, input_tensor.shape, "FP32")]
            inputs[0].set_data_from_numpy(input_tensor)

            # Handle different output names per model
            if model_name == "bind_embed":
                # Request all 5 CV model outputs
                outputs = [
                    triton_grpc.InferRequestedOutput(f"output_{i}")
                    for i in range(5)
                ]
            elif model_name == "prott5_sec":
                # Secondary structure has two outputs: 3-state and 8-state
                # We'll use the 3-state output (d3_Yhat)
                outputs = [triton_grpc.InferRequestedOutput("d3_Yhat")]
            elif model_name == "prott5_cons":
                # Conservation has "output" as output name
                outputs = [triton_grpc.InferRequestedOutput("output")]
            else:
                # Default output name
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

            # Post-process predictions
            if model_name == "bind_embed":
                # Apply sigmoid and average the 5 ensemble outputs
                sigmoid_outputs = []
                for i in range(5):
                    logits = response.as_numpy(f"output_{i}")  # Shape: (batch, seq_len, 3)
                    # Apply sigmoid: 1 / (1 + exp(-logits))
                    sigmoid = 1.0 / (1.0 + np.exp(-logits.astype(np.float32)))
                    sigmoid_outputs.append(sigmoid)

                # Average ensemble predictions
                predictions_batch = np.mean(sigmoid_outputs, axis=0)  # Shape: (batch, seq_len, 3)
            elif model_name == "prott5_sec":
                # Get 3-state predictions
                predictions_batch = response.as_numpy("d3_Yhat")
            elif model_name == "prott5_cons":
                # Get conservation predictions
                predictions_batch = response.as_numpy("output")
            else:
                predictions_batch = response.as_numpy("predictions")

            # Unpack batch into list, removing padding
            predictions_list = []
            for i, emb in enumerate(embeddings):
                seq_len = emb.shape[0]
                # Get predictions for this sequence, removing padding
                pred = predictions_batch[i, :seq_len, :]
                predictions_list.append(pred)

            inference_time = asyncio.get_event_loop().time() - start_time
            logger.info(
                f"Triton per-residue prediction completed: {len(embeddings)} sequences "
                f"in {inference_time * 1000:.1f}ms (model: {model_name})"
            )

            return predictions_list

        finally:
            await self._clients.put(client)

    async def predict_sequence_level(
        self, embeddings: List[np.ndarray], model_name: str
    ) -> List[np.ndarray]:
        """Compute sequence-level predictions from embeddings.

        Applies mean pooling to per-residue embeddings before prediction.

        Args:
            embeddings: List of per-residue embeddings, one per sequence
            model_name: Name of the prediction model

        Returns:
            List of sequence-level predictions, one array per sequence
        """
        return await self._circuit_breaker(self._predict_sequence_level_impl)(
            embeddings, model_name
        )

    async def _predict_sequence_level_impl(
        self, embeddings: List[np.ndarray], model_name: str
    ) -> List[np.ndarray]:
        """Direct implementation of predict_sequence_level."""
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
            # Pad embeddings to same length for batching
            max_len = max(emb.shape[0] for emb in embeddings)
            embed_dim = embeddings[0].shape[1]
            batch_size = len(embeddings)

            padded_batch = np.zeros(
                (batch_size, max_len, embed_dim), dtype=np.float32
            )
            masks = np.zeros((batch_size, max_len), dtype=np.float32)

            for i, emb in enumerate(embeddings):
                seq_len = emb.shape[0]
                padded_batch[i, :seq_len, :] = emb
                masks[i, :seq_len] = 1.0  # Mask: 1 for real positions, 0 for padding

            # Prepare input tensors
            # Different models expect different input shapes:
            # - TMbed: (batch, seq_len, embed_dim)
            # - light_attention: (batch, embed_dim, seq_len) - needs transpose
            if "light_attention" in model_name:
                # Transpose to (batch, embed_dim, seq_len) for light_attention
                input_tensor = np.transpose(padded_batch, (0, 2, 1))
            else:
                # Keep (batch, seq_len, embed_dim) for TMbed
                input_tensor = padded_batch

            inputs = [
                triton_grpc.InferInput("input", input_tensor.shape, "FP32"),
                triton_grpc.InferInput("mask", masks.shape, "FP32"),
            ]
            inputs[0].set_data_from_numpy(input_tensor)
            inputs[1].set_data_from_numpy(masks)

            outputs = [triton_grpc.InferRequestedOutput("output")]

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

            # Get predictions
            predictions_batch = response.as_numpy("output")  # Shape varies by model

            # TMbed can return variable shapes - let numpy handle squeezing automatically
            # light_attention returns (batch, num_classes) - correct shape
            if predictions_batch.ndim == 3:
                # Squeeze any singleton dimensions
                predictions_batch = np.squeeze(predictions_batch)
                # If squeeze removed batch dimension, add it back
                if predictions_batch.ndim == 1:
                    predictions_batch = predictions_batch[np.newaxis, :]

            # Unpack batch into list - each should be 1D array
            predictions_list = [predictions_batch[i] for i in range(len(embeddings))]

            inference_time = asyncio.get_event_loop().time() - start_time
            logger.info(
                f"Triton sequence-level prediction completed: {len(embeddings)} sequences "
                f"in {inference_time * 1000:.1f}ms (model: {model_name})"
            )

            return predictions_list

        finally:
            await self._clients.put(client)

    async def predict_seth(
        self, sequences: List[str], model_name: str = "seth"
    ) -> List[np.ndarray]:
        """Predict disorder from sequences using SETH model.

        First computes embeddings, then runs SETH prediction.

        Args:
            sequences: List of protein sequences
            model_name: Name of the SETH model (default: "seth")

        Returns:
            List of per-residue disorder scores, one array per sequence
        """
        return await self._circuit_breaker(self._predict_seth_impl)(
            sequences, model_name
        )

    async def _predict_seth_impl(
        self, sequences: List[str], model_name: str = "seth"
    ) -> List[np.ndarray]:
        """Direct implementation of predict_seth."""
        # First, compute ProtT5 embeddings (per-residue)
        embeddings = await self.compute_embeddings(
            sequences=sequences,
            model_name="prot_t5_pipeline",
            pooled=False,
        )

        # Now run SETH model on embeddings
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
            # Pad embeddings to same length for batching
            max_len = max(emb.shape[0] for emb in embeddings)
            embed_dim = embeddings[0].shape[1]
            batch_size = len(embeddings)

            padded_batch = np.zeros(
                (batch_size, max_len, embed_dim), dtype=np.float32
            )
            for i, emb in enumerate(embeddings):
                padded_batch[i, : emb.shape[0], :] = emb

            # Prepare input tensor (batch, seq_len, embed_dim)
            inputs = [triton_grpc.InferInput("input", padded_batch.shape, "FP32")]
            inputs[0].set_data_from_numpy(padded_batch)

            outputs = [triton_grpc.InferRequestedOutput("output")]

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

            # Get predictions - shape should be (batch, seq_len, 1) or (batch, seq_len)
            predictions_batch = response.as_numpy("output")

            # Squeeze last dimension if needed and unpack batch
            predictions_list = []
            for i, seq in enumerate(sequences):
                seq_len = len(seq)
                # Get predictions for this sequence, removing padding
                pred = predictions_batch[i, :seq_len]
                # Squeeze to 1D if needed
                if pred.ndim > 1:
                    pred = np.squeeze(pred, axis=-1)
                predictions_list.append(pred)

            inference_time = asyncio.get_event_loop().time() - start_time
            logger.info(
                f"Triton SETH prediction completed: {len(sequences)} sequences "
                f"in {inference_time * 1000:.1f}ms (model: {model_name})"
            )

            return predictions_list

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
