"""Shared helpers for Biocentral PyCharm plugin scripts.

All plugin scripts import this module. It provides:

* structured error reporting via a well-known JSON envelope on stdout so the
  Java side can parse both success and failure the same way,
* a minimal argparse-based CLI decorator to keep each script's main() small,
* a lazy import helper that produces a clear error when biocentral is not
  installed in the active interpreter.
"""

from __future__ import annotations

import json
import sys
import traceback
from typing import Any, Callable, Dict


ENVELOPE_MARKER = "__BIOCENTRAL_RESULT__"


def emit(payload: Dict[str, Any]) -> None:
    """Emit a single JSON line on stdout that the Java side can grep for.

    The marker prefix lets the plugin ignore unrelated stdout (e.g. tqdm
    progress bars, warnings) and pick up only the structured result.
    """
    sys.stdout.write(ENVELOPE_MARKER + json.dumps(payload) + "\n")
    sys.stdout.flush()


def emit_error(kind: str, message: str, **extra: Any) -> None:
    payload = {"ok": False, "error": {"kind": kind, "message": message, **extra}}
    emit(payload)


def emit_ok(**payload: Any) -> None:
    emit({"ok": True, **payload})


def require_biocentral():
    """Import biocentral, reporting a friendly error if the package is missing."""
    try:
        import biocentral  # noqa: F401
        return biocentral
    except ImportError as exc:
        emit_error(
            "biocentral_missing",
            "The 'biocentral' package is not installed in this interpreter. "
            "Install it via `pip install biocentral` (or `biocentral[local]`).",
            detail=str(exc),
        )
        sys.exit(2)


def run(main: Callable[[], None]) -> None:
    """Wrap a script main() so any unhandled exception is reported as JSON."""
    try:
        main()
    except SystemExit:
        raise
    except Exception as exc:  # noqa: BLE001 - we want the last resort catch
        emit_error(
            "unhandled_exception",
            f"{type(exc).__name__}: {exc}",
            traceback=traceback.format_exc(),
        )
        sys.exit(1)
