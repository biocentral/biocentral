from typing import List, Dict, Optional
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
    target_data: Dict[str, str] = Field(
        ..., 
        description="Map of sequence_id -> target label/value for evaluation"
    )

class ClusterHBIResponse(BaseModel): 
    metric_type: str = Field(
        ..., 
        description="'accuracy' for categorical targets, 'mae' for numerical"
    )
    score: float = Field(
        ..., 
        description="Calculated HBI baseline score transferring rep label to members"
    )
    num_clusters: int = Field(..., description="Total clusters found")
    num_members: int = Field(..., description="Total non-representative member sequences")
    evaluated_members: int = Field(..., description="Number of evaluated non-singleton members")
