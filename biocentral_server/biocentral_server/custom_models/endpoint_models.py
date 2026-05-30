from __future__ import annotations

from typing import List, Optional, Any, Dict

from biotrainer_core.data_classes import SequenceData
from pydantic import BaseModel, Field


class ErrorResponse(BaseModel):
    """Standard error response model"""

    error: str
    detail: Optional[str] = None


class ConfigVerificationRequest(BaseModel):
    """Request model for config verification"""

    config_dict: Dict[str, Any] = Field(
        description="Biotrainer configuration", min_length=1
    )


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
