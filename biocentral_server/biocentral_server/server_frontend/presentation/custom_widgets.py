import sys

import pystray
import tkinter as tk
from PIL import Image
from tkinter import ttk
from pystray import MenuItem


class StatusIndicator:

    def __init__(self, parent, status_name: str, status: bool):
        self.frame = ttk.Frame(parent, padding=5)
        self.frame.pack(pady=5, padx=10, fill=tk.X)

        self.label = ttk.Label(self.frame, text=status_name)
        self.label.pack(side=tk.LEFT)

        self.canvas = tk.Canvas(self.frame, width=20, height=20, bd=0, highlightthickness=0)
        self.canvas.pack(side=tk.RIGHT, padx=10)

        color = self._get_color(status)
        # Draw a filled circle in the canvas
        self.oval_id = self.canvas.create_oval(2, 2, 18, 18, fill=color, outline="")

    @staticmethod
    def _get_color(status: bool):
        return "green" if status else "red"

    def update_status(self, status_name: str, status: bool):
        self.label.config(text=status_name)
        color = self._get_color(status)
        self.canvas.itemconfig(self.oval_id, fill=color)


class SysTray:
    def __init__(self, root, control_panel):
        self.root = root
        self.icon = self._create_icon()
        self.control_panel = control_panel

    def _create_icon(self):
        self.menu = (MenuItem('Show UI', self.show_window), MenuItem('Stop Server', self.stop_server),
                     MenuItem('Quit', self.quit_window))
        image = Image.open("assets/icons/biocentral_icon.ico")
        return pystray.Icon("Biocentral Server", image, "Biocentral Server", self.menu)

    def show_window(self, icon, item):
        self.icon.stop()
        self.root.after(0, self.root.deiconify())

    def hide_window(self):
        if self.control_panel.server_thread is None:
            self.quit_window(self.icon, None)
        else:
            self.root.withdraw()
            self.icon = self._create_icon()
            self.icon.run()

    def stop_server(self):
        self.control_panel.stop_server()

    def quit_window(self, icon, item):
        self.icon.stop()
        self.root.destroy()
