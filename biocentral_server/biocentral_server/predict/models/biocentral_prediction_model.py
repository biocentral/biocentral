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
