#!/usr/bin/env python3

import sys
import os
import platform
import shutil
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple, Callable

PLATFORM = platform.system()


def get_config_dir():
    # If we are on windows, it would be located at the appdata directory
    if PLATFORM == "Windows":
        return os.environ['APPDATA']
    else:
        return os.path.expanduser('~/.config')


CONFIG_DIR = get_config_dir()
SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
HOME_DIR = os.path.expanduser("~")


@dataclass
class Configuration:
    platforms: List[str]
    src: str
    dest: str
    deps: List[str]
    setup: Optional[Callable]

    def is_available(self) -> bool:
        return len(self.platforms) == 0 or (PLATFORM in self.platforms)


CONFIGURATIONS = {
    "nvim_nvchad": Configuration(
        platforms=[],
        src="nvim_nvchad",
        dest="{}/nvim".format(CONFIG_DIR),
        deps=[],
        setup=None,
    ),
    "nvim": Configuration(
        platforms=[],
        src="nvim",
        dest="{}/nvim".format(CONFIG_DIR),
        deps=[],
        setup=None,
    ),
    "starship": Configuration(
        platforms=[],
        src="starship.toml",
        dest="{}/starship.toml".format(CONFIG_DIR),
        deps=[],
        setup=None,
    ),
    "tmux": Configuration(
        platforms=[],
        src=".tmux.conf",
        dest="{}/.tmux.conf".format(HOME_DIR),
        deps=[],
        setup=None,
    ),
    "nix-darwin": Configuration(
        platforms=["Darwin"],
        src="nix-darwin",
        dest="{}/nix-darwin".format(CONFIG_DIR),
        deps=[],
        setup=None,
    ),
    "ghostty": Configuration(
        platforms=[],
        src="ghostty",
        dest="{}/ghostty".format(CONFIG_DIR),
        deps=[],
        setup=None,
    ),
}  # type: Dict[str, Configuration]


# ---------------------------------------------------------------------------
# Error-resilient symlink / unlink
# ---------------------------------------------------------------------------

class SetupError(Exception):
    pass


def symlink(source, target):
    # type: (str, str) -> None
    if os.path.exists(target) or os.path.islink(target):
        raise SetupError(
            "destination {} already exists, please review and remove it manually".format(target)
        )
    os.symlink(source, target)


def unlink(target):
    # type: (str) -> None
    if not os.path.islink(target):
        if os.path.exists(target):
            raise SetupError(
                "{} is not a symlink, please remove it manually if you are sure".format(target)
            )
        else:
            raise SetupError("{} does not exist".format(target))
    os.unlink(target)


def install(config):
    # type: (Configuration) -> Tuple[bool, Optional[str]]
    source = os.path.join(SCRIPT_DIR, config.src)
    try:
        symlink(source, config.dest)
        return (True, None)
    except SetupError as e:
        return (False, str(e))


def uninstall(config):
    # type: (Configuration) -> Tuple[bool, Optional[str]]
    try:
        unlink(config.dest)
        return (True, None)
    except SetupError as e:
        return (False, str(e))


# ---------------------------------------------------------------------------
# Terminal capability detection
# ---------------------------------------------------------------------------

def supports_ansi_tui():
    # type: () -> bool
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        return False
    if os.environ.get("TERM", "") == "dumb":
        return False
    if PLATFORM == "Windows":
        try:
            import msvcrt  # noqa: F401
            return enable_windows_vt100()
        except ImportError:
            return False
    else:
        try:
            import termios  # noqa: F401
            import tty  # noqa: F401
            return True
        except ImportError:
            return False


def enable_windows_vt100():
    # type: () -> bool
    if PLATFORM != "Windows":
        return False
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32  # type: ignore[attr-defined]
        STD_OUTPUT_HANDLE = -11
        ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
        handle = kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
        mode = ctypes.c_ulong()
        if not kernel32.GetConsoleMode(handle, ctypes.byref(mode)):
            return False
        if not kernel32.SetConsoleMode(handle, mode.value | ENABLE_VIRTUAL_TERMINAL_PROCESSING):
            return False
        return True
    except Exception:
        return False


# ---------------------------------------------------------------------------
# Raw key reading
# ---------------------------------------------------------------------------

