"""Delta embeddings: each sequence's embedding minus the embedding of its wildtype.

Follows encode(mutant) - encode(wildtype) from
https://github.com/PaulSchwarze/rosetta_prediction, on the per-sequence (reduced) embeddings.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple

from biotrainer.embedding import BASELINE_EMBEDDERS
from biotrainer_core.data_classes import SequenceData

from ..server_management import TaskDTO

EmbeddingSubtaskWrapper = Callable[
    [List[SequenceData]], Tuple[Optional[TaskDTO], List[SequenceData]]
]

_BASELINE_EMBEDDERS = {name.lower() for name in BASELINE_EMBEDDERS}


def is_baseline_embedder(embedder_name: str) -> bool:
    """Whether the embedder is a biotrainer baseline rather than a protein language model."""
    return embedder_name.lower() in _BASELINE_EMBEDDERS


def with_delta_embeddings(
    embedding_subtask_wrapper: EmbeddingSubtaskWrapper, wildtype_sequence: str
) -> EmbeddingSubtaskWrapper:
    """Wrap an embedding subtask so it returns embeddings relative to the wildtype.

    The wildtype is embedded in the same request, so it goes through the same cache and
    embedder. It is only returned if it was one of the inputs, then as a zero vector.
    """
    wildtype = SequenceData(seq_id="delta_embeddings_wildtype", seq=wildtype_sequence)
    wildtype_hash = wildtype.get_hash()

    def embed(sequence_input: List[SequenceData]):
        wildtype_is_input = any(
            data_point.get_hash() == wildtype_hash for data_point in sequence_input
        )
        to_embed = sequence_input if wildtype_is_input else [*sequence_input, wildtype]

        error_dto, embedded = embedding_subtask_wrapper(to_embed)
        if error_dto:
            return error_dto, embedded

        wildtype_embedding = next(
            (
                data_point.embedding
                for data_point in embedded
                if data_point.get_hash() == wildtype_hash
            ),
            None,
        )
        if wildtype_embedding is None:
            return TaskDTO.errored(
                "Could not embed the wildtype for delta embeddings!"
            ), []
        return None, [
            data_point.copy_with_embedding(data_point.embedding - wildtype_embedding)
            for data_point in embedded
            if wildtype_is_input or data_point.get_hash() != wildtype_hash
        ]

    return embed
