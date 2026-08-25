import pandas as pd
import altair as alt

from typing import List

from biotrainer_core.data_classes import VariantScore, SequenceData


def plot_variant_score_distribution(dataset: List[VariantScore]):
    from .label_distribution import _plot_label_distribution_per_sequence_continuous
    # Convert to sequence data for re-use of functionality
    if len(dataset) == 0:
        raise ValueError("Dataset to plot is empty!")
    wt_seq = dataset[0].variant.wt_sequence or ""
    seqs = [SequenceData(seq_id=f"mut_{idx}",
                         seq=wt_seq,
                         label=str(variant.total_score)) for idx, variant in enumerate(dataset)]
    return _plot_label_distribution_per_sequence_continuous(seqs, labels_filter=lambda _: True)
