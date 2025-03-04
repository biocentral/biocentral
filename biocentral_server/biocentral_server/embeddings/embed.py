import logging
from pathlib import Path
from typing import Dict, List, Union

from flask import current_app
from biotrainer.protocols import Protocol
from biotrainer.embedders import get_embedding_service, EmbeddingService

from ..server_management import EmbeddingsDatabaseTriple, EmbeddingsDatabase

logger = logging.getLogger(__name__)


def _compute_embeddings(embedder_name: str,
                        all_seqs: Dict[str, str],
                        embeddings_out_path: Path,
                        reduce_by_protocol: Protocol,
                        use_half_precision: bool,
                        device) -> Path:
    embedding_service = get_embedding_service(embedder_name=embedder_name, embeddings_file_path=None,
                                              use_half_precision=use_half_precision, device=device)
    embeddings_file_path = embedding_service.compute_embeddings(input_data=all_seqs, output_dir=embeddings_out_path,
                                                                protocol=reduce_by_protocol, force_output_dir=True)
    return Path(embeddings_file_path)


def _load_embeddings(all_seqs: Dict[str, str], embeddings_file_path: Path) -> List[EmbeddingsDatabaseTriple]:
    loaded_embeddings = EmbeddingService.load_embeddings(str(embeddings_file_path))
    return EmbeddingsDatabase.unify_seqs_with_embeddings(seqs=all_seqs, embds=loaded_embeddings)


def compute_embeddings_and_save_to_db(embedder_name: str,
                                      all_seqs: Dict[str, str],
                                      embeddings_out_path: Path,
                                      reduce_by_protocol: Union[Protocol, str],
                                      use_half_precision: bool,
                                      device,
                                      embeddings_db: EmbeddingsDatabase = None) -> Path:
    if isinstance(reduce_by_protocol, str):
        reduce_by_protocol = Protocol.from_string(reduce_by_protocol)

    # List of embedder names that should not be saved in the database
    EXCLUDED_EMBEDDERS = ['one_hot_encoding']
    if embedder_name in EXCLUDED_EMBEDDERS:
        final_h5_path = _compute_embeddings(embedder_name=embedder_name,
                                            all_seqs=all_seqs,
                                            embeddings_out_path=embeddings_out_path,
                                            reduce_by_protocol=reduce_by_protocol,
                                            use_half_precision=use_half_precision,
                                            device=device)
        return final_h5_path

    # Compute with saving
    reduce = reduce_by_protocol in Protocol.per_sequence_protocols()

    # TODO [Optimization] If per-residue embeddings exist, but per-sequence embeddings not and are required,
    #  directly calculate them

    existing_embds_seqs, non_existing_embds_seqs = embeddings_db.filter_existing_embeddings(sequences=all_seqs,
                                                                                            embedder_name=embedder_name,
                                                                                            reduced=reduce)

    if len(non_existing_embds_seqs) > 0:
        h5_path = _compute_embeddings(embedder_name=embedder_name,
                                      all_seqs=non_existing_embds_seqs,
                                      embeddings_out_path=embeddings_out_path,
                                      reduce_by_protocol=reduce_by_protocol,
                                      use_half_precision=use_half_precision,
                                      device=device)
        computed_embeddings_triples = _load_embeddings(all_seqs=non_existing_embds_seqs, embeddings_file_path=h5_path)

        existing_embds = embeddings_db.get_embeddings(sequences=existing_embds_seqs, embedder_name=embedder_name,
                                                      reduced=reduce)
        embeddings_db.save_embeddings(ids_seqs_embds=computed_embeddings_triples, embedder_name=embedder_name,
                                      reduced=reduce)
        final_h5_path = embeddings_db.append_to_hdf5(triples=existing_embds,
                                                     existing_embeddings_path=embeddings_out_path)
        return final_h5_path

    else:
        logger.debug(f"All {len(existing_embds_seqs)} embeddings already computed!")
        existing_embds = embeddings_db.get_embeddings(sequences=existing_embds_seqs, embedder_name=embedder_name,
                                                      reduced=reduce)
        final_h5_path = embeddings_db.export_embedding_triples_to_hdf5(triples=existing_embds,
                                                                       output_path=embeddings_out_path)
        return final_h5_path
