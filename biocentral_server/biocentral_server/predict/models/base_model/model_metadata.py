from enum import Enum
from pydantic import BaseModel, Field
from typing import Optional, List, Tuple
from biotrainer.protocols import Protocol

from ..biocentral_prediction_model import BiocentralPredictionModel


class OutputType(Enum):
    PER_RESIDUE = "per_residue"
    PER_SEQUENCE = "per_sequence"
    MUTATION = "mutation"


class OutputClass(BaseModel):
    shortcut: str = Field(description="Shortcut of the label")
    label: str = Field(description="Label of the class")
    description: str = Field(description="Description of the class")


class ModelOutput(BaseModel):
    name: str = Field(description="Name of the output")
    description: str = Field(description="Description of the output")
    output_type: OutputType = Field(description="Type of output")
    value_type: str = Field(description="Type of output values")
    classes: Optional[List[OutputClass]] = Field(
        default=None,
        description="List of output classes for categorical outputs",
    )
    value_range: Optional[Tuple[float, float]] = Field(
        default=None, description="Value range of predictions for continous outputs"
    )  # for continuous outputs
    unit: Optional[str] = Field(
        default=None, description="Optional unit for numerical outputs"
    )


class ModelMetadata(BaseModel):
    name: BiocentralPredictionModel = Field(description="Model name")
    protocol: Protocol = Field(
        description="Protocol of model predictions", examples=Protocol.all()
    )
    description: str = Field(description="Model description")
    authors: str = Field(description="Authors of the model")
    model_link: str = Field(description="Link to the model's repository")
    citation: str = Field(description="Citation of the model")
    licence: str = Field(description="Licence of the model")
    outputs: List[ModelOutput] = Field(
        description="List of descriptions of model outputs"
    )
    model_size: str = Field(description="Size of the model in MB")
    embedder: str = Field(description="Name of the embedder used for the model")
    training_data_link: Optional[str] = Field(
        default=None,
        description="Link to the training data used for training the model",
    )
