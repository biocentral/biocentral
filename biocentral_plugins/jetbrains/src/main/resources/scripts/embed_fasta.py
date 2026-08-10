"""Compute embeddings for a FASTA file via ``Biocentral().embed()``.

Invoked by the PyCharm plugin. Arguments::

    embed_fasta.py
        --fasta PATH
        --embedder NAME
        --mode {api,local}
        [--api-url URL]
        [--device cpu|cuda|...]
        [--no-reduce]
        [--half-precision]
        --out JSON_PATH

The full embeddings can be very large. We therefore write the raw payload
to ``--out`` (as a JSON file with plain lists) and only report a compact
summary through the stdout envelope.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _bootstrap import emit_error, emit_ok, require_biocentral, run  # noqa: E402


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fasta", required=True)
    parser.add_argument("--embedder", required=True)
    parser.add_argument("--mode", required=True, choices=("api", "local"))
    parser.add_argument("--api-url", default=None)
    parser.add_argument("--device", default=None)
    parser.add_argument("--no-reduce", action="store_true")
    parser.add_argument("--half-precision", action="store_true")
    parser.add_argument("--out", required=True)
    return parser.parse_args()


def _to_plain_list(value):
    """Convert torch tensors / numpy arrays / lists to plain Python lists."""
    if value is None:
        return None
    if hasattr(value, "detach") and hasattr(value, "cpu"):
        return value.detach().cpu().numpy().tolist()
    if hasattr(value, "tolist"):
        return value.tolist()
    return list(value)


def _shape_of(embedding) -> list:
    if embedding is None:
        return []
    if hasattr(embedding, "shape"):
        return list(embedding.shape)
    if isinstance(embedding, list):
        shape = []
        cur = embedding
        while isinstance(cur, list):
            shape.append(len(cur))
            cur = cur[0] if cur else None
        return shape
    return []


def _build_biocentral(args) -> "Biocentral":  # noqa: F821 - stringified type
    """Instantiate Biocentral honoring the requested mode.

    The BiocentralAPI constructor takes ``fixed_server_url`` (not ``host``).
    We only pass it when the user supplied a custom URL so the default
    server-discovery flow (local first, then hosted) still kicks in otherwise.
    """
    from biocentral import Biocentral  # type: ignore
    from biocentral_api import BiocentralAPI  # type: ignore

    if args.mode == "api":
        if args.api_url:
            custom_api = BiocentralAPI(
                fixed_server_url=args.api_url,
                local_only=_is_local_url(args.api_url),
            )
        else:
            custom_api = None
        return Biocentral(mode="api", custom_api=custom_api)
    return Biocentral(mode="local", device=args.device or None)


def _is_local_url(url: str) -> bool:
    return "localhost" in url or "127.0.0.1" in url


def _extract_entries(result) -> list:
    """Normalize the various EmbeddingsResult surfaces to a plain list of dicts."""
    # Preferred: EmbeddingsResult.to_dict() -> {seq_id: np.ndarray}
    if hasattr(result, "to_dict"):
        try:
            seq2emb = result.to_dict()
            return [
                {
                    "seq_id": seq_id,
                    "shape": _shape_of(embedding),
                    "embedding": _to_plain_list(embedding),
                }
                for seq_id, embedding in seq2emb.items()
            ]
        except Exception:  # noqa: BLE001 - fall through to other shapes
            pass

    # Fall back: attribute-based access (older API surface).
    embeddings_map = getattr(result, "embeddings", None) or getattr(result, "sequences", None)
    entries = []
    if isinstance(embeddings_map, dict):
        for seq_id, payload in embeddings_map.items():
            embedding = getattr(payload, "embedding", payload)
            entries.append({
                "seq_id": seq_id,
                "shape": _shape_of(embedding),
                "embedding": _to_plain_list(embedding),
            })
    elif embeddings_map is not None:
        for i, item in enumerate(embeddings_map):
            embedding = getattr(item, "embedding", item)
            entries.append({
                "seq_id": getattr(item, "seq_id", str(i)),
                "shape": _shape_of(embedding),
                "embedding": _to_plain_list(embedding),
            })
    return entries


def _main() -> None:
    args = _parse_args()

    fasta_path = Path(args.fasta)
    if not fasta_path.exists():
        emit_error("fasta_missing", f"FASTA file not found: {fasta_path}")
        sys.exit(2)

    require_biocentral()

    bc = _build_biocentral(args)
    result = bc.embed(
        embedder_name=args.embedder,
        sequence_data=str(fasta_path),
        reduce=not args.no_reduce,
        use_half_precision=args.half_precision,
    )

    entries = _extract_entries(result)

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(
            {
                "embedder": args.embedder,
                "mode": args.mode,
                "reduce": not args.no_reduce,
                "half_precision": args.half_precision,
                "entries": entries,
            }
        )
    )

    emit_ok(
        json=str(out_path),
        embedder=args.embedder,
        mode=args.mode,
        count=len(entries),
        first_shape=entries[0]["shape"] if entries else [],
    )


if __name__ == "__main__":
    run(_main)
