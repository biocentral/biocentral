import pandas as pd
import altair as alt

from typing import List
from biotrainer_core.data_classes import SequenceData


def _plot_split_distribution(dataset: List[SequenceData]):
    # Collect rich data
    data_by_split = {}
    for record in dataset:
        split = record.set
        if split is None:
            continue

        if split not in data_by_split:
            data_by_split[split] = {
                'split': split,
                'count': 0,
                'seq_ids': [],
            }

        data_by_split[split]['count'] += 1
        data_by_split[split]['seq_ids'].append(record.seq_id)

    dataset_len = len(dataset)
    # Create DataFrame for Altair
    df = pd.DataFrame(list(data_by_split.values()))
    df['percentage'] = (df['count'] / df['count'].sum() * 100).round(1)

    # Create interactive chart
    chart = alt.Chart(df).mark_bar(
        cornerRadius=4,
        opacity=0.8,
    ).encode(
        x=alt.X('split:N', title='Split', axis=alt.Axis(labelAngle=-45), sort=['train', 'val', 'test']),
        y=alt.Y('count:Q', title='Number of Sequences'),
        color=alt.Color('split:N', legend=None, scale=alt.Scale(scheme='tableau10')),
        tooltip=[
            alt.Tooltip('split:N', title='Split'),
            alt.Tooltip('count:Q', title='Count'),
            alt.Tooltip('percentage:Q', title='Percentage', format='.1f'),
        ]
    ).properties(
        title='Split Distribution',
        width=400,
        height=300
    )
    metadata = {'dataset_len': dataset_len}
    return chart, metadata


def plot_split_distribution(dataset: List[SequenceData]):
    # split_set = {seq_data.set for seq_data in dataset if seq_data.set is not None}
    return _plot_split_distribution(dataset)
