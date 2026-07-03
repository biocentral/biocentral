import altair as alt
import pandas as pd

from typing import List, Set, Optional

from biocentral_api import ProjectionResult
from biotrainer_core.data_classes import SequenceData


def plot_projection_result(projection_result: ProjectionResult,
                           dataset: List[SequenceData],
                           color_attribute: str = "TARGET",
                           highlight_ids: Optional[Set[str]] = None,
                           highlight_name : Optional[str] = "highlight",
                           ):
    projections_data = projection_result.projections_data
    identifier = projections_data.identifier
    coord_map = {seq_id: (projections_data.x[idx], projections_data.y[idx], projections_data.z[idx]) for idx, seq_id in
                 enumerate(identifier)}
    seq_data_by_id = {seq_data.seq_id: seq_data for seq_data in dataset}
    highlight_ids = highlight_ids or set()
    # Prepare data for plotting
    plot_data = []
    highlight_data = []  # Save highlight data separately and add it in the end to keep coloring order
    all_labels = set()  # Collect all unique labels

    for seq_id in identifier:
        if seq_id in seq_data_by_id:
            seq_data = seq_data_by_id[seq_id]
            x, y, z = coord_map[seq_id]
            is_highlight = seq_id in highlight_ids
            label = str(seq_data.get_attribute(color_attribute))
            if is_highlight:
                label = str(highlight_name)
            all_labels.add(label)
            data_dict = {
                'seq_id': seq_id,
                'x': x,
                'y': y,
                'z': z,
                'label': label
            }
            if is_highlight:
                highlight_data.append(data_dict)
            else:
                plot_data.append(data_dict)

    plot_data.extend(highlight_data)
    # Create DataFrame
    df = pd.DataFrame(plot_data)

    # Create fixed domain: original labels (sorted) + highlight at the end
    color_domain = sorted(list(all_labels))
    color_range = alt.Color('label:N',
                            title=color_attribute,
                            scale=alt.Scale(
                                domain=color_domain + ([highlight_name] if highlight_ids else []),
                                range=['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b'] + (
                                    ['#FF0000'] if highlight_ids else [])
                            ),
                            sort=color_domain + ([highlight_name] if highlight_ids else []))

    # Create Altair scatter plot
    chart = alt.Chart(df).mark_circle(size=60).encode(
        x=alt.X('x:Q', title='X Coordinate'),
        y=alt.Y('y:Q', title='Y Coordinate'),
        color=alt.Color('label:N',
                        title=color_attribute,
                        scale=alt.Scale(domain=color_domain),
                        sort=color_domain),
        tooltip=['seq_id:N', 'x:Q', 'y:Q', 'z:Q', 'label:N']
    ).properties(
        width=600,
        height=400,
        title='Projection Result'
    ).interactive()

    # Prepare metadata
    metadata = {
        'type': 'projection_scatter',
        'n_points': len(plot_data),
        'color_attribute': color_attribute,
        'n_labels': df['label'].nunique(),
        'projection_method': projection_result.projection_method if hasattr(projection_result,
                                                                            'projection_method') else 'unknown',
        'dimensions': 3 if 'z' in df.columns else 2
    }

    return chart, metadata
