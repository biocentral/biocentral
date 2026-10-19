"""Concurrent writes to the embeddings database, against a real Postgres.

Needs POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER and POSTGRES_PASSWORD, e.g. from
.env.ci with the database of docker-compose.ci.yml running. Skipped otherwise.
"""

import os
import threading
import time
import uuid

import psycopg
import pytest
import torch
from biotrainer_core.data_classes import SequenceData

from biocentral_server.server_management.embedding_database.embedding_database import (
    EmbeddingsDatabase,
)

POSTGRES_CONFIG = {
    "host": os.getenv("POSTGRES_HOST"),
    "port": os.getenv("POSTGRES_PORT"),
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
}

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        not POSTGRES_CONFIG["host"], reason="needs a Postgres via POSTGRES_* settings"
    ),
]


@pytest.fixture
def embedder_name():
    name = f"test/concurrency-{uuid.uuid4().hex[:8]}"
    yield name
    with psycopg.connect(**POSTGRES_CONFIG) as conn:
        conn.execute("DELETE FROM embeddings WHERE embedder_name = %s", [name])


def _wait_for_blocked_insert(timeout: float = 5.0):
    """Wait until some backend's INSERT into embeddings is waiting on a row lock."""
    deadline = time.monotonic() + timeout
    with psycopg.connect(**POSTGRES_CONFIG, autocommit=True) as conn:
        while time.monotonic() < deadline:
            blocked = conn.execute(
                "SELECT count(*) FROM pg_stat_activity WHERE wait_event_type = 'Lock' "
                "AND query LIKE '%INSERT INTO embeddings%'"
            ).fetchone()[0]
            if blocked:
                return
            time.sleep(0.05)
    raise TimeoutError("save_embeddings never waited for the other writer")


def test_overlapping_saves_in_different_orders_do_not_deadlock(embedder_name):
    """Two jobs embedding the same new sequences must not lock each other's rows in turn.

    The engineering pipeline sends its sequences in a per-process order, so two jobs can
    write the same rows as [A, B] and [B, A]. Here another writer holds A, as a concurrent
    batch would, while save_embeddings is given [B, A]; then that writer also wants B.
    """
    database = EmbeddingsDatabase(postgres_config=POSTGRES_CONFIG)
    first, second = sorted(
        [
            SequenceData(seq_id="a", seq="MKTAYIAK"),
            SequenceData(seq_id="b", seq="MKTAYIAR"),
        ],
        key=lambda record: record.get_hash(),
    )
    records = [record.copy_with_embedding(torch.ones(4)) for record in (second, first)]

    insert = (
        "INSERT INTO embeddings (sequence_hash, embedder_name) VALUES (%s, %s) "
        "ON CONFLICT (sequence_hash, embedder_name) DO NOTHING"
    )
    with psycopg.connect(**POSTGRES_CONFIG) as other_writer:
        other_writer.execute(insert, [first.get_hash(), embedder_name])

        saving = threading.Thread(
            target=database.save_embeddings,
            kwargs={
                "embd_records": records,
                "embedder_name": embedder_name,
                "reduced": True,
            },
        )
        saving.start()
        _wait_for_blocked_insert()
        try:
            other_writer.execute(insert, [second.get_hash(), embedder_name])
        except psycopg.errors.DeadlockDetected:
            pytest.fail("Postgres detected a deadlock between the two writers")
        other_writer.commit()
        saving.join(timeout=10)

    sequences = {record.get_hash(): record.seq for record in records}
    loaded = database.get_embeddings(
        sequences=sequences, embedder_name=embedder_name, reduced=True
    )
    assert all(record.embedding is not None for record in loaded)
    assert len(loaded) == 2
