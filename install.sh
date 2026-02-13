#!/bin/bash

# infoshyt Installer
# Installs tools required by infoshyt.sh
# Usage: ./install.sh [OPTIONS]
#
# OPTIONS:
#   --check     Check installation status
#   --force     Force reinstall all tools
#   --help      Show this help message
#
# EXAMPLES:
#   ./install.sh              # Install all tools (skips already installed)
#   ./install.sh --check       # Check installation status
#   ./install.sh --force      # Force reinstall all tools

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Variables
TOOLS_DIR=~/Tools
FORCE=false
CHECK=false
SUDO=""

# Show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --check     Check installation status"
    echo "  --force     Force reinstall all tools"
    echo "  --help      Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0              # Install all tools (skips already installed)"
    echo "  $0 --check      # Check installation status"
    echo "  $0 --force      # Force reinstall all tools"
    exit 0
}

# Check installation status
check_installation() {
    echo -e "${BLUE}[CHECK] Installation Status${RESET}"
    echo ""
    
    echo -e "${BLUE}=== System Packages ===${RESET}"
    local PKGS=("python3" "git" "curl" "whois" "exiftool" "jq" "dig")
    for pkg in "${PKGS[@]}"; do
        if command -v "$pkg" &>/dev/null; then
            echo -e "  ${GREEN}[OK]${RESET} $pkg"
        else
            echo -e "  ${RED}[MISSING]${RESET} $pkg"
        fi
    done
    
    echo ""
    echo -e "${BLUE}=== Go Tools ===${RESET}"
    local GO_TOOLS=("gitdorks_go" "anew" "unfurl" "enumerepo" "gitleaks" "trufflehog" "misconfig-mapper" "porch-pirate" "cloud_enum")
    for tool in "${GO_TOOLS[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}[OK]${RESET} $tool"
        else
            echo -e "  ${RED}[MISSING]${RESET} $tool"
        fi
    done
    
    echo ""
    echo -e "${BLUE}=== Python Repos ===${RESET}"
    local REPOS=("dorks_hunter" "metagoofil" "SwaggerSpy" "EmailHarvester" "LeakSearch" "msftrecon" "Scopify" "Spoofy" "cloud_enum" "fav-up")
    for repo in "${REPOS[@]}"; do
        if [[ -d "$TOOLS_DIR/$repo" ]]; then
            echo -e "  ${GREEN}[OK]${RESET} $repo"
        else
            echo -e "  ${RED}[MISSING]${RESET} $repo"
        fi
    done
    
    echo ""
    echo -e "${BLUE}=== Configuration Files ===${RESET}"
    if [[ -f "$HOME/Tools/.github_tokens" ]]; then
        echo -e "  ${GREEN}[OK]${RESET} GitHub tokens"
    else
        echo -e "  ${RED}[MISSING]${RESET} GitHub tokens (run ./configure_infoshyt.sh)"
    fi
    
    if [[ -f "$HOME/Tools/.gitlab_tokens" ]]; then
        echo -e "  ${GREEN}[OK]${RESET} GitLab tokens"
    else
        echo -e "  ${RED}[MISSING]${RESET} GitLab tokens (run ./configure_infoshyt.sh)"
    fi
    
    if [[ -f "infoshyt.cfg" ]]; then
        echo -e "  ${GREEN}[OK]${RESET} infoshyt.cfg"
    else
        echo -e "  ${RED}[MISSING]${RESET} infoshyt.cfg (run ./configure_infoshyt.sh)"
    fi
    
    exit 0
}

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

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --check) CHECK=true; shift ;;
        --force) FORCE=true; shift ;;
        --help) show_help ;;
        *) echo -e "${RED}[ERROR] Unknown option: $1${RESET}"; echo "Use --help for usage information"; exit 1 ;;
    esac
done

# Run check if requested
if [[ $CHECK == true ]]; then
    check_installation
fi

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
        $SUDO apt-get install -y python3 python3-pip python3-venv pipx git curl whois exiftool jq dnsutils
    elif [[ -f /etc/redhat-release ]]; then
        $SUDO yum install -y python3 python3-pip git curl whois perl-Image-ExifTool jq bind-utils
    elif [[ -f /etc/arch-release ]]; then
        $SUDO pacman -Sy --noconfirm python python-pip git curl whois exiftool jq dnsutils
    else
        echo -e "${RED}[ERROR] Unsupported OS. Install dependencies manually.${RESET}"
        exit 1
    fi
    pipx ensurepath
    if ! command -v xnldorker &>/dev/null; then
        echo -e "${GREEN}[INSTALL] xnldorker${RESET}"
        pipx install xnldorker 2>&1 | tail -3
        pipx inject xnldorker pyyaml 2>&1 | tail -3
    else
        echo -e "${YELLOW}[SKIP] xnldorker already installed${RESET}"
    fi
}

