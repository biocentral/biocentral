"""A failed save of computed embeddings must fail the loading task with its own error."""

import torch
from biotrainer_core.data_classes import SequenceData

import biocentral_server.embeddings.embed as embed
from biocentral_server.embeddings import LoadEmbeddingsTask
from biocentral_server.server_management import EmbeddingDatabaseFactory, TaskStatus


class FakeEmbeddingService:
    def generate_embeddings(self, records, reduced):
        for record in records:
            yield record.copy_with_embedding(torch.ones(4))


class DatabaseRejectingSaves:
    """Nothing is cached yet, and every save fails like a deadlocked transaction."""

    def filter_existing_embeddings(self, sequences, embedder_name, reduced):
        return {}, dict(sequences)

    def save_embeddings(self, embd_records, embedder_name, reduced):
        raise RuntimeError("deadlock detected")


def test_failed_save_fails_the_task_with_the_database_error(monkeypatch):
    monkeypatch.setattr(
        embed, "get_biotrainer_embedding_service", lambda **_: FakeEmbeddingService()
    )
    monkeypatch.setattr(
        embed.DeviceService, "embedding_device", staticmethod(lambda **_: "cpu")
    )
    monkeypatch.setattr(
        EmbeddingDatabaseFactory,
        "get_embeddings_db",
        lambda self: DatabaseRejectingSaves(),
    )

    task = LoadEmbeddingsTask(
        embedder_name="facebook/esm2_t6_8M_UR50D",
        sequence_input=[SequenceData(seq_id="a", seq="MKTAYIAK")],
        reduced=True,
        use_half_precision=False,
    )
    dto = task.run_task(update_dto_callback=lambda _: None)

    assert dto.status == TaskStatus.FAILED
    assert "deadlock detected" in dto.error
