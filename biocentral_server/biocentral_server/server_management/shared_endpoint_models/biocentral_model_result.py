from biotrainer_core.data_classes import BiotrainerModelResult

from typing import Optional
from pydantic import BaseModel, Field


class BiocentralModelResult(BaseModel):
    model_result: BiotrainerModelResult = Field(description="Biotrainer Model Result containing config, "
                                                            "training and test results and metadata")
    logging_file: str = Field(description="Logging output during model training")
    checkpoints: list[bytes] = Field(description="List of bytes containing the checkpoint(s) of the model")
    onnx_checkpoint: Optional[list[bytes]] = Field(default=None,
                                                   description="Bytes containing the "
                                                               "ONNX-converted checkpoint(s) of the "
                                                               "model (if available)")
