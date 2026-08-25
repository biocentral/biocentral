from enum import Enum


class BiocentralPredictionModel(Enum):
    """Biocentral prediction model names (for usage in APIs)"""

    BindEmbed = "BindEmbed"
    ProtT5Conservation = "ProtT5Conservation"
    Seth = "Seth"
    LightAttentionSubcellularLocalization = "LightAttentionSubcellularLocalization"
    LightAttentionMembrane = "LightAttentionMembrane"
    TMbed = "TMbed"
    ProtT5SecondaryStructure = "ProtT5SecondaryStructure"
    ExoTox = "ExoTox"
    VespaG = "VespaG"
    UdonPred = "UdonPred"

    def to_onnx_dir_name(self):
        match self:
            case BiocentralPredictionModel.BindEmbed:
                return "bind_embed"
            case BiocentralPredictionModel.ProtT5Conservation:
                return "prott5_cons"
            case BiocentralPredictionModel.ProtT5SecondaryStructure:
                return "prott5_sec"
            case BiocentralPredictionModel.LightAttentionSubcellularLocalization:
                return "light_attention_subcell"
            case BiocentralPredictionModel.LightAttentionMembrane:
                return "light_attention_membrane"
            case BiocentralPredictionModel.TMbed:
                return "tmbed"
            case _:
                return self.name.lower()
