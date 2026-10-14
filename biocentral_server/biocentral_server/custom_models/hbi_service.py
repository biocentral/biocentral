import os
import torch
import shutil
import tempfile
from typing import Dict, Any, List
import pandas as pd

from pymmseqs.commands import easy_search
from biotrainer.shared import Bootstrapper
from biotrainer.shared.metrics import (SequenceClassificationMetricsCalculator, SequenceRegressionMetricsCalculator)
from biotrainer_core.data_classes.metrics import BootstrappedMetric


def run_easy_search_lookup(
        train_seqs: Dict[str, str],
        query_seqs: Dict[str, str],
        evalue_cutoff: float = 10.0,
        min_seq_id: float = 0.0,
        exclude_identical_id: bool = False,
) -> pd.DataFrame:
    """
    Executes an mmseqs2 easy_search lookup

    target = train sequences
    query sequences = test or val sequences

    returns a dataframe with the best hit (according to the evalue and bitscore) for every found query sequence
    """

    result_columns = ["query", "target", "fident", "alnlen", "evalue", "bits"]

    if not train_seqs or not query_seqs:
        return pd.DataFrame(columns=result_columns)

    temp_dir = tempfile.mkdtemp(prefix="mmseqs_hbi_lookup_")

    try:
        query_fasta = os.path.join(temp_dir, "query.fasta")
        target_fasta = os.path.join(temp_dir, "target.fasta")
        out_tsv = os.path.join(temp_dir, "hbi_lookup_hits.tsv")

        with open(query_fasta, "w", encoding="utf-8") as f_q:
            for seq_id, seq in query_seqs.items():
                f_q.write(f">{seq_id}\n{seq}\n")

        with open(target_fasta, "w", encoding="utf-8") as f_t:
            for seq_id, seq in train_seqs.items():
                f_t.write(f">{seq_id}\n{seq}\n")

        parser = easy_search(
            query_fasta=query_fasta,
            target_fasta_or_db=target_fasta,
            alignment_file=out_tsv,
            tmp_dir=temp_dir,
            e=evalue_cutoff,
            min_seq_id=min_seq_id,
            format_output="query,target,fident,alnlen,evalue,bits",
        )

        df_hits = parser.to_pandas()

        if df_hits.empty:
            return pd.DataFrame(columns=result_columns)

        if exclude_identical_id:
            df_hits = df_hits[df_hits["query"] != df_hits["target"]].copy()
            if df_hits.empty:
                return pd.DataFrame(columns=result_columns)

        df_hits["evalue"] = df_hits["evalue"].astype(float)
        df_hits["bits"] = df_hits["bits"].astype(float)
        df_hits["fident"] = df_hits["fident"].astype(float)

        top_hits = (
            df_hits.sort_values(by=["query", "evalue", "bits"], ascending=[True, True, False])
            .groupby("query", as_index=False)
            .first()
        )
        return top_hits

    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)


def _bootstrap_predictions(
        targets_map: Dict[str, Any],
        predictions_map: Dict[str, Any],
        valid_ids: List[str],
        is_numeric: bool,
        iterations: int,
        confidence_level: float = 0.05,
) -> List[BootstrappedMetric]:
    if not valid_ids:
        return []
    all_predictions_dict = {}
    all_targets_dict = {}

    if is_numeric:
        for seq_id in valid_ids:
            all_targets_dict[seq_id] = torch.tensor(float(targets_map[seq_id]), dtype=torch.float32)
            all_predictions_dict[seq_id] = torch.tensor(float(predictions_map[seq_id]), dtype=torch.float32)
        metrics_calc = SequenceRegressionMetricsCalculator(device="cpu", n_classes=1)
    else:
        all_unique_labels = sorted(list(set(targets_map.values()) | set(predictions_map.values())))
        label_to_idx = {label: idx for idx, label in enumerate(all_unique_labels)}
        n_classes = len(all_unique_labels)

        for seq_id in valid_ids:
            true_idx = label_to_idx[targets_map[seq_id]]
            pred_idx = label_to_idx[predictions_map[seq_id]]
            all_targets_dict[seq_id] = torch.tensor(true_idx, dtype=torch.long)
            all_predictions_dict[seq_id] = torch.tensor(pred_idx, dtype=torch.long)

        metrics_calc = SequenceClassificationMetricsCalculator(device="cpu", n_classes=n_classes)

    return Bootstrapper._do_bootstrapping(
        iterations=iterations,
        sample_size=len(valid_ids),
        confidence_level=confidence_level,
        seq_ids=valid_ids,
        all_predictions_dict=all_predictions_dict,
        all_targets_dict=all_targets_dict,
        metrics_calculator=metrics_calc.reset(),
    )


def compute_hbi_metrics_from_lookup(
        train_labels: Dict[str, Any],
        query_labels: Dict[str, Any],
        top_hits_df: pd.DataFrame,
        is_numeric: bool = False,
        iterations: int = 30,
        confidence_level: float = 0.05,
) -> List[BootstrappedMetric]:
    """
    Transfers labels from nearest training neighbor to queries and computes bootstrapped metrics across iterations using Biotrainers predefined Bootstrapper.
    """

    if top_hits_df.empty or not query_labels or not train_labels:
        return []

    hit_map = dict(zip(top_hits_df["query"], top_hits_df["target"]))
    valid_query_ids = [
        q_id for q_id in query_labels
        if q_id in hit_map and hit_map[q_id] in train_labels
    ]

    targets_map = {q_id: query_labels[q_id] for q_id in valid_query_ids}
    predictions_map = {q_id: train_labels[hit_map[q_id]] for q_id in valid_query_ids}

    return _bootstrap_predictions(
        targets_map=targets_map,
        predictions_map=predictions_map,
        valid_ids=valid_query_ids,
        is_numeric=is_numeric,
        iterations=iterations,
        confidence_level=confidence_level,
    )


def compute_hbi_cluster_metrics(
        clusters: Dict[str, List[str]],
        labels: Dict[str, Any],
        is_numeric: bool = False,
        iterations: int = 30,
        confidence_level: float = 0.05,
        include_centroids_as_members: bool = False,
) -> List[BootstrappedMetric]:
    if not clusters or not labels:
        return []

    valid_member_ids = []
    predictions_map = {}
    targets_map = {}

    for centroid_id, members in clusters.items():
        if centroid_id not in labels:
            continue

        for member_id in members:
            if not include_centroids_as_members and member_id == centroid_id:
                continue

            if member_id in labels:
                valid_member_ids.append(member_id)
                targets_map[member_id] = labels[member_id]
                predictions_map[member_id] = labels[centroid_id]

    valid_member_ids = list(dict.fromkeys(valid_member_ids))

    return _bootstrap_predictions(
        targets_map=targets_map,
        predictions_map=predictions_map,
        valid_ids=valid_member_ids,
        is_numeric=is_numeric,
        iterations=iterations,
        confidence_level=confidence_level,
    )
