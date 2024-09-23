import os
import sys


def get_asset_path(path: str) -> str:
    if getattr(sys, 'frozen', False):
        # running in a PyInstaller bundle
        bundle_dir = sys._MEIPASS
        return os.path.join(bundle_dir, path)
    return path
