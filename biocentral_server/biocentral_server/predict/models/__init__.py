from typing import Any, Dict, List

from .toxicity import ExoTox
from .binding import BindEmbed
from .base_model import BaseModel
from .variant_effect import VespaG
from .disorder import Seth, UdonPred
from .conservation import ProtT5Conservation
from .membrane import TMbed, LightAttentionMembrane
from .base_model.model_metadata import ModelMetadata
from .secondary_structure import ProtT5SecondaryStructure
from .localization import LightAttentionSubcellularLocalization
from .biocentral_prediction_model import BiocentralPredictionModel

MODEL_REGISTRY: Dict[BiocentralPredictionModel, Any] = {
    model_name: model_class
    for model_name, model_class in {
        TMbed.get_metadata().name: TMbed,
        LightAttentionMembrane.get_metadata().name: LightAttentionMembrane,
        LightAttentionSubcellularLocalization.get_metadata().name: LightAttentionSubcellularLocalization,
        Seth.get_metadata().name: Seth,
        UdonPred.get_metadata().name: UdonPred,
        BindEmbed.get_metadata().name: BindEmbed,
        ProtT5Conservation.get_metadata().name: ProtT5Conservation,
        ProtT5SecondaryStructure.get_metadata().name: ProtT5SecondaryStructure,
        VespaG.get_metadata().name: VespaG,
        ExoTox.get_metadata().name: ExoTox,
    }.items()
}

__all__ = [
    "BaseModel",
    "BiocentralPredictionModel",
    "ModelMetadata",
    "MODEL_REGISTRY",
]
