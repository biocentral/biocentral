import os
import time

from pathlib import Path
from copy import deepcopy
from biotrainer.protocols import Protocol
from typing import Callable, Optional, Dict, List
from biotrainer.input_files import read_FASTA, BiotrainerSequenceRecord
from biotrainer.utilities.executer import parse_config_file_and_execute_run

from ..embeddings import LoadEmbeddingsTask
from ..server_management import TaskInterface, TaskDTO, FileContextManager, EmbeddingDatabaseFactory, \
    TrainingDTOObserver, get_custom_training_pipeline_injection


class BiotrainerTask(TaskInterface):

    def __init__(self, model_path: Path, config_dict: dict):
        super().__init__()
        self.model_path = model_path
        self.config_dict = self._config_with_presets(config_dict)
        self.stop_reading = False
        self._last_read_position_in_log_file = 0

    @staticmethod
    def _config_with_presets(config_dict: dict):
        presets = BiotrainerTask.get_config_presets()
        for k, v in presets.items():
            config_dict[k] = v
        return config_dict

    @staticmethod
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

    @staticmethod
    def _read_seqs(server_input_file_path) -> List[BiotrainerSequenceRecord]:
        file_context_manager = FileContextManager()
        with file_context_manager.storage_read(server_input_file_path) as seq_file_path:
            all_seq_records = read_FASTA(str(seq_file_path))
        return all_seq_records

    def run_task(self, update_dto_callback: Callable) -> TaskDTO:
        server_input_file_path = self.config_dict["input_file"]
        all_seqs = self._read_seqs(server_input_file_path)

        protocol = Protocol.from_string(self.config_dict['protocol'])
        reduced = protocol in Protocol.using_per_sequence_embeddings()

        file_context_manager = FileContextManager()
        with file_context_manager.storage_write(self.model_path) as biotrainer_out_path:
            # Set output dirs to temp dir
            self.config_dict["output_dir"] = str(biotrainer_out_path)

            # Save input file temporarily on the file system
            tmp_path = biotrainer_out_path / "input_file.fasta"
            file_context_manager.save_file_temporarily(tmp_path, server_input_file_path)
            self.config_dict["input_file"] = str(tmp_path)

            embeddings = self._pre_embed_with_db(all_seqs=all_seqs, reduced=reduced,
                                                 update_dto_callback=update_dto_callback)

            config = deepcopy(self.config_dict)

            # Run biotrainer with custom pipeline to inject embeddings directly
            custom_pipeline = get_custom_training_pipeline_injection(embeddings=embeddings)
            custom_observer = TrainingDTOObserver(update_dto_callback=update_dto_callback)

            results = parse_config_file_and_execute_run(config=config, custom_pipeline=custom_pipeline,
                                                        custom_output_observers=[custom_observer]
                                                        )


        return TaskDTO.finished(result={})

    def _pre_embed_with_db(self, all_seqs: List[BiotrainerSequenceRecord], reduced: bool,
                           update_dto_callback: Callable) -> List[
        BiotrainerSequenceRecord]:
        embedder_name = self.config_dict['embedder_name']
        custom_tokenizer_config = self.config_dict.get('custom_tokenizer_config', None)
        device = self.config_dict.get('device', None)

        load_embedding_task = LoadEmbeddingsTask(embedder_name=embedder_name,
                                                 custom_tokenizer_config=custom_tokenizer_config,
                                                 sequence_input=all_seqs,
                                                 reduced=reduced,
                                                 use_half_precision=False,
                                                 device=device)
        load_dto: Optional[TaskDTO] = None
        for current_dto in self.run_subtask(load_embedding_task):
            load_dto = current_dto
            if "embedding_current" in load_dto.update:
                update_dto_callback(load_dto)

        if not load_dto:
            raise Exception("Could not compute embeddings!")

        if ".onnx" in embedder_name:
            # TODO CHECK
            embeddings_db = EmbeddingDatabaseFactory().get_embeddings_db()
            hashed_embedder_name = embeddings_db.get_onnx_model_hash(embedder_name)
            self.config_dict["embedder_name"] = hashed_embedder_name
            self.config_dict.pop("custom_tokenizer_config")

        missing = load_dto.update["missing"]
        embeddings: List[BiotrainerSequenceRecord] = load_dto.update["embeddings"]
        if len(missing) > 0:
            return TaskDTO.failed(error=f"Missing number of embeddings before training: {len(missing)}")

        return embeddings
