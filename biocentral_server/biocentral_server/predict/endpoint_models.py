from typing import Dict, List, Any

from pydantic import BaseModel, Field, field_validator, ValidationInfo


class ModelMetadataResponse(BaseModel):
    metadata: Dict[str, Any]  # TODO IMPROVE


class PredictionRequest(BaseModel):
    model_names: List[str] = Field(
        min_length=1,
        description="List of model names to use for prediction",
        examples=["BindEmbed", "TMbed"],
    )
    sequence_input: Dict[str, str] = Field(
        min_length=1, description="Dictionary mapping sequence IDs to protein sequences"
    )

    @field_validator("sequence_input")
    def validate_sequences(cls, v, info: ValidationInfo):
        """Validate protein sequences"""
        min_seq_length = 7
        max_seq_length = 5000  # TODO: Make this configurable

        for seq_id, seq in v.items():
            if not isinstance(seq, str):
                raise ValueError(f"{seq_id} is not a string")
            if len(seq) < min_seq_length:
                raise ValueError(
                    f"{seq_id} is too short, min_seq_length={min_seq_length}, "
                    f"max_seq_length={max_seq_length}"
                )
            elif len(seq) > max_seq_length:
                raise ValueError(
                    f"{seq_id} is too long, max_seq_length={max_seq_length}, "
                    f"min_seq_length={min_seq_length}"
                )
        return v
