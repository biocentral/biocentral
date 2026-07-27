from pydantic import BaseModel, Field, field_validator

from ..request_validation import validate_embedder_name


class EmbedderModelBase(BaseModel):
    embedder_name: str = Field(
        description="Name of the embedder model to use",
        examples=[
            "one_hot_encoding",
            "Rostlab/ProstT5",
            "facebook/esm2_t33_650M_UR50D",
        ],
    )

    @field_validator("embedder_name")
    @classmethod
    def check_embedder_name(cls, v: str) -> str:
        maybe_error = validate_embedder_name(v)
        if maybe_error is not None:
            raise ValueError(maybe_error)
        return v
