"""Check that candidate identities survive embedding and batch selection."""

from types import SimpleNamespace

from biotrainer_core.data_classes import SequenceData

from biocentral_server.active_learning.pipelines.protein_engineering.steps.embedding_step import (
    EmbeddingStep,
)
from biocentral_server.active_learning.pipelines.al_shared.steps.batch_selection_step import (
    BatchSelectionStep,
)
from biocentral_server.server_management.shared_endpoint_models.al_result import (
    ActiveLearningResult,
)


def test_embedding_preserves_resolvable_ids_and_training_labels():
    def embed(records):
        # Embedders may return records in a different order.
        return None, [record.model_copy(update={"embedding": [1.0, 2.0]}) for record in reversed(records)]

    context = SimpleNamespace(
        base_sequences=["VCDE"],
        mutations=["VFDE", "VCDA"],
        al_training_data=[
            SequenceData(seq_id="wt", seq="ACDE", label="1.0"),
            SequenceData(seq_id="parent", seq="VCDE", label="2.0"),
        ],
        embedding_subtask_wrapper=embed,
    )
    result = EmbeddingStep()._execute(context)
    assert {key: value.seq for key, value in result.inference_data.items()} == {"C2F": "VFDE", "E4A": "VCDA"}
    assert result.training_data["wt"].label == "1.0"
    assert result.training_data["parent"].label == "2.0"

    scored = [
        ActiveLearningResult(entity_id=key, prediction="1.0", uncertainty=0.1, score=score)
        for key, score in [("C2F", 0.2), ("E4A", 0.8)]
    ]
    _, suggestions = BatchSelectionStep._batch_selection(scored, 1)
    assert suggestions == ["E4A"]
