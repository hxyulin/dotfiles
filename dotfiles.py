#!/usr/bin/env python3

import sys
import os

def get_config_dir():
    # If we are on windows, it would be located at the appdata directory
    if sys.platform == 'win32':
        return os.environ['APPDATA']
    else:
        return os.path.expanduser('~/.config')

def get_script_dir():
    return os.path.dirname(os.path.realpath(__file__))

def symlink(source, target):
    if os.path.exists(target):
        print(f"Target {target} already exists.")
        sys.exit(1)
    os.symlink(source, target)

def unlink(target):
    if os.path.exists(target):
        os.unlink(target)

def print_help():
    name = sys.argv[0]
    print(f'Usage: {name} install <configuration | all>')
    print(f'Usage: {name} uninstall <configuration | all>')
    print(f'Usage: {name} list')
    sys.exit(1)

def install(configurations):
    config_dir = get_config_dir()
    script_dir = get_script_dir()
    print(f"Installing configurations to {config_dir}")

    for configuration in configurations:
        source = os.path.join(script_dir, configuration)
        target = os.path.join(config_dir, configuration)
        symlink(source, target)

def uninstall(configurations):
    config_dir = get_config_dir()
    print(f"Uninstalling configurations from {config_dir}")
    for configuration in configurations:
        target = os.path.join(config_dir, configuration)
        unlink(target)


def main():
    if len(sys.argv) < 2:
        print_help()
    command = sys.argv[1]

    configurations = [
        'nvim',
        'alacritty',
        'ghostty',
    ]

    if sys.platform == 'darwin':
        configurations += [
            'aerospace',
            'sketchybar',
            'skhd',
        ]

    if command == 'list':
        print(configurations)
        sys.exit(0)

    if command == 'install':
        if len(sys.argv) < 3:
            print_help()
        configuration = sys.argv[2]
        if configuration == 'all':
            install(configurations)
            sys.exit(0)
        if configuration not in configurations:
            print(f'Configuration {configuration} not found.')
            sys.exit(1)
        install([configuration])

    elif command == 'uninstall':
        if len(sys.argv) < 3:
            print_help()
        configuration = sys.argv[2]
        if configuration == 'all':
            uninstall(configurations)
            sys.exit(0)
        if configuration not in configurations:
            print(f'Configuration {configuration} not found.')
            sys.exit(1)
        uninstall([configuration])

if __name__ == '__main__':
    main()
