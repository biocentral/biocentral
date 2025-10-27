"""Triton inference mixin for remote model execution via Triton Inference Server."""

import asyncio
from typing import Dict, List, Any
import numpy as np

try:
    import tritonclient.grpc.aio as triton_grpc
    TRITON_AVAILABLE = True
except ImportError:
    TRITON_AVAILABLE = False
    triton_grpc = None

from biocentral_server.server_management import (
    TritonClientConfig,
    get_shared_repository,
)
from biocentral_server.utils import get_logger

logger = get_logger(__name__)


class TritonInferenceMixin:
    """Mixin providing Triton-based inference capabilities.

    This mixin provides methods for running inference via Triton Inference Server.
    It should be used with BaseModel through multiple inheritance.

    Expected class attributes (defined in concrete model):
        - TRITON_MODEL_NAME: str - Name of model in Triton repository
        - TRITON_INPUT_NAMES: List[str] - Names of input tensors
        - TRITON_OUTPUT_NAMES: List[str] - Names of output tensors
        - TRITON_INPUT_TRANSFORMER: Optional[callable] - Function to transform inputs
        - TRITON_OUTPUT_TRANSFORMER: Optional[callable] - Function to transform outputs
    """

    def _init_triton_backend(self):
        """Initialize Triton backend connection."""
        if not TRITON_AVAILABLE:
            raise ImportError(
                "Triton client dependencies not available. "
                "Install with: pip install tritonclient[grpc]"
            )

        # Validate required attributes
        if not hasattr(self, 'TRITON_MODEL_NAME'):
            raise AttributeError(
                f"{self.__class__.__name__} must define TRITON_MODEL_NAME class attribute"
            )
        if not hasattr(self, 'TRITON_INPUT_NAMES'):
            raise AttributeError(
                f"{self.__class__.__name__} must define TRITON_INPUT_NAMES class attribute"
            )
        if not hasattr(self, 'TRITON_OUTPUT_NAMES'):
            raise AttributeError(
                f"{self.__class__.__name__} must define TRITON_OUTPUT_NAMES class attribute"
            )

        # Initialize Triton connection
        self.triton_config = TritonClientConfig.from_env()
        # Get the shared repository once during initialization
        self.triton_repo = get_shared_repository(self.triton_config)

    async def _connect_triton(self):
        """Establish connection to Triton server."""
        # No-op - repository is already initialized and connected
        pass

    async def _disconnect_triton(self):
        """Disconnect from Triton server."""
        # No-op - repository lifecycle managed by RepositoryManager
        pass

    def _prepare_triton_inputs(
        self,
        batch: Dict[str, np.ndarray]
    ) -> List[triton_grpc.InferInput]:
        """Prepare inputs for Triton inference.

        Args:
            batch: Dictionary of input tensors (can be torch.Tensor or np.ndarray)

        Returns:
            List of Triton InferInput objects
        """
        # Apply model-specific input transformation if defined
        if hasattr(self, 'TRITON_INPUT_TRANSFORMER') and self.TRITON_INPUT_TRANSFORMER:
            batch = self.TRITON_INPUT_TRANSFORMER(self, batch)

        # Create Triton input objects
        inputs = []
        for input_name in self.TRITON_INPUT_NAMES:
            if input_name not in batch:
                raise ValueError(
                    f"Input '{input_name}' not found in batch. Available: {list(batch.keys())}"
                )

            tensor = batch[input_name]

            # Convert torch.Tensor to numpy if needed
            if hasattr(tensor, 'numpy'):
                tensor = tensor.cpu().numpy()

            # Ensure tensor is numpy array
            if not isinstance(tensor, np.ndarray):
                tensor = np.array(tensor)

            # Determine datatype
            if tensor.dtype == np.float32:
                dtype = "FP32"
            elif tensor.dtype == np.float16:
                dtype = "FP16"
            elif tensor.dtype == np.int32:
                dtype = "INT32"
            elif tensor.dtype == np.int64:
                dtype = "INT64"
            else:
                # Default to FP32
                tensor = tensor.astype(np.float32)
                dtype = "FP32"

            triton_input = triton_grpc.InferInput(input_name, tensor.shape, dtype)
            triton_input.set_data_from_numpy(tensor)
            inputs.append(triton_input)

        return inputs

    def _prepare_triton_outputs(self) -> List[triton_grpc.InferRequestedOutput]:
        """Prepare output requests for Triton inference.

        Returns:
            List of Triton InferRequestedOutput objects
        """
        return [
            triton_grpc.InferRequestedOutput(name)
            for name in self.TRITON_OUTPUT_NAMES
        ]

    def _process_triton_outputs(self, response: Any) -> Any:
        """Process Triton inference response.

        Args:
            response: Triton inference response

        Returns:
            Processed model outputs (format depends on model)
        """
        # Extract outputs
        if len(self.TRITON_OUTPUT_NAMES) == 1:
            # Single output - return as-is
            output = response.as_numpy(self.TRITON_OUTPUT_NAMES[0])
        else:
            # Multiple outputs - return as list
            output = [response.as_numpy(name) for name in self.TRITON_OUTPUT_NAMES]

        # Apply model-specific output transformation if defined
        if hasattr(self, 'TRITON_OUTPUT_TRANSFORMER') and self.TRITON_OUTPUT_TRANSFORMER:
            output = self.TRITON_OUTPUT_TRANSFORMER(self, output)

        return output

    async def _run_triton_inference_async(self, batch: Dict[str, Any]) -> Any:
        """Run async Triton inference on a batch.

        Args:
            batch: Dictionary containing input tensors

        Returns:
            Raw model output
        """
        await self._connect_triton()

        try:
            # Get client from pool
            client = await asyncio.wait_for(
                self.triton_repo._clients.get(),
                timeout=self.triton_config.triton_pool_acquisition_timeout,
            )

            try:
                # Prepare inputs and outputs
                inputs = self._prepare_triton_inputs(batch)
                outputs = self._prepare_triton_outputs()

                # Make inference request
                response = await asyncio.wait_for(
                    client.infer(
                        model_name=self.TRITON_MODEL_NAME,
                        inputs=inputs,
                        outputs=outputs,
                        timeout=int(self.triton_config.triton_timeout),
                    ),
                    timeout=self.triton_config.triton_timeout,
                )

                # Process outputs
                return self._process_triton_outputs(response)

            finally:
                # Return client to pool
                await self.triton_repo._clients.put(client)

        except Exception as e:
            # Re-raise any exceptions that occur during inference
            raise e

    def _run_triton_inference(self, batch: Dict[str, Any]) -> Any:
        """Run Triton inference on a batch (synchronous wrapper).

        Args:
            batch: Dictionary containing input tensors

        Returns:
            Raw model output
        """
        # Run async inference in event loop
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(self._run_triton_inference_async(batch))
        finally:
            loop.close()
