import unittest

import pytest

from biocentral_api import BiocentralAPI

LOCAL = True


def _make_api() -> BiocentralAPI:
    """Create API client for local (dev) or production based on LOCAL flag."""
    return BiocentralAPI(fixed_server_url=None, local_only=LOCAL)


def _wait_or_skip(api: BiocentralAPI, timeout: int = 60) -> BiocentralAPI:
    try:
        return api.wait_until_healthy(max_wait_seconds=timeout)
    except Exception as e:
        raise unittest.SkipTest(f"Biocentral service not available for integration tests: {e}")


@pytest.fixture(scope="session")
def api():
    """Session-scoped healthy API client shared across all integration tests."""
    return _wait_or_skip(_make_api())
