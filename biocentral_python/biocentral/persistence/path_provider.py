from pathlib import Path
from platformdirs import user_cache_dir

class PathProvider:
    @staticmethod
    def _get_cache_dir() -> Path:
        cache_dir = Path(user_cache_dir("biocentral"))
        cache_dir.mkdir(parents=True, exist_ok=True)
        return cache_dir

    @staticmethod
    def get_models_dir() -> Path:
        models_dir = PathProvider._get_cache_dir() / "models"
        models_dir.mkdir(parents=True, exist_ok=True)
        return models_dir

    @staticmethod
    def get_embeddings_dir() -> Path:
        embed_dir = PathProvider._get_cache_dir() / "embeddings"
        embed_dir.mkdir(parents=True, exist_ok=True)
        return embed_dir

    @staticmethod
    def get_model_dir(model_hash: str) -> Path:
        model_dir = PathProvider.get_models_dir() / model_hash
        model_dir.mkdir(parents=True, exist_ok=True)
        return model_dir