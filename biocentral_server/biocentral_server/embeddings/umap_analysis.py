import umap
import numpy as np
import pandas as pd


def calculate_umap(embeddings: np.ndarray, random_state=42, n_neighbors=20, min_dist=0.1, n_components=2,
                   metric='euclidean'):
    fit = umap.UMAP(
        random_state=random_state,
        n_neighbors=n_neighbors,
        min_dist=min_dist,
        n_components=n_components,
        metric=metric
    )
    embedding_umap = fit.fit_transform(embeddings)
    df_umap = pd.DataFrame()
    df_umap["x"] = embedding_umap[:, 0]
    df_umap["y"] = embedding_umap[:, 1]
    return df_umap