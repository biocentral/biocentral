import altair as alt
import pandas as pd

from typing import List, Set, Optional

from biocentral_api import ProjectionResult
from biotrainer_core.data_classes import SequenceData

from ..base.constants import DISCRETE_THRESHOLD


def _binnify_labels(
    all_labels: Set[str],
    data_df: pd.DataFrame,
    highlight_name: Optional[str],
    bins: int = 8,
):
    if len(all_labels) <= DISCRETE_THRESHOLD:
        return data_df
    try:
        # Filter out highlight entries for binning
        non_highlight_mask = data_df["label"] != highlight_name

        # Convert labels to float for non-highlight entries
        data_df.loc[non_highlight_mask, "label_numeric"] = pd.to_numeric(
            data_df.loc[non_highlight_mask, "label"], errors="raise"
        )

        # Create bins using pandas cut
        data_df.loc[non_highlight_mask, "label"] = pd.cut(
            data_df.loc[non_highlight_mask, "label_numeric"],
            bins=bins,
            duplicates="drop",
        ).astype(str)

        # Drop the temporary numeric column
        data_df = data_df.drop(columns=["label_numeric"])

    except ValueError:
        raise ValueError(
            "Found non-numeric label in continuous dataset in projection plotting!"
        )
    return data_df


def plot_projection_result(
    projection_result: ProjectionResult,
    dataset: List[SequenceData],
    color_attribute: str = "TARGET",
    highlight_ids: Optional[Set[str]] = None,
    highlight_name: Optional[str] = "highlight",
):
    projections_data = projection_result.projections_data
    identifier = projections_data.identifier
    coord_map = {
        seq_id: (
            projections_data.x[idx],
            projections_data.y[idx],
            projections_data.z[idx],
        )
        for idx, seq_id in enumerate(identifier)
    }
    seq_data_by_id = {seq_data.seq_id: seq_data for seq_data in dataset}
    highlight_ids = highlight_ids or set()
    # Prepare data for plotting
    plot_data = []
    highlight_data = []  # Save highlight data separately and add it in the end to keep coloring order
    all_labels = set()  # Collect all unique labels

    for seq_id in identifier:
        if seq_id in seq_data_by_id:
            seq_data = seq_data_by_id[seq_id]
            x, y, z = coord_map[seq_id]
            is_highlight = seq_id in highlight_ids
            original_label = str(seq_data.get_attribute(color_attribute))
            all_labels.add(original_label)

            if is_highlight:
                label = str(highlight_name)
            else:
                label = original_label

            data_dict = {"seq_id": seq_id, "x": x, "y": y, "z": z, "label": label}
            if is_highlight:
                highlight_data.append(data_dict)
            else:
                plot_data.append(data_dict)

    plot_data.extend(highlight_data)
    df = pd.DataFrame(plot_data)
    df_binned = _binnify_labels(all_labels, df, highlight_name, bins=10)
    all_labels = set(df_binned["label"])

    if highlight_ids:
        color_domain = sorted(list(all_labels)) + [highlight_name]
    else:
        color_domain = sorted(list(all_labels))

    # Define colors: default colors for labels + RED for highlight
    default_colors = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b"]
    color_range = default_colors[: len(all_labels)] + [
        "#FF0000"
    ]  # Always red for highlight

    coloring = alt.Color(
        "label:N",
        title=color_attribute,
        scale=alt.Scale(domain=color_domain, range=color_range),
        sort=color_domain,
    )

    # Opacity: 0.5 for non-highlights, 1.0 for highlights
    opacity = alt.value(0.8)
    if highlight_ids:
        opacity = alt.condition(
            alt.datum.label == highlight_name,
            alt.value(1.0),  # Full opacity for highlights
            alt.value(0.5),  # 50% opacity for non-highlights
        )

    projection_method = (
        projection_result.projections_metadata.projection_name[0] or "unknown"
    )
    # Create Altair scatter plot
    chart = (
        alt.Chart(df_binned)
        .mark_circle(size=60)
        .encode(
            x=alt.X("x:Q", title=f"{projection_method} - Dim 1"),
            y=alt.Y("y:Q", title=f"{projection_method} - Dim 2"),
            color=coloring,
            opacity=opacity,
            tooltip=["seq_id:N", "x:Q", "y:Q", "z:Q", "label:N"],
        )
        .properties(width=600, height=400, title="Projection Result")
        .interactive()
    )

    # Prepare metadata
    metadata = {
        "type": "projection_scatter",
        "n_points": len(plot_data),
        "color_attribute": color_attribute,
        "n_labels": df_binned["label"].nunique(),
        "projection_method": projection_method,
        "dimensions": 3 if "z" in df_binned.columns else 2,
    }

    return chart, metadata
