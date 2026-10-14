from __future__ import annotations

from typing import List, Optional, Any, Dict

from biotrainer_core.data_classes import SequenceData
from biotrainer_core.data_classes.metrics import BootstrappedMetric
from pydantic import BaseModel, Field, field_validator

from ..server_management import validate_embedder_name


class ErrorResponse(BaseModel):
    """Standard error response model"""

    error: str
    detail: Optional[str] = None


class ConfigVerificationRequest(BaseModel):
    """Request model for config verification"""

    config_dict: Dict[str, Any] = Field(
        description="Biotrainer configuration", min_length=1
    )

    @field_validator("config_dict")
    @classmethod
    def check_embedder_name(cls, v) -> str:
        maybe_embedder_name = v.get("embedder_name")
        if not maybe_embedder_name:
            return v
        maybe_error = validate_embedder_name(maybe_embedder_name)
        if maybe_error is not None:
            raise ValueError(maybe_error)
        return v


class ConfigVerificationResponse(BaseModel):
    """Response model for config verification"""

    error: str = Field(
        default="",
        description="Empty string if verification successful, error message otherwise",
    )


class ConfigOptionsResponse(BaseModel):
    options: List = Field(description="List of configuration option dictionaries")


class StartTrainingRequest(BaseModel):
    config_dict: Dict[str, Any] = Field(
        description="Biotrainer configuration", min_length=1
    )
    training_data: List[SequenceData] = Field(
        description="List of sequence training data", min_length=1
    )

    @field_validator("config_dict")
    @classmethod
    def check_embedder_name(cls, v) -> str:
        maybe_embedder_name = v.get("embedder_name")
        if not maybe_embedder_name:
            return v
        maybe_error = validate_embedder_name(maybe_embedder_name)
        if maybe_error is not None:
            raise ValueError(maybe_error)
        return v


class ModelFilesRequest(BaseModel):
    model_hash: str = Field(description="Hash identifier for the trained model")


class ModelFilesResponse(BaseModel):
    # TODO Define explicitly
    """Response model for model files"""

    # The actual structure depends on what file_manager.get_biotrainer_result_files returns
    # This is a flexible model that can handle various file dictionaries
    model_config = {"extra": "allow"}  # Allow additional fields


class StartInferenceRequest(BaseModel):
    """Request model for starting inference"""

    model_hash: str = Field(
        description="Hash identifier for the trained model to use for inference"
    )
    sequence_data: Dict[str, str] = Field(
        description="Sequence data for inference (seq_id -> sequence)", min_length=1
    )


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
    metrics: List[BootstrappedMetric] = Field(..., description="Bootstrapped evaluation metrics")
    clusters: Dict[str, List[str]] = Field(..., description="Calculated cluster dictionary (rep_id -> members)")

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
    metrics: List[BootstrappedMetric] = Field(..., description="Bootstrapped evaluation metrics")
    num_queries: int = Field(..., description="Total number of query sequences provided")
    hits_found: int = Field(..., description="Number of queries with homologous hits in train")
    evaluated_queries: int = Field(..., description="Number of queries successfully evaluated")
