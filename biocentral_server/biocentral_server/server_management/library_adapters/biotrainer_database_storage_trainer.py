from pathlib import Path
from typing import Dict, Union, Optional, Any

from biotrainer.trainers import Trainer
from biotrainer.protocols import Protocol

from .biotrainer_embedding_adapter import get_adapter_embedding_service

from ..embedding_database import EmbeddingsDatabase


class BiotrainerDatabaseStorageTrainer(Trainer):
    """
    A Trainer subclass that uses database storage for embeddings.
    """

    def __init__(self, embeddings_db: EmbeddingsDatabase, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.embeddings_db = embeddings_db
        # Extract sequences from sequence file for later use
        from Bio import SeqIO
        self.sequences = {
            seq.id: str(seq.seq)
            for seq in SeqIO.parse(self._sequence_file, "fasta")
        }

    def _create_and_load_embeddings(self) -> Dict[str, Any]:
        """
        Overrides the embedding creation/loading to use database storage.
        """
        embeddings_file = self._embeddings_file
        reduced = self._protocol in Protocol.using_per_sequence_embeddings()

        # Use adapter embedding service
        embedding_service = get_adapter_embedding_service(
            embeddings_file_path=embeddings_file,
            embedder_name=self._embedder_name,
            use_half_precision=self._use_half_precision,
            device=self._device,
            embeddings_db=self.embeddings_db,
            sequence_dict=self.sequences,
            reduced=reduced
        )

        if self._embedder_name == "one_hot_encoding":
            # Only calculate OHEs in biotrainer at the moment, all other embeddings are pre-calculated
            embeddings_file = embedding_service.compute_embeddings(
                input_data=self._sequence_file,
                protocol=self._protocol,
                output_dir=self._output_dir
            )

        # Get embeddings from database or file
        id2emb = embedding_service.load_embeddings(embeddings_file_path=embeddings_file)

        if self._is_dimension_reduction_possible(id2emb):
            id2emb = embedding_service.embeddings_dimensionality_reduction(
                embeddings=id2emb,
                dimension_reduction_method=self._dimension_reduction_method,
                n_reduced_components=self._n_reduced_components
            )

        return id2emb