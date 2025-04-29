from typing import Union
from dataclasses import dataclass
from vespag.utils import Mutation
from biotrainer.protocols import Protocol


@dataclass
class Prediction:
    """Base class for all model predictions."""
    model_name: str
    prediction_name: str
    protocol: Protocol
    prediction: Union[str, float]


@dataclass
class MutationPrediction(Prediction):
    mutation: Mutation
