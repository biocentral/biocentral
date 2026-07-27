"""Shared pytest configuration for biocentral_server tests."""

import os

if os.environ.get("CI") or not os.environ.get("DISPLAY"):
    import matplotlib

    matplotlib.use("Agg")



def pytest_collection_modifyitems(session, config, items):
    # Ensure embed tests run before projection tests.
    def get_test_priority(item):
        test_file = item.fspath.basename if hasattr(item, "fspath") else ""

        if "test_embed" in test_file:
            return 0
        elif "test_project" in test_file:
            return 1
        else:
            return 2

    items.sort(
        key=lambda item: (
            get_test_priority(item),
            items.index(item) if item in items else 0,
        )
    )
