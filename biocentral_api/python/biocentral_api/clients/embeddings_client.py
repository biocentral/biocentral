import io
import h5py
import base64
import numpy as np

from pathlib import Path
from tqdm.auto import tqdm
from typing import Dict, List, Union, Optional

from .tasks import BiocentralServerTask, DTOHandler
from .client_interface import ClientInterface

from ..utils import calculate_sequence_hash
from .._generated import ApiClient, EmbedRequest, EmbeddingsApi, TaskStatus, \
    TaskDTO


class EmbeddingsResult:
    def __init__(self, hash2id: Dict[str, str], embeddings_file_str: str):
        self._hash2id = hash2id
        self._id2hash = {v: k for k, v in hash2id.items()}
        self._embeddings_file_str = embeddings_file_str

        # Cached
        self.__embeddings_file_handle = None  # h5 file handle 
        self.__id2emb = None  # Hashed ids -> Embedding

    def _lazy_read_handle(self):
        """ Return cached handle or lazily read embeddings string """
        assert self.__id2emb is None, "Lazy reading called after id2emb already exists!"

        if self.__embeddings_file_handle is not None:
            return self.__embeddings_file_handle
        # Open
        h5_bytes = base64.b64decode(self._embeddings_file_str)
        h5_io = io.BytesIO(h5_bytes)
        self.__embeddings_file_handle = h5py.File(h5_io, 'r')
        return self.__embeddings_file_handle

    def _id2emb(self):
        if self.__id2emb is not None:
            return self.__id2emb
        # Read embeddings
        embeddings_file_handle = self._lazy_read_handle()
        id2emb = {
            hash_idx: np.array(embedding)
            for (hash_idx, embedding) in embeddings_file_handle.items()
        }
        self.__id2emb = id2emb
        embeddings_file_handle.close()
        return self.__id2emb

    def to_dict(self, hashed_ids: Optional[bool] = False) -> Dict[str, np.ndarray]:
        """
        Get a dictionary of id -> embedding.
        
        :param hashed_ids: If True, sequence hashes instead of the original sequence ids are used to index dict
        :return: Dictionary of sequence/hash ids and embeddings as numpy arrays
        """
        if hashed_ids:
            return dict(self._id2emb())
        else:
            seqid2emb = {self._hash2id[idx]: embd for idx, embd in self._id2emb().items()}
            return seqid2emb

    def to_list(self) -> List:
        """ Get the list of embeddings as lists """
        id2emb = self._id2emb()
        return [embd.tolist() for embd in id2emb.values()]

    def to_numpy(self) -> np.ndarray:
        """ Get the stacked numpy array of all embeddings """
        id2emb = self._id2emb()
        return np.stack(list(id2emb.values()))

    def __getitem__(self, item: str) -> Optional[np.ndarray]:
        """ Get a specific embedding for a particular id (can be both, sequence id or sequence hash) """

        def _retrieve(d):
            try:
                res = d.get(item)
                if res is None:
                    res = d.get(self._id2hash[item])
                if res is None:
                    raise Exception("No embedding found for id")
                return np.array(res)
            except Exception:
                raise KeyError(f"No embedding found for id {item}")

        if self.__id2emb is not None:
            return _retrieve(self.__id2emb)
        # Lazy get from handle
        embeddings_file_handle = self._lazy_read_handle()
        return _retrieve(embeddings_file_handle)

    def save(self, save_path: Union[Path, str], hashed_ids: Optional[bool] = False) -> None:
        """
        Save the embeddings as h5 file locally.
        
        :param save_path: Path where to save the embeddings file.
        :param hashed_ids: If True, sequence hashes instead of the original sequence ids are used to index the h5 database
        """
        if hashed_ids:
            with open(save_path, 'w') as h5_file:
                h5_file.write(self._embeddings_file_str)
        else:
            seqid2emb = self.to_dict(hashed_ids=False)
            with h5py.File(save_path, 'w') as h5_file:
                for seq_id, embedding in seqid2emb.items():
                    h5_file.create_dataset(seq_id, data=embedding)


class _EmbedDTOHandler(DTOHandler):
    def __init__(self, hash2id: Dict[str, str], embedder_name):
        self._hash2id = hash2id
        self._cached_embedding_total = None
        self._embedder_name = embedder_name

    def handle_result(self, dtos: List[TaskDTO]):
        for dto in dtos:
            status = dto.status
            if status == TaskStatus.FINISHED:
                embeddings_file = dto.embeddings_file
                if embeddings_file is None:
                    pass  # TODO Handle error
                return EmbeddingsResult(hash2id=self._hash2id, embeddings_file_str=embeddings_file)

        return None

    def update_tqdm(self, dtos: List[TaskDTO], pbar: tqdm) -> tqdm:
        for dto in dtos:
            status = dto.status
            if status in [TaskStatus.RUNNING,
                          TaskStatus.FINISHED]:
                if self._cached_embedding_total is None:
                    self._cached_embedding_total = dto.embedding_progress.total if dto.embedding_progress else None
                    pbar.total = self._cached_embedding_total if self._cached_embedding_total else 0
                current = dto.embedding_progress.current if dto.embedding_progress else None
                if current is not None:
                    pbar.update(current - pbar.n)
            match status:
                case TaskStatus.PENDING:
                    pbar.set_description(f"Waiting for embedding calculation to start..")
                case TaskStatus.RUNNING:
                    pbar.set_description(f"Embedding with {self._embedder_name}..")
                case TaskStatus.FINISHED:
                    pbar.set_description(f"Finished embedding calculation!")
                    break
                case TaskStatus.FAILED:
                    pbar.set_description(f"Embedding failed!")
                    break
        return pbar

    def get_tqdm_initial_description(self) -> str:
        return f"Embedding with {self._embedder_name}.."


class EmbeddingsClient(ClientInterface):
    def embed(self, api_client: ApiClient, embedder_name: str, reduce: bool, sequence_data: Dict[str, str],
              use_half_precision: bool) -> BiocentralServerTask[EmbeddingsResult]:
        assert len(sequence_data) > 0, "No sequences provided"
        assert len(sequence_data.values()) == len(set(sequence_data.values())), "Duplicate sequences provided"

        hash2id = {calculate_sequence_hash(seq): seq_id for seq_id, seq in sequence_data.items()}

        embed_request = EmbedRequest(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                                     use_half_precision=use_half_precision)
        api_instance = EmbeddingsApi(api_client)
        task_id = self._submit_task(
            endpoint_caller=lambda: api_instance.embed_api_v1_embeddings_service_embed_post(embed_request)
        )

        embed_dto_handler = _EmbedDTOHandler(hash2id=hash2id, embedder_name=embedder_name)
        biocentral_server_task = BiocentralServerTask(task_id=task_id,
                                                      api_client=api_client,
                                                      dto_handler=embed_dto_handler)
        return biocentral_server_task