class RawTerminal:
    """Context manager that puts the terminal into raw mode on Unix."""

    def __init__(self):
        # type: () -> None
        self._old_settings = None  # type: Optional[list]

    def __enter__(self):
        # type: () -> RawTerminal
        try:
            import termios
            import tty
            fd = sys.stdin.fileno()
            self._old_settings = termios.tcgetattr(fd)
            tty.setraw(fd)
        except Exception:
            self._old_settings = None
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        # type: (...) -> None
        if self._old_settings is not None:
            try:
                import termios
                termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, self._old_settings)
            except Exception:
                pass


def read_key_unix():
    # type: () -> str
    ch = sys.stdin.read(1)
    if ch == "\x1b":
        ch2 = sys.stdin.read(1)
        if ch2 == "[":
            ch3 = sys.stdin.read(1)
            mapping = {"A": "up", "B": "down", "C": "right", "D": "left"}
            return mapping.get(ch3, "")
        return "escape"
    if ch == " ":
        return "space"
    if ch in ("\r", "\n"):
        return "enter"
    if ch == "\x03":
        raise KeyboardInterrupt
    return ch


def read_key_windows():
    # type: () -> str
    import msvcrt
    ch = msvcrt.getwch()
    if ch in ("\x00", "\xe0"):
        ch2 = msvcrt.getwch()
        mapping = {"H": "up", "P": "down", "K": "left", "M": "right"}
        return mapping.get(ch2, "")
    if ch == " ":
        return "space"
    if ch in ("\r", "\n"):
        return "enter"
    if ch == "\x03":
        raise KeyboardInterrupt
    return ch


def read_key():
    # type: () -> str
    if PLATFORM == "Windows":
        return read_key_windows()
    return read_key_unix()


# ---------------------------------------------------------------------------
# ANSI TUI widgets
# ---------------------------------------------------------------------------

def _write(text):
    # type: (str) -> None
    sys.stdout.write(text)
    sys.stdout.flush()


def _clear_lines(n):
    # type: (int) -> None
    for _ in range(n):
        _write("\033[2K\033[A")
    _write("\033[2K\r")


# ---------------------------------------------------------------------------
# ANSI escape constants
# ---------------------------------------------------------------------------

ESC_ALT_SCREEN_ON = "\033[?1049h"
ESC_ALT_SCREEN_OFF = "\033[?1049l"
ESC_CURSOR_HOME = "\033[H"
ESC_CLEAR_SCREEN = "\033[2J"
ESC_HIDE_CURSOR = "\033[?25l"
ESC_SHOW_CURSOR = "\033[?25h"
ESC_BOLD = "\033[1m"
ESC_DIM = "\033[2m"
ESC_REVERSE = "\033[7m"
ESC_RESET = "\033[0m"
ESC_GREEN = "\033[32m"
ESC_RED = "\033[31m"
ESC_YELLOW = "\033[33m"
ESC_CYAN = "\033[36m"


# ---------------------------------------------------------------------------
# Config status detection
# ---------------------------------------------------------------------------


def get_config_status(name, conf):
    # type: (str, Configuration) -> str
    if not conf.is_available():
        return "unavailable"
    dest = conf.dest
    if os.path.islink(dest):
        source = os.path.join(SCRIPT_DIR, conf.src)
        if os.path.realpath(dest) == os.path.realpath(source):
            return "installed"
        else:
            return "conflict"
    elif os.path.exists(dest):
        return "conflict"
    else:
        return "not_installed"


