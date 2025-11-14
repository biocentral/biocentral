from prometheus_client import Counter, Histogram, Gauge

from ...utils import get_logger

logger = get_logger(__name__)

# Custom metrics
sequences_submitted = Counter(
    "sequences_submitted_total",
    "Total number of sequences submitted for embedding",
    ["embedder_name"],
)

sequence_length = Histogram(
    "sequence_length_bytes",
    "Distribution of sequence lengths",
    ["embedder_name"],
    buckets=[50, 100, 200, 500, 1000, 2000, 5000, 10000],
)

active_tasks = Gauge("active_tasks", "Number of currently active tasks", ["task_type"])

task_duration = Histogram(
    "task_duration_seconds", "Task processing duration", ["task_type", "status"]
)


class MetricsCollector:
    @staticmethod
    def record_embedding_request(
        sequences: dict,
        embedder_name: str,
    ) -> None:
        try:
            # Increment counter
            sequences_submitted.labels(embedder_name=embedder_name).inc(len(sequences))

            # Record sequence lengths
            for seq in sequences.values():
                sequence_length.labels(embedder_name=embedder_name).observe(len(seq))

            # Log
            logger.info(
                f"embed: sequence_count: {len(sequences)}, embedder_name: {embedder_name}"
            )
        except Exception as e:
            logger.error(f"Error recording embedding request: {e}")

    @staticmethod
    def increment_active_tasks(task_type: str) -> None:
        active_tasks.labels(task_type=task_type).inc()

    @staticmethod
    def decrement_active_tasks(task_type: str) -> None:
        active_tasks.labels(task_type=task_type).dec()
