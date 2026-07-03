from __future__ import annotations

from typing import List, Optional
from pydantic import BaseModel


class ProteinAnnotations(BaseModel):
    protein_id: List[str]


class ProjectionsMetadata(BaseModel):
    projection_name: List[str]
    dimensions: List[int]
    info_json: List[str]


class ProjectionsData(BaseModel):
    projection_name: List[str]
    identifier: List[str]
    x: List[float]
    y: List[float]
    z: List[Optional[float]]


class ProjectionResult(BaseModel):
    protein_annotations: ProteinAnnotations
    projections_metadata: ProjectionsMetadata
    projections_data: ProjectionsData
