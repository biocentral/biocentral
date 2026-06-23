from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any, Union
from biocentral_api import Prediction

from .base import BiocentralVisualization
from .predictions import highlight_prediction


class BiocentralHighlight(BiocentralVisualization):
    """Visualize sequence with per-residue predictions as colored highlights"""

    def __init__(
            self,
            svg: str,
            metadata: Dict[str, Any],
    ):
        self.svg = svg
        self.metadata = metadata

    # Color schemes for common prediction types
    @classmethod
    def from_prediction(
            cls,
            sequence: str,
            prediction: Prediction,
            title: Optional[str] = None,
            residues_per_line: int = 100,
    ):
        """Factory method to create highlight from prediction"""
        svg, metadata = highlight_prediction(sequence=sequence, prediction=prediction,
                                             title=title, residues_per_line=residues_per_line)

        return cls(svg, metadata)

    def to_svg(self) -> str:
        return self.svg

    def save(self, output_path: Union[str, Path]):
        with open(output_path, "w") as f:
            f.write(self.svg)
