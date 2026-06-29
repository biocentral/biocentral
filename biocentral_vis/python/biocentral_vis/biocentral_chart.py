import tempfile
import altair as alt

from pathlib import Path
from biocentral_api import ProjectionResult
from typing import List, Union, Dict, Any, Optional
from biotrainer_core.data_classes import SequenceData, BiotrainerModelResult

from .base import BiocentralVisualization
from .datasets import plot_label_distribution
from .projections import plot_projection_result
from .models import plot_test_set_performance, plot_loss_curves


class BiocentralChart(BiocentralVisualization):

    def __init__(self, chart: alt.Chart, metadata: Dict[str, Any]):
        self.chart = chart
        self.metadata = metadata

    @classmethod
    def label_distribution(cls, dataset: List[SequenceData]):
        chart, metadata = plot_label_distribution(dataset)
        return cls(chart, metadata)

    @classmethod
    def model_loss_curve(cls, model_result: BiotrainerModelResult, cv_split: str = "hold_out"):
        chart, metadata = plot_loss_curves(model_result, cv_split)
        return cls(chart, metadata)

    @classmethod
    def model_test_set_performance(cls, model_result: BiotrainerModelResult, metric_name: str):
        chart, metadata = plot_test_set_performance(model_result, metric_name)
        return cls(chart, metadata)

    @classmethod
    def projection_result(cls, projection_result: ProjectionResult, dataset: List[SequenceData]):
        chart, metadata = plot_projection_result(projection_result, dataset)
        return cls(chart, metadata)

    def to_svg(self) -> str:
        with tempfile.NamedTemporaryFile(suffix='.svg', delete=False) as tmp:
            self.chart.save(tmp.name)
            tmp_path = Path(tmp.name)
            svg_content = tmp_path.read_text()
            tmp_path.unlink()
            return svg_content

    def get_chart(self) -> Optional[alt.Chart]:
        return self.chart

    def save(self, output_path: Union[str, Path]):
        self.chart.save(output_path)
