import torch.multiprocessing as torch_mp

from .custom_models_endpoint import router

# Spawn new cuda contexts instead of forking:
# https://stackoverflow.com/questions/72779926/gunicorn-cuda-cannot-re-initialize-cuda-in-forked-subprocess
torch_mp.set_start_method("spawn", force=True)

__all__ = [
    "router",
]
