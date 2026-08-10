"""Render one or more BiocentralCharts for a FASTA dataset and save the result
as a single HTML page.

Invoked by the PyCharm plugin. Arguments::

    render_chart.py --fasta PATH [--chart-type TYPE ...] --out HTML_PATH

If no ``--chart-type`` is passed, all charts in :data:`ALL_CHART_TYPES` are
rendered and stacked vertically in the output page.

On success emits::

    __BIOCENTRAL_RESULT__{"ok": true, "html": "/tmp/...", "rendered": ["label", ...], "n": 123}
"""

from __future__ import annotations

import argparse
import html
import io
import os
import sys
from pathlib import Path
from typing import List, Tuple

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _bootstrap import emit_error, emit_ok, require_biocentral, run  # noqa: E402


CHART_RENDERERS = {
    "label": ("Label distribution", "label_distribution"),
    "length": ("Sequence length distribution", "sequence_length_distribution"),
    "split": ("Split (train/val/test) distribution", "split_distribution"),
    "labels_by_split": ("Labels by split", "labels_by_split_distribution"),
}

ALL_CHART_TYPES = ("length", "label", "split")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fasta", required=True)
    parser.add_argument(
        "--chart-type",
        action="append",
        choices=sorted(CHART_RENDERERS),
        help="May be specified multiple times. If omitted, all charts are rendered.",
    )
    parser.add_argument("--out", required=True, help="Path to the combined HTML output")
    return parser.parse_args()


def _render_one(chart_cls, chart_type: str, records) -> Tuple[str, str]:
    """Render a single chart and return (title, embeddable-html)."""
    title, method_name = CHART_RENDERERS[chart_type]
    factory = getattr(chart_cls, method_name)
    chart_obj = factory(records)

    buf = io.StringIO()
    # Altair's Chart.save() supports format="html".
    chart_obj.chart.save(buf, format="html")
    return title, buf.getvalue()


def _combine_html(pieces: List[Tuple[str, str]]) -> str:
    """Wrap the rendered chart HTMLs into a single scrollable page.

    Each Altair-produced HTML is a full document. Embedding several of them
    verbatim inside one page would repeat their <html>/<head>/<script> tags,
    which many browsers still parse but which is ugly. Iframes with
    ``srcdoc`` (an HTML5 attribute supported by every JCEF-backed Chromium
    build) give each chart a clean sandbox while letting them stack in a
    single scroll container.
    """
    sections = []
    for i, (title, chart_html) in enumerate(pieces):
        # Give each iframe an intrinsic height that comfortably contains a
        # single Altair chart; the outer page handles scrolling if needed.
        sections.append(
            "<section class='chart'>"
            f"<h2>{html.escape(title)}</h2>"
            f"<iframe srcdoc='{html.escape(chart_html, quote=True)}' "
            f"loading='lazy' id='chart-{i}'></iframe>"
            "</section>"
        )
    body = "\n".join(sections)
    return (
        "<!doctype html><html><head><meta charset='utf-8'>"
        "<title>Biocentral Charts</title>"
        "<style>"
        "body{margin:0;padding:12px;font-family:-apple-system,BlinkMacSystemFont,"
        "'Segoe UI',Roboto,sans-serif;background:#fafafa;color:#222;}"
        "section.chart{background:#fff;border:1px solid #e2e8f0;border-radius:8px;"
        "padding:12px;margin-bottom:16px;box-shadow:0 1px 3px rgba(0,0,0,.04);}"
        "section.chart h2{margin:0 0 8px 0;font-size:14px;font-weight:600;color:#334155;}"
        "iframe{width:100%;height:420px;border:0;display:block;}"
        "</style></head><body>" + body + "</body></html>"
    )


def _main() -> None:
    args = _parse_args()
    fasta_path = Path(args.fasta)
    if not fasta_path.exists():
        emit_error("fasta_missing", f"FASTA file not found: {fasta_path}")
        sys.exit(2)

    require_biocentral()

    from biocentral import BiocentralChart  # type: ignore
    from biotrainer_core.input_files import read_FASTA  # type: ignore

    records = read_FASTA(fasta_path)
    if not records:
        emit_error("empty_fasta", f"No sequences found in {fasta_path}")
        sys.exit(2)

    chart_types = args.chart_type or list(ALL_CHART_TYPES)

    rendered: List[Tuple[str, str]] = []
    failed: List[dict] = []
    for chart_type in chart_types:
        try:
            rendered.append(_render_one(BiocentralChart, chart_type, records))
        except Exception as exc:  # noqa: BLE001 - one chart failing shouldn't sink the rest
            failed.append({"chart_type": chart_type, "error": f"{type(exc).__name__}: {exc}"})

    if not rendered:
        emit_error("all_charts_failed", "No charts could be rendered.", failed=failed)
        sys.exit(1)

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(_combine_html(rendered), encoding="utf-8")

    emit_ok(
        html=str(out_path),
        rendered=[c for c in chart_types if any(t == CHART_RENDERERS[c][0] for t, _ in rendered)],
        n=len(records),
        failed=failed,
    )


if __name__ == "__main__":
    run(_main)
