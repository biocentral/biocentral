from pathlib import Path
from copy import deepcopy
from biotrainer.protocols import Protocol
from typing import Callable, Optional, List, Tuple
from biotrainer.input_files import BiotrainerSequenceRecord
from biotrainer.utilities.executer import parse_config_file_and_execute_run

from .endpoint_models import SequenceTrainingData
from ..embeddings import LoadEmbeddingsTask
from ..server_management import (
    TaskInterface,
    TaskDTO,
    FileContextManager,
    EmbeddingDatabaseFactory,
    TrainingDTOObserver,
    TaskStatus,
)


def _config_with_presets(config_dict: dict):
    presets = get_config_presets()
    for k, v in presets.items():
        config_dict[k] = v
    return config_dict


def get_config_presets():
    return {
        "device": "cuda",  # TODO Device Management
        "cross_validation_config": {"method": "hold_out"},
        "save_split_ids": False,
        "sanity_check": True,
        "ignore_file_inconsistencies": False,
        "disable_pytorch_compile": False,
        "auto_resume": False,
        "external_writer": "none",
        # "pretrained_model": None, TODO Improve biotrainer checking to set this (mutual exclusive)
    }


class BiotrainerTask(TaskInterface):
    def __init__(
        self,
        model_path: Path,
        config_dict: dict,
        training_data: List[SequenceTrainingData],
    ):
        super().__init__()
        self.model_path = model_path
        self.config_dict = _config_with_presets(config_dict)
        self.training_data = training_data

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        sequence_records = [
            seq_train_data.to_biotrainer_seq_record()
            for seq_train_data in self.training_data
        ]

        protocol = Protocol.from_string(self.config_dict["protocol"])
        reduced = protocol in Protocol.using_per_sequence_embeddings()

        file_context_manager = FileContextManager()
        with file_context_manager.storage_write_dynamic() as storage_writer:
            biotrainer_out_path = storage_writer.temp_dir
            # Set output dirs to temp dir
            self.config_dict["output_dir"] = str(biotrainer_out_path)

            error_dto, embeddings = self._pre_embed_with_db(
                all_seqs=sequence_records,
                reduced=reduced,
                update_dto_callback=update_dto_callback,
            )
            if error_dto:
                return error_dto

            # Add embeddings to input data (are read in biotrainer instead of embedding there)
            embd_dict = {
                embd_record.get_hash(): embd_record.embedding
                for embd_record in embeddings
            }
            embd_records = [
                seq_record.copy_with_embedding(
                    embedding=embd_dict[seq_record.get_hash()]
                )
                for seq_record in sequence_records
            ]
            self.config_dict["input_data"] = embd_records
            config = deepcopy(self.config_dict)

            custom_observer = TrainingDTOObserver(
                update_dto_callback=update_dto_callback
            )

            result_dict = parse_config_file_and_execute_run(
                config=config,
                custom_output_observers=[custom_observer],
            )

            model_hash = result_dict.get("derived_values", {}).get("model_hash", None)
            if model_hash is None:
                return TaskDTO(
                    status=TaskStatus.FAILED,
                    error="Model hash not found after training!",
                )

            # Save tmp dir to model hash directory
            new_path = self.model_path.parent / model_hash
            storage_writer.set_file_path(file_path=new_path)

        return TaskDTO(status=TaskStatus.FINISHED, biotrainer_result=result_dict)

    def _pre_embed_with_db(
        self,
        all_seqs: List[BiotrainerSequenceRecord],
        reduced: bool,
        update_dto_callback: Callable,
    ) -> Tuple[Optional[TaskDTO], List[BiotrainerSequenceRecord]]:
        embedder_name = self.config_dict["embedder_name"]
        custom_tokenizer_config = self.config_dict.get("custom_tokenizer_config", None)
        device = self.config_dict.get("device", None)

        load_embedding_task = LoadEmbeddingsTask(
            embedder_name=embedder_name,
            custom_tokenizer_config=custom_tokenizer_config,
            sequence_input=all_seqs,
            reduced=reduced,
            use_half_precision=False,
            device=device,
        )
        load_dto: Optional[TaskDTO] = None
        for current_dto in self.run_subtask(load_embedding_task):
            load_dto = current_dto
            if load_dto.embedding_progress is not None:
                update_dto_callback(load_dto)

        if not load_dto:
            return TaskDTO(
                status=TaskStatus.FAILED, error="Could not compute embeddings!"
            ), []

        if ".onnx" in embedder_name:
            # TODO CHECK
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            hashed_embedder_name = embeddings_db.get_onnx_model_hash(embedder_name)
            self.config_dict["embedder_name"] = hashed_embedder_name
            self.config_dict.pop("custom_tokenizer_config")

        embeddings: List[BiotrainerSequenceRecord] = load_dto.embeddings
        if len(embeddings) == 0:
            return TaskDTO(
                status=TaskStatus.FAILED,
                error="Did not receive embeddings for training!",
            ), []

        return None, embeddings


class BiotrainerTempTask(TaskInterface):
    """Task for training a model as a subtask in a temporary directory without saving the model"""

    def __init__(
        self,
        config_dict: dict,
        training_data_with_embeddings: List[BiotrainerSequenceRecord],
    ):
        super().__init__()
        self.config_dict = _config_with_presets(config_dict)
        self.training_data_with_embeddings = training_data_with_embeddings

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        file_context_manager = FileContextManager()
        with file_context_manager.temp_dir() as temp_dir:
            # Set output dirs to temp dir
            self.config_dict["output_dir"] = temp_dir
            self.config_dict["input_data"] = self.training_data_with_embeddings
            config = deepcopy(self.config_dict)

            custom_observer = TrainingDTOObserver(
                update_dto_callback=update_dto_callback
            )

            result_dict = parse_config_file_and_execute_run(
                config=config,
                custom_output_observers=[custom_observer],
                write_to_file=False,
            )

        return TaskDTO(status=TaskStatus.FINISHED, biotrainer_result=result_dict)
