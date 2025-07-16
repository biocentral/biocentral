from typing import Union
from dataclasses import dataclass
from vespag.utils import Mutation


@dataclass
class Prediction:
    """Base class for all model predictions."""

    model_name: str
    prediction_name: str
    protocol: str
    prediction: Union[str, float]


@dataclass
class MutationPrediction(Prediction):
    mutation: Mutation
