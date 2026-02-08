#!/usr/bin/env python3

import sys
import os
import platform
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
# Main
# ---------------------------------------------------------------------------

def main():
    # type: () -> None
    args = sys.argv[1:]

    if not args:
        name = sys.argv[0]
        print("Usage: {} install [configuration] [--no-interactive]".format(name))
        print("Usage: {} uninstall [configuration] [--no-interactive]".format(name))
        print("Usage: {} info <configuration>".format(name))
        print("Usage: {} list".format(name))
        sys.exit(1)

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
        _write("\033[?25h")
        print("\nCancelled.")
        sys.exit(130)
