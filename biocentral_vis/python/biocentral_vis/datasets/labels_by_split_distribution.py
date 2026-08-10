import pandas as pd
import altair as alt

from typing import List, Callable, Optional
from biotrainer_core.data_classes import SequenceData

from ..base.constants import DISCRETE_THRESHOLD


def _plot_labels_by_split_per_sequence_discrete(dataset: List[SequenceData]):
    # Collect counts per label per split
    rows = []
    for record in dataset:
        label = record.label
        if label is None:
            continue
        split = record.set or 'unknown'
        rows.append({'label': label, 'split': split})

    df = pd.DataFrame(rows)
    df_grouped = df.groupby(['split', 'label']).size().reset_index(name='count')

    # Normalize within each split to show proportions
    split_totals = df_grouped.groupby('split')['count'].transform('sum')
    df_grouped['percentage'] = (df_grouped['count'] / split_totals * 100).round(1)

    # Grouped bar chart: x=label, color=split
    chart = alt.Chart(df_grouped).mark_bar(
        cornerRadius=4,
        opacity=0.8,
    ).encode(
        x=alt.X('label:N', title='Class Label', axis=alt.Axis(labelAngle=-45)),
        y=alt.Y('percentage:Q', title='Percentage within Split'),
        color=alt.Color('split:N', title='Split', scale=alt.Scale(scheme='tableau10'),
                        sort=['train', 'val', 'test']),
        xOffset=alt.XOffset('split:N', sort=['train', 'val', 'test']),
        tooltip=[
            alt.Tooltip('split:N', title='Split'),
            alt.Tooltip('label:N', title='Label'),
            alt.Tooltip('count:Q', title='Count'),
            alt.Tooltip('percentage:Q', title='Percentage', format='.1f'),
        ]
    ).properties(
        title='Label Distribution by Split',
        width=500,
        height=300
    )

    metadata = {'dataset_len': len(dataset)}
    return chart, metadata


def _plot_labels_by_split_per_sequence_continuous(dataset: List[SequenceData]):
    rows = []
    for record in dataset:
        label = record.label
        if label is None:
            continue
        try:
            label_float = float(label)
        except ValueError:
            return _plot_labels_by_split_per_sequence_discrete(dataset)
        split = record.set or 'unknown'
        rows.append({'label': label_float, 'split': split})

    df = pd.DataFrame(rows)

    # Per-split statistics for subtitle
    stats = df.groupby('split')['label'].agg(['mean', 'std']).round(2)
    subtitle_parts = [f"{s}: μ={row['mean']:.2f}, σ={row['std']:.2f}" for s, row in stats.iterrows()]
    subtitle = ' | '.join(subtitle_parts)

    # Overlaid histograms per split
    chart = alt.Chart(df).mark_area(
        opacity=0.4,
        interpolate='step',
    ).encode(
        x=alt.X('label:Q', title='Label Value', bin=alt.Bin(maxbins=30)),
        y=alt.Y('count():Q', title='Number of Sequences', stack=None),
        color=alt.Color('split:N', title='Split', scale=alt.Scale(scheme='tableau10'),
                        sort=['train', 'val', 'test']),
        tooltip=[
            alt.Tooltip('split:N', title='Split'),
            alt.Tooltip('label:Q', title='Label Range', bin=alt.Bin(maxbins=30), format='.2f'),
            alt.Tooltip('count():Q', title='Count'),
        ]
    ).properties(
        title={
            'text': 'Label Distribution by Split (Continuous)',
            'subtitle': subtitle
        },
        width=500,
        height=300
    )

    metadata = {'dataset_len': len(dataset)}
    return chart, metadata


