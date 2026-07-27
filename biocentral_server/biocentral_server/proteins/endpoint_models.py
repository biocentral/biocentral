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
        description="Dictionary mapping sequence IDs to their amino acid sequence strings"
    )
    sequence_identity_threshold: float = Field(
        default=0.3, 
        ge=0.0, 
        le=1.0, 
        description="Sequence identity threshold for clustering (between 0.0 and 1.0)"
    )
    