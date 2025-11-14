from enum import Enum
from dataclasses import dataclass
from typing import Dict, List, Tuple, Type
from biotrainer.protocols import Protocol


class OutputType(Enum):
    PER_RESIDUE = "per_residue"
    PER_SEQUENCE = "per_sequence"
    MUTATION = "mutation"


@dataclass
class OutputClass:
    label: str
    description: str


@dataclass
class ModelOutput:
    name: str
    description: str
    output_type: OutputType
    value_type: Type
    classes: Dict[str, OutputClass] = None  # for categorical outputs
    value_range: Tuple[float, float] = None  # for continuous outputs
    unit: str = None  # optional, for numerical outputs

    def __post_init__(self):
        # Validate classes and value_range mutual exclusivity
        if self.classes is not None and self.value_range is not None:
            raise ValueError("Cannot specify both classes and value_range")

        if self.value_type == "class":
            if self.classes is None:
                raise ValueError("Must specify classes for value_type 'class'")
            if self.value_range is not None:
                raise ValueError("Cannot specify value_range for value_type 'class'")
            if self.unit is not None:
                raise ValueError("Cannot specify unit for value_type 'class'")

        if self.value_type == "float":
            if self.classes is not None:
                raise ValueError("Cannot specify classes for value_type 'float'")
            if self.value_range is None:
                raise ValueError("Must specify value_range for value_type 'float'")

        # Validate value_range if present
        if self.value_range is not None:
            if len(self.value_range) != 2:
                raise ValueError("value_range must be a tuple of (min, max)")
            if self.value_range[0] >= self.value_range[1]:
                raise ValueError("value_range[0] must be less than value_range[1]")

        # Validate classes if present
        if self.classes is not None:
            if not self.classes:
                raise ValueError("classes dictionary cannot be empty")
            for key, value in self.classes.items():
                if not isinstance(value, OutputClass):
                    raise ValueError(
                        f"classes values must be OutputClass instances, got {type(value)}"
                    )


@dataclass
class ModelMetadata:
    name: str
    protocol: Protocol
    description: str
    authors: str
    model_link: str
    citation: str
    licence: str
    outputs: List[ModelOutput]
    model_size: str
    testset_performance: str
    training_data_link: str
    embedder: str

    def to_dict(self):
        return {
            "name": self.name,
            "protocol": self.protocol.name,
            "description": self.description,
            "authors": self.authors,
            "model_link": self.model_link,
            "citation": self.citation,
            "licence": self.licence,
            "outputs": [
                {
                    "name": output.name,
                    "description": output.description,
                    "output_type": output.output_type.name,
                    "value_type": str(output.value_type),
                    "classes": {
                        k: {"label": v.label, "description": v.description}
                        for k, v in output.classes.items()
                    }
                    if output.classes
                    else None,
                    "value_range": output.value_range,
                    "unit": output.unit,
                }
                for output in self.outputs
            ],
            "model_size": self.model_size,
            "testset_performance": self.testset_performance,
            "training_data_link": self.training_data_link,
            "embedder": self.embedder,
        }
