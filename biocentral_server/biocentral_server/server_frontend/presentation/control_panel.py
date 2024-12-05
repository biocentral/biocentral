import os
import re
import torch
import psutil
import logging
import tkinter as tk

from tkinter import ttk, scrolledtext

from .custom_widgets import StatusIndicator

from ...utils import Constants
from ...server_entrypoint import create_server_app, ServerThread
from ...server_management import FileManager, TaskManager, UserManager


class ControlPanel:
    def __init__(self, root):
        self.start_button = None
        self.stop_button = None
        self.server_status_indicator = None
        self.stats_label = None
        self.disk_usage_label = None
        self.n_process_label = None
        self.notebook = None
        self.logs_tab = None
        self.log_text = None
        self.stats_tab = None
        self.device_tab = None

        self.server_thread = None

        # Root - Main Window
        self.root = root
        self.root.title("Biocentral Server - Control Panel")

        # Widgets
        self.setup_widgets()
        self.setup_log_tab()
        self.setup_stats_tab()
        self.setup_device_tab()

        # Logging handler
        self.setup_logging_display()

        # Call update stats functions
        self.update_stats()
        self.update_recompute_stats()

    def setup_widgets(self):
        self.start_button = ttk.Button(self.root, text="Start Server", command=self.start_server)
        self.start_button.pack(pady=10)

        self.stop_button = ttk.Button(self.root, text="Stop Server", command=self.stop_server)
        self.stop_button.pack(pady=10)

        self.server_status_indicator = StatusIndicator(self.root, status_name="Server not running", status=False)

        self.notebook = ttk.Notebook(self.root)
        self.notebook.pack(expand=1, fill="both")

    def setup_log_tab(self):
        self.logs_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.logs_tab, text='Logs')
        self.log_text = scrolledtext.ScrolledText(self.logs_tab, state='disabled', height=10)
        self.log_text.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

    def setup_logging_display(self):
        log_handler = GUILogHandler(self.log_text)
        log_handler.setFormatter(logging.Formatter(Constants.LOGGER_FORMAT))
        logging.getLogger().addHandler(log_handler)
        logging.getLogger().setLevel(logging.INFO)

    def setup_stats_tab(self):
        self.stats_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.stats_tab, text='Statistics')

        self.stats_label = ttk.Label(self.stats_tab, text="Number of requests since start: 0")
        self.stats_label.pack(pady=10)

        self.disk_usage_label = ttk.Label(self.stats_tab, text="Currently used storage: 0 MB")
        self.disk_usage_label.pack(pady=10)

        self.n_process_label = ttk.Label(self.stats_tab, text=f"Current number of running tasks: 0")
        self.n_process_label.pack(pady=10)

    @staticmethod
    def _get_usable_cpu_count():
        try:
            # Try to use psutil, which works on Windows, Linux, and macOS
            return len(psutil.Process().cpu_affinity())
        except AttributeError:
            # If cpu_affinity is not available (e.g., on macOS), fall back to logical CPU count
            return psutil.cpu_count(logical=True)

    def setup_device_tab(self):
        self.device_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.device_tab, text='Devices')

        # CPU always available in PyTorch context
        StatusIndicator(self.device_tab, f"CPU (Total: {os.cpu_count()}, "
                                         f"Useable for server: {self._get_usable_cpu_count()})", True)

        # Check CUDA availability
        cuda_available = torch.cuda.is_available()
        StatusIndicator(self.device_tab, "CUDA", cuda_available)

        if cuda_available:
            for i in range(torch.cuda.device_count()):
                device_name = torch.cuda.get_device_name(i)
                StatusIndicator(self.device_tab, f"CUDA Device {i}: {device_name}", True)
        else:
            StatusIndicator(self.device_tab, "No CUDA Devices", False)

        # Check MPS availability
        mps_available = torch.backends.mps.is_available()
        StatusIndicator(self.device_tab, "MPS (only macOS)", mps_available)

    def start_server(self):
        if self.server_thread is None or not self.server_thread.is_alive():
            self.server_thread = ServerThread(create_server_app())
            self.server_thread.daemon = True
            self.server_thread.start()
            self.server_status_indicator.update_status(status_name="Server running", status=True)

    def stop_server(self):
        if self.server_thread is not None:
            self.server_thread.shutdown()
            self.server_status_indicator.update_status(status_name="Server was shut down", status=False)
            self.server_thread = None

    def update_stats(self):
        """
        Update stats that do not need to be computed every second
        """
        repeat = 1000  # 1s

        number_requests_since_start = UserManager.get_total_number_of_requests_since_start()
        self.stats_label.config(text=f"Number of requests since start: {number_requests_since_start}")

        n_processes = TaskManager().get_current_number_of_running_tasks()
        self.n_process_label.config(text=f"Current number of running tasks: {n_processes}")

        self.root.after(repeat, self.update_stats)

    def update_recompute_stats(self):
        """
        Update stats that need to be re-computed only every ten seconds
        """
        repeat = 10000  # 10s

        disk_usage: str = FileManager.get_disk_usage()
        self.disk_usage_label.config(text=f"Currently used storage: {disk_usage} MB")

        self.root.after(repeat, self.update_recompute_stats)


class GUILogHandler(logging.Handler):
    def __init__(self, text_widget):
        super().__init__()
        self.text_widget = text_widget
        self.create_tags()

    def create_tags(self):
        # Define tags for various ANSI colors in the Tkinter text widget
        colors = {
            '30': 'black',  # Foreground black
            '31': 'red',  # Foreground red
            '32': 'green',  # Foreground green
            '33': 'yellow',  # Foreground yellow
            '34': 'blue',  # Foreground blue
            '35': 'magenta',  # Foreground magenta
            '36': 'cyan',  # Foreground cyan
            '37': 'white',  # Foreground white
        }
        for code, color in colors.items():
            self.text_widget.tag_configure("fg" + code, foreground=color)

    def emit(self, record):
        msg = self.format(record)
        self.text_widget.configure(state='normal')
        parts = re.split(r'(\x1B\[[0-9;]*m)', msg)
        tag = 'default'
        for part in parts:
            # Extract ANSI escape codes and map them to the corresponding tag
            ansi_escape = re.match(r'\x1B\[([0-9;]*)m', part)
            if ansi_escape:
                codes = ansi_escape.group(1).split(';')
                # Use the last color code in the sequence
                for code in codes:
                    if code in ('30', '31', '32', '33', '34', '35', '36', '37'):
                        tag = 'fg' + code
                        break
            else:
                self.text_widget.insert(tk.END, part, tag)
        self.text_widget.insert(tk.END, "\n", 'black')
        self.text_widget.configure(state='disabled')
        self.text_widget.yview(tk.END)