# Install Go
install_golang() {
    if command -v go &>/dev/null; then
        echo -e "${YELLOW}[SKIP] Go already installed: $(go version 2>/dev/null)${RESET}"
        return 0
    fi
    echo -e "${GREEN}[INFO] Installing Go${RESET}"
    local VERSION="go1.20.7"
    $SUDO rm -rf /usr/local/go
    wget -q "https://dl.google.com/go/$VERSION.linux-amd64.tar.gz" -O "/tmp/$VERSION.tar.gz"
    $SUDO tar -C /usr/local -xzf "/tmp/$VERSION.tar.gz"
    $SUDO ln -sf /usr/local/go/bin/go /usr/local/bin/
    export GOROOT=/usr/local/go
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH"
    if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q "GOROOT=/usr/local/go" "$HOME/.bashrc"; then
            cat <<EOF >>"$HOME/.bashrc"
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF
        fi
    fi
}

# Install Go tools
install_gotools() {
    echo -e "${GREEN}[INFO] Installing Go tools${RESET}"
    export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"
    
    local TOOLS=("gitdorks_go" "anew" "unfurl" "enumerepo")
    for TOOL in "${TOOLS[@]}"; do
        if [[ $FORCE == false ]] && command -v "$TOOL" &>/dev/null; then
            echo -e "${YELLOW}[SKIP] $TOOL already installed${RESET}"
            continue
        fi
        echo -e "${GREEN}[INSTALL] $TOOL${RESET}"
        case "$TOOL" in
            gitdorks_go) go install -v github.com/damit5/gitdorks_go@latest 2>&1 | tail -5 ;;
            anew) go install -v github.com/tomnomnom/anew@latest 2>&1 | tail -5 ;;
            unfurl) go install -v github.com/tomnomnom/unfurl@latest 2>&1 | tail -5 ;;
            enumerepo) go install -v github.com/trickest/enumerepo@latest 2>&1 | tail -5 ;;
            porch-pirate) go install -v github.com/MandConsultingGroup/porch-pirate@latest 2>&1 | tail -5 ;;
        esac
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[FAIL] $TOOL${RESET}"
        fi
    done
    
    if [[ $FORCE == false ]] && command -v "gitleaks" &>/dev/null; then
        echo -e "${YELLOW}[SKIP] gitleaks already installed${RESET}"
    else
        echo -e "${GREEN}[INSTALL] gitleaks (git clone + make build)${RESET}"
        local GITLEAKS_DIR="/tmp/gitleaks"
        rm -rf "$GITLEAKS_DIR"
        git clone --filter="blob:none" https://github.com/gitleaks/gitleaks.git "$GITLEAKS_DIR" 2>&1 | tail -3
        if [[ -d "$GITLEAKS_DIR" ]]; then
            cd "$GITLEAKS_DIR" && make build 2>&1 | tail -3
            $SUDO cp gitleaks /usr/local/bin/ 2>/dev/null || cp gitleaks "$HOME/go/bin/" 2>/dev/null
            cd - &>/dev/null
        else
            echo -e "${RED}[FAIL] gitleaks${RESET}"
        fi
    fi
    
    if [[ $FORCE == false ]] && command -v "trufflehog" &>/dev/null; then
        echo -e "${YELLOW}[SKIP] trufflehog already installed${RESET}"
    else
        echo -e "${GREEN}[INSTALL] trufflehog (install script)${RESET}"
        curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh 2>&1 | sh -s -- -b "$HOME/go/bin" 2>&1 | tail -5
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[FAIL] trufflehog${RESET}"
        fi
    fi
    
    if [[ $FORCE == false ]] && command -v "misconfig-mapper" &>/dev/null; then
        echo -e "${YELLOW}[SKIP] misconfig-mapper already installed${RESET}"
    else
        echo -e "${GREEN}[INSTALL] misconfig-mapper${RESET}"
        go install github.com/intigriti/misconfig-mapper/cmd/misconfig-mapper@latest 2>&1 | tail -5
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[FAIL] misconfig-mapper${RESET}"
        fi
    fi

    if [[ $FORCE == false ]] && command -v "porch-pirate" &>/dev/null; then
        echo -e "${YELLOW}[SKIP] porch-pirate already installed${RESET}"
    else
        echo -e "${GREEN}[INSTALL] porch-pirate${RESET}"
        pip3 install porch-pirate --break-system-packages 2>&1 | tail -5
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}[FAIL] porch-pirate${RESET}"
        fi
    fi
}

