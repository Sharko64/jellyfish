#!/usr/bin/env bash
# install_main.sh - main installer for the project
# This script installs the project and sets up the main command.

set -euo pipefail

PROJECT_NAME="myproject"           # Replace with your project name
INSTALL_DIR="$HOME/.local/bin"     # Default user-local install
REPO_URL="https://github.com/<username>/<repo>"  # Replace with your repo URL
BINARY_NAME="mycmd"                # The command user will run

# Ensure install dir exists
mkdir -p "$INSTALL_DIR"

# Check for required commands
for cmd in curl tar; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    fi
done

# Determine system architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
echo "Detected OS: $OS, ARCH: $ARCH"

# Construct URL for the binary tarball
TARBALL_URL="$REPO_URL/releases/latest/download/${PROJECT_NAME}_${OS}_${ARCH}.tar.gz"

# Temp directory for download and extraction
TMPDIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

echo "Downloading $PROJECT_NAME..."
curl -fsSL "$TARBALL_URL" -o "$TMPDIR/${PROJECT_NAME}.tar.gz"

echo "Extracting files..."
tar -xzf "$TMPDIR/${PROJECT_NAME}.tar.gz" -C "$TMPDIR"

echo "Installing $BINARY_NAME to $INSTALL_DIR..."
cp "$TMPDIR/$BINARY_NAME" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

# Add install dir to PATH if not already
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    SHELL_RC="$HOME/.bashrc"
    if [ -n "${ZSH_VERSION:-}" ]; then
        SHELL_RC="$HOME/.zshrc"
    fi
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "Added $INSTALL_DIR to PATH in $SHELL_RC. Please restart your shell."
fi

echo "$PROJECT_NAME installed successfully!"
echo "Run '$BINARY_NAME --help' to get started."