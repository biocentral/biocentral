import json
import altair as alt

from pathlib import Path
from abc import ABC, abstractmethod
from typing import Dict, Any, Union, Optional

from .exporter import CrossPlatformMetadataExporter


class BiocentralVisualization(ABC):
    """Base class for all biocentral visualizations"""
    metadata: Dict[str, Any]

    @abstractmethod
    def to_svg(self) -> str:
        """Convert visualization to SVG string"""
        pass

    @abstractmethod
    def save(self, output_path: Union[str, Path]):
        """Save data to file"""
        pass

    def save_export(self, output_path: Union[str, Path]):
        """Save export schema JSON File"""
        if Path(output_path).suffix != '.json':
            raise ValueError('Output path must have .json extension')

        export_data = self.export()
        with open(output_path, 'w') as f:
            json.dump(export_data, f)

    def get_metadata(self) -> Dict[str, Any]:
        """Get metadata about the visualization"""
        return self.metadata

    def get_chart(self) -> Optional[alt.Chart]:
        return None

    def export(self) -> Dict[str, Any]:
        """Create export schema dict"""
        svg = self.to_svg()
        metadata = self.get_metadata()
        chart = self.get_chart()
        exporter = CrossPlatformMetadataExporter(svg, metadata, chart)
        return exporter.export()
