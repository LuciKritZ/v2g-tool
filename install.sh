#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting v2g Universal Installer...${NC}"

# ==============================================================================
# OS & Dependency Detection
# ==============================================================================
install_deps() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected macOS."
        if command -v brew &> /dev/null; then
            echo "Installing dependencies via Homebrew..."
            brew install ffmpeg gifsicle
        else
            echo "Error: Homebrew is not installed. Please install it first."
            exit 1
        fi
    elif [[ -f /etc/arch-release ]]; then
        echo "Detected Arch Linux."
        echo "Installing dependencies via Pacman..."
        sudo pacman -S --noconfirm ffmpeg gifsicle
    elif [[ -f /etc/debian_version ]]; then
        echo "Detected Debian/Ubuntu."
        echo "Installing dependencies via Apt..."
        sudo apt update && sudo apt install -y ffmpeg gifsicle
    elif [[ -f /etc/fedora-release ]]; then
        echo "Detected Fedora."
        echo "Installing dependencies via DNF..."
        sudo dnf install -y ffmpeg gifsicle
    else
        echo "Unknown OS. Please install 'ffmpeg' and 'gifsicle' manually."
    fi
}

# ==============================================================================
# File Installation
# ==============================================================================

# Install Dependencies
install_deps

echo -e "\n${YELLOW}Installing Library Files...${NC}"

# Define paths
INSTALL_BIN="/usr/local/bin"
INSTALL_LIB="/usr/local/lib/v2g"

# Create lib directory
echo "Creating $INSTALL_LIB..."
sudo mkdir -p "$INSTALL_LIB"

# Copy library
echo "Copying library..."
sudo cp lib/v2g.sh "$INSTALL_LIB/v2g.sh"
sudo chmod 644 "$INSTALL_LIB/v2g.sh"

# Copy executable
echo "Copying executable..."
sudo cp bin/v2g "$INSTALL_BIN/v2g"
sudo chmod +x "$INSTALL_BIN/v2g"

echo -e "\n${GREEN}Success! 'v2g' is now installed on your system.${NC}"
echo -e "Usage: v2g <video_file> [output_name]"
