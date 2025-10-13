from typing import Dict, List, Optional, Generator, Tuple
import asyncio
import numpy as np

from biotrainer.input_files import BiotrainerSequenceRecord
from biotrainer.embedders import get_embedding_service, EmbeddingService

from ..utils import get_logger
from ..server_management import (
    EmbeddingsDatabase,
    TritonClientConfig,
    TritonModelRouter,
    create_triton_repository,
)

logger = get_logger(__name__)


def compute_memory_encodings(
    embedder_name: str, all_seqs: Dict[str, str], reduced: bool
) -> List[BiotrainerSequenceRecord]:
    embedding_service: EmbeddingService = get_embedding_service(
        embedder_name=embedder_name,
        use_half_precision=False,
        custom_tokenizer_config=None,
        device="cpu",
    )
    embd_record_tuples = list(
        embedding_service.generate_embeddings(
            input_data=list(all_seqs.values()), reduce=reduced
        )
    )
    return [
        seq_record.copy_with_embedding(embd) for seq_record, embd in embd_record_tuples
    ]


async def compute_embeddings_triton(
    embedder_name: str,
    all_seqs: Dict[str, str],
    reduced: bool,
    embeddings_db: EmbeddingsDatabase = None,
) -> Generator[Tuple[int, int], None, None]:
    """
    Compute embeddings using Triton Inference Server and store them in the embedding database.

    :param embedder_name: Embedder name
    :param all_seqs: Dictionary of all sequences (seq_hash -> sequence)
    :param reduced: If per-sequence embeddings should be computed
    :param embeddings_db: Embeddings database
    :return: Yields number of computed embeddings
    """
    progress = 0
    total_seqs = len(all_seqs)

    # Filter existing embeddings
    existing_embds_seqs, non_existing_embds_seqs = (
        embeddings_db.filter_existing_embeddings(
            sequences=all_seqs, embedder_name=embedder_name, reduced=reduced
        )
    )
    n_non_existing = len(non_existing_embds_seqs)
    progress += len(existing_embds_seqs)
    logger.info(
        f"Loaded {progress} embeddings from database, "
        f"embedding other {n_non_existing} sequences via Triton.."
    )
    yield progress, total_seqs

    if n_non_existing > 0:
        # Get Triton model name
        triton_model = TritonModelRouter.get_embedding_model(embedder_name)
        if not triton_model:
            logger.warning(
                f"No Triton model found for embedder {embedder_name}, "
                f"falling back to biotrainer"
            )
            # Fall back to regular compute_embeddings
            for result in compute_embeddings(
                embedder_name=embedder_name,
                all_seqs=non_existing_embds_seqs,
                reduced=reduced,
                use_half_precision=False,
                device="cuda" if embeddings_db else "cpu",
                embeddings_db=embeddings_db,
            ):
                yield result
            return

        # Create Triton repository
        config = TritonClientConfig.from_env()
        triton_repo = create_triton_repository(config)

        try:
            # Connect to Triton
            await triton_repo.connect()

            # Process sequences in batches
            batch = []
            batch_hashes = []
            max_batch_size = min(config.triton_max_batch_size, 8)

            non_existing_items = list(non_existing_embds_seqs.items())

            for seq_hash, seq in non_existing_items:
                batch.append(seq)
                batch_hashes.append(seq_hash)

                if len(batch) >= max_batch_size:
                    # Compute embeddings via Triton
                    try:
                        embeddings = await triton_repo.compute_embeddings(
                            sequences=batch,
                            model_name=triton_model,
                            pooled=reduced,
                        )

                        # Create BiotrainerSequenceRecord objects
                        embd_records = [
                            BiotrainerSequenceRecord(
                                seq_id=seq_hash, seq=seq
                            ).copy_with_embedding(embedding)
                            for seq_hash, seq, embedding in zip(
                                batch_hashes, batch, embeddings
                            )
                        ]

                        # Save to database
                        embeddings_db.save_embeddings(
                            embd_records=embd_records,
                            embedder_name=embedder_name,
                            reduced=reduced,
                        )

                        progress += len(batch)
                        logger.info(f"Embedding progress: {progress} / {total_seqs}")
                        yield progress, total_seqs

                    except Exception as e:
                        logger.error(f"Triton inference failed: {e}, falling back to biotrainer")
                        # Fall back to biotrainer for this batch
                        _compute_embeddings_biotrainer_batch(
                            embedder_name=embedder_name,
                            sequences={h: s for h, s in zip(batch_hashes, batch)},
                            reduced=reduced,
                            embeddings_db=embeddings_db,
                        )
                        progress += len(batch)
                        yield progress, total_seqs

                    batch = []
                    batch_hashes = []

            # Process remaining sequences
            if batch:
                try:
                    embeddings = await triton_repo.compute_embeddings(
                        sequences=batch,
                        model_name=triton_model,
                        pooled=reduced,
                    )

                    embd_records = [
                        BiotrainerSequenceRecord(
                            seq_id=seq_hash, seq=seq
                        ).copy_with_embedding(embedding)
                        for seq_hash, seq, embedding in zip(
                            batch_hashes, batch, embeddings
                        )
                    ]

                    embeddings_db.save_embeddings(
                        embd_records=embd_records,
                        embedder_name=embedder_name,
                        reduced=reduced,
                    )

                    progress += len(batch)
                    logger.info(f"Embedding progress: {progress} / {total_seqs}")
                    yield progress, total_seqs

                except Exception as e:
                    logger.error(f"Triton inference failed: {e}, falling back to biotrainer")
                    _compute_embeddings_biotrainer_batch(
                        embedder_name=embedder_name,
                        sequences={h: s for h, s in zip(batch_hashes, batch)},
                        reduced=reduced,
                        embeddings_db=embeddings_db,
                    )
                    progress += len(batch)
                    yield progress, total_seqs

        finally:
            # Always disconnect
            await triton_repo.disconnect()

    else:
        logger.debug(f"All {len(existing_embds_seqs)} embeddings already computed!")


