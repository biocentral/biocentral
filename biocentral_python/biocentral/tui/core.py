"""Core curses utilities, widgets, color schemes, and window helpers for Biocentral TUI."""

import sys
import curses
from typing import List, Tuple, Optional, Callable, Any

# Color Pair IDs
COLOR_DEFAULT = 1
COLOR_PRIMARY = 2
COLOR_HIGHLIGHT = 3
COLOR_SUCCESS = 4
COLOR_WARNING = 5
COLOR_ERROR = 6
COLOR_MUTED = 7
COLOR_HEADER = 8
COLOR_ACCENT = 9
COLOR_BOX = 10


def init_colors() -> None:
    """Initialize curses color pairs safely."""
    if not curses.has_colors():
        return

    curses.start_color()
    curses.use_default_colors()

    # Define color pairs (pair_id, fg, bg)
    try:
        curses.init_pair(COLOR_DEFAULT, curses.COLOR_WHITE, -1)
        curses.init_pair(COLOR_PRIMARY, curses.COLOR_CYAN, -1)
        curses.init_pair(COLOR_HIGHLIGHT, curses.COLOR_BLACK, curses.COLOR_CYAN)
        curses.init_pair(COLOR_SUCCESS, curses.COLOR_GREEN, -1)
        curses.init_pair(COLOR_WARNING, curses.COLOR_YELLOW, -1)
        curses.init_pair(COLOR_ERROR, curses.COLOR_RED, -1)
        curses.init_pair(COLOR_MUTED, curses.COLOR_WHITE, -1)
        curses.init_pair(COLOR_HEADER, curses.COLOR_BLACK, curses.COLOR_CYAN)
        curses.init_pair(COLOR_ACCENT, curses.COLOR_MAGENTA, -1)
        curses.init_pair(COLOR_BOX, curses.COLOR_CYAN, -1)
    except Exception:
        # Fallback to standard 0 if pairs fail
        pass


def safe_addstr(
    win: curses.window,
    y: int,
    x: int,
    text: str,
    attr: int = 0,
    max_len: Optional[int] = None,
) -> None:
    """Safely write text to a curses window within bounds, avoiding border exceptions."""
    max_y, max_x = win.getmaxyx()
    if y < 0 or y >= max_y or x < 0 or x >= max_x:
        return

    available = max_x - x
    if max_len is not None:
        available = min(available, max_len)

    if available <= 0:
        return

    text_to_print = text[:available]
    # In curses, writing to bottom-right cell can raise curses.error even on success
    try:
        win.addstr(y, x, text_to_print, attr)
    except curses.error:
        pass


def draw_box(
    win: curses.window,
    y: int,
    x: int,
    h: int,
    w: int,
    title: Optional[str] = None,
    border_attr: int = 0,
    title_attr: int = 0,
) -> None:
    """Draw a styled box border with an optional title."""
    max_y, max_x = win.getmaxyx()
    if y >= max_y or x >= max_x or h <= 1 or w <= 1:
        return

    h = min(h, max_y - y)
    w = min(w, max_x - x)

    # Top border
    safe_addstr(win, y, x, "┌" + "─" * (w - 2) + "┐", border_attr)

    # Side borders
    for i in range(1, h - 1):
        safe_addstr(win, y + i, x, "│", border_attr)
        safe_addstr(win, y + i, x + w - 1, "│", border_attr)

    # Bottom border
    safe_addstr(win, y + h - 1, x, "└" + "─" * (w - 2) + "┘", border_attr)

    # Title
    if title:
        title_str = f" {title} "
        if len(title_str) < w - 4:
            safe_addstr(win, y, x + 2, title_str, title_attr or curses.A_BOLD)


def draw_header(win: curses.window, title: str, subtitle: Optional[str] = None) -> None:
    """Draw top header banner across the window."""
    _, max_x = win.getmaxyx()
    header_text = f"  BIOCENTRAL :: {title.upper()}"
    if subtitle:
        header_text += f" - {subtitle}"

    bar = header_text.ljust(max_x)
    safe_addstr(win, 0, 0, bar, curses.color_pair(COLOR_HEADER) | curses.A_BOLD)


def draw_footer(
    win: curses.window, shortcuts: List[Tuple[str, str]], status: Optional[str] = None
) -> None:
    """Draw bottom footer bar with keyboard shortcuts and optional status message."""
    max_y, max_x = win.getmaxyx()
    footer_y = max_y - 1

    # Fill footer background
    safe_addstr(win, footer_y, 0, " " * max_x, curses.color_pair(COLOR_HEADER))

    col = 1
    for key, desc in shortcuts:
        key_str = f"[{key}]"
        desc_str = f" {desc}  "
        if col + len(key_str) + len(desc_str) >= max_x - 1:
            break
        safe_addstr(
            win,
            footer_y,
            col,
            key_str,
            curses.color_pair(COLOR_HEADER) | curses.A_BOLD | curses.A_UNDERLINE,
        )
        col += len(key_str)
        safe_addstr(win, footer_y, col, desc_str, curses.color_pair(COLOR_HEADER))
        col += len(desc_str)

    if status:
        status_str = f" {status} "
        if len(status_str) < max_x - col:
            safe_addstr(
                win,
                footer_y,
                max_x - len(status_str) - 1,
                status_str,
                curses.color_pair(COLOR_HEADER) | curses.A_BOLD,
            )


