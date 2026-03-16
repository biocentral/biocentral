import torch

from biotrainer.utilities import get_device
from biotrainer.embedders import get_predefined_embedder_names


class DeviceService:
    @staticmethod
    def train_device() -> torch.device:
        return torch.device("cpu")

    @staticmethod
    def embedding_device(embedder_name: str) -> torch.device:
        if embedder_name in get_predefined_embedder_names():
            return torch.device("cpu")
        return get_device()

    @staticmethod
    def inference_device() -> torch.device:
        return torch.device("cpu")

    @staticmethod
    def prediction_device() -> torch.device:
        return get_device()
