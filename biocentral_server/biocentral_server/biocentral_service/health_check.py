"""Deep health check module for verifying all backend service connectivity."""

import os
import time

import torch
import psycopg
from redis.asyncio import Redis

from .utils import get_logger
from .server_management.file_management import FileManager
from .server_management.triton_client import TritonClientConfig

logger = get_logger(__name__)


class HealthCheckResult:
    """Represents the health status of a single service component."""

    def __init__(
        self, name: str, healthy: bool, message: str = "", details: dict = None
    ):
        self.name = name
        self.healthy = healthy
        self.message = message
        self.details = details or {}

    def to_dict(self) -> dict:
        result = {
            "name": self.name,
            "healthy": self.healthy,
        }
        if self.message:
            result["message"] = self.message
        if self.details:
            result["details"] = self.details
        return result


async def check_redis() -> HealthCheckResult:
    """Check if Redis (jobs queue) is reachable."""
    redis_host = os.environ.get("REDIS_JOBS_HOST", "redis-jobs")
    redis_port = int(os.environ.get("REDIS_JOBS_PORT", "6379"))

    redis_conn = Redis(host=redis_host, port=redis_port, db=0)
    try:
        start = time.monotonic()
        pong = await redis_conn.ping()
        elapsed_ms = round((time.monotonic() - start) * 1000, 2)
        await redis_conn.aclose()

        if pong:
            return HealthCheckResult(
                name="redis",
                healthy=True,
                message="Connected",
                details={
                    "host": redis_host,
                    "port": redis_port,
                    "latency_ms": elapsed_ms,
                },
            )
        else:
            return HealthCheckResult(
                name="redis",
                healthy=False,
                message="Ping returned False",
                details={"host": redis_host, "port": redis_port},
            )
    except Exception as e:
        return HealthCheckResult(
            name="redis",
            healthy=False,
            message=f"Connection failed: {e}",
            details={"host": redis_host, "port": redis_port},
        )


def check_postgres() -> HealthCheckResult:
    """Check if PostgreSQL (embeddings database) is reachable."""
    postgres_config = {
        "host": os.getenv("POSTGRES_HOST"),
        "port": os.getenv("POSTGRES_PORT"),
        "dbname": os.getenv("POSTGRES_DB"),
        "user": os.getenv("POSTGRES_USER"),
        "password": os.getenv("POSTGRES_PASSWORD"),
    }

    # If no Postgres config is set, skip the check
    if not all(postgres_config.values()):
        return HealthCheckResult(
            name="postgres",
            healthy=True,
            message="Not configured (skipped)",
            details={"configured": False},
        )

    try:
        start = time.monotonic()
        with psycopg.connect(**postgres_config) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        elapsed_ms = round((time.monotonic() - start) * 1000, 2)

        return HealthCheckResult(
            name="postgres",
            healthy=True,
            message="Connected",
            details={
                "host": postgres_config["host"],
                "port": postgres_config["port"],
                "dbname": postgres_config["dbname"],
                "latency_ms": elapsed_ms,
            },
        )
    except Exception as e:
        return HealthCheckResult(
            name="postgres",
            healthy=False,
            message=f"Connection failed: {e}",
            details={
                "host": postgres_config["host"],
                "port": postgres_config["port"],
            },
        )


def check_triton() -> HealthCheckResult:
    """Check if Triton Inference Server is healthy."""
    use_triton = os.getenv("USE_TRITON", "true").lower() in ("true", "1", "yes")

    if not use_triton:
        return HealthCheckResult(
            name="triton",
            healthy=True,
            message="Disabled (skipped)",
            details={"enabled": False},
        )

    try:
        config = TritonClientConfig()
        healthy = config.is_healthy()
        grpc_url = config.get_grpc_url_without_protocol()
        http_url = config.triton_http_url

        if healthy:
            return HealthCheckResult(
                name="triton",
                healthy=True,
                message="Ready",
                details={"grpc_url": grpc_url, "http_url": http_url},
            )
        else:
            return HealthCheckResult(
                name="triton",
                healthy=False,
                message="Not ready",
                details={"grpc_url": grpc_url, "http_url": http_url},
            )
    except Exception as e:
        return HealthCheckResult(
            name="triton",
            healthy=False,
            message=f"Check failed: {e}",
            details={},
        )


def check_file_storage() -> HealthCheckResult:
    """Check if file storage backend is operational."""
    try:
        file_manager = FileManager("health_check")
        healthy = file_manager.verify_storage_backend()

        if healthy:
            return HealthCheckResult(
                name="file_storage",
                healthy=True,
                message="Read/write verified",
            )
        else:
            return HealthCheckResult(
                name="file_storage",
                healthy=False,
                message="Verification failed",
            )
    except Exception as e:
        return HealthCheckResult(
            name="file_storage",
            healthy=False,
            message=f"Check failed: {e}",
        )


def check_gpu() -> HealthCheckResult:
    """Check GPU/CUDA availability."""
    cuda_available = torch.cuda.is_available()
    details = {"cuda_available": cuda_available}

    if cuda_available:
        device_count = torch.cuda.device_count()
        device_names = [torch.cuda.get_device_name(i) for i in range(device_count)]
        details["device_count"] = device_count
        details["device_names"] = device_names

        return HealthCheckResult(
            name="gpu",
            healthy=True,
            message=f"{device_count} GPU(s) available",
            details=details,
        )
    else:
        return HealthCheckResult(
            name="gpu",
            healthy=True,
            message="No GPU available (CPU-only mode)",
            details=details,
        )


async def run_deep_health_check() -> dict:
    """
    Run all deep health checks and return aggregated results.

    Returns a dict with overall status, version, and per-service health details.
    """
    # Run all checks concurrently where possible
    redis_result = await check_redis()

    # Synchronous checks run in the threadpool implicitly via FastAPI
    postgres_result = check_postgres()
    triton_result = check_triton()
    file_storage_result = check_file_storage()
    gpu_result = check_gpu()

    all_results = [
        redis_result,
        postgres_result,
        triton_result,
        file_storage_result,
        gpu_result,
    ]

    all_healthy = all(r.healthy for r in all_results)

    return {
        "status": "healthy" if all_healthy else "degraded",
        "services": [r.to_dict() for r in all_results],
    }
