from typing import List, Optional, Any, Dict

from biotrainer.input_files import BiotrainerSequenceRecord
from pydantic import BaseModel, Field, model_validator


class SequenceTrainingData(BaseModel):
    seq_id: str = Field(description="Sequence identifier", min_length=1)
    sequence: str = Field(description="AA Sequence", min_length=1)
    label: str = Field(description="Label to predict")
    set: str = Field(description="Set", examples=["train", "val", "test", "pred"])
    mask: Optional[str] = Field(default=None, description="MASK for per-residue tasks")

    @model_validator(mode="after")
    def validate_training_data(self):
        if self.mask is not None:
            if len(self.mask) != len(self.sequence):
                raise ValueError("Length of mask must match length of sequence")

        return self

    def to_biotrainer_seq_record(self) -> BiotrainerSequenceRecord:
        attributes = {"TARGET": self.label, "SET": self.set}
        if self.mask is not None:
            attributes["MASK"] = self.mask
        return BiotrainerSequenceRecord(
            seq_id=self.seq_id, seq=self.sequence, attributes=attributes
        )

    def to_fasta(self):
        fasta_str = f">{self.seq_id} TARGET={self.label} SET={self.set}"
        fasta_str += "\n" if self.mask is None else f"MASK={self.mask}\n"
        fasta_str += self.sequence
        return fasta_str


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


class ProtocolsResponse(BaseModel):
    """Response model for available protocols"""

    protocols: List[str] = Field(description="List of available protocol names")


# TODO Improve this model to match biotrainer config option format
class ConfigOption(BaseModel):
    key: str = Field(description="Configuration option key")
    value: Any = Field(description="Configuration option value")


class ConfigOptionsResponse(BaseModel):
    options: List[ConfigOption] = Field(
        description="List of configuration option dictionaries"
    )


class StartTrainingRequest(BaseModel):
    config_dict: Dict[str, Any] = Field(
        description="Biotrainer configuration", min_length=1
    )
    training_data: List[SequenceTrainingData] = Field(
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
