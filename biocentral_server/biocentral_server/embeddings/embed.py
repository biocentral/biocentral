from typing import Dict, List, Optional, Generator, Tuple

from biotrainer.input_files import BiotrainerSequenceRecord
from biotrainer.embedders import get_embedding_service, EmbeddingService

from ..utils import get_logger
from ..server_management import EmbeddingsDatabase

logger = get_logger(__name__)


def compute_memory_encodings(embedder_name: str, all_seqs: Dict[str, str], reduced: bool) -> List[
    BiotrainerSequenceRecord]:

    embedding_service: EmbeddingService = get_embedding_service(embedder_name=embedder_name,
                                                                use_half_precision=False,
                                                                custom_tokenizer_config=None,
                                                                device="cpu"
                                                                )
    embd_record_tuples = list(embedding_service.generate_embeddings(input_data=list(all_seqs.values()),
                                                                    reduce=reduced))
    return [seq_record.copy_with_embedding(embd) for seq_record, embd in embd_record_tuples]


def compute_embeddings(embedder_name: str,
                       all_seqs: Dict[str, str],
                       reduced: bool,
                       use_half_precision: bool,
                       device,
                       custom_tokenizer_config: Optional[str] = None,
                       embeddings_db: EmbeddingsDatabase = None,
                       ) -> Generator[Tuple[int, int], None, None]:
    """
    Compute embeddings for all provided sequences and store them in the embedding database. Yields the number of
    embeddings computed (i.e. the progress).

    :param embedder_name: Embedder name
    :param all_seqs: Dictionary of all sequences (seq_hash -> sequence)
    :param reduced: If per-sequence embeddings should be computed
    :param use_half_precision: Use half-precision mode for embedding calculation
    :param device: Device to use
    :param custom_tokenizer_config: Custom tokenizer configuration (for onnx)
    :param embeddings_db: Embeddings database
    :return: Yields number of computed embeddings
    """
    progress = 0
    total_seqs = len(all_seqs)
    # TODO [Optimization] Ensure that sequences are actually unique at this step?
    # TODO [Optimization] If per-residue embeddings exist, but per-sequence embeddings not and are required,
    #  directly calculate them
    existing_embds_seqs, non_existing_embds_seqs = embeddings_db.filter_existing_embeddings(sequences=all_seqs,
                                                                                            embedder_name=embedder_name,
                                                                                            reduced=reduced)
    n_non_existing = len(non_existing_embds_seqs)
    progress += len(existing_embds_seqs)
    logger.info(f"Loaded {progress} embeddings from database, "
                f"embedding other {n_non_existing} sequences..")
    yield progress, total_seqs

    if n_non_existing > 0:
        embedding_service: EmbeddingService = get_embedding_service(embedder_name=embedder_name,
                                                                    custom_tokenizer_config=custom_tokenizer_config,
                                                                    use_half_precision=use_half_precision,
                                                                    device=device
                                                                    )
        non_existing_records = [BiotrainerSequenceRecord(seq_id=seq_id,
                                                         seq=seq) for seq_id, seq in non_existing_embds_seqs.items()]

        # Store to database in batches
        batch = []
        max_batch_size = 50

        for seq_record, embedding in embedding_service.generate_embeddings(non_existing_records, reduced):
            batch.append(seq_record.copy_with_embedding(embedding))
            if len(batch) >= max_batch_size:
                embeddings_db.save_embeddings(embd_records=batch,
                                              embedder_name=embedder_name,
                                              reduced=reduced)
                progress += len(batch)
                logger.info(f"Embedding progress: {progress} / {total_seqs}")
                yield progress, total_seqs

                batch = []

        # Save remaining embeddings
        if batch:
            embeddings_db.save_embeddings(embd_records=batch,
                                          embedder_name=embedder_name,
                                          reduced=reduced)
            progress += len(batch)

            logger.info(f"Embedding progress: {progress} / {total_seqs}")
            del batch
            yield progress, total_seqs
    else:
        logger.debug(f"All {len(existing_embds_seqs)} embeddings already computed!")
