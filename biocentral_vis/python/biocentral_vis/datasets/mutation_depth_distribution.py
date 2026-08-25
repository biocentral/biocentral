import pandas as pd
import altair as alt

from typing import List
from biotrainer_core.data_classes import Variant


def _plot_mutation_depth_distribution(dataset: List[Variant]):
    mutation_depths = [variant.mutation_depth() for variant in dataset]

    # Collect data by mutation depth
    data_by_depth = {}
    for depth in mutation_depths:
        depth_key = str(depth)
        if depth > 15:
            depth_key = "15+"
            depth = 15
        if depth_key not in data_by_depth:
            data_by_depth[depth_key] = {
                "depth": depth,
                "count": 0,
            }
        data_by_depth[depth_key]["count"] += 1

    dataset_len = len(dataset)
    # Create DataFrame for Altair
    df = pd.DataFrame(list(data_by_depth.values()))
    df = df.sort_values("depth")
    df["percentage"] = (df["count"] / df["count"].sum() * 100).round(1)

    # Create interactive chart
    chart = (
        alt.Chart(df)
        .mark_bar(
            cornerRadius=4,
            opacity=0.8,
        )
        .encode(
            x=alt.X("depth:N", title="Mutation Depth", axis=alt.Axis(labelAngle=-45)),
            y=alt.Y("count:Q", title="Number of Variants"),
            color=alt.Color(
                "depth:N", legend=None, scale=alt.Scale(scheme="tableau10")
            ),
            tooltip=[
                alt.Tooltip("depth:N", title="Depth"),
                alt.Tooltip("count:Q", title="Count"),
                alt.Tooltip("percentage:Q", title="Percentage", format=".1f"),
            ],
        )
        .properties(title="Mutation Depth Distribution", width=400, height=300)
    )
    metadata = {"dataset_len": dataset_len}
    return chart, metadata


def plot_mutation_depth_distribution(dataset: List[Variant]):
    return _plot_mutation_depth_distribution(dataset)
