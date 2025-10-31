from typing import List
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