class MultiSelect:
    """Arrow-key driven multi-select widget."""

    def __init__(self, title, items, selected=None):
        # type: (str, List[Tuple[str, str]], Optional[set]) -> None
        self.title = title
        self.items = items
        self.selected = set(selected) if selected else set()  # type: set
        self.cursor = 0
        self._rendered_lines = 0

    def _render(self):
        # type: () -> None
        if self._rendered_lines > 0:
            _clear_lines(self._rendered_lines)

        lines = []  # type: List[str]
        lines.append(self.title)
        lines.append(
            "  \033[2m\u2191\u2193 navigate  SPACE toggle  A toggle all  ENTER confirm  Q quit\033[0m"
        )
        lines.append("")

        max_name = max(len(item[0]) for item in self.items) if self.items else 0

        for i, (name, desc) in enumerate(self.items):
            check = "x" if i in self.selected else " "
            prefix = "> " if i == self.cursor else "  "
            line = "{}[{}] {}  {}".format(prefix, check, name.ljust(max_name), desc)
            if i == self.cursor:
                line = "\033[7m{}\033[0m".format(line)
            lines.append(line)

        count = len(self.selected)
        total = len(self.items)
        lines.append("")
        lines.append("  {} of {} selected".format(count, total))

        output = "\r\n".join(lines)
        _write(output)
        self._rendered_lines = len(lines) - 1

    def run(self):
        # type: () -> Optional[List[int]]
        _write("\033[?25l")  # hide cursor
        try:
            self._render()
            while True:
                key = read_key()
                if key == "up":
                    self.cursor = (self.cursor - 1) % len(self.items)
                elif key == "down":
                    self.cursor = (self.cursor + 1) % len(self.items)
                elif key == "space":
                    if self.cursor in self.selected:
                        self.selected.discard(self.cursor)
                    else:
                        self.selected.add(self.cursor)
                elif key in ("a", "A"):
                    if len(self.selected) == len(self.items):
                        self.selected.clear()
                    else:
                        self.selected = set(range(len(self.items)))
                elif key == "enter":
                    return sorted(self.selected)
                elif key in ("q", "Q", "escape"):
                    return None
                self._render()
        finally:
            _write("\033[?25h")  # show cursor
            _write("\n")


class ConfirmPrompt:
    """Arrow-key or y/n confirm prompt."""

    def __init__(self, message, default=True):
        # type: (str, bool) -> None
        self.message = message
        self.default = default
        self.choice = default
        self._rendered_lines = 0

    def _render(self):
        # type: () -> None
        if self._rendered_lines > 0:
            _clear_lines(self._rendered_lines)

        yes_label = "\033[7m Yes \033[0m" if self.choice else " Yes "
        no_label = "\033[7m No \033[0m" if not self.choice else " No "

        lines = []  # type: List[str]
        lines.append(self.message)
        lines.append("")
        lines.append("  Continue?  {}  {}".format(yes_label, no_label))

        output = "\r\n".join(lines)
        _write(output)
        self._rendered_lines = len(lines) - 1

    def run(self):
        # type: () -> bool
        _write("\033[?25l")
        try:
            self._render()
            while True:
                key = read_key()
                if key in ("left", "right"):
                    self.choice = not self.choice
                elif key in ("y", "Y"):
                    self.choice = True
                    return True
                elif key in ("n", "N"):
                    self.choice = False
                    return False
                elif key == "enter":
                    return self.choice
                elif key in ("q", "Q", "escape"):
                    return False
                self._render()
        finally:
            _write("\033[?25h")
            _write("\n")


# ---------------------------------------------------------------------------
# Fallback (non-ANSI) widgets
# ---------------------------------------------------------------------------

def simple_multiselect(title, items, selected=None):
    # type: (str, List[Tuple[str, str]], Optional[set]) -> Optional[List[int]]
    print(title)
    print()
    for i, (name, desc) in enumerate(items):
        marker = "*" if (selected and i in selected) else " "
        print("  {}. [{}] {}  {}".format(i + 1, marker, name, desc))
    print()
    print("Enter numbers (comma-separated), 'all', 'none', or 'q' to quit:")

    try:
        raw = input("> ").strip()
    except EOFError:
        return None

    if not raw or raw.lower() == "q":
        return None
    if raw.lower() == "all":
        return list(range(len(items)))
    if raw.lower() == "none":
        return []

    result = set()  # type: set
    for part in raw.split(","):
        part = part.strip()
        if "-" in part:
            bounds = part.split("-", 1)
            try:
                lo = int(bounds[0]) - 1
                hi = int(bounds[1]) - 1
                for idx in range(lo, hi + 1):
                    if 0 <= idx < len(items):
                        result.add(idx)
            except ValueError:
                pass
        else:
            try:
                idx = int(part) - 1
                if 0 <= idx < len(items):
                    result.add(idx)
            except ValueError:
                pass

    return sorted(result)


