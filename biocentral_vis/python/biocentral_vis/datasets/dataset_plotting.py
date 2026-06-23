import pandas as pd
import altair as alt

from typing import List
from biotrainer_core.data_classes import SequenceData

DISCRETE_THRESHOLD = 20


def _plot_label_distribution_discrete(dataset: List[SequenceData]):
    # Collect rich data
    data_by_label = {}
    for record in dataset:
        label = record.label
        if label is None:
            continue

        if label not in data_by_label:
            data_by_label[label] = {
                'label': label,
                'count': 0,
                'seq_ids': [],
                'sets': {},
            }

        data_by_label[label]['count'] += 1
        data_by_label[label]['seq_ids'].append(record.seq_id)

        set_name = record.set or 'unknown'
        data_by_label[label]['sets'][set_name] = data_by_label[label]['sets'].get(set_name, 0) + 1

    dataset_len = len(dataset)
    # Create DataFrame for Altair
    df = pd.DataFrame(list(data_by_label.values()))
    df['percentage'] = (df['count'] / df['count'].sum() * 100).round(1)

    # Create interactive chart
    chart = alt.Chart(df).mark_bar(
        cornerRadius=4,
        opacity=0.8,
    ).encode(
        x=alt.X('label:N', title='Class Label', axis=alt.Axis(labelAngle=-45)),
        y=alt.Y('count:Q', title='Number of Sequences'),
        color=alt.Color('label:N', legend=None, scale=alt.Scale(scheme='tableau10')),
        tooltip=[
            alt.Tooltip('label:N', title='Label'),
            alt.Tooltip('count:Q', title='Count'),
            alt.Tooltip('percentage:Q', title='Percentage', format='.1f'),
        ]
    ).properties(
        title='Label Distribution',
        width=400,
        height=300
    )
    metadata = {'dataset_len': dataset_len}
    return chart, metadata


def _plot_label_distribution_continuous(dataset: List[SequenceData], ):
    try:
        labels_float = [float(seq_data.label) for seq_data in dataset if seq_data.label is not None]
    except ValueError:
        return _plot_label_distribution_discrete(dataset)

    dataset_len = len(dataset)

    # Create DataFrame with continuous labels
    df = pd.DataFrame({
        'label': labels_float
    })

    # Calculate statistics for tooltip
    mean_val = df['label'].mean()
    median_val = df['label'].median()
    std_val = df['label'].std()

    # Create histogram with automatic binning
    chart = alt.Chart(df).mark_bar(
        cornerRadius=4,
        opacity=0.8,
        color='steelblue'
    ).encode(
        x=alt.X('label:Q',
                title='Label Value',
                bin=alt.Bin(maxbins=30)),
        y=alt.Y('count():Q', title='Number of Sequences'),
        tooltip=[
            alt.Tooltip('label:Q', title='Label Range', bin=alt.Bin(maxbins=30), format='.2f'),
            alt.Tooltip('count():Q', title='Count'),
        ]
    ).properties(
        title={
            'text': 'Label Distribution (Continuous)',
            'subtitle': f'Mean: {mean_val:.2f} | Median: {median_val:.2f} | Std: {std_val:.2f}'
        },
        width=400,
        height=300
    )

    metadata = {"dataset_len": dataset_len}
    return chart, metadata


def plot_label_distribution(dataset: List[SequenceData]):
    labels_set = {seq_data.label for seq_data in dataset if seq_data.label is not None}
    if len(labels_set) > DISCRETE_THRESHOLD:
        return _plot_label_distribution_continuous(dataset)
    return _plot_label_distribution_discrete(dataset)
