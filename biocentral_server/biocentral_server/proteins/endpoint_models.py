from typing import List, Dict, Optional, Any
from pydantic import BaseModel, Field


class TaxonomyItem(BaseModel):
    taxonomy_id: int
    name: str
    family: str


class TaxonomyRequest(BaseModel):
    taxonomy_ids: List[int] = Field(
        min_length=1, description="List of taxonomy ids", examples=[9606, 1, 11292]
    )


class TaxonomyResponse(BaseModel):
    taxonomy: List[TaxonomyItem] = Field(description="List of taxonomy lookup results")


class ClusteringRequest(BaseModel):
    sequence_data: Dict[str, str] = Field(
        ...,
        description="Dictionary mapping sequence IDs to their amino acid sequence strings",
    )
    sequence_identity_threshold: float = Field(
        default=0.3,
        ge=0.0,
        le=1.0,
        description="Sequence identity threshold for clustering (between 0.0 and 1.0)",
    )

class BootstrappedMetricDTO(BaseModel):
    name: str = Field(..., description="Metric name, e.g accuracy, matthews-correlation-coefficient, mse")
    mean: float = Field(..., description="Mean score over bootstrap iterations")
    lower: float = Field(..., description="Lower confidence interval bound (default 95% CI)")
    upper: float = Field(..., description="Upper confidence interval bound (default 95% CI)")
    iterations: int = Field(..., description="Number of bootstrap iterations performed")
    sample_size: int = Field(..., description="Sample size evaluated in each iteration")

class ClusterHBIRequest(BaseModel): 
    dataset_hash: str = Field(
        ..., 
        description="Unique hash of the dataset for caching"
    )
    sequence_identity_threshold: float = Field(
        default=0.3, 
        ge=0.0, 
        le=1.0, 
        description="Sequence identity threshold for clustering"
    )
    sequence_data: Optional[Dict[str, str]] = Field(
        default= None, 
        description="Map of sequence_id -> sequence. Required on first call"
    )
    target_data: Dict[str, Any] = Field(
        ..., 
        description="Map of sequence_id -> target label/value for evaluation"
    )
    is_numeric: bool = Field(
        default=False,
        description="True for continuous regression targets, False for classification"
    )
    iterations: int = Field(default=30, description="Bootstrap iterations performed")

class ClusterHBIResponse(BaseModel): 
    metrics: List[BootstrappedMetricDTO] = Field(..., description="Bootstrapped evaluation metrics")
    num_clusters: int = Field(..., description="Total clusters found")
    num_members: int = Field(..., description="Total non-representative member sequences")
    evaluated_members: int = Field(..., description="Number of evaluated non-singleton members")

class SplitHBIRequest(BaseModel):
    train_seqs: Dict[str, str] = Field(..., description="Target database sequences (train split)")
    query_seqs: Dict[str, str] = Field(..., description="Query database sequences to evaluate (test/val split)")
    train_labels: Dict[str, Any] = Field(..., description="Ground truth annotations for train sequences")
    query_labels: Dict[str, Any] = Field(..., description="Ground truth annotations for query sequences")
    evalue_cutoff: float = Field(default=10.0, description="Maximum MMSeqs2 E-value threshold")
    min_seq_id: float = Field(default=0.0, description="Minimum sequence identity threshold")
    is_numeric: bool = Field(default=False, description="True for continuous regression targets, False for classification")
    iterations: int = Field(default=30, description="Bootstrap iterations performed")

class SplitHBIResponse(BaseModel):
    metrics: List[BootstrappedMetricDTO] = Field(..., description="Bootstrapped evaluation metrics")
    num_queries: int = Field(..., description="Total number of query sequences provided")
    hits_found: int = Field(..., description="Number of queries with homologous hits in train")
    evaluated_queries: int = Field(..., description="Number of queries successfully evaluated")