def _plot_labels_by_split_per_residue_discrete(dataset: List[SequenceData]):
    # Aggregate per-residue labels by split
    rows = []
    for record in dataset:
        label = record.label
        if label is None:
            continue
        split = record.set or 'unknown'
        for residue_label in label:
            rows.append({'label': residue_label, 'split': split})

    df = pd.DataFrame(rows)
    total_residues = len(df)
    df_grouped = df.groupby(['split', 'label']).size().reset_index(name='count')

    # Normalize within each split
    split_totals = df_grouped.groupby('split')['count'].transform('sum')
    df_grouped['percentage'] = (df_grouped['count'] / split_totals * 100).round(1)

    chart = alt.Chart(df_grouped).mark_bar(
        cornerRadius=4,
        opacity=0.8,
    ).encode(
        x=alt.X('label:N', title='Residue Label', axis=alt.Axis(labelAngle=-45)),
        y=alt.Y('percentage:Q', title='Percentage within Split'),
        color=alt.Color('split:N', title='Split', scale=alt.Scale(scheme='tableau10'),
                        sort=['train', 'val', 'test']),
        xOffset=alt.XOffset('split:N', sort=['train', 'val', 'test']),
        tooltip=[
            alt.Tooltip('split:N', title='Split'),
            alt.Tooltip('label:N', title='Label'),
            alt.Tooltip('count:Q', title='Count'),
            alt.Tooltip('percentage:Q', title='Percentage', format='.1f'),
        ]
    ).properties(
        title='Per-Residue Label Distribution by Split',
        width=500,
        height=300
    )

    metadata = {'dataset_len': len(dataset), 'total_residues': total_residues}
    return chart, metadata


def _plot_labels_by_split_per_residue_continuous(dataset: List[SequenceData]):
    rows = []
    for record in dataset:
        label = record.label
        if label is None:
            continue
        split = record.set or 'unknown'
        try:
            delimiter = ";" if ";" in label else ","
            rows.extend([{'label': float(v), 'split': split} for v in label.split(delimiter)])
        except ValueError:
            return _plot_labels_by_split_per_residue_discrete(dataset)

    df = pd.DataFrame(rows)
    total_residues = len(df)

    # Per-split statistics
    stats = df.groupby('split')['label'].agg(['mean', 'std']).round(2)
    subtitle_parts = [f"{s}: μ={row['mean']:.2f}, σ={row['std']:.2f}" for s, row in stats.iterrows()]
    subtitle = ' | '.join(subtitle_parts)

    chart = alt.Chart(df).mark_area(
        opacity=0.4,
        interpolate='step',
    ).encode(
        x=alt.X('label:Q', title='Residue Label Value', bin=alt.Bin(maxbins=30)),
        y=alt.Y('count():Q', title='Number of Residues', stack=None),
        color=alt.Color('split:N', title='Split', scale=alt.Scale(scheme='tableau10'),
                        sort=['train', 'val', 'test']),
        tooltip=[
            alt.Tooltip('split:N', title='Split'),
            alt.Tooltip('label:Q', title='Label Range', bin=alt.Bin(maxbins=30), format='.2f'),
            alt.Tooltip('count():Q', title='Count'),
        ]
    ).properties(
        title={
            'text': 'Per-Residue Label Distribution by Split (Continuous)',
            'subtitle': subtitle
        },
        width=500,
        height=300
    )

    metadata = {'dataset_len': len(dataset), 'total_residues': total_residues}
    return chart, metadata


def plot_labels_by_split_distribution(dataset: List[SequenceData],
                                      labels_filter: Optional[Callable[[str], bool]] = None):
    # TODO Apply the labels filter everywhere
    labels_set = {seq_data.label: seq_data.seq for seq_data in dataset if seq_data.label is not None}
    is_discrete = len(labels_set) < DISCRETE_THRESHOLD
    is_per_residue = all([len(label) == len(seq or "") or ";" in label for label, seq in labels_set.items()])
    if is_discrete:
        if is_per_residue:
            return _plot_labels_by_split_per_residue_discrete(dataset)
        return _plot_labels_by_split_per_sequence_discrete(dataset)
    # Continuous
    if is_per_residue:
        return _plot_labels_by_split_per_residue_continuous(dataset)
    return _plot_labels_by_split_per_sequence_continuous(dataset)
