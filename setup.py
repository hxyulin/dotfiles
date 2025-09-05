#!/usr/bin/env python3

import sys
import os
import platform
from dataclasses import dataclass

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
# TODO: Read env variable and or arguments

@dataclass
class Configuration:
    platforms: list[str]
    src: str
    dest: str
    deps: list[str]
    setup: None

    def is_available(self) -> bool:
        return len(self.platforms) == 0 or (PLATFORM in self.platforms)

CONFIGURATIONS: dict[str, Configuration] = {
    "nvim_nvchad": Configuration(
        platforms=[],
        src="nvim_nvchad",
        dest=f"{CONFIG_DIR}/nvim",
        deps=[],
        # Additional setup function
        setup=None,
    ),
    "nvim": Configuration(
        platforms=[],
        src="nvim",
        dest=f"{CONFIG_DIR}/nvim",
        deps=[],
        # Additional setup function
        setup=None,
    ),
    "starship": Configuration(
        platforms=[],
        src="starship.toml",
        dest=f"{CONFIG_DIR}/starship.toml",
        deps=[],
        # TODO=Find shell, and give instructions for installation
        setup=None,
    ),
    "tmux": Configuration(
        platforms=[],
        src=".tmux.conf",
        dest=f"{HOME_DIR}/.tmux.conf",
        deps=[],
        setup=None,
    ),
    "nix-darwin": Configuration(
        platforms=["Darwin"],
        src="nix-darwin",
        dest=f"{CONFIG_DIR}/nix-darwin",
        deps=[],
        setup=None,
    ),
    "ghostty": Configuration(
        platforms=[],
        src="ghostty",
        dest=f"{CONFIG_DIR}/ghostty",
        deps=[],
        setup=None,
    ),
}

def symlink(source: str, target: str):
    if os.path.exists(target):
        print(f"installation destination {target} already exists, please review and remove it manually!")
        sys.exit(1)
    os.symlink(source, target)

def unlink(target: str):
    if not os.path.islink(target):
        print(f"{target} is not symlinked, please remove it manually if you are sure!")
        sys.exit(1)
    if os.path.exists(target) and os.path.islink(target):
        os.unlink(target)
    else:
        print(f"cannot unlink {target}, because it doesn't exist or isn't a symlink")

def install(config: Configuration):
    source = os.path.join(SCRIPT_DIR, config.src)
    print(f"symlinking {config.dest} -> {source}")
    symlink(source, config.dest)

def uninstall(config: Configuration):
    unlink(config.dest)

def main():
    if len(sys.argv) < 2:
        name = sys.argv[0]
        print(f'Usage: {name} install [configuration]')
        print(f'Usage: {name} uninstall [configuration]')
        print(f"Usage: {name} info <configuration>")
        print(f'Usage: {name} list')
        sys.exit(1)
    command = sys.argv[1]

    match command:
        case 'list':
            unavailable: int = 0
            for name,conf in CONFIGURATIONS.items():
                if not conf.is_available():
                    unavailable += 1;
                    continue
                print(name)
            print(f"... and {unavailable} more not supported for the current platform")
            sys.exit(0)
        case 'info':
            if len(sys.argv) < 3:
                print("requires configuration name")
                sys.exit(1)
            name = sys.argv[2]
            try:
                conf = CONFIGURATIONS[name]
                print(f"Configuration '{name}'")
                if len(conf.platforms) != 0:
                    print(f"Available for platforms: {",".join(conf.platforms)}")
                else:
                    print(f"Available for all platforms")
                print(f"Configuration destination: '{conf.dest}'")
            except KeyError: 
                print("invalid configuration")
                sys.exit(1)
            sys.exit(0)
        case 'install':
            if len(sys.argv) < 3:
                print("installing all configurations...")
                for name,conf in CONFIGURATIONS.items():
                    if not conf.is_available():
                        continue
                    print(f"installing {name}...")
                    install(conf)
            else:
                name = sys.argv[2]
                try:
                    install(CONFIGURATIONS[name])
                except KeyError:
                    print("invalid configuration")
                    sys.exit(1)
                sys.exit(0)
        case 'uninstall' | 'remove':
            if len(sys.argv) < 3:
                if input("are you sure you want to remove all configurations? Y/n").lower() == 'n':
                    print("cancelled")
                    sys.exit(1)
                for name,conf in CONFIGURATIONS.items():
                    if not conf.is_available():
                        continue
                    print(f"removing {name}...")
                    uninstall(conf)
            else:
                name = sys.argv[2]
                try:
                    uninstall(CONFIGURATIONS[name])
                except KeyError:
                    print("invalid configuration")
                    sys.exit(1)
                sys.exit(0)

        case _:
            print("invalid subcommand")

if __name__ == '__main__':
    main()
