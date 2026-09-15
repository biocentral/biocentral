import os

from fastapi_limiter.depends import RateLimiter

DEFAULT_TIMES = 60
DEFAULT_SECONDS = 60


def _positive_int(name: str, default: int) -> int:
    raw = os.environ.get(name)
    if raw is None or raw.strip() == "":
        return default
    try:
        value = int(raw)
    except ValueError:
        raise ValueError(f"{name} must be an integer, got {raw!r}") from None
    if value < 1:
        raise ValueError(f"{name} must be >= 1, got {value}")
    return value


def job_rate_limiter() -> RateLimiter:
    """Admission limit for endpoints that queue a compute job.

    Changed through RATE_LIMIT_JOB_TIMES / RATE_LIMIT_JOB_SECONDS which are read at import time.
    """
    return RateLimiter(
        times=_positive_int("RATE_LIMIT_JOB_TIMES", DEFAULT_TIMES),
        seconds=_positive_int("RATE_LIMIT_JOB_SECONDS", DEFAULT_SECONDS),
    )
