import logging
import tempfile
from pathlib import Path
from typing import Dict, List, Optional

from biotrainer.protocols import Protocol

from ..server_management import EmbeddingsDatabaseTriple, EmbeddingsDatabase, get_adapter_embedding_service

logger = logging.getLogger(__name__)


def _load_embeddings(embedding_service, all_seqs: Dict[str, str], embeddings_file_path: Path) -> List[
    EmbeddingsDatabaseTriple]:
    loaded_embeddings = embedding_service.load_embeddings(str(embeddings_file_path))
    return EmbeddingsDatabase.unify_seqs_with_embeddings(seqs=all_seqs, embds=loaded_embeddings)


def compute_one_hot_encodings(all_seqs: Dict[str, str], reduced: bool) -> List[EmbeddingsDatabaseTriple]:
    # OHEs are not stored, tmpdir is only necessary for compatibility with biotrainer
    with tempfile.TemporaryDirectory() as tmpdir:
        reduced_by_protocol = Protocol.using_per_sequence_embeddings()[0] if reduced \
            else Protocol.using_per_residue_embeddings()[0]

        embedding_service = get_adapter_embedding_service(embedder_name="one_hot_encoding",
                                                          embeddings_file_path=None,
                                                          use_half_precision=False,
                                                          device="cpu",
                                                          embeddings_db=None,
                                                          sequence_dict=all_seqs,
                                                          reduced=reduced)
        embeddings_file_path = embedding_service.compute_embeddings(input_data=all_seqs,
                                                                    output_dir=Path(tmpdir),
                                                                    protocol=reduced_by_protocol,
                                                                    force_output_dir=True)
    return _load_embeddings(embedding_service, all_seqs, Path(embeddings_file_path))


def compute_embeddings(embedder_name: str,
                       all_seqs: Dict[str, str],
                       reduced: bool,
                       use_half_precision: bool,
                       device,
                       embeddings_db: EmbeddingsDatabase = None,
                       ):
    reduced_by_protocol = Protocol.using_per_sequence_embeddings()[0] if reduced \
        else Protocol.using_per_residue_embeddings()[0]

    # TODO [Optimization] If per-residue embeddings exist, but per-sequence embeddings not and are required,
    #  directly calculate them
    existing_embds_seqs, non_existing_embds_seqs = embeddings_db.filter_existing_embeddings(sequences=all_seqs,
                                                                                            embedder_name=embedder_name,
                                                                                            reduced=reduced)
    if len(non_existing_embds_seqs) > 0:
        # Embeddings are not stored as h5, tmpdir is only necessary for compatibility with biotrainer
        with tempfile.TemporaryDirectory() as tmpdir:
            embedding_service = get_adapter_embedding_service(embedder_name=embedder_name,
                                                              embeddings_file_path=None,
                                                              use_half_precision=use_half_precision,
                                                              device=device,
                                                              embeddings_db=embeddings_db,
                                                              sequence_dict=all_seqs,
                                                              reduced=reduced)
            _ = embedding_service.compute_embeddings(input_data=non_existing_embds_seqs,
                                                     output_dir=Path(tmpdir),
                                                     protocol=reduced_by_protocol,
                                                     force_output_dir=True)
    else:
        logger.debug(f"All {len(existing_embds_seqs)} embeddings already computed!")
