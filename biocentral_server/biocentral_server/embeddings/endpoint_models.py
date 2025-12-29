import json

from enum import Enum
from typing import List, Dict, Any
from pydantic import BaseModel, Field, field_validator, ValidationInfo


class CommonEmbedder(str, Enum):
    """Common embedder model names"""

    # Huggingface pLMs
    ProtT5 = "Rostlab/prot_t5_xl_uniref50"
    ProstT5 = "Rostlab/ProstT5"
    ESM2_3B = "facebook/esm2_t36_3B_UR50D"
    ESM2_650M = "facebook/esm2_t33_650M_UR50D"
    ESM_8M = "facebook/esm2_t6_8M_UR50D"
    # Baseline models (biotrainer)
    ONE_HOT_ENCODING = "one_hot_encoding"
    RANDOM_EMBEDDER = "random_embedder"
    AAOntology = "AAOntology"
    BLOSUM62 = "blosum62"

    @classmethod
    def __get_pydantic_json_schema__(cls, core_schema, handler):
        json_schema = handler(core_schema)
        json_schema = handler.resolve_ref_schema(json_schema)
        # Add custom variable names for OpenAPI generator
        json_schema["x-enum-varnames"] = [e.name for e in cls]
        return json_schema


class EmbedRequest(BaseModel):
    embedder_name: str = Field(
        description="Name of the embedder model to use", examples=list(CommonEmbedder)
    )
    reduce: bool = Field(
        default="false", description="Whether to use dimensionality reduction"
    )
    sequence_data: Dict[str, str] = Field(
        description="Sequence data to embed (seq_id -> sequence)", min_length=1
    )
    use_half_precision: bool = Field(
        default="false", description="Whether to use half precision"
    )


class GetMissingEmbeddingsRequest(BaseModel):
    """Request model for checking missing embeddings"""

    sequences: str = Field(description="JSON string containing sequence data")
    embedder_name: str = Field(
        description="Name of the embedder model", examples=list(CommonEmbedder)
    )
    reduced: bool = Field(description="Whether to check for reduced embeddings")

    @field_validator("sequences")
    def validate_sequences(cls, v, info: ValidationInfo):
        """Validate that sequences is a valid JSON string"""
        try:
            parsed = json.loads(v)
            if not isinstance(parsed, dict):
                raise ValueError("sequences must be a JSON object (dictionary)")
            return v
        except json.JSONDecodeError:
            raise ValueError("sequences must be valid JSON")


class GetMissingEmbeddingsResponse(BaseModel):
    """Response model for missing embeddings check"""

    missing: List[str] = Field(
        description="List of sequence IDs that are missing embeddings"
    )


class AddEmbeddingsRequest(BaseModel):
    """Request model for adding embeddings"""

    h5_bytes: str = Field(description="Base64 encoded HDF5 file containing embeddings")
    sequences: str = Field(description="JSON string containing sequence data")
    embedder_name: str = Field(description="Name of the embedder model")
    reduced: bool = Field(description="Whether these are reduced embeddings")


class AddEmbeddingsResponse(BaseModel):
    success: bool = Field(
        description="Bool flag indicating whether embeddings were added successfully"
    )


class GetProjectionConfigResponse(BaseModel):
    """Response model for projection configuration"""

    projection_config: Dict[str, List] = Field(
        description="Projection configuration for each method"
    )


class ProjectionRequest(BaseModel):
    """Request model for projection"""

    sequence_data: Dict[str, str] = Field(
        description="Sequence data to embed (seq_id -> sequence)", min_length=1
    )
    method: str = Field(description="Projection method to use")
    config: Dict[str, Any] = Field(description="Projection configuration")
    embedder_name: str = Field(description="Name of the embedder model")
