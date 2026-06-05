from pathlib import Path
from copy import deepcopy
from biotrainer.training import BiotrainerModel
from typing import Any, Dict, Callable, Optional, List, Tuple
from biotrainer_core.data_classes import SequenceData, Protocol

from ..server_management import (
    TaskInterface,
    TaskDTO,
    FileContextManager,
    EmbeddingDatabaseFactory,
    TrainingDTOObserver,
    TaskStatus,
    DeviceService,
    PreEmbedMixin,
)
from ..utils import get_logger

logger = get_logger(__name__)


def _config_with_presets(config_dict: dict):
    presets = get_config_presets()
    for k, v in presets.items():
        config_dict[k] = v
    return config_dict


def get_config_presets():
    return {
        "device": str(DeviceService.train_device()),
        "cross_validation_config": {"method": "hold_out"},
        "save_split_ids": False,
        "sanity_check": True,
        "ignore_file_inconsistencies": False,
        "disable_pytorch_compile": False,
        "auto_resume": False,
        "external_writer": "none",
        # "pretrained_model": None, TODO Improve biotrainer checking to set this (mutual exclusive)
    }


class BiotrainerTask(TaskInterface, PreEmbedMixin):
    def __init__(
        self,
        model_path: Path,
        config_dict: dict,
        training_data: List[SequenceData],
    ):
        super().__init__()
        self.model_path = model_path
        self.config_dict = _config_with_presets(config_dict)
        self.training_data = training_data

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        protocol = Protocol.from_string(self.config_dict["protocol"])
        reduced = protocol in Protocol.using_per_sequence_embeddings()

        file_context_manager = FileContextManager()
        with file_context_manager.storage_write_dynamic() as storage_writer:
            biotrainer_out_path = storage_writer.temp_dir
            # Set output dirs to temp dir
            self.config_dict["output_dir"] = str(biotrainer_out_path)
            embedder_name = self.config_dict["embedder_name"]

            error_dto, embeddings = self._pre_embed_with_db(
                embedder_name=embedder_name,
                sequence_input=self.training_data,
                reduced=reduced,
                update_dto_callback=update_dto_callback,
            )
            if error_dto:
                return error_dto

            # Add embeddings to input data (are read in biotrainer instead of embedding there)
            self.config_dict["input_data"] = embeddings
            config = deepcopy(self.config_dict)

            custom_observer = TrainingDTOObserver(
                update_dto_callback=update_dto_callback
            )

            biotrainer_result = BiotrainerModel().train(
                config=config,
                custom_output_observers=[custom_observer],
            )

            model_hash = biotrainer_result.derived_values.model_hash
            if model_hash is None:
                return TaskDTO.errored("Model hash not found after training!")

            # Save tmp dir to model hash directory
            new_path = self.model_path.parent
            storage_writer.set_file_path(file_path=new_path)
            logger.info(f"Saved trained model {model_hash} to {new_path}!")

        return TaskDTO(status=TaskStatus.FINISHED, biotrainer_result=biotrainer_result)

    def _pre_embed_with_db(
        self,
        embedder_name: str,
        sequence_input: List[SequenceData],
        reduced: bool,
        update_dto_callback: Optional[Callable] = None,
        custom_tokenizer_config: Optional[Dict[str, Any]] = None,
    ) -> Tuple[Optional[TaskDTO], List[SequenceData]]:
        if custom_tokenizer_config is None:
            custom_tokenizer_config = self.config_dict.get(
                "custom_tokenizer_config", None
            )

        error_dto, embeddings = super()._pre_embed_with_db(
            embedder_name=embedder_name,
            sequence_input=sequence_input,
            reduced=reduced,
            update_dto_callback=update_dto_callback,
            custom_tokenizer_config=custom_tokenizer_config,
        )

        if error_dto:
            return error_dto, []

        if ".onnx" in embedder_name:
            # TODO CHECK
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            hashed_embedder_name = embeddings_db.get_onnx_model_hash(embedder_name)
            self.config_dict["embedder_name"] = hashed_embedder_name
            self.config_dict.pop("custom_tokenizer_config")

        return None, embeddings


class BiotrainerTempTask(TaskInterface):
    """Task for training a model as a subtask in a temporary directory without saving the model"""

    def __init__(
        self,
        config_dict: dict,
        training_data_with_embeddings: List[SequenceData],
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

            biotrainer_result = BiotrainerModel().train(
                config=config,
                custom_output_observers=[custom_observer],
                write_to_file=False,
            )

        return TaskDTO(status=TaskStatus.FINISHED, biotrainer_result=biotrainer_result)
