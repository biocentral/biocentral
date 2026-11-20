from biotrainer_core.data_classes import BiotrainerModelResult

from typing import Optional
from pydantic import BaseModel, Field


class BiotrainerCheckpoint(BaseModel):
    name: str = Field(description="Name of the checkpoint (e.g. hold_out)")
    checkpoint: bytes = Field(description="Bytes containing the checkpoint")


class BiocentralModelResult(BaseModel):
    model_result: BiotrainerModelResult = Field(description="Biotrainer Model Result containing config, "
                                                            "training and test results and metadata")
    logging_file: str = Field(description="Logging output during model training")
    checkpoints: list[BiotrainerCheckpoint] = Field(
        description="List of bytes containing the checkpoint(s) of the model "
                    "(name -> checkpoint)")
    onnx_checkpoint: Optional[list[BiotrainerCheckpoint]] = Field(default=None,
                                                                  description="Bytes containing the "
                                                                              "ONNX-converted checkpoint(s) of the "
                                                                              "model (if available, name -> checkpoint)")
