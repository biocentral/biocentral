from __future__ import annotations

from biocentral_vis import BiocentralChart
from typing import Dict, Any, List, Optional, Union

from biocentral_api import (
    BiotrainerModelResult,
    BiotrainerInferenceResult,
    Prediction,
    BiocentralAPI,
    SequenceData,
    ProjectionResult,
)
from biocentral_api.clients import EmbeddingsResult

from .base import BiocentralBackend


class Biocentral:
    """Unified entry point to the biocentral ecosystem.

    Provides a single interface for embedding, training, inference, and prediction
    that works both locally (via biotrainer) and remotely (via biocentral server API).

    Examples:

        # API mode (default) - requires a running biocentral server
        bc = Biocentral(mode="api")
        result = bc.embed("Rostlab/prot_t5_xl_uniref50", {"seq1": "MKTL"})

        # Local mode - requires pip install biocentral[local]
        bc = Biocentral(mode="local", device="cuda")
        result = bc.embed("Rostlab/prot_t5_xl_uniref50", {"seq1": "MKTL"})

        # Train and then run inference using the model hash
        model_result = bc.train(config, training_data)
        model_hash = model_result.derived_values.model_hash
        inference_result = bc.inference(model_hash, {"seq1": "MKTL"})
    """

    def __init__(
            self,
            mode: str = "api",
            custom_api: Optional[BiocentralAPI] = None,
            device: Optional[str] = None,
    ):
        """
        :param mode: Execution mode - "api" for remote server, "local" for local biotrainer execution.
        :param custom_api: Custom BiocentralAPI instance (api mode only).
        :param device: Device for local computation, e.g. "cuda" or "cpu" (local mode only).
        """
        self._mode = mode

        if mode == "api":
            from .api import APIBackend

            self._backend: BiocentralBackend = APIBackend(
                custom_api=custom_api,
            )
        elif mode == "local":
            from .local import LocalBackend

            self._backend = LocalBackend(device=device)
        else:
            raise ValueError(f"Unknown mode: '{mode}'. Use 'api' or 'local'.")

    @property
    def mode(self) -> str:
        return self._mode

    @staticmethod
    def _read_fasta(sequence_data: str) -> List[SequenceData]:
        from biotrainer_core.input_files import read_FASTA
        from pathlib import Path

        fasta_path = Path(sequence_data)
        if not fasta_path.exists():
            raise ValueError(f"FASTA file not found: {fasta_path}")
        records = read_FASTA(fasta_path)
        return records

    @staticmethod
    def _parse_input_as_dict(
            sequence_data: Union[str, Dict[str, str], List[SequenceData]],
    ) -> Dict[str, str]:
        if isinstance(sequence_data, str):
            records = Biocentral._read_fasta(sequence_data)
            seq_dat = {r.seq_id: r.seq for r in records}
        elif isinstance(sequence_data, list):
            seq_dat = {r.seq_id: r.seq for r in sequence_data}
        elif isinstance(sequence_data, dict):
            seq_dat = sequence_data
        else:
            raise ValueError(f"Invalid sequence data type: {type(sequence_data)}")

        if len(seq_dat) == 0:
            raise ValueError("No sequences found in input data")

        return seq_dat

    @staticmethod
    def _parse_input_as_sequence_data(
            sequence_data: Union[str, Dict[str, str], List[SequenceData]],
    ) -> List[SequenceData]:
        if isinstance(sequence_data, str):
            seq_dat = Biocentral._read_fasta(sequence_data)
        elif isinstance(sequence_data, list) and len(sequence_data) > 0 and isinstance(sequence_data[0], SequenceData):
            seq_dat = sequence_data
        elif isinstance(sequence_data, dict):
            seq_dat = [SequenceData(seq_id=k, seq=v) for k, v in sequence_data.items()]
        else:
            raise ValueError(f"Invalid sequence data type: {type(sequence_data)}")

        if len(seq_dat) == 0:
            raise ValueError("No sequences found in input data")

        return seq_dat

    @staticmethod
    def visualize(sequence_data: Union[str, Dict[str, str], List[SequenceData]], save: bool = False) -> List[
        BiocentralChart]:
        """
        Visualize a given set of proteins. Automatically tries to find the best available visualization method(s).
        For more fine-grained visualizations, use the BiocentralChart class directly.

        :param sequence_data: Dict of {id: sequence} or path to a FASTA file.
        :param save: Whether to save generated svg files in the current working directory. Defaults to False.
        """
        seq_dat = Biocentral._parse_input_as_sequence_data(sequence_data)
        have_labels = any([data_point.label is not None for data_point in seq_dat])
        have_splits = any([data_point.set is not None for data_point in seq_dat])

        plots_to_generate = [("Sequence Length Distribution",
                              lambda sd: BiocentralChart.sequence_length_distribution(dataset=sd))]
        if have_labels:
            plots_to_generate.append(("Label Distribution",
                                      lambda sd: BiocentralChart.label_distribution(dataset=sd)),
                                     )
        if have_splits:
            plots_to_generate.append(("Splits Distribution",
                                      lambda sd: BiocentralChart.split_distribution(dataset=sd)))
        if have_labels and have_splits:
            plots_to_generate.append(("Label Distribution By Split",
                                      lambda sd: BiocentralChart.labels_by_split_distribution(dataset=sd)))

        plots: List[BiocentralChart] = []

        print(f"Generating plots for dataset of {len(seq_dat)} sequences..")
        for title, plotter in plots_to_generate:
            print(f"Generating plot: {title}")
            plot = plotter(seq_dat)
            plots.append(plot)

        if save:
            for plot in plots:
                plot.save(output_path=".")

        return plots

    def embed(
            self,
            embedder_name: str,
            sequence_data: Union[str, Dict[str, str], List[SequenceData]],
            reduce: bool = True,
            use_half_precision: bool = False,
    ) -> EmbeddingsResult:
        """Compute embeddings for the given sequences.

        :param embedder_name: Embedder identifier (e.g. "Rostlab/prot_t5_xl_uniref50").
        :param sequence_data: Dict of {id: sequence} or path to a FASTA file.
        :param reduce: Whether to reduce embeddings to per-sequence. Defaults to True.
        :param use_half_precision: Use half precision to reduce memory. Defaults to False.
        :return: EmbeddingsResult containing the computed embeddings.
        """
        seq_dat = self._parse_input_as_dict(sequence_data)

        return self._backend.embed(
            embedder_name, seq_dat, reduce=reduce, use_half_precision=use_half_precision
        )

    def train(
            self, config: Dict[str, Any], training_data: Union[str, List[SequenceData]]
    ) -> BiotrainerModelResult:
        """Train a model using biotrainer.

        :param config: Training configuration dict (must include "embedder_name" and "protocol").
        :param training_data: List of SequenceData objects for training or path to biotrainer fasta file.
        :return: BiotrainerModelResult with training results and model hash.
        """
        training_data = self._parse_input_as_sequence_data(training_data)
        return self._backend.train(config, training_data)

    def inference(
            self,
            model_result: Union[str, BiotrainerModelResult],
            inference_data: Union[str, Dict[str, str], List[SequenceData]],
    ) -> BiotrainerInferenceResult:
        """Run inference using a model trained via biotrainer, identified by its hash.

        :param model_result: Either hash of the trained model (from BiotrainerModelResult.derived_values.model_hash)
        or provide the BiotrainerModelResult directly.
        :param inference_data: Dict of {id: sequence} or path to a FASTA file.
        :return: BiotrainerInferenceResult with predictions.
        """
        inference_dat = self._parse_input_as_dict(inference_data)
        if isinstance(model_result, BiotrainerModelResult):
            model_hash = model_result.derived_values.model_hash
            if model_hash is None:
                raise ValueError(
                    "Model hash is None. Please provide a valid model hash or BiotrainerModelResult."
                )
        else:
            model_hash = model_result
        return self._backend.inference(model_hash, inference_dat)

    def project(
            self,
            embedder_name: str,
            method: str,
            sequence_data: Union[str, Dict[str, str], List[SequenceData]],
            projection_config: Dict[str, str],
    ) -> ProjectionResult:
        project_dat = self._parse_input_as_dict(sequence_data)

        return self._backend.project(
            embedder_name, method, project_dat, projection_config
        )

    def predict(
            self,
            model_names: List[str],
            sequence_data: Union[str, Dict[str, str], List[SequenceData]],
    ) -> Dict[str, List[Prediction]]:
        """Predict using pre-trained server-hosted models (API mode only).

        :param model_names: List of BiocentralPredictionModel names.
        :param sequence_data: Dict of {id: sequence} or path to a FASTA file.
        :return: Dict mapping model names to lists of Predictions.
        :raises NotAvailableError: If called in local mode.
        """
        predict_dat = self._parse_input_as_dict(sequence_data)

        return self._backend.predict(model_names, predict_dat)

    def cluster(
            self, sequence_data: Union[str, Dict[str, str], List[SequenceData]],
            sequence_identity_threshold: float = 0.3
    ) -> Dict[str, List[str]]:
        """
        Cluster sequences into groups based on sequence identity.

        :param sequence_data: Dict of {id: sequence} or path to a FASTA file.
        :param sequence_identity_threshold: Threshold for sequence identity.
        :return: Dict mapping sequence IDs to cluster IDs.
        """
        cluster_dat = self._parse_input_as_dict(sequence_data)

        if len(cluster_dat) <= 1:
            raise ValueError("At least two sequences are required for clustering!")

        return self._backend.cluster(cluster_dat, sequence_identity_threshold)
