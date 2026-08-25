"""Report which Biocentral packages are available in the current interpreter.

Used by the plugin to decide whether to prompt the user to install biocentral
before enabling actions. Emits a JSON envelope on stdout.
"""

from __future__ import annotations

import importlib.metadata as im
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _bootstrap import emit_ok, run  # noqa: E402


PROBED = (
    "biocentral",
    "biocentral_api",
    "biocentral_vis",
    "biotrainer",
    "biotrainer_core",
)


def _main() -> None:
    versions = {}
    for pkg in PROBED:
        try:
            versions[pkg] = im.version(pkg)
        except im.PackageNotFoundError:
            versions[pkg] = None
    emit_ok(python=sys.version.split()[0], packages=versions)


if __name__ == "__main__":
    run(_main)
