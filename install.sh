#!/usr/bin/env bash
# LLMX Installer
# Installs LLMX CLI tools to ~/.local/bin
#
# Usage: ./install.sh

set -e

VERSION="1.0.0"
REPO_URL="https://github.com/maiglesi/llmx"
RAW_URL="https://raw.githubusercontent.com/maiglesi/llmx/main"

# Colors (disable with NO_COLOR=1)
if [[ -z "${NO_COLOR:-}" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

echo -e "${CYAN}${BOLD}LLMX Installer${NC} v${VERSION}"
echo

# Determine install directory
INSTALL_DIR="${LLMX_INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$INSTALL_DIR"

if [[ ! -w "$INSTALL_DIR" ]]; then
    echo -e "${RED}Error: Cannot write to $INSTALL_DIR${NC}"
    exit 1
fi

echo -e "Installing to ${BOLD}$INSTALL_DIR${NC}..."
echo

# Check if running from pipe (curl) or local
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null)" 2>/dev/null && pwd)"

if [[ -f "$SCRIPT_DIR/bin/llmx" ]]; then
    # Local install from cloned repo
    echo "Installing from local repository..."
    cp "$SCRIPT_DIR/bin/llmx" "$INSTALL_DIR/llmx"
    cp "$SCRIPT_DIR/bin/orchestrate" "$INSTALL_DIR/orchestrate"
else
    # Remote install via curl
    echo "Downloading from GitHub..."

    if command -v curl &>/dev/null; then
        curl -fsSL "$RAW_URL/bin/llmx" -o "$INSTALL_DIR/llmx"
        curl -fsSL "$RAW_URL/bin/orchestrate" -o "$INSTALL_DIR/orchestrate"
    elif command -v wget &>/dev/null; then
        wget -q "$RAW_URL/bin/llmx" -O "$INSTALL_DIR/llmx"
        wget -q "$RAW_URL/bin/orchestrate" -O "$INSTALL_DIR/orchestrate"
    else
        echo -e "${RED}Error: curl or wget required${NC}"
        exit 1
    fi
fi

# Make executable
chmod +x "$INSTALL_DIR/llmx"
chmod +x "$INSTALL_DIR/orchestrate"

echo -e "${GREEN}✓${NC} Installed llmx"
echo -e "${GREEN}✓${NC} Installed orchestrate"
echo

# Check if in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Add to PATH:${NC}"
    echo

    # Detect shell
    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        zsh)
            echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.zshrc"
            echo "  source ~/.zshrc"
            ;;
        bash)
            echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.bashrc"
            echo "  source ~/.bashrc"
            ;;
        *)
            echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
            ;;
    esac
    echo
fi

# Create default config if not exists
if [[ ! -f "$HOME/.llmxrc" ]]; then
    echo "Creating config at ~/.llmxrc..."
    cat > "$HOME/.llmxrc" << 'EOF'
# LLMX Configuration
# Customize LLM commands and settings here

# LLM Commands (uncomment and modify as needed)
# LLMX_CMD_GEMINI="gemini"
# LLMX_CMD_CODEX="codex exec"
# LLMX_CMD_GPT4="openai chat"
# LLMX_CMD_OLLAMA="ollama run llama2"

# Default target (optional)
# LLMX_DEFAULT_TARGET="gemini"

# Log directory
# LLMX_LOG_DIR="$HOME/.llmx"
EOF
    echo -e "${GREEN}✓${NC} Created ~/.llmxrc"
    echo
fi

echo -e "${GREEN}${BOLD}Installation complete!${NC}"
echo
echo "Quick start:"
echo "  ${BOLD}llmx --help${NC}"
echo "  ${BOLD}orchestrate --help${NC}"
echo
echo "Example:"
echo "  ${BOLD}llmx ask gemini \"What is LLMX?\"${NC}"
echo
echo "Documentation: $REPO_URL"
