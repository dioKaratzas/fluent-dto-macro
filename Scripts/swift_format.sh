#!/bin/sh

# Get the real path of the script, resolving symlinks
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"

SWIFT_VERSION=6.0
CONFIG_FILE="$SCRIPT_DIR/configs/config.swiftformat"
SWIFTFORMAT_CMD="$SCRIPT_DIR/bin/swiftformat"

# Function to set green text color
green_colorize() {
    text=$1
    echo "$(tput setaf 2)$text$(tput sgr0)"
}

# Function to set blue text color
blue_colorize() {
    text=$1
    echo "$(tput setaf 4)$text$(tput sgr0)"
}

# Function to display usage
usage() {
    echo "Usage: $SCRIPT_PATH [option]"
    echo "Options:"
    echo "  -l    Lint all files without making changes."
    echo "  -a    Apply format to all files."
    echo "  -c    Apply format to changed files only."
    echo "  -h    Display this help message."
    exit 1
}

# Function to show interactive choices if no argument is provided
show_choices() {
    echo "Please select an option:"
    echo "$(green_colorize '1)') Lint all files without making changes."
    echo "$(green_colorize '2)') Apply format to all files."
    echo "$(green_colorize '3)') Apply format to changed files only."
    read -p "$(blue_colorize 'Enter choice: ')" choice

    echo ""
    case $choice in
        1) option="-l" ;;
        2) option="-a" ;;
        3) option="-c" ;;
        *) echo "Invalid choice. Exiting."; exit 1 ;;
    esac

    # Execute the selected option using the absolute path
    sh "$SCRIPT_PATH" "$option"
    exit 0
}

# Check if swiftformat is installed
if ! command -v "$SWIFTFORMAT_CMD" >/dev/null; then
    echo "error: swiftformat needs to be installed"
    exit 1
fi

# Process command-line options
if [ -z "$1" ]; then
    show_choices
else
    case $1 in
        -l)
            echo "> Lint all files without making changes..."
            $SWIFTFORMAT_CMD "$PARENT_DIR" --lint --config "$CONFIG_FILE" --swiftversion $SWIFT_VERSION ;;
        -a)
            echo "> Apply format to all files..."
            $SWIFTFORMAT_CMD "$PARENT_DIR" --config "$CONFIG_FILE" --swiftversion $SWIFT_VERSION ;;
        -c)
            echo "> Apply format to changed files only..."
            git diff --diff-filter=d --name-only --line-prefix=$(git rev-parse --show-toplevel)/ $(git merge-base origin/develop HEAD) | grep "\.swift" | while read filename; do
                $SWIFTFORMAT_CMD "$filename" --config "$CONFIG_FILE" --swiftversion $SWIFT_VERSION
            done
            ;;
        -h | *) usage ;;
    esac
fi