def draw_card(
    win: curses.window,
    y: int,
    x: int,
    h: int,
    w: int,
    title: str,
    lines: List[str],
    selected: bool = False,
) -> None:
    """Draw a content card with title and body lines."""
    border_attr = (
        curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD
        if selected
        else curses.color_pair(COLOR_MUTED)
    )
    title_attr = (
        curses.color_pair(COLOR_HIGHLIGHT) | curses.A_BOLD
        if selected
        else curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD
    )

    draw_box(win, y, x, h, w, title=title, border_attr=border_attr, title_attr=title_attr)

    for i, line in enumerate(lines[: h - 2]):
        safe_addstr(win, y + 1 + i, x + 2, line, curses.color_pair(COLOR_DEFAULT), max_len=w - 4)


def prompt_text_input(
    stdscr: curses.window,
    title: str,
    prompt: str,
    initial_value: str = "",
) -> Optional[str]:
    """Display a modal dialog to prompt user for single-line text input."""
    curses.curs_set(1)
    max_y, max_x = stdscr.getmaxyx()
    h, w = 8, min(70, max_x - 4)
    y, x = max(1, (max_y - h) // 2), max(1, (max_x - w) // 2)

    buf = list(initial_value)
    cursor_pos = len(buf)

    while True:
        # Draw background and box
        draw_box(
            stdscr,
            y,
            x,
            h,
            w,
            title=title,
            border_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
            title_attr=curses.color_pair(COLOR_PRIMARY) | curses.A_BOLD,
        )

        safe_addstr(
            stdscr,
            y + 2,
            x + 3,
            prompt,
            curses.color_pair(COLOR_DEFAULT) | curses.A_BOLD,
            max_len=w - 6,
        )

        # Input field background
        field_w = w - 6
        input_y = y + 4
        input_x = x + 3
        safe_addstr(stdscr, input_y, input_x, " " * field_w, curses.color_pair(COLOR_HIGHLIGHT))

        visible_text = "".join(buf)
        if len(visible_text) > field_w:
            offset = max(0, cursor_pos - field_w + 1)
            display_text = visible_text[offset : offset + field_w]
            cur_x_offset = cursor_pos - offset
        else:
            display_text = visible_text
            cur_x_offset = cursor_pos

        safe_addstr(
            stdscr,
            input_y,
            input_x,
            display_text,
            curses.color_pair(COLOR_HIGHLIGHT),
            max_len=field_w,
        )

        safe_addstr(
            stdscr,
            y + 6,
            x + 3,
            "[Enter] Submit   [Esc] Cancel",
            curses.color_pair(COLOR_MUTED),
        )

        stdscr.move(input_y, input_x + cur_x_offset)
        stdscr.refresh()

        key = stdscr.getch()
        if key in (10, 13, curses.KEY_ENTER):
            curses.curs_set(0)
            return "".join(buf)
        elif key in (27,):  # ESC
            curses.curs_set(0)
            return None
        elif key in (curses.KEY_BACKSPACE, 127, 8):
            if cursor_pos > 0:
                buf.pop(cursor_pos - 1)
                cursor_pos -= 1
        elif key == curses.KEY_DC:  # Delete
            if cursor_pos < len(buf):
                buf.pop(cursor_pos)
        elif key == curses.KEY_LEFT:
            if cursor_pos > 0:
                cursor_pos -= 1
        elif key == curses.KEY_RIGHT:
            if cursor_pos < len(buf):
                cursor_pos += 1
        elif key == curses.KEY_HOME:
            cursor_pos = 0
        elif key == curses.KEY_END:
            cursor_pos = len(buf)
        elif 32 <= key <= 126:
            buf.insert(cursor_pos, chr(key))
            cursor_pos += 1


def show_message_dialog(
    stdscr: curses.window,
    title: str,
    message: str,
    msg_type: str = "info",
) -> None:
    """Display a modal message dialog."""
    curses.curs_set(0)
    max_y, max_x = stdscr.getmaxyx()
    lines = message.split("\n")
    h = min(max_y - 4, max(8, len(lines) + 6))
    w = min(max_x - 4, max(50, max(len(l) for l in lines) + 8))
    y = max(1, (max_y - h) // 2)
    x = max(1, (max_x - w) // 2)

    color = COLOR_PRIMARY
    if msg_type == "error":
        color = COLOR_ERROR
    elif msg_type == "success":
        color = COLOR_SUCCESS
    elif msg_type == "warning":
        color = COLOR_WARNING

    while True:
        # Clear dialog area
        for i in range(h):
            safe_addstr(stdscr, y + i, x, " " * w, curses.color_pair(COLOR_DEFAULT))

        draw_box(
            stdscr,
            y,
            x,
            h,
            w,
            title=title,
            border_attr=curses.color_pair(color) | curses.A_BOLD,
            title_attr=curses.color_pair(color) | curses.A_BOLD,
        )

        for i, line in enumerate(lines[: h - 5]):
            safe_addstr(
                stdscr,
                y + 2 + i,
                x + 4,
                line,
                curses.color_pair(COLOR_DEFAULT),
                max_len=w - 8,
            )

        btn_str = "[ Press any key to continue ]"
        safe_addstr(
            stdscr,
            y + h - 2,
            x + (w - len(btn_str)) // 2,
            btn_str,
            curses.color_pair(COLOR_HIGHLIGHT) | curses.A_BOLD,
        )

        stdscr.refresh()
        key = stdscr.getch()
        if key != -1:
            break


def run_with_curses(entry_fn: Callable[[curses.window], Any]) -> Any:
    """Wrapper to run a curses application with safe terminal initialization and restoration."""
    try:
        return curses.wrapper(entry_fn)
    except Exception as e:
        # Ensure terminal is restored if wrapper fails unexpectedly
        try:
            curses.endwin()
        except Exception:
            pass
        print(f"[Biocentral TUI Error] {e}", file=sys.stderr)
        raise
