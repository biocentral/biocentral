import pandas as pd
import altair as alt

from typing import List
from biotrainer_core.data_classes import SequenceData


def _plot_sequence_length_distribution(dataset: List[SequenceData]):
    rows = []
    for record in dataset:
        seq = record.seq
        if seq is None:
            continue
        split = record.set or "unknown"
        rows.append({"length": len(seq), "split": split})

    df = pd.DataFrame(rows)

    # Per-split statistics for subtitle
    stats = df.groupby("split")["length"].agg(["mean", "std"]).round(2)
    subtitle_parts = [
        f"{s}: μ={row['mean']:.2f}, σ={row['std']:.2f}" for s, row in stats.iterrows()
    ]
    subtitle = " | ".join(subtitle_parts)

    # Overlaid histograms per split with KDE
    histogram = (
        alt.Chart(df)
        .mark_area(
            opacity=0.4,
            interpolate="step",
        )
        .encode(
            x=alt.X("length:Q", title="Sequence Length", bin=alt.Bin(maxbins=30)),
            y=alt.Y("count():Q", title="Number of Sequences", stack=None),
            color=alt.Color(
                "split:N",
                title="Split",
                scale=alt.Scale(scheme="tableau10"),
                sort=["train", "val", "test"],
            ),
            tooltip=[
                alt.Tooltip("split:N", title="Split"),
                alt.Tooltip(
                    "length:Q",
                    title="Length Range",
                    bin=alt.Bin(maxbins=30),
                    format=".0f",
                ),
                alt.Tooltip("count():Q", title="Count"),
            ],
        )
    )

    # KDE overlay per split
    kde = (
        alt.Chart(df)
        .transform_density(
            "length",
            as_=["length", "density"],
            groupby=["split"],
        )
        .mark_line(
            strokeWidth=2,
        )
        .encode(
            x=alt.X("length:Q", title="Sequence Length"),
            y=alt.Y("density:Q", title="Density", axis=None),
            color=alt.Color(
                "split:N",
                title="Split",
                scale=alt.Scale(scheme="tableau10"),
                sort=["train", "val", "test"],
            ),
        )
    )

    chart = (
        alt.layer(histogram, kde)
        .resolve_scale(y="independent")
        .properties(
            title={"text": "Sequence Length Distribution", "subtitle": subtitle},
            width=500,
            height=300,
        )
    )

    metadata = {"dataset_len": len(dataset)}
    return chart, metadata


def plot_sequence_length_distribution(dataset: List[SequenceData]):
    return _plot_sequence_length_distribution(dataset)
