from ttkthemes import ThemedTk

from .presentation import ControlPanel, SysTray


def run_frontend():
    root = ThemedTk(theme="breeze")
    root.geometry("640x480")
    root.resizable(False, False)
    root.iconbitmap("assets/icons/biocentral_icon.ico")

    control_panel = ControlPanel(root=root)

    sys_tray = SysTray(root=root, control_panel=control_panel)
    root.protocol('WM_DELETE_WINDOW', sys_tray.hide_window)

    root.mainloop()
