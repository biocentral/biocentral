"""Interactive TUI view for displaying server and database statistics."""

import curses
import subprocess
from pathlib import Path
from typing import Optional, Dict, Any, List, Tuple

from .core import (
    init_colors,
    safe_addstr,
    draw_header,
    draw_footer,
    draw_box,
    draw_card,
    run_with_curses,
    COLOR_DEFAULT,
    COLOR_PRIMARY,
    COLOR_HIGHLIGHT,
    COLOR_SUCCESS,
    COLOR_WARNING,
    COLOR_ERROR,
    COLOR_MUTED,
    COLOR_HEADER,
    COLOR_ACCENT,
)


def fetch_server_stats() -> Dict[str, Any]:
    """Fetch database and container statistics from local environment."""
    stats_data: Dict[str, Any] = {
        "db_connected": False,
        "db_stats": {},
        "service_stats": None,
        "docker_services": [],
        "error": None,
    }

    # 1. Attempt database statistics
    project_root = Path(__file__).parent.parent.parent.parent / "biocentral_server"
    env_file = project_root / ".env"
    if env_file.exists():
        try:
            from dotenv import load_dotenv

            load_dotenv(env_file)
        except ImportError:
            pass

    try:
        from biocentral_server.server_management import EmbeddingDatabaseFactory

        db_factory = EmbeddingDatabaseFactory()
        db = db_factory.get_embeddings_db()
        db_statistics = db.get_database_statistics()
        if db_statistics:
            stats_data["db_connected"] = True
            stats_data["db_stats"] = db_statistics
    except Exception as e:
        stats_data["db_error"] = str(e)

    try:
        # 2. Get service stats
        from biocentral_api import BiocentralAPI

        bc_api = BiocentralAPI(local_only=True)
        service_stats = bc_api.service_stats()
        if service_stats:
            stats_data["service_stats"] = service_stats.model_dump() if hasattr(service_stats,
                                                                                'model_dump') else service_stats
    except Exception as e:
        stats_data["service_stats"] = None

    # 2. Check Docker compose services status
    try:
        res = subprocess.run(
            ["docker", "compose", "ps", "--format", "table {{.Service}}\t{{.State}}\t{{.Status}}"],
            capture_output=True,
            text=True,
            cwd=str(project_root) if project_root.exists() else None,
            timeout=3,
        )
        if res.returncode == 0 and res.stdout.strip():
            lines = res.stdout.strip().splitlines()
            if len(lines) > 1:
                for line in lines[1:]:
                    parts = line.split(maxsplit=2)
                    if len(parts) >= 2:
                        service_name = parts[0]
                        service_state = parts[1]
                        service_status = parts[2] if len(parts) > 2 else ""
                        stats_data["docker_services"].append(
                            {
                                "name": service_name,
                                "state": service_state,
                                "status": service_status,
                            }
                        )
    except Exception:
        pass

    return stats_data