def simple_confirm(message, default=True):
    # type: (str, bool) -> bool
    hint = "Y/n" if default else "y/N"
    print("{} ({}) ".format(message, hint), end="")
    try:
        raw = input().strip().lower()
    except EOFError:
        return default
    if not raw:
        return default
    return raw.startswith("y")


# ---------------------------------------------------------------------------
# Smart dispatchers
# ---------------------------------------------------------------------------

def select_configs(title, items, selected=None):
    # type: (str, List[Tuple[str, str]], Optional[set]) -> Optional[List[int]]
    if supports_ansi_tui():
        with RawTerminal():
            return MultiSelect(title, items, selected).run()
    else:
        return simple_multiselect(title, items, selected)


def confirm_continue(message):
    # type: (str, ...) -> bool
    if supports_ansi_tui():
        with RawTerminal():
            return ConfirmPrompt(message, default=True).run()
    else:
        return simple_confirm(message, default=True)


# ---------------------------------------------------------------------------
# Dashboard widgets
# ---------------------------------------------------------------------------


class MenuSelect:
    """Single-select vertical menu with highlight-and-enter."""

    def __init__(self, items):
        # type: (List[str]) -> None
        self.items = items
        self.cursor = 0

    def render(self):
        # type: () -> List[str]
        lines = []  # type: List[str]
        for i, item in enumerate(self.items):
            if i == self.cursor:
                lines.append("  {}{}> {}{}".format(ESC_REVERSE, ESC_BOLD, item, ESC_RESET))
            else:
                lines.append("    {}".format(item))
        return lines

    def handle_key(self, key):
        # type: (str) -> Optional[int]
        if key == "up":
            self.cursor = (self.cursor - 1) % len(self.items)
        elif key == "down":
            self.cursor = (self.cursor + 1) % len(self.items)
        elif key == "enter":
            return self.cursor
        elif key in ("q", "Q"):
            return -1
        return None


# ---------------------------------------------------------------------------
# Command handlers
# ---------------------------------------------------------------------------

def get_available_configs():
    # type: () -> List[Tuple[str, Configuration]]
    return [(name, conf) for name, conf in CONFIGURATIONS.items() if conf.is_available()]


def cmd_list():
    # type: () -> None
    unavailable = 0
    for name, conf in CONFIGURATIONS.items():
        if not conf.is_available():
            unavailable += 1
            continue
        print(name)
    print("... and {} more not supported for the current platform".format(unavailable))


def cmd_info(name):
    # type: (str) -> None
    if name not in CONFIGURATIONS:
        print("invalid configuration")
        sys.exit(1)
    conf = CONFIGURATIONS[name]
    print("Configuration '{}'".format(name))
    if len(conf.platforms) != 0:
        print("Available for platforms: {}".format(",".join(conf.platforms)))
    else:
        print("Available for all platforms")
    print("Configuration destination: '{}'".format(conf.dest))


def cmd_install(names=None, interactive=True):
    # type: (Optional[List[str]], bool) -> None
    if names is not None:
        # Specific configs requested — install directly
        for name in names:
            if name not in CONFIGURATIONS:
                print("invalid configuration: {}".format(name))
                sys.exit(1)
            conf = CONFIGURATIONS[name]
            if not conf.is_available():
                print("{} is not available on this platform".format(name))
                sys.exit(1)
            source = os.path.join(SCRIPT_DIR, conf.src)
            print("symlinking {} -> {}".format(conf.dest, source))
            ok, err = install(conf)
            if not ok:
                print("Error installing {}: {}".format(name, err))
                sys.exit(1)
        return

    available = get_available_configs()
    if not available:
        print("No configurations available for this platform")
        return

    if not interactive:
        # Non-interactive: install everything
        print("installing all configurations...")
        succeeded = 0
        failed = []  # type: List[Tuple[str, str]]
        for name, conf in available:
            source = os.path.join(SCRIPT_DIR, conf.src)
            print("symlinking {} -> {}".format(conf.dest, source))
            ok, err = install(conf)
            if ok:
                succeeded += 1
            else:
                failed.append((name, err or "unknown error"))
                print("Error: {}".format(err))
        _print_summary(succeeded, failed, "installed")
        return

    # Interactive mode
    items = [(name, conf.dest) for name, conf in available]
    preselected = set(range(len(items)))
    selected = select_configs("Select configurations to install:", items, preselected)

    if selected is None:
        print("Cancelled.")
        return
    if not selected:
        print("Nothing selected.")
        return

    succeeded = 0
    failed = []  # type: List[Tuple[str, str]]
    to_install = [available[i] for i in selected]

    for name, conf in to_install:
        source = os.path.join(SCRIPT_DIR, conf.src)
        print("symlinking {} -> {}".format(conf.dest, source))
        ok, err = install(conf)
        if ok:
            succeeded += 1
        else:
            print("Error installing {}: {}".format(name, err))
            if len(to_install) > 1 and (name, conf) != to_install[-1]:
                if not confirm_continue("Continue with remaining configurations?"):
                    failed.append((name, err or "unknown error"))
                    break
            failed.append((name, err or "unknown error"))

    _print_summary(succeeded, failed, "installed")


