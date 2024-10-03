import os
import sys
import tempfile


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
