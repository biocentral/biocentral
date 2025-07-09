import torch
from typing import List

from ..embedding_database import EmbeddingsDatabase

from biotrainer.protocols import Protocol
from biotrainer.utilities import get_logger
from biotrainer.trainers import DefaultPipeline
from biotrainer.trainers.pipeline import Pipeline, PipelineContext
from biotrainer.input_files import BiotrainerSequenceRecord, read_FASTA
from biotrainer.embedders import get_embedding_service, EmbeddingService
from biotrainer.trainers.pipeline.pipeline_step import PipelineStep, PipelineStepType

MOCK_CONFIG = {}

def get_custom_training_pipeline_memory(embedder_name: str) -> Pipeline:
    """ For in-memory embeddings: Calculate directly during pipeline """
    return (DefaultPipeline(config=MOCK_CONFIG)
            .with_custom_steps(custom_embedding_step=MemoryEmbeddingStep(embedder_name=embedder_name))
            .pipeline
            )


def get_custom_training_pipeline_injection(embeddings: List[BiotrainerSequenceRecord]) -> Pipeline:
    """ For Biotrainer: Directly inject all calculated embeddings """
    return (DefaultPipeline(config=MOCK_CONFIG)
            .with_custom_steps(custom_embedding_step=InjectionEmbeddingStep(embeddings=embeddings))
            .pipeline
            )


def get_custom_training_pipeline_loading(embedder_name: str, embeddings_db: EmbeddingsDatabase) -> Pipeline:
    """ For Autoeval: Only load relevant embeddings for task """
    return (DefaultPipeline(config=MOCK_CONFIG).with_custom_steps(
        custom_embedding_step=DatabaseLoadEmbeddingStep(embedder_name=embedder_name,
                                                        embeddings_db=embeddings_db)).pipeline
            )


class InjectionEmbeddingStep(PipelineStep):
    """ Direct injection from LoadEmbeddingsTask for BiotrainerTask """

    def __init__(self, embeddings: List[BiotrainerSequenceRecord]):
        self.embeddings = embeddings

    def get_step_type(self) -> PipelineStepType:
        return PipelineStepType.EMBEDDING

    def process(self, context: PipelineContext) -> PipelineContext:
        # Inject embeddings from LoadEmbeddingsTask directly into pipeline context
        # TODO Consider replacing with database loading step for reduced code
        context.id2emb = {embd_record.get_hash(): torch.tensor(embd_record.embedding)
                          for embd_record in self.embeddings}

        return context


class DatabaseLoadEmbeddingStep(PipelineStep):
    """ Loading from Database for Autoeval Task """

    def __init__(self, embedder_name: str, embeddings_db: EmbeddingsDatabase):
        self.embedder_name = embedder_name
        self.embeddings_db = embeddings_db

    def get_step_type(self) -> PipelineStepType:
        return PipelineStepType.EMBEDDING

    def process(self, context: PipelineContext) -> PipelineContext:
        input_file = context.config["input_file"]
        reduced = Protocol.from_string(context.config["protocol"]) in Protocol.using_per_sequence_embeddings()

        seq_records = read_FASTA(input_file)
        seq_dict = {seq_record.get_hash(): seq_record.seq for seq_record in seq_records}
        embeddings = self.embeddings_db.get_embeddings(sequences=seq_dict,
                                                       embedder_name=self.embedder_name,
                                                       reduced=reduced)
        context.id2emb = {embd_record.get_hash(): embd_record.seq for embd_record in embeddings}
        return context


class MemoryEmbeddingStep(PipelineStep):
    def __init__(self, embedder_name: str):
        self.embedder_name = embedder_name

    def get_step_type(self) -> PipelineStepType:
        return PipelineStepType.EMBEDDING

    def process(self, context: PipelineContext) -> PipelineContext:
        input_file = context.config["input_file"]
        reduced = context.config["protocol"] in Protocol.using_per_sequence_embeddings()

        seq_records = read_FASTA(input_file)

        embedding_service: EmbeddingService = get_embedding_service(embedder_name=self.embedder_name,
                                                                    custom_tokenizer_config=None,
                                                                    use_half_precision=False,
                                                                    device=torch.device("cpu"))

        embd_record_tuples = list(embedding_service.generate_embeddings(input_data=seq_records,
                                                                   reduce=reduced))

        logger = get_logger(__name__)
        logger.info(f"Calculated {len(embd_record_tuples)} embeddings for {self.embedder_name}")

        context.id2emb = {seq_record.get_hash(): torch.tensor(embd) for seq_record, embd in embd_record_tuples}
        return context