def cmd_uninstall(names=None, interactive=True):
    # type: (Optional[List[str]], bool) -> None
    if names is not None:
        for name in names:
            if name not in CONFIGURATIONS:
                print("invalid configuration: {}".format(name))
                sys.exit(1)
            conf = CONFIGURATIONS[name]
            ok, err = uninstall(conf)
            if not ok:
                print("Error uninstalling {}: {}".format(name, err))
                sys.exit(1)
            else:
                print("removed {}".format(name))
        return

    available = get_available_configs()
    if not available:
        print("No configurations available for this platform")
        return

    if not interactive:
        print("uninstalling all configurations...")
        succeeded = 0
        failed = []  # type: List[Tuple[str, str]]
        for name, conf in available:
            print("removing {}...".format(name))
            ok, err = uninstall(conf)
            if ok:
                succeeded += 1
            else:
                failed.append((name, err or "unknown error"))
                print("Error: {}".format(err))
        _print_summary(succeeded, failed, "uninstalled")
        return

    # Interactive mode — pre-select none for safety
    items = [(name, conf.dest) for name, conf in available]
    selected = select_configs("Select configurations to uninstall:", items, selected=set())

    if selected is None:
        print("Cancelled.")
        return
    if not selected:
        print("Nothing selected.")
        return

    succeeded = 0
    failed = []  # type: List[Tuple[str, str]]
    to_uninstall = [available[i] for i in selected]

    for name, conf in to_uninstall:
        print("removing {}...".format(name))
        ok, err = uninstall(conf)
        if ok:
            succeeded += 1
        else:
            print("Error uninstalling {}: {}".format(name, err))
            if len(to_uninstall) > 1 and (name, conf) != to_uninstall[-1]:
                if not confirm_continue("Continue with remaining configurations?"):
                    failed.append((name, err or "unknown error"))
                    break
            failed.append((name, err or "unknown error"))

    _print_summary(succeeded, failed, "uninstalled")


def _print_summary(succeeded, failed, verb):
    # type: (int, List[Tuple[str, str]], str) -> None
    parts = []  # type: List[str]
    parts.append("{} {}".format(succeeded, verb))
    if failed:
        skipped = ", ".join("{}: {}".format(n, e) for n, e in failed)
        parts.append("{} skipped ({})".format(len(failed), skipped))
    print("\n" + ", ".join(parts))


# ---------------------------------------------------------------------------
# Interactive TUI dashboard
# ---------------------------------------------------------------------------


