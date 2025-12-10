#!/usr/bin/env bash
# LLMX Installer
# Installs LLMX CLI tools to /usr/local/bin or user's bin directory

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${LLMX_INSTALL_DIR:-/usr/local/bin}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}LLMX Installer${NC}"
echo

# Check if we can write to install directory
if [[ ! -w "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}Cannot write to $INSTALL_DIR${NC}"
    echo "Options:"
    echo "  1. Run with sudo: sudo ./install.sh"
    echo "  2. Install to user directory:"
    echo "     LLMX_INSTALL_DIR=~/.local/bin ./install.sh"
    echo

    # Try user's local bin
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"

    if [[ ! -w "$INSTALL_DIR" ]]; then
        echo -e "${RED}Cannot create $INSTALL_DIR${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Installing to $INSTALL_DIR instead${NC}"
    echo
fi

# Install scripts
echo "Installing to $INSTALL_DIR..."

cp "$REPO_DIR/bin/llmx" "$INSTALL_DIR/llmx"
cp "$REPO_DIR/bin/orchestrate" "$INSTALL_DIR/orchestrate"

chmod +x "$INSTALL_DIR/llmx"
chmod +x "$INSTALL_DIR/orchestrate"

echo -e "${GREEN}Installed:${NC}"
echo "  - llmx"
echo "  - orchestrate"
echo

# Check if in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Note:${NC} $INSTALL_DIR is not in your PATH"
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
    echo
fi

# Create default config if not exists
if [[ ! -f "$HOME/.llmxrc" ]]; then
    echo "Creating default config at ~/.llmxrc..."
    cat > "$HOME/.llmxrc" << 'EOF'
# LLMX Configuration
# Customize LLM commands and settings here

# LLM Commands
# LLMX_CMD_GEMINI="gemini"
# LLMX_CMD_CODEX="codex exec"
# LLMX_CMD_GPT4="openai chat"
# LLMX_CMD_OLLAMA="ollama run llama2"

# Default target (optional)
# LLMX_DEFAULT_TARGET="gemini"

# Log directory
# LLMX_LOG_DIR="$HOME/.llmx"
EOF
    echo -e "${GREEN}Created ~/.llmxrc${NC}"
    echo
fi

echo -e "${GREEN}Installation complete!${NC}"
echo
echo "Quick start:"
echo "  llmx --help"
echo "  orchestrate --help"
echo
echo "Example:"
echo "  llmx ask gemini \"What is LLMX?\""
