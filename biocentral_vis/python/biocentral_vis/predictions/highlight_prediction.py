from typing import Dict, List, Tuple, Any, Optional
from biocentral_api import Prediction

_COLOR_SCHEMES = {
    'secondary_structure': {
        'H': '#FF6B6B',  # Helix - red
        'E': '#4ECDC4',  # Sheet - cyan
        'C': '#95E1D3',  # Coil - light green
        'L': '#95E1D3',  # Loop - light green
    },
    'disorder': {
        'D': '#FF6B6B',  # Disordered - red
        'O': '#4ECDC4',  # Ordered - cyan
    },
    # TODO: More schemes
}


def _auto_detect_color_scheme(prediction_name: str, prediction: str) -> Dict[str, str]:
    """Auto-detect color scheme based on prediction label"""
    prediction_name = prediction_name.lower()

    if 'secondary' in prediction_name or 'structure' in prediction_name:
        return _COLOR_SCHEMES['secondary_structure']
    elif 'disorder' in prediction_name:
        return _COLOR_SCHEMES['disorder']
    else:
        # Generate default colors for unique values
        unique_values = set(prediction)
        colors = ['#FF6B6B', '#4ECDC4', '#95E1D3', '#F7DC6F', '#BB8FCE', '#85C1E2']
        return {val: colors[i % len(colors)] for i, val in enumerate(sorted(unique_values))}


def _process_prediction(sequence: str, pred_value) -> str:
    """Convert prediction value to string of same length as sequence"""
    try:
        pred_str = "".join(pred_value) if isinstance(pred_value, (list, tuple)) else str(pred_value)
        if len(pred_str) != len(sequence):
            raise ValueError(
                f"Prediction length ({len(pred_str)}) doesn't match "
                f"sequence length ({len(sequence)})"
            )
        return pred_str
    except Exception as e:
        raise ValueError(f"Can only highlight per-residue predictions: {e}")


def _split_into_lines(sequence: str, pred_value: str, residues_per_line: int) -> List[Tuple[str, str]]:
    """Split sequence and prediction into lines"""
    lines = []
    for i in range(0, len(sequence), residues_per_line):
        seq_chunk = sequence[i:i + residues_per_line]
        pred_chunk = pred_value[i:i + residues_per_line]
        lines.append((seq_chunk, pred_chunk))
    return lines


def _get_prediction_distribution(pred_value: str) -> Dict[str, int]:
    """Count occurrences of each prediction value"""
    distribution = {}
    for pred in pred_value:
        distribution[pred] = distribution.get(pred, 0) + 1
    return distribution


def highlight_prediction(sequence: str, prediction: Prediction, title: Optional[str] = None, residues_per_line: int = 100) -> Tuple[
    str, Dict[str, Any]]:
    pred_value = prediction.value
    pred_value = _process_prediction(sequence, pred_value)

    title = title or f"Sequence Highlight: {prediction.prediction_name}"
    color_scheme = _auto_detect_color_scheme(prediction.prediction_name, pred_value)

    char_width = 12
    char_height = 20
    line_spacing = 30
    margin = 40
    legend_height = 60

    lines = _split_into_lines(sequence, pred_value, residues_per_line)

    # Calculate dimensions
    width = margin * 2 + residues_per_line * char_width
    height = margin * 2 + len(lines) * line_spacing * 2 + legend_height

    # Build SVG
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}">',
        f'  <style>',
        f'    .residue {{ font-family: monospace; font-size: 14px; }}',
        f'    .title {{ font-family: sans-serif; font-size: 16px; font-weight: bold; }}',
        f'    .legend {{ font-family: sans-serif; font-size: 12px; }}',
        f'  </style>',
        f'  <rect width="100%" height="100%" fill="white"/>',
        f'  <text x="{width / 2}" y="25" class="title" text-anchor="middle">{title}</text>',
    ]

    # Draw sequences
    y_offset = margin + 20
    for l_idx, (line_seq, line_pred) in enumerate(lines):
        x_offset = margin
        line_start_idx = l_idx * residues_per_line
        for i, (res, pred) in enumerate(zip(line_seq, line_pred)):
            color = color_scheme.get(pred, '#EEEEEE')
            x = x_offset + i * char_width
            absolute_idx = line_start_idx + i + 1

            # Background rectangle
            svg_parts.append(
                f'  <rect x="{x}" y="{y_offset - 14}" width="{char_width}" height="{char_height}" '
                f'fill="{color}" opacity="0.7" data-residue="{res}" data-prediction="{pred}" data-index="{absolute_idx}" '
                f'data-type="residue"/>'
            )

            # Residue letter
            svg_parts.append(
                f'  <text x="{x + char_width / 2}" y="{y_offset}" class="residue" '
                f'text-anchor="middle">{res}</text>'
            )

            y_offset_res = y_offset + line_spacing
            # Background rectangle Pred
            svg_parts.append(
                f'  <rect x="{x}" y="{y_offset_res - 14}" width="{char_width}" height="{char_height}" '
                f'fill="{color}" opacity="0.7" data-residue="{res}" data-prediction="{pred}" data-index="{absolute_idx}" '
                f'data-type="prediction"/>'
            )

            # Prediction letter
            svg_parts.append(
                f'  <text x="{x + char_width / 2}" y="{y_offset_res}" class="residue" '
                f'text-anchor="middle">{pred}</text>'
            )

        y_offset += 2 * line_spacing

    # Draw legend
    legend_y = height - legend_height + 20
    legend_x = margin
    svg_parts.append(f'  <text x="{legend_x}" y="{legend_y}" class="legend">Legend:</text>')

    legend_x += 60
    for label, color in sorted(color_scheme.items()):
        svg_parts.append(
            f'  <rect x="{legend_x}" y="{legend_y - 10}" width="15" height="15" fill="{color}" opacity="0.7"/>'
        )
        svg_parts.append(
            f'  <text x="{legend_x + 20}" y="{legend_y}" class="legend">{label}</text>'
        )
        legend_x += 80

    svg_parts.append('</svg>')

    svg_final = '\n'.join(svg_parts)

    metadata = {
        'type': 'highlight',
        'sequence_length': len(sequence),
        'prediction_label': prediction.prediction_name,
        'color_scheme': color_scheme,
        'residues_per_line': residues_per_line,
        'prediction_distribution': _get_prediction_distribution(pred_value),
    }

    return svg_final, metadata
