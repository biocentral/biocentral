import altair as alt
import pandas as pd

from typing import List

from biocentral_api import ProjectionResult
from biotrainer_core.data_classes import SequenceData


def plot_projection_result(projection_result: ProjectionResult, dataset: List[SequenceData]):
    projections_data = projection_result.projections_data
    identifier = projections_data.identifier
    coord_map = {seq_id: (projections_data.x[idx], projections_data.y[idx], projections_data.z[idx]) for idx, seq_id in
                 enumerate(identifier)}
    seq_data_by_id = {seq_data.seq_id: seq_data for seq_data in dataset}

    # Prepare data for plotting
    plot_data = []
    for seq_id in identifier:
        if seq_id in seq_data_by_id:
            x, y, z = coord_map[seq_id]
            label = seq_data_by_id[seq_id].label
            plot_data.append({
                'seq_id': seq_id,
                'x': x,
                'y': y,
                'z': z,
                'label': str(label)  # Convert to string for discrete coloring
            })

    # Create DataFrame
    df = pd.DataFrame(plot_data)

    # Create Altair scatter plot
    chart = alt.Chart(df).mark_circle(size=60).encode(
        x=alt.X('x:Q', title='X Coordinate'),
        y=alt.Y('y:Q', title='Y Coordinate'),
        color=alt.Color('label:N', title='Label'),
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
        'n_labels': df['label'].nunique(),
        'projection_method': projection_result.projection_method if hasattr(projection_result,
                                                                            'projection_method') else 'unknown',
        'dimensions': 3 if 'z' in df.columns else 2
    }

    return chart, metadata
