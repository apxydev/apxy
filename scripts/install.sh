#!/usr/bin/env bash
set -euo pipefail

# APXY Installer
# Downloads and installs the APXY binary from GitHub Releases.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/apxydev/apxy/main/scripts/install.sh | bash
#   ./install.sh [install|uninstall|status]

APXY_VERSION="${APXY_VERSION:-1.0.5}"
GITHUB_REPO="apxydev/apxy"
INSTALL_DIR="${APXY_INSTALL_DIR:-$HOME/.apxy/bin}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    echo "APXY Installer v${APXY_VERSION}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  install     Install APXY (default)"
    echo "  uninstall   Remove APXY"
    echo "  status      Check installation status"
    echo ""
    echo "Environment variables:"
    echo "  APXY_VERSION       Version to install (default: ${APXY_VERSION})"
    echo "  APXY_INSTALL_DIR   Install directory (default: ${INSTALL_DIR})"
}

detect_platform() {
    local os arch archive_name

    os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    arch="$(uname -m)"

    case "$os" in
        darwin) os="darwin" ;;
        linux)  os="linux" ;;
        *)
            err "Unsupported OS: $os"
            exit 1
            ;;
    esac

    case "$arch" in
        x86_64|amd64)  arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        *)
            err "Unsupported architecture: $arch"
            exit 1
            ;;
    esac

    archive_name="apxy-${APXY_VERSION}-${os}-${arch}.tar.gz"
    echo "$archive_name"
}

download_url() {
    local archive_name="$1"
    echo "https://github.com/${GITHUB_REPO}/releases/download/v${APXY_VERSION}/${archive_name}"
}

checksum_url() {
    echo "https://github.com/${GITHUB_REPO}/releases/download/v${APXY_VERSION}/checksums.txt"
}

download_file() {
    local url="$1" output="$2"

    if command -v curl &>/dev/null; then
        curl -fSL --progress-bar -o "$output" "$url"
    elif command -v wget &>/dev/null; then
        wget -q --show-progress -O "$output" "$url"
    else
        err "Neither curl nor wget found. Please install one and try again."
        exit 1
    fi
}

verify_checksum() {
    local file="$1" checksums_file="$2" archive_name="$3"

    if ! command -v shasum &>/dev/null && ! command -v sha256sum &>/dev/null; then
        warn "Neither shasum nor sha256sum found. Skipping checksum verification."
        return 0
    fi

    local expected
    expected=$(grep "$archive_name" "$checksums_file" | awk '{print $1}')

    if [ -z "$expected" ]; then
        warn "No checksum found for $archive_name. Skipping verification."
        return 0
    fi

    local actual
    if command -v sha256sum &>/dev/null; then
        actual=$(sha256sum "$file" | awk '{print $1}')
    else
        actual=$(shasum -a 256 "$file" | awk '{print $1}')
    fi

    if [ "$expected" != "$actual" ]; then
        err "Checksum mismatch!"
        err "  Expected: $expected"
        err "  Actual:   $actual"
        exit 1
    fi

    ok "Checksum verified"
}

APXY_SHELL_RC=""

add_to_path() {
    local shell_rc=""

    local shell_name="${SHELL:+${SHELL##*/}}"

    case "$shell_name" in
        zsh)  shell_rc="$HOME/.zshrc" ;;
        bash) shell_rc="$HOME/.bashrc" ;;
        *)
            if [ -f "$HOME/.zshrc" ]; then
                shell_rc="$HOME/.zshrc"
            elif [ -f "$HOME/.bashrc" ]; then
                shell_rc="$HOME/.bashrc"
            else
                shell_rc="$HOME/.profile"
            fi
            ;;
    esac

    APXY_SHELL_RC="$shell_rc"

    local path_line="export PATH=\"${INSTALL_DIR}:\$PATH\""

    if grep -qF "$path_line" "$shell_rc" 2>/dev/null; then
        return
    fi

    {
        echo ""
        echo "# APXY"
        echo "$path_line"
    } >> "$shell_rc"
    ok "Added ${INSTALL_DIR} to PATH in ${shell_rc}"
}

do_install() {
    local archive_name
    archive_name=$(detect_platform)

    info "Installing APXY v${APXY_VERSION} (${archive_name})..."

    mkdir -p "$INSTALL_DIR"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap '[ -n "${tmp_dir:-}" ] && rm -rf "$tmp_dir"' EXIT

    local url
    url=$(download_url "$archive_name")

    info "Downloading from ${url}..."
    download_file "$url" "${tmp_dir}/${archive_name}"

    # Download and verify checksums
    local checksums_url
    checksums_url=$(checksum_url)
    if download_file "$checksums_url" "${tmp_dir}/checksums.txt" 2>/dev/null; then
        verify_checksum "${tmp_dir}/${archive_name}" "${tmp_dir}/checksums.txt" "$archive_name"
    else
        warn "Could not download checksums. Skipping verification."
    fi

    if ! tar -xzf "${tmp_dir}/${archive_name}" -C "$tmp_dir"; then
        err "Failed to extract ${archive_name}"
        exit 1
    fi

    if [ ! -f "${tmp_dir}/apxy" ]; then
        err "Archive ${archive_name} did not contain the expected apxy binary"
        exit 1
    fi

    chmod +x "${tmp_dir}/apxy"
    mv "${tmp_dir}/apxy" "${INSTALL_DIR}/apxy"

    add_to_path

    echo ""
    ok "APXY v${APXY_VERSION} installed to ${INSTALL_DIR}/apxy"
    echo ""
    info "Next steps:"
    echo "  1. Reload your shell:  source ${APXY_SHELL_RC}  (or open a new terminal)"
    echo "  2. Verify:             apxy version"
    echo "  3. Start proxy:        apxy proxy start"
    echo ""
}

do_uninstall() {
    info "Uninstalling APXY..."

    if [ -f "${INSTALL_DIR}/apxy" ]; then
        rm -f "${INSTALL_DIR}/apxy"
        ok "Removed ${INSTALL_DIR}/apxy"
    else
        warn "APXY binary not found at ${INSTALL_DIR}/apxy"
    fi

    if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
        rmdir "$INSTALL_DIR" 2>/dev/null || true
    fi

    echo ""
    ok "APXY uninstalled."
    info "You may want to remove the PATH entry from your shell config manually."
}

do_status() {
    if command -v apxy &>/dev/null; then
        local version
        version=$(apxy version 2>/dev/null || echo "unknown")
        ok "APXY is installed: $(which apxy) (${version})"
    elif [ -f "${INSTALL_DIR}/apxy" ]; then
        warn "APXY is installed at ${INSTALL_DIR}/apxy but not in PATH"
    else
        warn "APXY is not installed"
    fi
}

# Main
case "${1:-install}" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
    status)    do_status ;;
    -h|--help) usage ;;
    *)
        err "Unknown command: $1"
        usage
        exit 1
        ;;
esac
