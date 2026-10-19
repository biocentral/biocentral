"""Computed embeddings must be stored under the name they are later looked up by."""

import torch
from biotrainer_core.data_classes import SequenceData

import biocentral_server.embeddings.embed as embed


class FakeEmbeddingService:
    def generate_embeddings(self, records, reduced):
        for record in records:
            yield record.copy_with_embedding(torch.ones(4))


class RecordingDatabase:
    """Nothing is cached yet; remembers the embedder name of every save."""

    def __init__(self):
        self.saved_under = []

    def filter_existing_embeddings(self, sequences, embedder_name, reduced):
        return {}, dict(sequences)

    def save_embeddings(self, embd_records, embedder_name, reduced):
        self.saved_under.extend([embedder_name] * len(embd_records))


def test_half_precision_embeddings_are_all_saved_under_the_half_name(monkeypatch):
    monkeypatch.setattr(
        embed, "get_biotrainer_embedding_service", lambda **_: FakeEmbeddingService()
    )
    monkeypatch.setattr(
        embed.DeviceService, "embedding_device", staticmethod(lambda **_: "cpu")
    )
    # More than one full batch of 50, so both save paths run
    records = [
        SequenceData(seq_id=f"s{i}", seq="MKTAYIAK" + "A" * i) for i in range(60)
    ]
    database = RecordingDatabase()

    for _ in embed.compute_embeddings(
        embedder_name="facebook/esm2_t6_8M_UR50D",
        all_seqs={record.get_hash(): record.seq for record in records},
        reduced=True,
        use_half_precision=True,
        embeddings_db=database,
    ):
        pass

    assert len(database.saved_under) == 60
    assert set(database.saved_under) == {"facebook/esm2_t6_8M_UR50D-half"}
