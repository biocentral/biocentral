"""Tasks that pre-embed their input must report why loading the embeddings failed."""

from biotrainer_core.data_classes import SequenceData

from biocentral_server.server_management import PreEmbedMixin, TaskDTO


class TaskWithFailingEmbeddings(PreEmbedMixin):
    def run_subtask(self, subtask):
        yield TaskDTO.errored("Missing number of embeddings before loading: 3")


def test_loading_error_reaches_the_caller():
    error_dto, embeddings = TaskWithFailingEmbeddings()._pre_embed_with_db(
        embedder_name="facebook/esm2_t6_8M_UR50D",
        sequence_input=[SequenceData(seq_id="a", seq="MKTAYIAK")],
        reduced=True,
    )

    assert error_dto.error == "Missing number of embeddings before loading: 3"
    assert embeddings == []