def _compute_embeddings_biotrainer_batch(
    embedder_name: str,
    sequences: Dict[str, str],
    reduced: bool,
    embeddings_db: EmbeddingsDatabase,
) -> None:
    """
    Helper function to compute embeddings using biotrainer for a batch of sequences.

    :param embedder_name: Embedder name
    :param sequences: Dictionary of sequences (seq_hash -> sequence)
    :param reduced: If per-sequence embeddings should be computed
    :param embeddings_db: Embeddings database
    """
    embedding_service: EmbeddingService = get_embedding_service(
        embedder_name=embedder_name,
        use_half_precision=False,
        custom_tokenizer_config=None,
        device="cpu",
    )

    seq_records = [
        BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
        for seq_id, seq in sequences.items()
    ]

    for seq_record, embedding in embedding_service.generate_embeddings(
        seq_records, reduced
    ):
        embd_record = seq_record.copy_with_embedding(embedding)
        embeddings_db.save_embeddings(
            embd_records=[embd_record],
            embedder_name=embedder_name,
            reduced=reduced,
        )


def compute_embeddings(
    embedder_name: str,
    all_seqs: Dict[str, str],
    reduced: bool,
    use_half_precision: bool,
    device,
    custom_tokenizer_config: Optional[str] = None,
    embeddings_db: EmbeddingsDatabase = None,
    use_triton: Optional[bool] = None,
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
    :param use_triton: Whether to use Triton (if None, checks environment)
    :return: Yields number of computed embeddings
    """
    # Check if Triton should be used
    if use_triton is None:
        config = TritonClientConfig.from_env()
        use_triton = config.is_enabled()

    # Try Triton first if enabled and model is available
    if use_triton and TritonModelRouter.is_triton_embedding_available(embedder_name):
        logger.info(f"Using Triton for embeddings: {embedder_name}")
        try:
            # Run async function in event loop
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                generator = compute_embeddings_triton(
                    embedder_name=embedder_name,
                    all_seqs=all_seqs,
                    reduced=reduced,
                    embeddings_db=embeddings_db,
                )
                # Convert async generator to sync generator
                while True:
                    try:
                        result = loop.run_until_complete(generator.__anext__())
                        yield result
                    except StopAsyncIteration:
                        break
            finally:
                loop.close()
            return
        except Exception as e:
            logger.warning(
                f"Triton embedding failed: {e}, falling back to biotrainer"
            )
            # Fall through to biotrainer implementation

    # Use biotrainer (original implementation)
    progress = 0
    total_seqs = len(all_seqs)
    # TODO [Optimization] Ensure that sequences are actually unique at this step?
    # TODO [Optimization] If per-residue embeddings exist, but per-sequence embeddings not and are required,
    #  directly calculate them
    existing_embds_seqs, non_existing_embds_seqs = (
        embeddings_db.filter_existing_embeddings(
            sequences=all_seqs, embedder_name=embedder_name, reduced=reduced
        )
    )
    n_non_existing = len(non_existing_embds_seqs)
    progress += len(existing_embds_seqs)
    logger.info(
        f"Loaded {progress} embeddings from database, "
        f"embedding other {n_non_existing} sequences.."
    )
    yield progress, total_seqs

    if n_non_existing > 0:
        embedding_service: EmbeddingService = get_embedding_service(
            embedder_name=embedder_name,
            custom_tokenizer_config=custom_tokenizer_config,
            use_half_precision=use_half_precision,
            device=device,
        )
        non_existing_records = [
            BiotrainerSequenceRecord(seq_id=seq_id, seq=seq)
            for seq_id, seq in non_existing_embds_seqs.items()
        ]

        # Store to database in batches
        batch = []
        max_batch_size = 50

        for seq_record, embedding in embedding_service.generate_embeddings(
            non_existing_records, reduced
        ):
            batch.append(seq_record.copy_with_embedding(embedding))
            if len(batch) >= max_batch_size:
                embeddings_db.save_embeddings(
                    embd_records=batch, embedder_name=embedder_name, reduced=reduced
                )
                progress += len(batch)
                logger.info(f"Embedding progress: {progress} / {total_seqs}")
                yield progress, total_seqs

                batch = []

        # Save remaining embeddings
        if batch:
            embeddings_db.save_embeddings(
                embd_records=batch, embedder_name=embedder_name, reduced=reduced
            )
            progress += len(batch)

            logger.info(f"Embedding progress: {progress} / {total_seqs}")
            del batch
            yield progress, total_seqs
    else:
        logger.debug(f"All {len(existing_embds_seqs)} embeddings already computed!")
