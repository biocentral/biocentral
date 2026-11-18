"""
Custom rate limiter for FastAPI endpoints using pyrate-limiter with Redis backend.

Provides a simple per-endpoint interface identical to the old fastapi-limiter:
    @router.get("/endpoint", dependencies=[Depends(RateLimiter(times=2, seconds=60))])

Under the hood, uses pyrate-limiter's RedisBucket for distributed rate limiting.
"""

from typing import Callable, Awaitable

from fastapi import Request, HTTPException, status
from pyrate_limiter import (
    Limiter,
    Rate,
    RedisBucket,
)
from redis.asyncio import Redis

# Global state, set during app startup
_redis: Redis | None = None
_enabled: bool = False
_identifier_func: Callable[[Request], Awaitable[str]] | None = None


async def init_rate_limiter(
    redis: Redis,
    identifier_func: Callable[[Request], Awaitable[str]] | None = None,
    enabled: bool = True,
) -> None:
    """
    Initialize the rate limiter with a Redis connection.

    Args:
        redis: An async Redis connection.
        identifier_func: Async function that extracts a user identifier from a Request.
        enabled: If False, rate limiting is disabled (useful for debug mode).
    """
    global _redis, _enabled, _identifier_func
    _redis = redis
    _enabled = enabled
    _identifier_func = identifier_func


class RateLimiter:
    """
    FastAPI dependency for per-endpoint rate limiting.

    Usage:
        @router.get(
            "/endpoint",
            dependencies=[Depends(RateLimiter(times=2, seconds=60))],
        )
        async def my_endpoint():
            ...

    Args:
        times: Number of allowed requests within the time window.
        seconds: Time window in seconds.
        minutes: Time window in minutes (alternative to seconds).
    """

    def __init__(
        self,
        times: int,
        seconds: int | None = None,
        minutes: int | None = None,
    ):
        if seconds is not None and minutes is not None:
            raise ValueError("Specify only one of 'seconds' or 'minutes', not both.")
        if seconds is not None:
            self._rate = Rate(times, seconds)
            self._expire = seconds
        elif minutes is not None:
            self._rate = Rate(times, minutes * 60)
            self._expire = minutes * 60
        else:
            # Default to seconds=60 if neither is specified
            self._rate = Rate(times, 60)
            self._expire = 60

    async def __call__(self, request: Request) -> None:
        if not _enabled or _redis is None:
            return

        user_id = "anonymous"
        if _identifier_func is not None:
            user_id = await _identifier_func(request)

        endpoint = request.url.path
        key = f"ratelimit:{endpoint}:{user_id}"

        bucket = await RedisBucket.init(
            [self._rate],
            _redis,
            key,
        )
        limiter = Limiter(bucket)

        try:
            acquired = await limiter.try_acquire_async(key, blocking=False)
            if not acquired:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Rate limit exceeded. Please try again later.",
                    headers={"Retry-After": str(self._expire)},
                )
        finally:
            limiter.close()
