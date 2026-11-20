import unittest
import pytest

from biocentral import Biocentral
from biocentral_api import BiocentralAPI

LOCAL = True


def _make_api_bc() -> Biocentral:
    api = BiocentralAPI(fixed_server_url=None, local_only=LOCAL)
    try:
        api.wait_until_healthy(max_wait_seconds=60)
    except Exception as e:
        raise unittest.SkipTest(
            f"Biocentral service not available for integration tests: {e}"
        )
    return Biocentral(mode="api", custom_api=api)


@pytest.fixture(scope="session")
def bc_api():
    """Session-scoped Biocentral client in API mode."""
    return _make_api_bc()


@pytest.fixture(scope="session")
def bc_local():
    """Session-scoped Biocentral client in local mode."""
    return Biocentral(mode="local")
