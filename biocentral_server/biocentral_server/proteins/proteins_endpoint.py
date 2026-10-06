from fastapi import APIRouter, Depends, Request, HTTPException
from fastapi_limiter.depends import RateLimiter

from .taxonomy import Taxonomy
from .endpoint_models import (
    TaxonomyResponse,
    TaxonomyRequest,
    TaxonomyItem,
    ClusteringRequest,
    ClusterHBIRequest,
    ClusterHBIResponse,
    SplitHBIRequest,
    SplitHBIResponse,
    BootstrappedMetricDTO,
)
from .proteins_task import (
    ClusterSequencesTask,
    run_pymmseqs_clustering,
)
from .hbi_service import (
    run_easy_search_lookup,
    compute_hbi_metrics_from_lookup,
    compute_hbi_cluster_metrics,
)

from ..server_management import (
    ErrorResponse,
    NotFoundErrorResponse,
    TaskManager,
    UserManager,
    StartTaskResponse,
)
from ..utils import get_logger

import time
from collections import OrderedDict
from dataclasses import dataclass
from typing import Any, Optional

logger = get_logger(__name__)

router = APIRouter(
    prefix="/protein_service",
    tags=["proteins"],
    responses={404: {"model": NotFoundErrorResponse}},
)


@dataclass
class CacheEntry:
    data: Any
    last_accessed: float


class InMemoryTTLCache:
    def __init__(self, max_size: int = 10, ttl_seconds: float = 600.0):
        self.max_size = max_size
        self.ttl_seconds = ttl_seconds
        self._cache: OrderedDict[str, CacheEntry] = OrderedDict()

    def _purge_expired(self, now: float) -> None:
        "Remove expired entries"
        expired_keys = [
            key
            for key, entry in self._cache.items()
            if now - entry.last_accessed > self.ttl_seconds
        ]
        for key in expired_keys:
            del self._cache[key]

    def get(self, key: str) -> Optional[Any]:
        now = time.time()
        self._purge_expired(now)

        entry = self._cache.get(key)
        if entry is None:
            return None

        # Accessing the hash renews the timestamp
        entry.last_accessed = now
        self._cache.move_to_end(key)
        return entry.data

    def set(self, key: str, value: Any) -> None:
        now = time.time()
        self._purge_expired(now)

        if key in self._cache:
            # Update existing Entry
            self._cache[key] = CacheEntry(data=value, last_accessed=now)
            self._cache.move_to_end(key)
            return

        # Remove oldest entry when limit is reached
        if len(self._cache) >= self.max_size:
            self._cache.popitem(last=False)

        self._cache[key] = CacheEntry(data=value, last_accessed=now)

    def __contains__(self, key: str):
        return self.get(key) is not None

    def __len__(self) -> int:
        self._purge_expired(time.time())
        return len(self._cache)


DATASET_CACHE = InMemoryTTLCache(max_size=10, ttl_seconds=600)


# Endpoint to get taxonomy data (taxon name and family name from taxonomy id)
@router.post(
    "/taxonomy/",
    response_model=TaxonomyResponse,
    responses={400: {"model": ErrorResponse}},
    summary="Retrieve taxonomy data",
    description="Retrieve taxonomy data for a list of taxonomy ids",
    dependencies=[Depends(RateLimiter(times=20, seconds=60))],
)
def taxonomy(taxonomy_request: TaxonomyRequest):
    taxonomy_ids = taxonomy_request.taxonomy_ids

    taxonomy_list = []
    taxonomy_object = Taxonomy()
    for taxonomy_id in taxonomy_ids:
        name = ""
        family = ""
        try:
            name = taxonomy_object.get_name_from_id(int(taxonomy_id))
            family = taxonomy_object.get_family_from_id(int(taxonomy_id))
        except Exception:
            logger.warning(f"Unknown taxonomy id: {taxonomy_id}")
        taxonomy_list.append(
            TaxonomyItem(taxonomy_id=taxonomy_id, name=name, family=family)
        )

    return TaxonomyResponse(taxonomy=taxonomy_list)


