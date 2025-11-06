from typing import Union, Optional
from vespag.utils import Mutation
from pydantic import BaseModel, Field


class Prediction(BaseModel):
    """Base class for all model predictions."""

    model_name: str = Field(description="Name of the model")
    prediction_name: str = Field(description="Name of the prediction")
    protocol: str = Field(description="Protocol name")
    prediction: Union[str, float] = Field(description="Prediction value")
    prediction_lower: Optional[float] = Field(
        default=None, description="Lower bound of the prediction"
    )
    prediction_upper: Optional[float] = Field(
        default=None, description="Upper bound of the prediction"
    )


class MutationPrediction(Prediction):
    mutation: Mutation
