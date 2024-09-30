import tkinter as tk
from ttkthemes import ThemedTk

from .presentation import ControlPanel, SysTray

from ..utils import get_asset_path


def run_frontend():
    root = ThemedTk(theme="breeze")
    root.geometry("640x480")
    root.resizable(False, False)
    root.iconphoto(False, tk.PhotoImage(file=get_asset_path("assets/icons/biocentral_icon.png")))

    control_panel = ControlPanel(root=root)

    sys_tray = SysTray(root=root, control_panel=control_panel)
    root.protocol('WM_DELETE_WINDOW', sys_tray.hide_window)

    root.mainloop()