class DashboardApp:
    """Full-screen interactive TUI for managing dotfile configurations."""

    def __init__(self):
        # type: () -> None
        self._cols = 80
        self._rows = 24

    def _refresh_size(self):
        # type: () -> None
        size = shutil.get_terminal_size((80, 24))
        self._cols = size.columns
        self._rows = size.lines

    def _clear(self):
        # type: () -> None
        _write(ESC_CURSOR_HOME + ESC_CLEAR_SCREEN)

    def _draw(self, lines):
        # type: (List[str]) -> None
        self._refresh_size()
        self._clear()
        output = "\r\n".join(lines[: self._rows])
        _write(output)

    def _header(self, title=""):
        # type: (str) -> List[str]
        lines = []  # type: List[str]
        lines.append("{}{}  Dotfiles Setup  {}".format(ESC_BOLD, ESC_CYAN, ESC_RESET))
        if title:
            lines.append("  {}{}{}".format(ESC_DIM, title, ESC_RESET))
        lines.append("  " + "\u2500" * min(40, self._cols - 4))
        lines.append("")
        return lines

    # -- entry point --------------------------------------------------------

    def run(self):
        # type: () -> None
        if not supports_ansi_tui():
            self._run_simple_fallback()
            return
        _write(ESC_ALT_SCREEN_ON + ESC_HIDE_CURSOR)
        try:
            with RawTerminal():
                self._main_menu()
        finally:
            _write(ESC_SHOW_CURSOR + ESC_ALT_SCREEN_OFF)

    # -- main menu ----------------------------------------------------------

    def _main_menu(self):
        # type: () -> None
        menu = MenuSelect(["Status", "Install", "Uninstall", "Info", "Quit"])
        while True:
            available = get_available_configs()
            installed = sum(
                1 for n, c in available if get_config_status(n, c) == "installed"
            )
            total = len(available)

            lines = self._header()
            lines.append(
                "  {}{}/{}{}  configs installed".format(ESC_GREEN, installed, total, ESC_RESET)
            )
            lines.append("")
            lines.extend(menu.render())
            lines.append("")
            lines.append(
                "  {}\u2191\u2193 navigate  ENTER select  Q quit{}".format(ESC_DIM, ESC_RESET)
            )
            self._draw(lines)

            key = read_key()
            result = menu.handle_key(key)
            if result is None:
                continue
            if result == 0:
                self._view_status()
            elif result == 1:
                self._view_install()
            elif result == 2:
                self._view_uninstall()
            elif result == 3:
                self._view_info()
            elif result == 4 or result == -1:
                return

    # -- status view --------------------------------------------------------

    def _view_status(self):
        # type: () -> None
        all_configs = list(CONFIGURATIONS.items())
        cursor = 0

        while True:
            lines = self._header("Status")

            status_lines = []  # type: List[Tuple[str, str, str]]
            for name, conf in all_configs:
                status = get_config_status(name, conf)
                if status == "installed":
                    icon = "{}\u25cf{}".format(ESC_GREEN, ESC_RESET)
                    label = "installed"
                elif status == "not_installed":
                    icon = "\u25cb"
                    label = "not installed"
                elif status == "conflict":
                    icon = "{}!{}".format(ESC_YELLOW, ESC_RESET)
                    label = "conflict"
                else:
                    icon = "{}\u2500{}".format(ESC_DIM, ESC_RESET)
                    label = "unavailable"
                status_lines.append((name, icon, label))

            max_name = max(len(s[0]) for s in status_lines)
            for i, (name, icon, label) in enumerate(status_lines):
                line = "  {} {}  {}".format(icon, name.ljust(max_name), label)
                if i == cursor:
                    line = "{}{}{}".format(ESC_REVERSE, line, ESC_RESET)
                lines.append(line)

            lines.append("")
            lines.append(
                "  {}\u2191\u2193 navigate  ENTER detail  Q back{}".format(ESC_DIM, ESC_RESET)
            )
            self._draw(lines)

            key = read_key()
            if key == "up":
                cursor = (cursor - 1) % len(all_configs)
            elif key == "down":
                cursor = (cursor + 1) % len(all_configs)
            elif key == "enter":
                name, conf = all_configs[cursor]
                self._show_config_detail(name, conf)
            elif key in ("q", "Q", "escape"):
                return

    def _show_config_detail(self, name, conf):
        # type: (str, Configuration) -> None
        status = get_config_status(name, conf)
        source = os.path.join(SCRIPT_DIR, conf.src)

        lines = self._header("Detail: {}".format(name))
        lines.append("  Name:        {}".format(name))
        lines.append("  Status:      {}".format(status))
        lines.append("  Source:      {}".format(source))
        lines.append("  Dest:        {}".format(conf.dest))
        if conf.platforms:
            lines.append("  Platforms:   {}".format(", ".join(conf.platforms)))
        else:
            lines.append("  Platforms:   all")
        if os.path.islink(conf.dest):
            lines.append("  Link target: {}".format(os.readlink(conf.dest)))
        lines.append("")
        lines.append("  {}Press any key to go back{}".format(ESC_DIM, ESC_RESET))
        self._draw(lines)
        read_key()

    # -- install view -------------------------------------------------------

    def _view_install(self):
        # type: () -> None
        available = get_available_configs()
        uninstalled = [
            (n, c)
            for n, c in available
            if get_config_status(n, c) != "installed"
        ]
        if not uninstalled:
            self._show_message("All configs are already installed.")
            return

        items = [(n, c.dest) for n, c in uninstalled]
        selected = set()  # type: set
        cursor = 0

        while True:
            lines = self._header("Install")
            lines.append("  Select configurations to install:")
            lines.append("")

            max_name = max(len(item[0]) for item in items)
            for i, (name, dest) in enumerate(items):
                check = "x" if i in selected else " "
                prefix = "> " if i == cursor else "  "
                line = "{}[{}] {}  {}".format(prefix, check, name.ljust(max_name), dest)
                if i == cursor:
                    line = "{}{}{}".format(ESC_REVERSE, line, ESC_RESET)
                lines.append("  {}".format(line))

            lines.append("")
            lines.append("  {} of {} selected".format(len(selected), len(items)))
            lines.append("")
            lines.append(
                "  {}\u2191\u2193 navigate  SPACE toggle  A all  ENTER confirm  Q back{}".format(
                    ESC_DIM, ESC_RESET
                )
            )
            self._draw(lines)

            key = read_key()
            if key == "up":
                cursor = (cursor - 1) % len(items)
            elif key == "down":
                cursor = (cursor + 1) % len(items)
            elif key == "space":
                if cursor in selected:
                    selected.discard(cursor)
                else:
                    selected.add(cursor)
            elif key in ("a", "A"):
                if len(selected) == len(items):
                    selected.clear()
                else:
                    selected = set(range(len(items)))
            elif key == "enter":
                if not selected:
                    self._show_message("Nothing selected.")
                    continue
                results = []  # type: List[str]
                for idx in sorted(selected):
                    name = uninstalled[idx][0]
                    conf = uninstalled[idx][1]
                    ok, err = install(conf)
                    if ok:
                        results.append(
                            "{}\u2713{} {}".format(ESC_GREEN, ESC_RESET, name)
                        )
                    else:
                        results.append(
                            "{}\u2717{} {}: {}".format(ESC_RED, ESC_RESET, name, err)
                        )
                self._show_message("\n".join(results))
                return
            elif key in ("q", "Q", "escape"):
                return

    # -- uninstall view -----------------------------------------------------

    def _view_uninstall(self):
        # type: () -> None
        available = get_available_configs()
        installed_list = [
            (n, c)
            for n, c in available
            if get_config_status(n, c) == "installed"
        ]
        if not installed_list:
            self._show_message("No configs are currently installed.")
            return

        items = [(n, c.dest) for n, c in installed_list]
        selected = set()  # type: set
        cursor = 0

        while True:
            lines = self._header("Uninstall")
            lines.append("  Select configurations to uninstall:")
            lines.append("")

            max_name = max(len(item[0]) for item in items)
            for i, (name, dest) in enumerate(items):
                check = "x" if i in selected else " "
                prefix = "> " if i == cursor else "  "
                line = "{}[{}] {}  {}".format(prefix, check, name.ljust(max_name), dest)
                if i == cursor:
                    line = "{}{}{}".format(ESC_REVERSE, line, ESC_RESET)
                lines.append("  {}".format(line))

            lines.append("")
            lines.append("  {} of {} selected".format(len(selected), len(items)))
            lines.append("")
            lines.append(
                "  {}\u2191\u2193 navigate  SPACE toggle  A all  ENTER confirm  Q back{}".format(
                    ESC_DIM, ESC_RESET
                )
            )
            self._draw(lines)

            key = read_key()
            if key == "up":
                cursor = (cursor - 1) % len(items)
            elif key == "down":
                cursor = (cursor + 1) % len(items)
            elif key == "space":
                if cursor in selected:
                    selected.discard(cursor)
                else:
                    selected.add(cursor)
            elif key in ("a", "A"):
                if len(selected) == len(items):
                    selected.clear()
                else:
                    selected = set(range(len(items)))
            elif key == "enter":
                if not selected:
                    self._show_message("Nothing selected.")
                    continue
                results = []  # type: List[str]
                for idx in sorted(selected):
                    name = installed_list[idx][0]
                    conf = installed_list[idx][1]
                    ok, err = uninstall(conf)
                    if ok:
                        results.append(
                            "{}\u2713{} {}".format(ESC_GREEN, ESC_RESET, name)
                        )
                    else:
                        results.append(
                            "{}\u2717{} {}: {}".format(ESC_RED, ESC_RESET, name, err)
                        )
                self._show_message("\n".join(results))
                return
            elif key in ("q", "Q", "escape"):
                return

    # -- info view ----------------------------------------------------------

    def _view_info(self):
        # type: () -> None
        all_configs = list(CONFIGURATIONS.items())
        cursor = 0

        while True:
            lines = self._header("Info")
            lines.append("  Select a configuration:")
            lines.append("")

            for i, (name, _conf) in enumerate(all_configs):
                if i == cursor:
                    lines.append(
                        "  {}{}> {}{}".format(ESC_REVERSE, ESC_BOLD, name, ESC_RESET)
                    )
                else:
                    lines.append("    {}".format(name))

            lines.append("")
            lines.append(
                "  {}\u2191\u2193 navigate  ENTER select  Q back{}".format(ESC_DIM, ESC_RESET)
            )
            self._draw(lines)

            key = read_key()
            if key == "up":
                cursor = (cursor - 1) % len(all_configs)
            elif key == "down":
                cursor = (cursor + 1) % len(all_configs)
            elif key == "enter":
                name, conf = all_configs[cursor]
                self._show_config_detail(name, conf)
            elif key in ("q", "Q", "escape"):
                return

    # -- message overlay ----------------------------------------------------

    def _show_message(self, message):
        # type: (str) -> None
        lines = self._header("Result")
        for line in message.split("\n"):
            lines.append("  {}".format(line))
        lines.append("")
        lines.append("  {}Press any key to continue{}".format(ESC_DIM, ESC_RESET))
        self._draw(lines)
        read_key()

    # -- simple fallback (non-ANSI) -----------------------------------------

    def _run_simple_fallback(self):
        # type: () -> None
        while True:
            available = get_available_configs()
            installed = sum(
                1 for n, c in available if get_config_status(n, c) == "installed"
            )
            total = len(available)

            print("\n  Dotfiles Setup  ({}/{} installed)".format(installed, total))
            print("  1. Status")
            print("  2. Install")
            print("  3. Uninstall")
            print("  4. Info")
            print("  5. Quit")

            try:
                choice = input("\n> ").strip()
            except EOFError:
                return

            if choice == "1":
                for name, conf in CONFIGURATIONS.items():
                    status = get_config_status(name, conf)
                    print("  {} {}".format(name, status))
            elif choice == "2":
                cmd_install(names=None, interactive=False)
            elif choice == "3":
                cmd_uninstall(names=None, interactive=False)
            elif choice == "4":
                try:
                    name = input("Config name: ").strip()
                except EOFError:
                    continue
                if name in CONFIGURATIONS:
                    cmd_info(name)
                else:
                    print("Unknown config: {}".format(name))
            elif choice in ("5", "q", "Q"):
                return


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    # type: () -> None
    args = sys.argv[1:]

    if not args:
        DashboardApp().run()
        return

    command = args[0]
    rest = args[1:]
    no_interactive = "--no-interactive" in rest
    config_args = [a for a in rest if not a.startswith("--")]

    if command == "list":
        cmd_list()
    elif command == "info":
        if not config_args:
            print("requires configuration name")
            sys.exit(1)
        cmd_info(config_args[0])
    elif command == "install":
        if config_args:
            cmd_install(names=config_args, interactive=True)
        else:
            cmd_install(names=None, interactive=not no_interactive)
    elif command in ("uninstall", "remove"):
        if config_args:
            cmd_uninstall(names=config_args, interactive=True)
        else:
            cmd_uninstall(names=None, interactive=not no_interactive)
    else:
        print("invalid subcommand")
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        # Restore terminal and exit cleanly
        _write(ESC_SHOW_CURSOR + ESC_ALT_SCREEN_OFF)
        print("\nCancelled.")
        sys.exit(130)
