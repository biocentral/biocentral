import os

from typing import List
from redis import Redis
from datetime import datetime
from biotrainer.utilities import AMINO_ACIDS

from .research_stats import ResearchStats

from ...utils import get_logger

logger = get_logger(__name__)


class MetricsService:
    def __init__(self):
        # Redis connection for research statistics (DB 2 to separate from RQ/Rate Limiter)
        redis_host = os.environ.get("REDIS_JOBS_HOST", "redis-jobs")
        redis_port = int(os.environ.get("REDIS_JOBS_PORT", 6379))
        self.redis = Redis(
            host=redis_host, port=redis_port, db=2, decode_responses=True
        )

        # Redis keys
        self.KEY_SEQS_TOTAL_ALL = "stats:sequences:total_all"
        self.KEY_SEQS_TOTAL_LENGTH = "stats:sequences:total_length"
        self.KEY_TOP_EMBEDDERS = "stats:embedders:usage"
        self.KEY_TOP_PREDICTORS = "stats:predictors:usage"
        self.KEY_AA_DISTRIBUTION = "stats:amino_acids:distribution"
        self.KEY_TASKS_TOTAL = "stats:tasks:total"

    def _track_sequences(self, sequences: dict):
        count = len(sequences)
        total_len = sum(len(seq) for seq in sequences.values())

        # 1. Increment all-time total
        self.redis.incrby(self.KEY_SEQS_TOTAL_ALL, count)

        # 2. Increment today's total (with 48h expiry)
        today_key = f"stats:sequences:today:{datetime.utcnow().strftime('%Y-%m-%d')}"
        self.redis.incrby(today_key, count)
        self.redis.expire(today_key, 60 * 60 * 48)  # 48 hours

        # 3. Track total length for average calculation
        self.redis.incrby(self.KEY_SEQS_TOTAL_LENGTH, total_len)

        # 5. Track amino acid distribution
        aa_counts = {}
        for seq in sequences.values():
            for aa in seq.upper():
                aa_char = aa if aa in AMINO_ACIDS else "X"
                aa_counts[aa_char] = aa_counts.get(aa_char, 0) + 1

        if aa_counts:
            # Use a pipeline for multiple HINCRBY calls
            with self.redis.pipeline() as pipe:
                for aa, aa_count in aa_counts.items():
                    pipe.hincrby(self.KEY_AA_DISTRIBUTION, aa, aa_count)
                pipe.execute()

    def _track_embedders(self, embedder_name: str, count: int):
        self.redis.zincrby(self.KEY_TOP_EMBEDDERS, count, embedder_name)

    def _track_tasks(self):
        self.redis.incrby(self.KEY_TASKS_TOTAL, 1)

    def _track_predictors(self, predictor_names: List[str], count: int):
        for predictor_name in predictor_names:
            self.redis.zincrby(self.KEY_TOP_PREDICTORS, count, predictor_name)

    def record_sequence_data(
        self,
        sequences: dict,
        embedder_name: str,
    ) -> None:
        try:
            count = len(sequences)

            self._track_sequences(sequences)
            self._track_embedders(embedder_name, count)
            self._track_tasks()

            logger.info(
                f"Recorded metrics [sequences]: sequence_count: {count}, embedder: {embedder_name}"
            )
        except Exception as e:
            logger.error(f"Error recording embedding request to Redis: {e}")

    def record_prediction_data(self, sequences: dict, predictor_names: List[str]):
        try:
            count = len(sequences)
            self._track_sequences(sequences)
            self._track_predictors(predictor_names, count)
            self._track_tasks()

            logger.info(
                f"Recorded metrics [prediction]: sequence_count: {count}, predictors: {predictor_names}"
            )
        except Exception as e:
            logger.error(f"Error recording prediction request to Redis: {e}")

    def record_training_data(self, sequences: dict):
        try:
            count = len(sequences)
            self._track_sequences(sequences)
            self._track_tasks()

            logger.info(f"Recorded metrics [training]: sequence_count: {count}")
        except Exception as e:
            logger.error(f"Error recording training request to Redis: {e}")

    def record_inference_data(self, sequences: dict):
        try:
            count = len(sequences)
            self._track_sequences(sequences)
            self._track_tasks()

            logger.info(f"Recorded metrics [inference]: sequence_count: {count}")
        except Exception as e:
            logger.error(f"Error recording inference request to Redis: {e}")

    async def get_total_tasks(self) -> int:
        try:
            return int(self.redis.get(self.KEY_TASKS_TOTAL) or 0)
        except Exception as e:
            logger.error(f"Error retrieving total tasks from Redis: {e}")
            return 0

    async def get_research_stats(self) -> ResearchStats:
        """Get public usage statistics from Redis"""
        try:
            # Get all-time total
            total_all = int(self.redis.get(self.KEY_SEQS_TOTAL_ALL) or 0)

            # Get today's total
            today_key = (
                f"stats:sequences:today:{datetime.utcnow().strftime('%Y-%m-%d')}"
            )
            total_today = int(self.redis.get(today_key) or 0)

            # Calculate average length
            total_length = int(self.redis.get(self.KEY_SEQS_TOTAL_LENGTH) or 0)
            avg_len = round(total_length / total_all, 2) if total_all > 0 else 0.0

            # Get top 10 embedders
            top_res = self.redis.zrevrange(
                self.KEY_TOP_EMBEDDERS, 0, 10, withscores=True
            )
            top_embedders = {name: int(score) for name, score in top_res}

            # Get top 10 predictors
            top_pred_res = self.redis.zrevrange(
                self.KEY_TOP_PREDICTORS, 0, 10, withscores=True
            )
            top_predictors = {name: int(score) for name, score in top_pred_res}

            # Get amino acid distribution
            aa_distribution = self.redis.hgetall(self.KEY_AA_DISTRIBUTION)
            aa_distribution = {aa: int(count) for aa, count in aa_distribution.items()}

            return ResearchStats(
                total_sequences_today=total_today,
                total_sequences_all_time=total_all,
                avg_sequence_length=avg_len,
                aa_distribution=aa_distribution,
                top_embedders=top_embedders,
                top_predictors=top_predictors,
                updated_at=datetime.utcnow(),
            )
        except Exception as e:
            logger.error(f"Error retrieving research stats from Redis: {e}")
            return ResearchStats(
                total_sequences_today=0,
                total_sequences_all_time=0,
                aa_distribution={},
                avg_sequence_length=0.0,
                top_embedders={},
                top_predictors={},
                updated_at=datetime.utcnow(),
            )
