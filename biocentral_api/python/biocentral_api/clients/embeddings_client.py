import io
import h5py
import base64
import numpy as np

from tqdm import tqdm
from typing import Dict, List

from .tasks import BiocentralServerTask, DTOHandler

from ..utils import calculate_sequence_hash
from .._generated import ApiClient, EmbedRequest, EmbeddingsApi, StartTaskResponse, TaskStatus, \
    TaskDTO


class _EmbedDTOHandler(DTOHandler):
    def __init__(self, hash2id: Dict[str, str]):
        self.hash2id = hash2id
        self._cached_embedding_total = None

    def _parse_embeddings_file(self, embeddings_file: str):
        h5_bytes = base64.b64decode(embeddings_file)

        h5_io = io.BytesIO(h5_bytes)
        embeddings_file = h5py.File(h5_io, 'r')

        # sequence hash -> Embedding
        id2emb = {
            self.hash2id[idx]: np.array(embedding).tolist()
            for (idx, embedding) in embeddings_file.items()
        }

        embeddings_file.close()
        return id2emb

    def handle(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                embeddings_file = dto.embeddings_file
                if embeddings_file is None:
                    pass # TODO Handle error
                return self._parse_embeddings_file(embeddings_file)

        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            if status in [TaskStatus.RUNNING,
                          TaskStatus.FINISHED]:
                if self._cached_embedding_total is None:
                    self._cached_embedding_total = dto.embedding_total
                    pbar.total = self._cached_embedding_total if self._cached_embedding_total else 0
                current = dto.embedding_current
                if current is not None:
                    pbar.update(current - pbar.n)
            match status:
                case TaskStatus.PENDING:
                    pbar.set_description(f"Waiting for embedding calculation to start..")
                case TaskStatus.RUNNING:
                    pbar.set_description(f"Embedding..")
                case TaskStatus.FINISHED:
                    pbar.set_description(f"Finished embedding calculation!")
                    pbar.close()
                    break
                case TaskStatus.FAILED:
                    pbar.set_description(f"Embedding failed!")
                    pbar.close()
                    break
        return pbar


class EmbeddingsClient:
    def embed(self, api_client: ApiClient, embedder_name: str, reduce: bool, sequence_data: Dict[str, str],
              use_half_precision: bool) -> BiocentralServerTask:
        assert len(sequence_data) > 0, "No sequences provided"
        assert len(sequence_data.values()) == len(set(sequence_data.values())), "Duplicate sequences provided"

        hash2id = {calculate_sequence_hash(seq): seq_id for seq_id, seq in sequence_data.items()}

        embed_request = EmbedRequest(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                                     use_half_precision=use_half_precision)
        api_instance = EmbeddingsApi(api_client)
        start_task_response: StartTaskResponse = api_instance.embed_api_v1_embeddings_service_embed_post(embed_request)
        if start_task_response.task_id is None:
            raise Exception("Failed to start embed task")

        embed_dto_handler = _EmbedDTOHandler(hash2id)
        biocentral_server_task = BiocentralServerTask(task_id=start_task_response.task_id,
                                                      api_client=api_client,
                                                      dto_handler=embed_dto_handler)
        return biocentral_server_task
