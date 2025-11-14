from pydantic import BaseModel

from typing import Optional


class AutoDetectFormatRequest(BaseModel):
    header: str


class DetectedFormatResponse(BaseModel):
    detected_format: str


class RunTestRequest(BaseModel):
    hash: str
    test: str


class TestResult(BaseModel):
    success: str
    information: str
    test_metrics: str
    test_statistic: str
    p_value: str
    significance_level: Optional[float]


class RunTestResponse(BaseModel):
    test_result: TestResult


class ImportDatasetRequest(BaseModel):
    format: str
    dataset: str


class ImportDatasetResponse(BaseModel):
    imported_dataset: dict
