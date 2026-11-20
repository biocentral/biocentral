from __future__ import annotations

from pydantic import BaseModel, Field, field_validator

from biotrainer_core.data_classes import ZeroShotMethod

class PerplexityResult(BaseModel):
    """ (Pseudo)perplexity result for a set of sequences (method depends on given protein language model)."""
    method: ZeroShotMethod = Field(description="Either perplexity or pseudoperplexity")
    seq2perplexity: dict[str, float] = Field(description="Dictionary mapping sequence "
                                                         "IDs to their (pseudo)perplexity scores")

    @field_validator("method")
    def validate_method(cls, value):
        if value not in [ZeroShotMethod.PERPLEXITY, ZeroShotMethod.PSEUDOPERPLEXITY]:
            raise ValueError("Invalid method. Must be either perplexity or pseudoperplexity.")
        return value

