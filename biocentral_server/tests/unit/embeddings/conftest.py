"""Fixtures for FixedEmbedder unit tests."""

import pytest

from tests.fixtures.fixed_embedder import FixedEmbedder


@pytest.fixture(autouse=True)
def disable_strict_dataset(monkeypatch):
    """Disable strict_dataset validation for unit tests."""
    original_init = FixedEmbedder.__init__

    def patched_init(self, *args, strict_dataset=False, **kwargs):
        return original_init(self, *args, strict_dataset=False, **kwargs)

    monkeypatch.setattr(FixedEmbedder, "__init__", patched_init)
