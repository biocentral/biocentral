from typing import Any, Dict, List

from .disorder import Seth
from .toxicity import ExoTox
from .binding import BindEmbed
from .base_model import BaseModel
from .variant_effect import VespaG
from .conservation import ProtT5Conservation
from .membrane import TMbed, LightAttentionMembrane
from .secondary_structure import ProtT5SecondaryStructure
from .localization import LightAttentionSubcellularLocalization

MODEL_REGISTRY: Dict[str, Any] = {
    name.lower(): model_class
    for name, model_class in {
        TMbed.get_metadata().name: TMbed,
        LightAttentionMembrane.get_metadata().name: LightAttentionMembrane,
        LightAttentionSubcellularLocalization.get_metadata().name: LightAttentionSubcellularLocalization,
        Seth.get_metadata().name: Seth,
        BindEmbed.get_metadata().name: BindEmbed,
        ProtT5Conservation.get_metadata().name: ProtT5Conservation,
        ProtT5SecondaryStructure.get_metadata().name: ProtT5SecondaryStructure,
        VespaG.get_metadata().name: VespaG,
        ExoTox.get_metadata().name: ExoTox,
    }.items()
}


def filter_models(model_names: List[str]) -> Dict[str, Any]:
    model_names = [model_name.lower() for model_name in model_names]

    assert all([model_name in MODEL_REGISTRY for model_name in model_names]), (
        "Invalid model name, this should have been caught in the endpoint"
    )

    return {
        model_name: MODEL_REGISTRY[model_name]
        for model_name in model_names
        if model_name in MODEL_REGISTRY
    }


def get_metadata_for_all_models() -> Dict[str, Any]:
    return {
        model.get_metadata().name: model.get_metadata()
        for _, model in MODEL_REGISTRY.items()
    }


__all__ = ["filter_models", "get_metadata_for_all_models", "BaseModel"]
