import os.path
import asyncio
import tempfile

from pathlib import Path
from typing import Dict, Any
import torch.multiprocessing as torch_mp
import yaml
from biotrainer.utilities import read_FASTA, get_device

from biotrainer.utilities.cli import headless_main

from ..server_management import TaskInterface, TaskStatus, EmbeddingsDatabase
from ..embeddings import compute_embeddings_and_save_to_db


class BiotrainerProcess(TaskInterface):
    process: torch_mp.Process = None

    def __init__(self, config_path: Path, config_dict: dict, database_instance: EmbeddingsDatabase, log_path: Path):
        self.config_path = config_path
        self.config_dict = config_dict
        self.database_instance = database_instance
        self.log_path = log_path
        self._last_read_position_in_log_file = 0

    async def start(self):
        self._biotrainer_pipeline()

    def _biotrainer_pipeline(self):
        # Embed before training to re-use embeddings
        self._pre_embed_with_db()
        self.process = torch_mp.Process(target=headless_main, args=(str(self.config_path),))
        self.process.start()

    def _pre_embed_with_db(self):
        sequence_file = self.config_dict['sequence_file']

        all_seq_records = read_FASTA(str(sequence_file))
        all_seqs = {seq.id: str(seq.seq) for seq in all_seq_records}

        embedder_name = self.config_dict['embedder_name']
        protocol = self.config_dict['protocol']
        device = get_device(self.config_dict.get('device', None))
        output_path = self.config_path.parent / "embeddings.h5"
        with tempfile.TemporaryDirectory() as temp_embeddings_dir:
            temp_embeddings_path = Path(temp_embeddings_dir)
            embedding_triples = compute_embeddings_and_save_to_db(embedder_name=embedder_name, all_seqs=all_seqs,
                                                                  embeddings_out_path=temp_embeddings_path,
                                                                  reduce_by_protocol=protocol,
                                                                  use_half_precision=False,
                                                                  device=device,
                                                                  database_instance=self.database_instance)
            EmbeddingsDatabase.export_embeddings_to_hdf5(triples=embedding_triples, output_path=output_path)
        self.config_dict.pop("embedder_name")
        self.config_dict["embeddings_file"] = str(output_path)
        # TODO Enable biotrainer to accept a dict
        config_file_yaml = yaml.dump(self.config_dict)
        with open(self.config_path, "w") as config_file:
            config_file.write(config_file_yaml)

    def get_task_status(self) -> TaskStatus:
        # TODO Adapt to pipeline
        if not self.process:
            return TaskStatus.RUNNING
        if self.process.is_alive():
            return TaskStatus.RUNNING
        else:
            return TaskStatus.FINISHED

    def update(self) -> Dict[str, Any]:
        result = {"log_file": "", "status": self.get_task_status().name}
        if os.path.exists(self.log_path):
            with open(self.log_path, "r") as log_file:
                log_file.seek(self._last_read_position_in_log_file)
                new_content = log_file.read()
                self._last_read_position_in_log_file = log_file.tell()
                result["log_file"] = new_content
        return result
