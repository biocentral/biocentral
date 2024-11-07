import os
import sys
import tempfile
from pathlib import Path
from appdirs import user_cache_dir


def get_bundle_dir() -> str:
    bundle_dir = ""
    if getattr(sys, 'frozen', False):
        # running in a PyInstaller bundle
        if hasattr(sys, '_MEIPASS'):
            # running from the extracted directory (onedir mode)
            bundle_dir = sys._MEIPASS
        else:
            # running in onefile mode
            bundle_dir = os.path.join(tempfile.gettempdir(), f'_MEI{os.getpid()}')
    return bundle_dir


def get_asset_path(path: str) -> str:
    if getattr(sys, 'frozen', False):
        bundle_dir = get_bundle_dir()
        return os.path.join(bundle_dir, path)
    return path


def get_cache_dir(cache_subdir: str) -> Path:
    cache_dir = user_cache_dir(cache_subdir)
    os.makedirs(cache_dir, exist_ok=True)
    return Path(cache_dir)