# Install Python repos
install_repos() {
    echo -e "${GREEN}[INFO] Installing Python repos${RESET}"
    mkdir -p "$TOOLS_DIR"
    
    local -A REPO_URLS=(
        ["dorks_hunter"]="https://github.com/six2dez/dorks_hunter"
        ["metagoofil"]="https://github.com/opsdisk/metagoofil"
        ["SwaggerSpy"]="https://github.com/UndeadSec/SwaggerSpy"
        ["EmailHarvester"]="https://github.com/maldevel/EmailHarvester"
        ["LeakSearch"]="https://github.com/JoelGMSec/LeakSearch"
        ["msftrecon"]="https://github.com/six2dez/msftrecon"
        ["Scopify"]="https://github.com/Arcanum-Sec/Scopify"
        ["Spoofy"]="https://github.com/MattKeeley/Spoofy"
        ["cloud_enum"]="https://github.com/initstring/cloud_enum"
        ["fav-up"]="https://github.com/pielco11/fav-up"
    )
    
    local REPOS=("dorks_hunter" "metagoofil" "SwaggerSpy" "EmailHarvester" "LeakSearch" "msftrecon" "Scopify" "Spoofy" "cloud_enum" "fav-up")
    
    for REPO in "${REPOS[@]}"; do
        if [[ $FORCE == false ]] && [[ -d "$TOOLS_DIR/$REPO" ]]; then
            echo -e "${YELLOW}[SKIP] $REPO already cloned${RESET}"
            continue
        fi
        
        echo -e "${GREEN}[INSTALL] $REPO${RESET}"
        
        if [[ "$REPO" == "Scopify" ]]; then
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/scopify.py" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                ./venv/bin/pip install --upgrade pip 2>&1 | tail -3
                ./venv/bin/pip install -r requirements.txt 2>&1 | tail -3
                cd "$TOOLS_DIR" || exit 1
            fi
        elif [[ "$REPO" == "EmailHarvester" ]]; then
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/requirements.txt" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                ./venv/bin/pip install --upgrade pip 2>&1 | tail -3
                ./venv/bin/pip install -r requirements.txt 2>&1 | tail -3
                cd "$TOOLS_DIR" || exit 1
            fi
        elif [[ "$REPO" == "Spoofy" ]]; then
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/requirements.txt" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                ./venv/bin/pip install --upgrade pip 2>&1 | tail -3
                ./venv/bin/pip install -r requirements.txt 2>&1 | tail -3
                cd "$TOOLS_DIR" || exit 1
            fi
        elif [[ "$REPO" == "LeakSearch" ]]; then
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/requirements.txt" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                ./venv/bin/pip install --upgrade pip 2>&1 | tail -3
                ./venv/bin/pip install -r requirements.txt 2>&1 | tail -3
                cd "$TOOLS_DIR" || exit 1
            fi
        elif [[ "$REPO" == "cloud_enum" ]]; then
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/requirements.txt" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                ./venv/bin/pip install --upgrade pip 2>&1 | tail -3
                ./venv/bin/pip install -r requirements.txt 2>&1 | tail -3
                cd "$TOOLS_DIR" || exit 1
            fi
        elif [[ "$REPO" == "fav-up" ]]; then
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/requirements.txt" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                source venv/bin/activate
                pip3 install --upgrade -r requirements.txt 2>&1 | tail -5
                deactivate
                cd "$TOOLS_DIR" || exit 1
            fi
        else
            git clone --filter="blob:none" "${REPO_URLS[$REPO]}" "$TOOLS_DIR/$REPO" 2>&1 | tail -3
            if [[ -f "$TOOLS_DIR/$REPO/requirements.txt" ]]; then
                cd "$TOOLS_DIR/$REPO" || continue
                python3 -m venv venv 2>&1 | tail -3
                source venv/bin/activate
                pip3 install --upgrade -r requirements.txt 2>&1 | tail -5
                deactivate
                cd "$TOOLS_DIR" || exit 1
            fi
        fi
    done
}

# Main installation
if [[ $FORCE == true ]]; then
    echo -e "${YELLOW}[FORCE] Force reinstall mode enabled${RESET}"
fi

echo -e "${GREEN}[START] Installing infoshyt tools${RESET}"
install_system_packages
install_golang
install_gotools
install_repos
echo -e "${GREEN}[SUCCESS] Installation completed!${RESET}"
echo ""
echo -e "${YELLOW}Next steps:${RESET}"
echo -e "  1. Run ${GREEN}./configure_infoshyt.sh${RESET} to set up API keys"
echo -e "  2. Run ${GREEN}./install.sh --check${RESET} to verify installation"
