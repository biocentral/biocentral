"""Configuration for Triton Inference Server client."""

import os
import struct
from typing import Optional

# Calculate INT32_MAX for gRPC message size limits (matches official Triton client)
INT32_MAX = 2 ** (struct.Struct("i").size * 8 - 1) - 1


class TritonClientConfig:
    """Configuration for Triton client connection and behavior."""

    def __init__(
        self,
        triton_grpc_url: Optional[str] = None,
        triton_http_url: Optional[str] = None,
        triton_pool_size: int = 4,
        triton_timeout: int = 30,
        triton_connection_timeout: int = 10,
        triton_pool_acquisition_timeout: int = 5,
        triton_circuit_breaker_failure_threshold: int = 5,
        triton_circuit_breaker_timeout: int = 60,
        triton_max_batch_size: int = 32,
        triton_max_message_size: int = INT32_MAX,  # ~2GB (matches official Triton client)
        triton_grpc_keepalive_time_ms: int = INT32_MAX,
        triton_grpc_keepalive_timeout_ms: int = 20000,  # 20 seconds
        triton_http2_max_pings_without_data: int = 2,
        use_triton: bool = True,
    ):
        """Initialize Triton client configuration.

        Args:
            triton_grpc_url: Triton gRPC endpoint URL (default: http://localhost:8001)
            triton_http_url: Triton HTTP endpoint URL (default: http://localhost:8000)
            triton_pool_size: Number of connections in the pool (default: 4)
            triton_timeout: Request timeout in seconds (default: 30)
            triton_connection_timeout: Connection timeout in seconds (default: 10)
            triton_pool_acquisition_timeout: Max time to wait for client from pool (default: 5)
            triton_circuit_breaker_failure_threshold: Failures before opening circuit (default: 5)
            triton_circuit_breaker_timeout: Seconds before retrying after circuit opens (default: 60)
            triton_max_batch_size: Maximum sequences per request (default: 32)
            triton_max_message_size: Max gRPC message size in bytes (default: INT32_MAX ~2GB)
            triton_grpc_keepalive_time_ms: gRPC keepalive time in ms (default: INT32_MAX)
            triton_grpc_keepalive_timeout_ms: gRPC keepalive timeout in ms (default: 20000)
            triton_http2_max_pings_without_data: HTTP/2 max pings without data (default: 2)
            use_triton: Whether to use Triton for inference (default: True)
        """
        self.triton_grpc_url = triton_grpc_url or os.getenv(
            "TRITON_GRPC_URL", "http://localhost:8001"
        )
        self.triton_http_url = triton_http_url or os.getenv(
            "TRITON_HTTP_URL", "http://localhost:8000"
        )
        self.triton_pool_size = int(
            os.getenv("TRITON_POOL_SIZE", str(triton_pool_size))
        )
        self.triton_timeout = int(os.getenv("TRITON_TIMEOUT", str(triton_timeout)))
        self.triton_connection_timeout = int(
            os.getenv("TRITON_CONNECTION_TIMEOUT", str(triton_connection_timeout))
        )
        self.triton_pool_acquisition_timeout = int(
            os.getenv(
                "TRITON_POOL_ACQUISITION_TIMEOUT", str(triton_pool_acquisition_timeout)
            )
        )
        self.triton_circuit_breaker_failure_threshold = int(
            os.getenv(
                "TRITON_CIRCUIT_BREAKER_THRESHOLD",
                str(triton_circuit_breaker_failure_threshold),
            )
        )
        self.triton_circuit_breaker_timeout = int(
            os.getenv("TRITON_CIRCUIT_BREAKER_TIMEOUT", str(triton_circuit_breaker_timeout))
        )
        self.triton_max_batch_size = int(
            os.getenv("TRITON_MAX_BATCH_SIZE", str(triton_max_batch_size))
        )
        self.triton_max_message_size = int(
            os.getenv("TRITON_MAX_MESSAGE_SIZE", str(triton_max_message_size))
        )
        self.triton_grpc_keepalive_time_ms = int(
            os.getenv(
                "TRITON_GRPC_KEEPALIVE_TIME_MS", str(triton_grpc_keepalive_time_ms)
            )
        )
        self.triton_grpc_keepalive_timeout_ms = int(
            os.getenv(
                "TRITON_GRPC_KEEPALIVE_TIMEOUT_MS",
                str(triton_grpc_keepalive_timeout_ms),
            )
        )
        self.triton_http2_max_pings_without_data = int(
            os.getenv(
                "TRITON_HTTP2_MAX_PINGS_WITHOUT_DATA",
                str(triton_http2_max_pings_without_data),
            )
        )
        self.use_triton = os.getenv("USE_TRITON", str(use_triton)).lower() in (
            "true",
            "1",
            "yes",
        )

    def is_enabled(self) -> bool:
        """Check if Triton integration is enabled."""
        return self.use_triton

    @classmethod
    def from_env(cls) -> "TritonClientConfig":
        """Create configuration from environment variables."""
        return cls()

    def get_grpc_url_without_protocol(self) -> str:
        """Get gRPC URL without http:// or https:// prefix."""
        url = self.triton_grpc_url
        if url.startswith("http://"):
            return url[7:]
        elif url.startswith("https://"):
            return url[8:]
        return url

    def __repr__(self) -> str:
        return (
            f"TritonClientConfig(grpc_url={self.triton_grpc_url}, "
            f"pool_size={self.triton_pool_size}, "
            f"enabled={self.use_triton})"
        )
