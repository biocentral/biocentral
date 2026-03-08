import csv
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

import numpy as np


def _stable_sort_key(row: Dict[str, Any]) -> tuple:
    # Use masking_ratio for numerical sorting if present, otherwise fall back to parameter string
    masking_ratio = row.get("masking_ratio")
    seq_idx = (
        row.get("parameter", "").split("_")[0]
        if "mask" in row.get("parameter", "")
        else ""
    )
    return (
        str(row.get("embedder", "")),
        str(row.get("model", "")),
        str(row.get("method", "")),
        str(row.get("test_type", "")),
        seq_idx,
        masking_ratio if masking_ratio is not None else float("inf"),
        str(row.get("parameter", "")),
    )


def _format_float(value: Any, precision: int = 8) -> str:
    try:
        return f"{float(value):.{precision}f}"
    except (TypeError, ValueError):
        return ""


def compute_cosine_distance(a: np.ndarray, b: np.ndarray) -> float:
    a_flat = _ensure_1d(a)
    b_flat = _ensure_1d(b)

    norm_a = np.linalg.norm(a_flat)
    norm_b = np.linalg.norm(b_flat)

    if norm_a == 0 or norm_b == 0:
        return 1.0

    cosine_similarity = np.dot(a_flat, b_flat) / (norm_a * norm_b)

    cosine_similarity = np.clip(cosine_similarity, -1.0, 1.0)
    return float(1.0 - cosine_similarity)


def compute_l2_distance(a: np.ndarray, b: np.ndarray) -> float:
    a_flat = _ensure_1d(a)
    b_flat = _ensure_1d(b)

    return float(np.linalg.norm(a_flat - b_flat))


def compute_all_metrics(a: np.ndarray, b: np.ndarray) -> Dict[str, float]:
    return {
        "cosine_distance": compute_cosine_distance(a, b),
        "l2_distance": compute_l2_distance(a, b),
    }


def _ensure_1d(arr: np.ndarray) -> np.ndarray:
    if arr.ndim == 1:
        return arr
    elif arr.ndim == 2:
        return arr.mean(axis=0)
    else:
        raise ValueError(f"Expected 1D or 2D array, got {arr.ndim}D")


def format_metrics_table(
    results: List[Dict[str, Any]],
    title: Optional[str] = None,
) -> str:
    if not results:
        return "No results to display."

    headers = [
        "Embedder",
        "Test Type",
        "Parameter",
        "Cosine",
        "L2",
        "Threshold",
        "Passed",
    ]
    col_widths = [15, 20, 12, 10, 10, 10, 8]

    lines = []

    if title:
        lines.append(f"\n{'=' * 97}")
        lines.append(f"  {title}")
        lines.append(f"{'=' * 97}")

    header_row = " | ".join(h.ljust(w) for h, w in zip(headers, col_widths))
    lines.append(header_row)
    lines.append("-" * len(header_row))

    for row in sorted(results, key=_stable_sort_key):
        values = [
            str(row.get("embedder", ""))[:15],
            str(row.get("test_type", ""))[:20],
            str(row.get("parameter", ""))[:12],
            f"{row.get('cosine_distance', 0):.6f}",
            f"{row.get('l2_distance', 0):.4f}",
            f"{row.get('threshold', 0):.4f}",
            "✓" if row.get("passed", False) else "✗",
        ]
        data_row = " | ".join(v.ljust(w) for v, w in zip(values, col_widths))
        lines.append(data_row)

    lines.append("")
    return "\n".join(lines)


def write_metrics_csv(
    results: List[Dict[str, Any]],
    path: Union[str, Path],
) -> None:
    path = Path(path)

    path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        "timestamp",
        "embedder",
        "test_type",
        "parameter",
        "cosine_distance",
        "l2_distance",
        "threshold",
        "passed",
    ]

    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()

        for row in sorted(results, key=_stable_sort_key):
            csv_row = {
                "timestamp": row.get("timestamp", ""),
                "embedder": row.get("embedder", ""),
                "test_type": row.get("test_type", ""),
                "parameter": row.get("parameter", ""),
                "cosine_distance": _format_float(row.get("cosine_distance", 0.0)),
                "l2_distance": _format_float(row.get("l2_distance", 0.0)),
                "threshold": _format_float(row.get("threshold", 0.0)),
                "passed": row.get("passed", False),
            }
            writer.writerow(csv_row)


def get_default_report_path() -> Path:
    return Path(__file__).parent.parent.parent / "reports" / "oracle_metrics.csv"
