"""Shared fixtures for endpoint unit tests."""

import asyncio

import pytest
from unittest.mock import AsyncMock, MagicMock
from fastapi.testclient import TestClient


@pytest.fixture(autouse=True, scope="function")
def mock_fastapi_limiter():
    # Initialize FastAPILimiter with a mock Redis for all endpoint unit tests.
    from fastapi_limiter import FastAPILimiter

    mock_redis = MagicMock()
    mock_redis.evalsha = AsyncMock(return_value=0)
    mock_redis.script_load = AsyncMock(return_value="fake_sha")
    mock_redis.get = AsyncMock(return_value=None)
    mock_redis.set = AsyncMock(return_value=True)
    mock_redis.close = AsyncMock()

    async def init_limiter():
        await FastAPILimiter.init(redis=mock_redis)

    async def close_limiter():
        await FastAPILimiter.close()

    loop = asyncio.new_event_loop()
    loop.run_until_complete(init_limiter())

    yield

    loop.run_until_complete(close_limiter())
    loop.close()


@pytest.fixture
def mock_task_manager():
    """Mock TaskManager for endpoint tests."""
    manager = MagicMock()
    manager.add_task.return_value = "test-task-id-123"
    manager.get_unique_task_id.return_value = "unique-task-id-456"
    return manager


@pytest.fixture
def mock_user_manager():
    """Mock UserManager for endpoint tests."""
    manager = MagicMock()
    manager.get_user_id_from_request = AsyncMock(return_value="test-user-id")
    return manager


@pytest.fixture
def mock_file_manager():
    """Mock FileManager for endpoint tests."""
    manager = MagicMock()
    manager.get_biotrainer_model_path.return_value = "/mock/model/path"
    manager.get_biotrainer_result_files.return_value = {
        "out_config": "config_content",
        "logging_out": "log_content",
        "out_file": "file_content",
    }
    return manager


@pytest.fixture
def mock_embeddings_database():
    """Mock EmbeddingsDatabase for endpoint tests."""
    db = MagicMock()
    db.get_missing_embeddings.return_value = ["seq1", "seq2"]
    db.add_embeddings.return_value = None
    return db


@pytest.fixture
def mock_rate_limiter():
    """Disable rate limiting for tests."""

    async def no_rate_limit():
        pass

    return no_rate_limit


@pytest.fixture
def base_endpoint_mocks(mock_task_manager, mock_user_manager, mock_rate_limiter):
    """Bundle common endpoint mocks for reuse."""
    return {
        "task_manager": mock_task_manager,
        "user_manager": mock_user_manager,
        "rate_limiter": mock_rate_limiter,
    }


def create_test_client_with_mocks(app, mocks: dict):
    """Helper to create a test client with applied mocks."""
    return TestClient(app)
