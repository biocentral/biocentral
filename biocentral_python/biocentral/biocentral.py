from __future__ import annotations

from typing import Dict, Any, List, Optional, Union

from biocentral_api import BiotrainerModelResult, BiotrainerInferenceResult, Prediction, BiocentralAPI, SequenceData, ProjectionResult
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

    def __init__(self,
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
            self._backend: BiocentralBackend = APIBackend(custom_api=custom_api,)
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
    def _handle_sequence_data_input(sequence_data: Union[str, Dict[str, str], List[SequenceData]]) -> Dict[str, str]:
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

    def embed(self,
              embedder_name: str,
              sequence_data: Union[str, Dict[str, str], List[SequenceData]],
              reduce: bool = True,
              use_half_precision: bool = False) -> EmbeddingsResult:
        """Compute embeddings for the given sequences.

        :param embedder_name: Embedder identifier (e.g. "Rostlab/prot_t5_xl_uniref50").
        :param sequence_data: Dict of {id: sequence} or path to a FASTA file.
        :param reduce: Whether to reduce embeddings to per-sequence. Defaults to True.
        :param use_half_precision: Use half precision to reduce memory. Defaults to False.
        :return: EmbeddingsResult containing the computed embeddings.
        """
        seq_dat = self._handle_sequence_data_input(sequence_data)

        return self._backend.embed(embedder_name, seq_dat,
                                   reduce=reduce, use_half_precision=use_half_precision)

    def train(self,
              config: Dict[str, Any],
              training_data: Union[str, List[SequenceData]]) -> BiotrainerModelResult:
        """Train a model using biotrainer.

        :param config: Training configuration dict (must include "embedder_name" and "protocol").
        :param training_data: List of SequenceData objects for training or path to biotrainer fasta file.
        :return: BiotrainerModelResult with training results and model hash.
        """
        if isinstance(training_data, str):
            training_data = self._read_fasta(training_data)
        return self._backend.train(config, training_data)

    def inference(self,
                  model_result: Union[str, BiotrainerModelResult],
                  inference_data: Union[str, Dict[str, str], List[SequenceData]]) -> BiotrainerInferenceResult:
        """Run inference using a model trained via biotrainer, identified by its hash.

        :param model_result: Either hash of the trained model (from BiotrainerModelResult.derived_values.model_hash)
        or provide the BiotrainerModelResult directly.
        :param inference_data: Dict of {id: sequence} or path to a FASTA file.
        :return: BiotrainerInferenceResult with predictions.
        """
        inference_dat = self._handle_sequence_data_input(inference_data)
        if isinstance(model_result, BiotrainerModelResult):
            model_hash = model_result.derived_values.model_hash
            if model_hash is None:
                raise ValueError("Model hash is None. Please provide a valid model hash or BiotrainerModelResult.")
        else:
            model_hash = model_result
        return self._backend.inference(model_hash, inference_dat)

    def project(self,
                embedder_name: str,
                method: str,
                sequence_data: Union[str, Dict[str, str], List[SequenceData]],
                projection_config: Dict[str, str]) -> ProjectionResult:
        project_dat = self._handle_sequence_data_input(sequence_data)

        return self._backend.project(embedder_name, method, project_dat, projection_config)

    def predict(self,
                model_names: List[str],
                sequence_data: Union[str, Dict[str, str], List[SequenceData]]) -> Dict[str, List[Prediction]]:
        """Predict using pre-trained server-hosted models (API mode only).

        :param model_names: List of BiocentralPredictionModel names.
        :param sequence_data: Dict of {id: sequence} or path to a FASTA file.
        :return: Dict mapping model names to lists of Predictions.
        :raises NotAvailableError: If called in local mode.
        """
        predict_dat = self._handle_sequence_data_input(sequence_data)

        return self._backend.predict(model_names, predict_dat)
