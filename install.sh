#!/bin/bash

# infoshyt Installer
# Installs tools required by infoshyt.sh
# Usage: ./install.sh [--force]

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Banner
echo -e "
 ▄▀▀█▀▄    ▄▀▀▄ ▀▄  ▄▀▀▀█▄    ▄▀▀▀▀▄   ▄▀▀▀▀▄  ▄▀▀▄ ▄▄   ▄▀▀▄ ▀▀▄  ▄▀▀▀█▀▀▄ 
█   █  █  █  █ █ █ █  ▄▀  ▀▄ █      █ █ █   ▐ █  █   ▄▀ █   ▀▄ ▄▀ █    █  ▐ 
▐   █  ▐  ▐  █  ▀█ ▐ █▄▄▄▄   █      █    ▀▄   ▐  █▄▄▄█  ▐     █   ▐   █     
    █       █   █   █    ▐   ▀▄    ▄▀ ▀▄   █     █   █        █      █      
 ▄▀▀▀▀▀▄  ▄▀   █    █          ▀▀▀▀    █▀▀▀     ▄▀  ▄▀      ▄▀     ▄▀       
█       █ █    ▐   █                   ▐       █   █        █     █         
▐       ▐ ▐        ▐                           ▐   ▐        ▐     ▐         
                                    
infoshyt Installer
"

# Variables
TOOLS_DIR=~/Tools
FORCE=false
SUDO=""
PROFILE_SHELL=".bashrc"

# Check for zsh
if [[ -f "$HOME/.zshrc" ]]; then
    PROFILE_SHELL=".zshrc"
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE=true; shift ;;
        *) echo -e "${RED}[ERROR] Unknown option: $1${RESET}"; exit 1 ;;
    esac
done

# Determine if script is run as root
if [[ "$(id -u)" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Check Bash version
BASH_VERSION_NUM=$(bash --version | awk 'NR==1{print $4}' | cut -d'.' -f1)
if [[ $BASH_VERSION_NUM -lt 4 ]]; then
    echo -e "${RED}[ERROR] Bash version < 4, please update.${RESET}"
    exit 1
fi

# Install system packages
install_system_packages() {
    echo -e "${GREEN}[INFO] Installing system packages${RESET}"
    if [[ -f /etc/debian_version ]]; then
        $SUDO apt-get update -y
        $SUDO apt-get install -y python3 python3-pip python3-venv pipx git curl whois exiftool jq
    elif [[ -f /etc/redhat-release ]]; then
        $SUDO yum install -y python3 python3-pip git curl whois perl-Image-ExifTool jq
    elif [[ -f /etc/arch-release ]]; then
        $SUDO pacman -Sy --noconfirm python python-pip git curl whois exiftool jq
    else
        echo -e "${RED}[ERROR] Unsupported OS. Install dependencies manually.${RESET}"
        exit 1
    fi
    pipx ensurepath
    source "$HOME/$PROFILE_SHELL"
}

# Install Go
install_golang() {
    echo -e "${GREEN}[INFO] Installing Go${RESET}"
    local VERSION="go1.20.7"
    $SUDO rm -rf /usr/local/go
    wget -q "https://dl.google.com/go/$VERSION.linux-amd64.tar.gz" -O "/tmp/$VERSION.tar.gz"
    $SUDO tar -C /usr/local -xzf "/tmp/$VERSION.tar.gz"
    $SUDO ln -sf /usr/local/go/bin/go /usr/local/bin/
    export GOROOT=/usr/local/go
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH"
    cat <<EOF >>"$HOME/$PROFILE_SHELL"
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF
    source "$HOME/$PROFILE_SHELL"
}

# Install Go tools
install_gotools() {
    echo -e "${GREEN}[INFO] Installing Go tools${RESET}"
    local TOOLS=("gitdorks_go" "anew" "unfurl" "enumerepo" "gitleaks" "trufflehog" "misconfig-mapper")
    for TOOL in "${TOOLS[@]}"; do
        if [[ $FORCE == false ]] && command -v "$TOOL" &>/dev/null; then
            echo -e "${YELLOW}[SKIP] $TOOL already installed${RESET}"
            continue
        fi
        go install -v "github.com/damit5/gitdorks_go@latest" &>/dev/null || echo -e "${RED}Failed to install $TOOL${RESET}"
    done
}

# Install Python repos
install_repos() {
    echo -e "${GREEN}[INFO] Installing Python repos${RESET}"
    local REPOS=("dorks_hunter" "metagoofil" "SwaggerSpy" "EmailHarvester" "LeakSearch" "msftrecon" "Scopify" "Spoofy")
    for REPO in "${REPOS[@]}"; do
        if [[ $FORCE == false ]] && [[ -d "$TOOLS_DIR/$REPO" ]]; then
            echo -e "${YELLOW}[SKIP] $REPO already cloned${RESET}"
            continue
        fi
        git clone --filter="blob:none" "https://github.com/six2dez/$REPO" "$TOOLS_DIR/$REPO" &>/dev/null
        cd "$TOOLS_DIR/$REPO" || continue
        python3 -m venv venv
        source venv/bin/activate
        pip3 install --upgrade -r requirements.txt &>/dev/null
        deactivate
        cd "$TOOLS_DIR" || exit 1
    done
}

# Main installation
echo -e "${GREEN}[START] Installing infoshyt tools${RESET}"
install_system_packages
install_golang
install_gotools
install_repos
echo -e "${GREEN}[SUCCESS] Installation completed!${RESET}"
echo -e "${YELLOW}Remember to set your API keys:${RESET}"
echo -e "- GitHub (/home/aparichit/Tools/.github_tokens)"
echo -e "- GitLab (/home/aparichit/Tools/.gitlab_tokens)"
echo -e "- WHOISXML API (WHOISXML_API in infoshyt.cfg or env var)"
