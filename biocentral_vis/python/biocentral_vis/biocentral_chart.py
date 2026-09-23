import tempfile
import altair as alt

from pathlib import Path
from biocentral_api import ProjectionResult
from typing import List, Union, Dict, Any, Optional, Set, Callable
from biotrainer_core.data_classes import SequenceData, BiotrainerModelResult, Variant, VariantScore

from .base import BiocentralVisualization
from .datasets import (
    plot_label_distribution,
    plot_split_distribution,
    plot_labels_by_split_distribution,
    plot_sequence_length_distribution,
    plot_mutation_depth_distribution,
    plot_variant_score_distribution,
)
from .projections import plot_projection_result
from .models import plot_test_set_performance, plot_loss_curves


class BiocentralChart(BiocentralVisualization):
    def __init__(self, default_chart_name: str, chart: alt.Chart, metadata: Dict[str, Any]):
        self._default_chart_name = default_chart_name
        self.chart = chart
        self.metadata = metadata

    @classmethod
    def sequence_length_distribution(cls, dataset: List[SequenceData]):
        chart, metadata = plot_sequence_length_distribution(dataset)
        return cls("sequence_length_distribution", chart, metadata)

    @classmethod
    def label_distribution(cls, dataset: List[SequenceData],
                           labels_filter: Optional[Callable[[str], bool]] = None):
        """ Plot the distribution of labels in the dataset.
        Filter function must return True if the label should be considered for plotting. """
        chart, metadata = plot_label_distribution(dataset, labels_filter)
        return cls("label_distribution", chart, metadata)

    @classmethod
    def split_distribution(cls, dataset: List[SequenceData]):
        chart, metadata = plot_split_distribution(dataset)
        return cls("split_distribution", chart, metadata)

    @classmethod
    def labels_by_split_distribution(cls, dataset: List[SequenceData],
                                     labels_filter: Optional[Callable[[str], bool]] = None):
        """ Plot the distribution of labels in the dataset by training/val/test split.
        Filter function must return True if the label should be considered for plotting. """
        chart, metadata = plot_labels_by_split_distribution(dataset, labels_filter)
        return cls("labels_by_split_distribution", chart, metadata)

    @classmethod
    def mutation_depth_distribution(cls, dataset: List[Variant]):
        chart, metadata = plot_mutation_depth_distribution(dataset)
        return cls("mutation_depth_distribution", chart, metadata)

    @classmethod
    def variant_score_distribution(cls, dataset: List[VariantScore]):
        chart, metadata = plot_variant_score_distribution(dataset)
        return cls("variant_score_distribution", chart, metadata)

    @classmethod
    def model_loss_curve(
        cls, model_result: BiotrainerModelResult, cv_split: str = "hold_out"
    ):
        chart, metadata = plot_loss_curves(model_result, cv_split)
        return cls("model_loss_curve", chart, metadata)

    @classmethod
    def model_test_set_performance(
        cls, model_result: BiotrainerModelResult, metric_name: str
    ):
        chart, metadata = plot_test_set_performance(model_result, metric_name)
        return cls("model_test_set_performance", chart, metadata)

    @classmethod
    def projection_result(
        cls,
        projection_result: ProjectionResult,
        dataset: List[SequenceData],
        color_attribute: str = "TARGET",
        highlight_ids: Optional[Set[str]] = None,
        highlight_name: Optional[str] = "highlight",
    ):
        chart, metadata = plot_projection_result(
            projection_result,
            dataset,
            color_attribute=color_attribute,
            highlight_ids=highlight_ids,
            highlight_name=highlight_name,
        )
        return cls("projection_result", chart, metadata)

    def to_svg(self) -> str:
        with tempfile.NamedTemporaryFile(suffix=".svg", delete=False) as tmp:
            self.chart.save(tmp.name)
            tmp_path = Path(tmp.name)
            svg_content = tmp_path.read_text()
            tmp_path.unlink()
            return svg_content

    def to_png(self) -> bytes:
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
            self.chart.save(tmp.name)
            tmp_path = Path(tmp.name)
            png_bytes = tmp_path.read_bytes()
            tmp_path.unlink()
            return png_bytes

    def get_chart(self) -> Optional[alt.Chart]:
        return self.chart

    def save(self, output_path: Union[str, Path]):
        output_path = Path(output_path)
        if output_path.is_dir():
            output_path = output_path / f"{self._default_chart_name}.svg"
            format = "svg"
        else:
            format = output_path.suffix.strip(".")
        self.chart.save(output_path, format=format)
