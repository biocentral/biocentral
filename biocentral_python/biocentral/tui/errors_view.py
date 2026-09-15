"""Interactive TUI view for browsing and diagnosing server error logs."""

import curses
import os
import re
import subprocess
from pathlib import Path
from typing import Optional, List, Dict, Any, Tuple

from .core import (
    init_colors,
    safe_addstr,
    draw_header,
    draw_footer,
    draw_box,
    prompt_text_input,
    show_message_dialog,
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


def parse_log_content(content: str, source: str) -> List[Dict[str, Any]]:
    """Parse log text content into structured error dictionaries."""
    errors = []
    lines = content.splitlines()
    current_error = None

    for line in lines:
        # File format: 2026-05-13 16:33:36,937 ERROR ...
        file_match = re.match(
            r"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) ERROR (.*)", line
        )
        # Docker format: 2026-06-12T13:45:01.123456789Z ... ERROR ...
        docker_match = re.match(
            r"^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z) (.*ERROR.*)", line
        )

        if file_match:
            if current_error:
                errors.append(current_error)
            current_error = {
                "timestamp": file_match.group(1),
                "message": file_match.group(2),
                "context": "",
                "source": source,
            }
        elif docker_match:
            if current_error:
                errors.append(current_error)
            current_error = {
                "timestamp": docker_match.group(1),
                "message": docker_match.group(2),
                "context": "",
                "source": source,
            }
        elif current_error:
            if (
                line.strip() == ""
                or line.startswith(" ")
                or line.startswith("\t")
                or "Traceback" in line
                or line.startswith("  File")
            ):
                current_error["context"] += line + "\n"
            else:
                if re.match(r"^(\d{4}-\d{2}-\d{2})", line):
                    errors.append(current_error)
                    current_error = None
                else:
                    current_error["context"] += line + "\n"

    if current_error:
        errors.append(current_error)

    return errors


def deduplicate_errors(errors: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Deduplicate error logs based on message and traceback context."""
    seen = set()
    deduped = []
    for err in errors:
        key = (err.get("message", ""), err.get("context", ""))
        if key not in seen:
            seen.add(key)
            deduped.append(err)
    return deduped


def collect_server_errors(project_root: Optional[Path] = None) -> List[Dict[str, Any]]:
    """Collect error logs from Docker compose and local log directory."""
    if project_root is None:
        # Resolve biocentral_server project root
        project_root = (
            Path(__file__).parent.parent.parent.parent / "biocentral_server"
        )

    error_list = []

    # 1. Collect from docker compose logs
    try:
        result = subprocess.run(
            [
                "docker",
                "compose",
                "logs",
                "biocentral-server",
                "biocentral-worker",
                "--no-color",
                "--timestamps",
            ],
            capture_output=True,
            text=True,
            cwd=str(project_root) if project_root.exists() else None,
            timeout=5,
        )
        if result.returncode == 0 and result.stdout:
            error_list.extend(parse_log_content(result.stdout, "docker"))
    except Exception:
        pass

    # 2. Collect from ./logs directory
    logs_dir = project_root / "logs" if project_root.exists() else Path("logs")
    if logs_dir.exists():
        for log_file in logs_dir.glob("*.log"):
            try:
                content = log_file.read_text(encoding="utf-8", errors="ignore")
                error_list.extend(parse_log_content(content, log_file.name))
            except Exception:
                pass

    deduped = deduplicate_errors(error_list)
    deduped.sort(key=lambda x: x.get("timestamp") or "", reverse=True)
    return deduped


def run_error_viewer_tui_view(
    stdscr: curses.window,
    initial_errors: Optional[List[Dict[str, Any]]] = None,
) -> None:
    """Main loop for the interactive Error Log Browser."""
    init_colors()
    curses.curs_set(0)

    all_errors = (
        initial_errors
        if initial_errors is not None
        else collect_server_errors()
    )

    filter_query = ""
    current_idx = 0
    context_scroll_offset = 0

    while True:
        stdscr.clear()
        max_y, max_x = stdscr.getmaxyx()

        # Apply filtering
        if filter_query:
            filtered_errors = [
                e
                for e in all_errors
                if filter_query.lower() in e.get("message", "").lower()
                or filter_query.lower() in e.get("context", "").lower()
                or filter_query.lower() in e.get("source", "").lower()
            ]
        else:
            filtered_errors = all_errors

        total_errors = len(filtered_errors)
        if current_idx >= total_errors and total_errors > 0:
            current_idx = total_errors - 1
        elif total_errors == 0:
            current_idx = 0

        # Header and Footer
        subtitle = (
            f"Filter: '{filter_query}' ({total_errors} matching)"
            if filter_query
            else f"Total Errors: {total_errors}"
        )
        draw_header(stdscr, "Server Error Logs", subtitle)
        draw_footer(
            stdscr,
            shortcuts=[
                ("N/→", "Next"),
                ("P/←", "Prev"),
                ("↑/↓", "Scroll Traceback"),
                ("/", "Filter"),
                ("C", "Clear Filter"),
                ("R", "Reload"),
                ("Q/Esc", "Back"),
            ],
            status=f"Item {current_idx + 1}/{total_errors}" if total_errors > 0 else "No Errors",
        )

        if total_errors == 0:
            # Empty state
            h, w = 8, min(max_x - 4, 60)
            y, x = max(2, (max_y - h) // 2), max(2, (max_x - w) // 2)
            draw_box(
                stdscr,
                y,
                x,
                h,
                w,
                title="Log Status",
                border_attr=curses.color_pair(COLOR_SUCCESS) | curses.A_BOLD,
                title_attr=curses.color_pair(COLOR_SUCCESS) | curses.A_BOLD,
            )
            safe_addstr(
                stdscr,
                y + 2,
                x + 4,
                "✔ No error logs found.",
                curses.color_pair(COLOR_SUCCESS) | curses.A_BOLD,
            )
            if filter_query:
                safe_addstr(
                    stdscr,
                    y + 3,
                    x + 4,
                    f"No results matching query: '{filter_query}'",
                    curses.color_pair(COLOR_MUTED),
                )
                safe_addstr(
                    stdscr,
                    y + 5,
                    x + 4,
                    "[C] Clear Filter   [R] Reload Logs   [Q] Back",
                    curses.color_pair(COLOR_PRIMARY),
                )
            else:
                safe_addstr(
                    stdscr,
                    y + 4,
                    x + 4,
                    "[R] Reload Logs    [Q] Back",
                    curses.color_pair(COLOR_PRIMARY),
                )
            stdscr.refresh()
        else:
            err = filtered_errors[current_idx]

            # Summary Box (Top)
            top_y, top_x = 2, 2
            top_h = 7
            top_w = max_x - 4

            draw_box(
                stdscr,
                top_y,
                top_x,
                top_h,
                top_w,
                title=f"Error {current_idx + 1} of {total_errors}",
                border_attr=curses.color_pair(COLOR_ERROR) | curses.A_BOLD,
                title_attr=curses.color_pair(COLOR_ERROR) | curses.A_BOLD,
            )

            safe_addstr(
                stdscr,
                top_y + 1,
                top_x + 3,
                f"Timestamp: ",
                curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            )
            safe_addstr(
                stdscr,
                top_y + 1,
                top_x + 14,
                f"{err.get('timestamp', 'N/A')}",
                curses.color_pair(COLOR_DEFAULT),
            )

            safe_addstr(
                stdscr,
                top_y + 2,
                top_x + 3,
                f"Source:    ",
                curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            )
            safe_addstr(
                stdscr,
                top_y + 2,
                top_x + 14,
                f"{err.get('source', 'N/A')}",
                curses.color_pair(COLOR_ACCENT) | curses.A_BOLD,
            )

            safe_addstr(
                stdscr,
                top_y + 3,
                top_x + 3,
                f"Message:   ",
                curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            )
            safe_addstr(
                stdscr,
                top_y + 4,
                top_x + 5,
                f"{err.get('message', 'No message')}",
                curses.color_pair(COLOR_ERROR) | curses.A_BOLD,
                max_len=top_w - 8,
            )

            # Traceback / Context Box (Bottom)
            bot_y = top_y + top_h
            bot_x = 2
            bot_h = max_y - bot_y - 2
            bot_w = max_x - 4

            context_lines = err.get("context", "").strip().splitlines()
            if not context_lines:
                context_lines = ["(No additional stack trace or context available)"]

            total_ctx_lines = len(context_lines)
            visible_ctx_lines = max(1, bot_h - 2)

            # Clamp scroll offset
            max_scroll = max(0, total_ctx_lines - visible_ctx_lines)
            context_scroll_offset = min(context_scroll_offset, max_scroll)

            scroll_info = ""
            if total_ctx_lines > visible_ctx_lines:
                scroll_info = f" [Lines {context_scroll_offset + 1}-{min(context_scroll_offset + visible_ctx_lines, total_ctx_lines)} of {total_ctx_lines}] "

            draw_box(
                stdscr,
                bot_y,
                bot_x,
                bot_h,
                bot_w,
                title=f"Stack Trace & Context{scroll_info}",
                border_attr=curses.color_pair(COLOR_MUTED),
                title_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            )

            for i in range(visible_ctx_lines):
                line_idx = context_scroll_offset + i
                if line_idx < total_ctx_lines:
                    line_text = context_lines[line_idx]
                    attr = curses.color_pair(COLOR_DEFAULT)
                    if "File " in line_text or "line " in line_text:
                        attr = curses.color_pair(COLOR_PRIMARY)
                    elif "Error" in line_text or "Exception" in line_text:
                        attr = curses.color_pair(COLOR_ERROR) | curses.A_BOLD

                    safe_addstr(
                        stdscr,
                        bot_y + 1 + i,
                        bot_x + 2,
                        line_text,
                        attr,
                        max_len=bot_w - 4,
                    )

            stdscr.refresh()

        key = stdscr.getch()

        if key in (ord("n"), ord("N"), curses.KEY_RIGHT, ord(" ")):
            if total_errors > 0 and current_idx < total_errors - 1:
                current_idx += 1
                context_scroll_offset = 0
        elif key in (ord("p"), ord("P"), curses.KEY_LEFT):
            if total_errors > 0 and current_idx > 0:
                current_idx -= 1
                context_scroll_offset = 0
        elif key in (curses.KEY_DOWN, ord("j")):
            context_scroll_offset += 1
        elif key in (curses.KEY_UP, ord("k")):
            if context_scroll_offset > 0:
                context_scroll_offset -= 1
        elif key in (curses.KEY_NPAGE,):  # Page Down
            context_scroll_offset += 10
        elif key in (curses.KEY_PPAGE,):  # Page Up
            context_scroll_offset = max(0, context_scroll_offset - 10)
        elif key in (curses.KEY_HOME,):
            context_scroll_offset = 0
        elif key in (curses.KEY_END,):
            context_scroll_offset = 99999
        elif key in (ord("/"), ord("f"), ord("F")):
            query = prompt_text_input(
                stdscr,
                "Filter Errors",
                "Enter keyword or search term:",
                initial_value=filter_query,
            )
            if query is not None:
                filter_query = query.strip()
                current_idx = 0
                context_scroll_offset = 0
        elif key in (ord("c"), ord("C")):
            filter_query = ""
            current_idx = 0
            context_scroll_offset = 0
        elif key in (ord("r"), ord("R")):
            all_errors = collect_server_errors()
            current_idx = 0
            context_scroll_offset = 0
        elif key in (27, ord("q"), ord("Q")):
            return


def run_error_viewer_tui(
    errors: Optional[List[Dict[str, Any]]] = None,
) -> None:
    """Launch the interactive Error Log Browser."""
    run_with_curses(lambda stdscr: run_error_viewer_tui_view(stdscr, initial_errors=errors))
