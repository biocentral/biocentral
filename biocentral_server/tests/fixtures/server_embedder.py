import os
import time
import logging
from typing import Dict, List, Optional

import httpx
import numpy as np
from biotrainer.utilities import calculate_sequence_hash
from biotrainer.input_files import BiotrainerSequenceRecord

from biocentral_server.server_management.embedding_database import EmbeddingsDatabase


class ServerEmbedder:
    # Embedder that calls the server's embedding endpoint.

    def __init__(
        self,
        base_url: Optional[str] = None,
        embedder_name: str = "facebook/esm2_t6_8M_UR50D",
        timeout: float = 300.0,
        poll_interval: float = 2.0,
    ):
        # Initialize the server embedder.
        self.base_url = base_url or os.environ.get(
            "CI_SERVER_URL", "http://localhost:9540"
        )
        self.api_url = f"{self.base_url}/api/v1"
        self.embedder_name = embedder_name
        self.model_name = embedder_name
        self.timeout = timeout
        self.poll_interval = poll_interval

        self._use_fixed_embedder = os.environ.get("CI_EMBEDDER", "").lower() == "fixed"
        self._fixed_embedder = None

        if self._use_fixed_embedder:
            from tests.fixtures.fixed_embedder import FixedEmbedder

            self._fixed_embedder = FixedEmbedder(
                model_name="esm2_t6", strict_dataset=False
            )
            logging.info("ServerEmbedder: Using FixedEmbedder mode (CI_EMBEDDER=fixed)")

        postgres_config = {
            "host": os.environ.get("POSTGRES_HOST", "localhost"),
            "port": int(os.environ.get("POSTGRES_PORT", "5432")),
            "dbname": os.environ.get("POSTGRES_DB", "embeddings_db"),
            "user": os.environ.get("POSTGRES_USER", "embeddingsuser"),
            "password": os.environ.get("POSTGRES_PASSWORD", "embeddingspwd"),
        }
        self._db = EmbeddingsDatabase(postgres_config)

        transport = httpx.HTTPTransport(retries=3)
        self.client = httpx.Client(
            base_url=self.api_url,
            timeout=httpx.Timeout(timeout, connect=10.0),
            transport=transport,
        )

    def _submit_embed_task(
        self,
        sequences: Dict[str, str],
        reduce: bool = False,
    ) -> str:
        request_data = {
            "embedder_name": self.embedder_name,
            "reduce": reduce,
            "sequence_data": sequences,
            "use_half_precision": False,
        }

        response = self.client.post("/embeddings_service/embed", json=request_data)

        if response.status_code != 200:
            raise RuntimeError(
                f"Failed to submit embedding task: {response.status_code} - {response.text}"
            )

        return response.json()["task_id"]

    def _poll_task(self, task_id: str) -> Dict:
        from biocentral_server.server_management.task_management.task_interface import TaskStatus

        start = time.time()

        while time.time() - start < self.timeout:
            response = self.client.get(f"/biocentral_service/task_status/{task_id}")

            if response.status_code != 200:
                logging.warning(f"Poll returned {response.status_code}, retrying...")
                time.sleep(self.poll_interval)
                continue

            dtos = response.json().get("dtos", [])
            if not dtos:
                time.sleep(self.poll_interval)
                continue

            latest = dtos[-1]
            status = latest.get("status", "").upper()

            if status == TaskStatus.FINISHED.value:
                return latest
            elif status == TaskStatus.FAILED.value:
                raise RuntimeError(
                    f"Embedding task failed: {latest.get('error', 'unknown')}"
                )

            time.sleep(self.poll_interval)

        raise TimeoutError(f"Task {task_id} did not complete within {self.timeout}s")

    def _get_embedding_from_db(
        self,
        sequence: str,
        reduce: bool = False,
    ) -> Optional[np.ndarray]:
        seq_hash = calculate_sequence_hash(sequence)
        records = self._db.get_embeddings(
            {seq_hash: sequence}, self.embedder_name, reduce
        )
        if records and records[0].embedding is not None:
            emb = records[0].embedding
            # Convert torch tensor to numpy if needed
            if hasattr(emb, "numpy"):
                return emb.numpy()
            return np.asarray(emb)
        return None

    def _compute_and_save_fixed_embedding(
        self,
        sequence: str,
        reduce: bool = False,
    ) -> np.ndarray:
        # Compute embedding using FixedEmbedder and save to database.
        if reduce:
            embedding = self._fixed_embedder.embed_pooled(sequence)
        else:
            embedding = self._fixed_embedder.embed(sequence)

        record = BiotrainerSequenceRecord(
            seq_id="fixed", seq=sequence, embedding=embedding
        )
        self._db.save_embeddings([record], self.embedder_name, reduced=reduce)

        return embedding

    def embed(self, sequence: str) -> np.ndarray:
        # Embed a single sequence, returning per-residue embeddings.

        if self._use_fixed_embedder:
            return self._compute_and_save_fixed_embedding(sequence, reduce=False)

        sequences = {"seq_0": sequence}

        task_id = self._submit_embed_task(sequences, reduce=False)

        self._poll_task(task_id)

        embedding = self._get_embedding_from_db(sequence, reduce=False)

        if embedding is None:
            raise RuntimeError("Embedding not found in database after task completion")

        return embedding

    def embed_pooled(self, sequence: str) -> np.ndarray:
        # Embed a single sequence, returning pooled (reduced) embedding.

        if self._use_fixed_embedder:
            return self._compute_and_save_fixed_embedding(sequence, reduce=True)

        sequences = {"seq_0": sequence}

        task_id = self._submit_embed_task(sequences, reduce=True)

        self._poll_task(task_id)

        embedding = self._get_embedding_from_db(sequence, reduce=True)

        if embedding is None:
            raise RuntimeError("Embedding not found in database after task completion")

        return embedding

    def embed_batch(
        self,
        sequences: List[str],
        pooled: bool = False,
    ) -> List[np.ndarray]:
        # Embed multiple sequences.

        if self._use_fixed_embedder:
            return [
                self._compute_and_save_fixed_embedding(seq, reduce=pooled)
                for seq in sequences
            ]

        seq_dict = {f"seq_{i}": seq for i, seq in enumerate(sequences)}

        task_id = self._submit_embed_task(seq_dict, reduce=pooled)

        self._poll_task(task_id)

        embeddings = []
        for seq in sequences:
            emb = self._get_embedding_from_db(seq, reduce=pooled)
            embeddings.append(emb if emb is not None else np.array([]))

        return embeddings

    def close(self):
        self.client.close()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