@router.post(
    "/cluster/",
    response_model=StartTaskResponse,
    responses={404: {"model": ErrorResponse}},
    summary="Calculate clustering",
    description="Submit sequences for clustering with pymmseqs",
    dependencies=[Depends(RateLimiter(times=3, seconds=60))],
)
async def trigger_protein_clustering(payload: ClusteringRequest, request: Request):
    try:
        task_instance = ClusterSequencesTask(
            sequence_data=payload.sequence_data,
            sequence_identity_threshold=payload.sequence_identity_threshold,
        )

        user_id = await UserManager.get_user_id_from_request(req=request)

        task_manager = TaskManager()
        task_id = task_manager.add_task(task=task_instance, user_id=user_id)

        return StartTaskResponse(task_id=task_id)

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to submit background cluster task: {str(e)}",
        )


@router.post(
    "/cluster-hbi/",
    response_model=ClusterHBIResponse,
    summary="Direct synchronous HBI calculation on CPU with bootstrapping and dataset cache",
    dependencies=[Depends(RateLimiter(times=60, seconds=60))],
)
def cluster_hbi(payload: ClusterHBIRequest):
    # resolve caches sequences or store new upload
    if payload.sequence_data:
        DATASET_CACHE.set(payload.dataset_hash, payload.sequence_data)
        sequences = payload.sequence_data
    else:
        sequences = DATASET_CACHE.get(payload.dataset_hash)

    if not sequences:
        raise HTTPException(
            status_code=400,
            detail="Dataset not found in cache. Please provide sequence_data on initial call."
        )
    # run MMseqs2 directly in-thread
    try:
        clusters = run_pymmseqs_clustering(
            sequence_data=sequences,
            sequence_identity_threshold=payload.sequence_identity_threshold,
        )
    except Exception as e:
        logger.error(f"Cluster HBI error: {e}")
        raise HTTPException(status_code=500, detail=f"Clustering error: {str(e)}")

    # calculate HBI score
    try:
        raw_metrics = compute_hbi_cluster_metrics(
            clusters=clusters,
            labels=payload.target_data,
            is_numeric=payload.is_numeric,
            iterations=payload.iterations,
        )
    except Exception as e:
        logger.error(f"Cluster HBI metrics error: {e}")
        raise HTTPException(status_code=500, detail=f"Clustering error: {str(e)}")

    total_members = sum(len(m) - 1 for m in clusters.values() if len(m) > 1)
    evaluated_members = raw_metrics[0]["sample_size"] if raw_metrics else 0
    metric_dtos = [BootstrappedMetricDTO(**m) for m in raw_metrics]

    return ClusterHBIResponse(
        metrics=metric_dtos,
        num_clusters=len(clusters),
        num_members=total_members,
        evaluated_members=evaluated_members,
    )


@router.post(
    "/split-hbi/",
    response_model=SplitHBIResponse,
    summary="Evaluate homology transfer between dataset splits via easy_search lookup",
    dependencies=[Depends(RateLimiter(times=30, seconds=60))],
)
def split_hbi(payload: SplitHBIRequest):
    try:
        # MMseqs2 easy_search Top-1 lookup
        top_hits = run_easy_search_lookup(
            train_seqs=payload.train_seqs,
            query_seqs=payload.query_seqs,
            evalue_cutoff=payload.evalue_cutoff,
            min_seq_id=payload.min_seq_id,
        )

        # Bootstrapped split metrics
        raw_metrics = compute_hbi_metrics_from_lookup(
            train_labels=payload.train_labels,
            query_labels=payload.query_labels,
            top_hits_df=top_hits,
            is_numeric=payload.is_numeric,
            iterations=payload.iterations,
        )
    except Exception as e:
        logger.error(f"Split HBI execution error: {e}")
        raise HTTPException(status_code=500, detail=f"Split HBI execution error: {str(e)}")

    evaluated_queries = raw_metrics[0]["sample_size"] if raw_metrics else 0
    metric_dtos = [BootstrappedMetricDTO(**m) for m in raw_metrics]

    return SplitHBIResponse(
        metrics=metric_dtos,
        num_queries=len(payload.query_seqs),
        hits_found=len(top_hits),
        evaluated_queries=evaluated_queries,
    )
