from pydantic import BaseModel, Field, field_validator

from typing import Optional

from ..server_management import validate_identifier


class AutoDetectFormatRequest(BaseModel):
    header: str


class DetectedFormatResponse(BaseModel):
    detected_format: str


class RunTestRequest(BaseModel):
    hash: str
    test: str

    @field_validator("hash")
    @classmethod
    def validate_hash(cls, value: str) -> str:
        return validate_identifier(value)


class PPITestResult(BaseModel):
    success: str
    information: str
    test_metrics: str
    test_statistic: str
    p_value: str
    significance_level: Optional[float]


class RunTestResponse(BaseModel):
    test_result: PPITestResult


class ImportDatasetRequest(BaseModel):
    format: str
    dataset: str = Field(max_length=50 * 1024 * 1024)


class ImportDatasetResponse(BaseModel):
    imported_dataset: dict
