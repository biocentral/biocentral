from typing import Any, Dict, List

from .disorder import SETH
from .binding import BindEmbed
from .variant_effect import VespaG
from .conservation import ProtT5Conservation
from .membrane import TMbed, LightAttentionMembrane
from .secondary_structure import ProtT5SecondaryStructure
from .localization import LightAttentionSubcellularLocalization


MODEL_REGISTRY: Dict[str, Any] = {
    TMbed.get_metadata().name: TMbed,
    LightAttentionMembrane.get_metadata().name: LightAttentionMembrane,
    LightAttentionSubcellularLocalization.get_metadata().name: LightAttentionSubcellularLocalization,
    SETH.get_metadata().name: SETH,
    BindEmbed.get_metadata().name: BindEmbed,
    ProtT5Conservation.get_metadata().name: ProtT5Conservation,
    ProtT5SecondaryStructure.get_metadata().name: ProtT5SecondaryStructure,
    VespaG.get_metadata().name: VespaG,
}


def filter_models(model_names: List[str]) -> Dict[str, Any]:
    assert all([model_name in MODEL_REGISTRY for model_name in model_names]), (
        "Invalid model name, this should have been caught in the endpoint"
    )

    return {
        model_name: MODEL_REGISTRY[model_name]
        for model_name in model_names
        if model_name in MODEL_REGISTRY
    }


def get_metadata_for_all_models() -> Dict[str, Any]:
    return {name: model.get_metadata() for name, model in MODEL_REGISTRY.items()}