def run_stats_tui_view(stdscr: curses.window) -> None:
    """Main loop for the interactive Server Statistics screen."""
    init_colors()
    curses.curs_set(0)

    data = fetch_server_stats()

    while True:
        stdscr.clear()
        max_y, max_x = stdscr.getmaxyx()

        draw_header(stdscr, "Server Statistics", "Database & System Status")
        draw_footer(
            stdscr,
            shortcuts=[
                ("R", "Refresh"),
                ("Q/Esc", "Back"),
            ],
            status="Online" if data.get("db_connected") else "Database Standby / Offline",
        )

        db_connected = data.get("db_connected", False)
        db_stats = data.get("db_stats", {})
        services = data.get("docker_services", [])
        service_stats = data.get("service_stats")

        # Calculate widths for three cards in one row
        total_width = max_x - 8  # Leave margins
        card_width = total_width // 3
        card_height = max_y - 7  # Leave space for header and footer

        # Database Stats Card (Left)
        card1_y, card1_x = 2, 2
        card1_w = card_width
        card1_h = card_height

        draw_box(
            stdscr,
            card1_y,
            card1_x,
            card1_h,
            card1_w,
            title="Database Metrics",
            border_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            title_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
        )

        if db_connected:
            status_text = "● Connected (PostgreSQL)"
            safe_addstr(stdscr, card1_y + 1, card1_x + 3, status_text, curses.color_pair(COLOR_SUCCESS) | curses.A_BOLD)

            total_emb = db_stats.get("total_embeddings", 0)
            models_cnt = db_stats.get("unique_models", 0)
            size_mb = db_stats.get("database_size_mb", 0.0)
            avg_acc = db_stats.get("avg_access_count", 0.0)
            oldest = db_stats.get("oldest_access") or "N/A"
            newest = db_stats.get("newest_access") or "N/A"
            stale_30d = db_stats.get("older_than_30_days", 0)
            stale_7d = db_stats.get("older_than_7_days", 0)

            stats_rows = [
                ("Total Embeddings:", f"{total_emb:,}"),
                ("Unique Models:", f"{models_cnt}"),
                ("Database Size:", f"{size_mb:.2f} MB" if size_mb else "N/A"),
                ("Avg Access Count:", f"{avg_acc:.2f}"),
                ("Oldest Access:", f"{str(oldest)[:19]}"),
                ("Newest Access:", f"{str(newest)[:19]}"),
                ("Stale (>30 days):", f"{stale_30d}"),
                ("Stale (>7 days):", f"{stale_7d}"),
            ]

            for i, (label, val) in enumerate(stats_rows):
                if card1_y + 3 + i < card1_y + card1_h - 1:
                    safe_addstr(stdscr, card1_y + 3 + i, card1_x + 3, label.ljust(18), curses.color_pair(COLOR_MUTED))
                    safe_addstr(stdscr, card1_y + 3 + i, card1_x + 21, val[:card1_w - 24],
                                curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD)
        else:
            safe_addstr(stdscr, card1_y + 2, card1_x + 3, "○ Database not reachable",
                        curses.color_pair(COLOR_WARNING) | curses.A_BOLD)
            safe_addstr(stdscr, card1_y + 4, card1_x + 3, "Start server via CLI:", curses.color_pair(COLOR_DEFAULT))
            safe_addstr(stdscr, card1_y + 5, card1_x + 5, "$ biocentral server up",
                        curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD)
            if data.get("db_error"):
                err_snippet = str(data.get("db_error"))[:card1_w - 6]
                safe_addstr(stdscr, card1_y + 7, card1_x + 3, f"Details: {err_snippet}", curses.color_pair(COLOR_MUTED))

        # Docker Services Card (Middle)
        card2_y = card1_y
        card2_x = card1_x + card1_w + 2
        card2_w = card_width
        card2_h = card_height

        draw_box(
            stdscr,
            card2_y,
            card2_x,
            card2_h,
            card2_w,
            title="Service Status",
            border_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            title_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
        )

        if services:
            safe_addstr(stdscr, card2_y + 1, card2_x + 2, "SERVICE",
                        curses.color_pair(COLOR_MUTED) | curses.A_UNDERLINE)
            safe_addstr(stdscr, card2_y + 1, card2_x + 15, "STATE", curses.color_pair(COLOR_MUTED) | curses.A_UNDERLINE)
            for i, s in enumerate(services[: card2_h - 4]):
                if card2_y + 3 + i < card2_y + card2_h - 1:
                    s_name = s.get("name", "")[:12]
                    s_state = s.get("state", "")[:10]

                    state_attr = curses.color_pair(
                        COLOR_SUCCESS) if "running" in s_state.lower() or "up" in s_state.lower() else curses.color_pair(
                        COLOR_WARNING)

                    safe_addstr(stdscr, card2_y + 3 + i, card2_x + 2, s_name.ljust(12),
                                curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD)
                    safe_addstr(stdscr, card2_y + 3 + i, card2_x + 15, s_state, state_attr | curses.A_BOLD)
        else:
            safe_addstr(stdscr, card2_y + 2, card2_x + 3, "No active containers", curses.color_pair(COLOR_MUTED))
            safe_addstr(stdscr, card2_y + 4, card2_x + 3, "Run 'biocentral", curses.color_pair(COLOR_DEFAULT))
            safe_addstr(stdscr, card2_y + 5, card2_x + 3, "server up' to start.", curses.color_pair(COLOR_DEFAULT))

        # Service Metrics Card (Right)
        card3_y = card1_y
        card3_x = card2_x + card2_w + 2
        card3_w = max_x - card3_x - 2
        card3_h = card_height

        draw_box(
            stdscr,
            card3_y,
            card3_x,
            card3_h,
            card3_w,
            title="Service Metrics",
            border_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            title_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
        )

        if service_stats:
            row = card3_y + 1
            # System Resources
            cpu_count = service_stats.get("usable_cpu_count", 0)
            db_size = service_stats.get("embeddings_database_size", 0)
            db_size_mb = db_size / (1024 * 1024) if db_size else 0.0

            safe_addstr(stdscr, row, card3_x + 3, "System Resources", curses.color_pair(COLOR_ACCENT) | curses.A_BOLD)
            row += 1
            safe_addstr(stdscr, row, card3_x + 3, "CPU Cores:", curses.color_pair(COLOR_MUTED))
            safe_addstr(stdscr, row, card3_x + 18, f"{cpu_count}", curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD)
            row += 1
            safe_addstr(stdscr, row, card3_x + 3, "DB Size:", curses.color_pair(COLOR_MUTED))
            safe_addstr(stdscr, row, card3_x + 18, f"{db_size_mb:.1f} MB",
                        curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD)
            row += 2

            # Task Statistics
            total_tasks = service_stats.get("total_tasks", 0)
            running_tasks = service_stats.get("running_tasks", 0)
            queue_length = service_stats.get("queue_length", 0)

            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "Task Statistics",
                            curses.color_pair(COLOR_ACCENT) | curses.A_BOLD)
            row += 1
            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "Total:", curses.color_pair(COLOR_MUTED))
                safe_addstr(stdscr, row, card3_x + 18, f"{total_tasks:,}",
                            curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD)
            row += 1
            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "Running:", curses.color_pair(COLOR_MUTED))
                safe_addstr(stdscr, row, card3_x + 18, f"{running_tasks}",
                            curses.color_pair(COLOR_SUCCESS if running_tasks > 0 else COLOR_DEFAULT) | curses.A_BOLD)
            row += 1
            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "Queued:", curses.color_pair(COLOR_MUTED))
                safe_addstr(stdscr, row, card3_x + 18, f"{queue_length}",
                            curses.color_pair(COLOR_WARNING if queue_length > 0 else COLOR_DEFAULT) | curses.A_BOLD)
            row += 2

            # CUDA Information
            cuda_available = service_stats.get("cuda_available", False)
            cuda_device_count = service_stats.get("cuda_device_count", 0)
            cuda_device_names = service_stats.get("cuda_device_names", [])

            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "CUDA Acceleration",
                            curses.color_pair(COLOR_ACCENT) | curses.A_BOLD)
            row += 1
            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "Available:", curses.color_pair(COLOR_MUTED))
                cuda_status = "Yes" if cuda_available else "No"
                cuda_attr = curses.color_pair(COLOR_SUCCESS) if cuda_available else curses.color_pair(COLOR_WARNING)
                safe_addstr(stdscr, row, card3_x + 18, cuda_status, cuda_attr | curses.A_BOLD)
            row += 1
            if row < card3_y + card3_h - 1:
                safe_addstr(stdscr, row, card3_x + 3, "Devices:", curses.color_pair(COLOR_MUTED))
                safe_addstr(stdscr, row, card3_x + 18, f"{cuda_device_count}",
                            curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD)
            row += 1

            if cuda_device_names:
                for i, device_name in enumerate(cuda_device_names[:min(4, card3_h - row - 2)]):
                    if row < card3_y + card3_h - 1:
                        display_name = device_name[:card3_w - 8] if len(device_name) > card3_w - 8 else device_name
                        safe_addstr(stdscr, row, card3_x + 5, f"• {display_name}", curses.color_pair(COLOR_DEFAULT))
                        row += 1
        else:
            safe_addstr(stdscr, card3_y + 2, card3_x + 3, "Service stats N/A", curses.color_pair(COLOR_MUTED))
            safe_addstr(stdscr, card3_y + 4, card3_x + 3, "Ensure server is", curses.color_pair(COLOR_DEFAULT))
            safe_addstr(stdscr, card3_y + 5, card3_x + 3, "running.", curses.color_pair(COLOR_DEFAULT))

        stdscr.refresh()
        key = stdscr.getch()

        if key in (ord("r"), ord("R")):
            data = fetch_server_stats()
        elif key in (27, ord("q"), ord("Q")):
            return


def run_server_stats_tui() -> None:
    """Launch the interactive Server Statistics TUI."""
    run_with_curses(run_stats_tui_view)
