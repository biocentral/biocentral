import os
import torch
import shutil
import tempfile
from typing import Dict, Any, List
import pandas as pd

from pymmseqs.commands import easy_search
from biotrainer.shared import Bootstrapper
from biotrainer.shared.metrics import (SequenceClassificationMetricsCalculator, SequenceRegressionMetricsCalculator)


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


def compute_hbi_metrics_from_lookup(
        train_labels: Dict[str, str],
        query_labels: Dict[str, str],
        top_hits_df: pd.DataFrame,
        is_numeric: bool = False,
        iterations: int = 30,
        confidence_level: float = 0.05,
) -> List[Dict[str, Any]]:
    """
    Transfers labels from nearest training neighbor to queries and computes bootstrapped metrics across iterations using Biotrainers predefined Bootstrapper.
    """

    if top_hits_df.empty or not query_labels or not train_labels:
        return []

    hit_map = dict(zip(top_hits_df["query"], top_hits_df["target"]))

    valid_query_ids = []

    for q_id, true_val in query_labels.items():
        if q_id in hit_map:
            target_id = hit_map[q_id]
            if target_id in train_labels:
                valid_query_ids.append(q_id)

    if not valid_query_ids:
        return []

    all_predictions_dict = {}
    all_targets_dict = {}

    if not is_numeric:
        all_unique_labels = sorted(list(set(train_labels.values()) | set(query_labels.values())))
        label_to_idx = {label: idx for idx, label in enumerate(all_unique_labels)}
        n_classes = len(all_unique_labels)

        for q_id in valid_query_ids:
            t_id = hit_map[q_id]
            true_idx = label_to_idx[query_labels[q_id]]
            pred_idx = label_to_idx[train_labels[t_id]]

            all_targets_dict[q_id] = torch.tensor(true_idx, dtype=torch.long)
            all_predictions_dict[q_id] = torch.tensor(pred_idx, dtype=torch.long)

        metrics_calc = SequenceClassificationMetricsCalculator(
            device="cpu",
            n_classes=n_classes,
        )
    else:
        for q_id in valid_query_ids:
            t_id = hit_map[q_id]
            all_targets_dict[q_id] = torch.tensor(float(query_labels[q_id]), dtype=torch.float32)
            all_predictions_dict[q_id] = torch.tensor(float(train_labels[t_id]), dtype=torch.float32)
        metrics_calc = SequenceRegressionMetricsCalculator(device="cpu", n_classes=1)

    bootstrapped_metrics = Bootstrapper._do_bootstrapping(
        iterations=iterations,
        sample_size=len(valid_query_ids),
        confidence_level=confidence_level,
        seq_ids=valid_query_ids,
        all_predictions_dict=all_predictions_dict,
        all_targets_dict=all_targets_dict,
        metrics_calculator=metrics_calc.reset(),
    )

    return [
        {
            "name": m.name,
            "mean": m.mean,
            "lower": m.lower,
            "upper": m.upper,
            "iterations": m.iterations,
            "sample_size": m.sample_size,

        }
        for m in bootstrapped_metrics
    ]


def compute_hbi_cluster_metrics(
        clusters: Dict[str, List[str]],
        labels: Dict[str, Any],
        is_numeric: bool = False,
        iterations: int = 30,
        confidence_level: float = 0.05,
        include_centroids_as_members: bool = False,
) -> List[Dict[str, Any]]:
    """
    Evaluates cluster consistency via HBI:
    The label of each cluster centroid is transferred as the prediction to all its members.
    Bootstrapping (using Biotrainer) is performed over all valid member predictions.
    """

    if not clusters or not labels:
        return []

    valid_member_ids = []
    member_to_centroid_map = {}

    for centroid_id, members in clusters.items():

        if centroid_id not in labels:
            continue

        for member_id in members:
            if not include_centroids_as_members and member_id == centroid_id:
                continue

            if member_id in labels:
                valid_member_ids.append(member_id)
                member_to_centroid_map[member_id] = centroid_id

    valid_member_ids = list(dict.fromkeys(valid_member_ids))
    if not valid_member_ids:
        return []

    all_predictions_dict = {}
    all_targets_dict = {}

    if not is_numeric:
        all_unique_labels = sorted(list(set(labels.values())))
        label_to_idx = {label: idx for idx, label in enumerate(all_unique_labels)}
        n_classes = len(all_unique_labels)

        for member_id in valid_member_ids:
            centroid_id = member_to_centroid_map[member_id]
            true_idx = label_to_idx[labels[member_id]]
            pred_idx = label_to_idx[labels[centroid_id]]

            all_targets_dict[member_id] = torch.tensor(true_idx, dtype=torch.long)
            all_predictions_dict[member_id] = torch.tensor(pred_idx, dtype=torch.long)

        metrics_calc = SequenceClassificationMetricsCalculator(
            device="cpu",
            n_classes=n_classes,
        )

    else:
        for member_id in valid_member_ids:
            centroid_id = member_to_centroid_map[member_id]
            all_targets_dict[member_id] = torch.tensor(float(labels[member_id]), dtype=torch.float32)
            all_predictions_dict[member_id] = torch.tensor(float(labels[centroid_id]), dtype=torch.float32)

        metrics_calc = SequenceRegressionMetricsCalculator(device="cpu", n_classes=1)

    bootstrapped_metrics = Bootstrapper._do_bootstrapping(
        iterations=iterations,
        sample_size=len(valid_member_ids),
        confidence_level=confidence_level,
        seq_ids=valid_member_ids,
        all_predictions_dict=all_predictions_dict,
        all_targets_dict=all_targets_dict,
        metrics_calculator=metrics_calc.reset(),
    )

    return [
        {
            "name": m.name,
            "mean": m.mean,
            "lower": m.lower,
            "upper": m.upper,
            "iterations": m.iterations,
            "sample_size": m.sample_size,

        } for m in bootstrapped_metrics
    ]
